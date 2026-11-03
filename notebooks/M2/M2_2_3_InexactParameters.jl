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
# # Sub-optimal Sampling: Inexact Parameters
#
# **Module 2, Lesson 2, item 3.** Text: Chapter 6 (Estimating Probabilities).
#
# After this notebook you will be able to:
#
# - approximate the optimal sampling distribution with a convenient family,
# - see how the gain depends on that family's parameters,
# - recognize that a gain can collapse when a parameter is pushed too far.
#
# Notation used here:
#
# | Math | Julia |
# |---|---|
# | $\mu$, $\nu$ | `μ`, `ν` |
# | $\mathbf{1}_E(x)$ | `in_E(x)` |
# | $\ell(y) = f_X(y)/f_Y(y)$ | `ℓ` |
# | $p_E$, $\tilde{p}_E$ | `p_E`, `p_tilde` |

# %%
include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
check_version(v"0.1.0")

using Distributions, Statistics, StableRNGs

# %% [markdown]
# ## The problem
#
# Truncation (items 2.2 and 2.4) needs the CDF of $\mu$. Often we cannot
# truncate $\mu$, or sampling from it is expensive. Then we sample from a
# convenient family instead, here a Normal $\nu = \mathcal{N}(m, s^2)$ placed
# over $E = (3.2, 3.3)$, and choose its **parameters** $m$ and $s$ to imitate the
# optimal density $\mathbf{1}_E f_X / p_E$.
#
# Unlike the covering interval, $\nu$ puts some samples outside $E$ (wasted) and
# its shape inside $E$ differs from $f_X$, so the terms
# $\mathbf{1}_E(y)\,\ell(y)$ are no longer constant on $E$. The gain depends on
# how well $m$ and $s$ are chosen, and there is no simple formula for it.
#
# Note on Julia: `Normal(m, s)` takes the **standard deviation** $s$, not the
# variance $s^2$.

# %% [markdown]
# ## Example 1: one reasonable guess
#
# Centre the proposal on $E$, $m = 3.25$, with $s = 0.04$, so that most of its
# mass falls inside the interval of width 0.1.

# %%
let
    μ = Normal(0, 1)
    ν = Normal(3.25, 0.04)
    in_E(x) = 3.2 < x < 3.3
    p_E = interval_probability(μ, 3.2, 3.3)

    rng = StableRNG(2026)
    r_naive = naive_estimate(rng, μ, in_E; N = 100_000)
    r_is = is_estimate(rng, μ, ν, in_E; N = 100_000)
    report(r_naive, r_is; exact = p_E, σ²_naive = bernoulli_variance(p_E))
    println("\nShare of samples inside E: ", round(n_nonzero(r_is) / length(r_is); digits = 3))
end

# %% [markdown]
# ## Example 2: the gain as a function of $s$
#
# Below, the same experiment is repeated for six values of $s$. Each gain is
# computed from the exact naive variance $p_E(1 - p_E)$. Watch both ends of the
# range: a wide proposal wastes samples outside $E$, and a narrow one leaves
# part of $E$ almost unsampled.

# %%
let
    μ = Normal(0, 1)
    in_E(x) = 3.2 < x < 3.3
    σ²_naive = bernoulli_variance(interval_probability(μ, 3.2, 3.3))
    println(" s       gain      share in E   N_eff")
    for (k, s) in enumerate((0.01, 0.02, 0.04, 0.08, 0.16, 0.32))
        r = is_estimate(StableRNG(100 + k), μ, Normal(3.25, s), in_E; N = 100_000)
        println(rpad(s, 6), lpad(round(Int, gain(σ²_naive, r)), 9),
                lpad(round(n_nonzero(r) / length(r); digits = 3), 13),
                lpad(round(Int, N_eff(r)), 9))
    end
end

# %% [markdown]
# For the smallest $s$, nearly every sample lands in $E$, yet the gain is the
# worst in the table. The samples cluster near the centre of $E$, and the few
# that reach its edges carry very large likelihood ratios. Item 2.6 takes this
# failure further.

# %% [markdown]
# ## Problem 1: run one proposal (2 points)
#
# Using `rng1`, run `is_estimate` with $\nu = \mathcal{N}(3.24, 0.05)$ and
# $N = 10^4$. Store the result in `r1` and its estimate in `p_tilde1`.

# %% nbgrader={"grade": false, "grade_id": "p1_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
μ = Normal(0, 1)
in_E(x) = 3.2 < x < 3.3
p_E = interval_probability(μ, 3.2, 3.3)
rng1 = StableRNG(1)

# r1       = ...
# p_tilde1 = ...
#@solution p1
#@end

# %% nbgrader={"grade": true, "grade_id": "p1_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert r1 isa EstimateResult && length(r1) == 10_000 "Use is_estimate with N = 10_000"
@assert p_tilde1 == estimate(r1) "p_tilde1 should be the estimate from r1"
#@hidden-tests p1
#@end

# %% [markdown]
# ## Problem 2: tune the width (3 points)
#
# For each $s$ in `s_grid`, run `is_estimate` with $\nu = \mathcal{N}(3.25, s)$,
# $N = 10^4$, and the generator `StableRNG(200 + k)` for the k-th value of $s$.
# Store the gains, computed from the exact naive variance, in the vector
# `gains`, in the same order as `s_grid`. Then set `s_best` to the value of $s$
# with the largest gain.

# %% nbgrader={"grade": false, "grade_id": "p2_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
s_grid = [0.02, 0.03, 0.04, 0.05, 0.06, 0.08]

# gains  = ...
# s_best = ...
#@solution p2
#@end

# %% nbgrader={"grade": true, "grade_id": "p2_tests", "locked": true, "points": 3, "schema_version": 3, "solution": false, "task": false}
@assert length(gains) == length(s_grid) "One gain per value of s"
@assert all(gains .> 1) "Every proposal on this grid should beat naive sampling"
@assert s_best in s_grid "s_best should be one of the values in s_grid"
#@hidden-tests p2
#@end

# %% [markdown]
# ## Problem 3: reading the table (2 points)
#
# In Example 2 the proposal with $s = 0.01$ put almost every sample inside $E$
# but had the smallest gain. Which statement explains this? Set `answer3` to
# `:a`, `:b`, `:c` or `:d`.
#
# - (a) Samples inside $E$ never contribute to the estimate.
# - (b) The proposal is biased because it is narrower than $E$.
# - (c) Samples near the edges of $E$ are rare under $\nu$ but carry very large
#   likelihood ratios, so a few terms dominate the variance.
# - (d) Too many samples fall outside $E$.

# %% nbgrader={"grade": false, "grade_id": "p3_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
# answer3 = ...
#@solution p3
#@end

# %% nbgrader={"grade": true, "grade_id": "p3_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert answer3 in (:a, :b, :c, :d) "answer3 should be one of :a, :b, :c, :d"
#@hidden-tests p3
#@end
