# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:percent
#     text_representation:
#       extension: .jl
#       format_name: percent
#   kernelspec:
#     display_name: Julia 1.12
#     language: julia
#     name: julia-1.12
# ---

# %% [markdown]
# # Optimal Sampling Distribution: Truncation
#
# **Module 2, Lesson 2, item 2.** Text: Chapter 6 (Estimating Probabilities).
#
# After this notebook you will be able to:
#
# - write down the zero-variance sampling distribution for a probability,
# - realize it by truncation, for continuous and discrete measures,
# - explain why it cannot be used in practice, and what it is good for.
#
# Notation used here:
#
# | Math | Julia |
# |---|---|
# | $\mu$, $\nu$ | `μ`, `ν` |
# | $\mathbf{1}_E(x)$ | `in_E(x)` |
# | $\ell(y) = f_X(y)/f_Y(y)$, $L(y) = \log \ell(y)$ | `ℓ`, `L` |
# | $p_E$, $\tilde{p}_E$ | `p_E`, `p_tilde` |

# %%
include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
check_version(v"0.1.0")

using Distributions, Statistics, StableRNGs

# %% [markdown]
# ## The optimal density
#
# To estimate $p_E = \Pr(\mathbf{X} \in E)$ we average the terms
# $\mathbf{1}_E(y_i)\,\ell(y_i)$. Module 1 showed that the variance is zero when
# every term equals $p_E$. Samples outside $E$ contribute zero, so none should be
# drawn there; inside $E$ the term $\ell(y) = f_X(y)/f_Y(y)$ must equal $p_E$.
# Together these give the **optimal sampling density**
#
# $$f_Y(y) = \frac{\mathbf{1}_E(y)\, f_X(y)}{p_E},$$
#
# which is $f_X$ **truncated** to $E$: the same shape, restricted to $E$ and
# rescaled to integrate to one. In Distributions.jl it is `truncated(μ, a, b)`.

# %% [markdown]
# ## Example 1: a Normal tail interval
#
# For $\mathbf{X}$ standard Normal and $E = (3.2, 3.3)$, sampling from the
# truncated distribution gives the same term for every sample. `report` flags
# the result as an oracle rather than printing an enormous gain.

# %%
let
    μ = Normal(0, 1)
    ν = truncated(μ, 3.2, 3.3)
    in_E(x) = 3.2 < x < 3.3
    p_E = interval_probability(μ, 3.2, 3.3)

    rng = StableRNG(2026)
    r_naive = naive_estimate(rng, μ, in_E; N = 100_000)
    r_opt = is_estimate(rng, μ, ν, in_E; N = 100)

    report(r_naive, r_opt; exact = p_E, labels = ["Naive N=1e5", "Optimal N=100"])
    println("\nDistinct values among the 100 terms: ", length(unique(round.(r_opt.terms; sigdigits = 12))))
end

# %% [markdown]
# ## Where the answer comes from
#
# One hundred samples gave the exact answer, and so would one. That should be
# suspicious. To build $f_Y = \mathbf{1}_E f_X / p_E$, `truncated` must compute
# the normalizing constant $p_E$ itself, from the cumulative distribution
# function: $p_E = F_X(b) - F_X(a)$. The estimator only hands back a number the
# constructor already knew. This is the circularity of the oracle from Module 1:
# the optimal distribution requires the answer.
#
# The next cell shows the constant directly, without sampling at all.

# %%
let
    μ = Normal(0, 1)
    ν = truncated(μ, 3.2, 3.3)
    y = 3.25                                   # any point inside E
    println("ℓ(y)          = ", exp(logpdf(μ, y) - logpdf(ν, y)))
    println("F(b) - F(a)   = ", cdf(μ, 3.3) - cdf(μ, 3.2))
end

# %% [markdown]
# ## Example 2: a truncated Exponential
#
# The same construction works for any distribution with a computable CDF. Here
# $\mathbf{X}$ is Exponential with rate 1 and $E = \{x < 2\}$, so
# $p_E = 1 - e^{-2}$. The event is not rare; the point is only that the terms
# are again constant.

# %%
let
    μ = Exponential(1)
    ν = truncated(μ, 0, 2)
    r = is_estimate(StableRNG(5), μ, ν, x -> x < 2; N = 1_000)
    report(r; exact = 1 - exp(-2))
end

# %% [markdown]
# ## Why the optimal distribution still matters
#
# We cannot use it, but it tells us what a good sampling distribution looks
# like: concentrated on $E$, and shaped like $f_X$ there. Every sub-optimal
# strategy in this lesson approximates it, either by covering $E$ with a wider
# truncation (item 2.4) or by imitating its shape with a convenient family
# (item 2.3). Lesson 3 develops strategies for doing this systematically.

# %% [markdown]
# ## Problem 1: the constant term (2 points)
#
# Let $\mathbf{X}$ be standard Normal and $E = (1, 2)$. Construct the optimal
# sampling distribution `ν1`, and compute `ℓ1`, the likelihood ratio at the
# point $y = 1.5$, using `logpdf`. Then compute `p_E1` from the CDF.

# %% nbgrader={"grade": false, "grade_id": "p1_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
μ1 = Normal(0, 1)

# ν1   = ...
# ℓ1   = ...
# p_E1 = ...
#@solution p1
#@end

# %% nbgrader={"grade": true, "grade_id": "p1_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert ν1 isa Truncated "ν1 should be a truncated distribution"
@assert minimum(ν1) == 1 && maximum(ν1) == 2 "ν1 should be truncated to [1, 2]"
@assert 0 < ℓ1 < 1 "ℓ1 is a ratio of densities here and lies between 0 and 1"
#@hidden-tests p1
#@end

# %% [markdown]
# ## Problem 2: a discrete oracle (2 points)
#
# A loaded die has probability mass vector
# $\vec{p} = (0.10, 0.15, 0.25, 0.30, 0.10, 0.10)$ for faces 1 to 6. We want
# $p_E = \Pr(\text{even face})$.
#
# Write the optimal sampling mass vector `q`: zero on the odd faces, and
# proportional to $\vec{p}$ on the even faces, summing to one. Then run
# `is_estimate` with `rng2`, $N = 50$ samples, and $\nu$ = `Categorical(q)`,
# storing the result in `r2`.

# %% nbgrader={"grade": false, "grade_id": "p2_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
p_die = [0.10, 0.15, 0.25, 0.30, 0.10, 0.10]
μ2 = Categorical(p_die)
in_even(x) = iseven(x)
rng2 = StableRNG(22)

# q  = ...
# r2 = ...
#@solution p2
#@end

# %% nbgrader={"grade": true, "grade_id": "p2_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert length(q) == 6 "q has one entry per face"
@assert isapprox(sum(q), 1; atol = 1e-12) "q must sum to 1"
@assert all(q[[1, 3, 5]] .== 0) "Odd faces should never be sampled"
@assert r2 isa EstimateResult && length(r2) == 50 "Use is_estimate with N = 50"
#@hidden-tests p2
#@end

# %% [markdown]
# ## Problem 3: why not always do this? (2 points)
#
# Which statement best explains why the optimal distribution is not a practical
# method? Set `answer3` to `:a`, `:b`, `:c` or `:d`.
#
# - (a) Sampling from a truncated distribution is too slow.
# - (b) Constructing it requires the normalizing constant, which is $p_E$ itself.
# - (c) Its estimator is biased.
# - (d) It only works for continuous distributions.

# %% nbgrader={"grade": false, "grade_id": "p3_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
# answer3 = ...
#@solution p3
#@end

# %% nbgrader={"grade": true, "grade_id": "p3_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert answer3 in (:a, :b, :c, :d) "answer3 should be one of :a, :b, :c, :d"
#@hidden-tests p3
#@end
