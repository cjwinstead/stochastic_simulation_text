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
# # Indicator Functions
#
# **Module 2, Lesson 2, item 1.** Text: Chapter 3 (Confidence Intervals; Rare
# Events) and Chapter 6 (Estimating Probabilities).
#
# After this notebook you will be able to:
#
# - write a probability as the expectation of an indicator function,
# - attach a confidence interval to a probability estimate, and choose between
#   the Wald and Wilson intervals,
# - compute how many naive samples a rare event requires,
# - write indicators for events in several dimensions, including events that
#   are not product events,
# - see how an indicator enters an importance sampling estimate.
#
# Notation used here:
#
# | Math | Julia |
# |---|---|
# | $\mu$, $\nu$ | `μ`, `ν` |
# | $\mathbf{1}_E(x)$ | `in_E(x)` |
# | $p_E$, $\hat{p}_E$, $\tilde{p}_E$ | `p_E`, `p_hat`, `p_tilde` |
# | $N$ | `N` |

# %%
include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
check_version(v"0.1.0")

using Distributions, Statistics, StableRNGs, LinearAlgebra

# %% [markdown]
# ## Probabilities are expectations
#
# The **indicator function** of an event $E$ is $\mathbf{1}_E(x)=1$ if $x\in E$
# and $0$ otherwise. Its expectation is the probability of the event:
#
# $$p_E = \Pr(\mathbf{X}\in E) = \mathcal{E}_\mu\left(\mathbf{1}_E(\mathbf{X})\right).$$
#
# So every method for estimating an expectation also estimates a probability.
# The naive estimator is the fraction of samples that land in $E$,
#
# $$\hat{p}_E = \frac{1}{N}\sum_{i=1}^N \mathbf{1}_E(x_i),$$
#
# and since each term is a Bernoulli variable with success probability $p_E$,
#
# $$\operatorname{Var}\left(\hat{p}_E\right) = \frac{p_E(1-p_E)}{N}.$$
#
# In Julia an indicator is a function that returns a `Bool`. Arithmetic treats
# `true` as 1 and `false` as 0, so `mean(in_E.(x))` is $\hat{p}_E$.

# %% [markdown]
# ## Example 1: confidence intervals for a probability
#
# Let $\mathbf{X}$ be standard Normal and $E=\{x>3\}$, so $p_E\approx 1.35\times 10^{-3}$.
# With $N=10^4$ samples we expect about 13 hits. The course file provides the
# Wald and Wilson 95% intervals from Chapter 3.

# %%
let
    μ = Normal(0, 1)
    in_E(x) = x > 3
    p_E = ccdf(μ, 3)
    N = 10_000

    for seed in (1, 2)
        r = naive_estimate(StableRNG(seed), μ, in_E; N=N)
        p_hat = estimate(r)
        wald = round.(wald_interval(p_hat, N); sigdigits=3)
        wilson = round.(wilson_interval(p_hat, N); sigdigits=3)
        println("hits = ", n_nonzero(r), ",  p_hat = ", p_hat,
                ",  Wald ", wald, ",  Wilson ", wilson)
    end
    println("exact p_E = ", round(p_E; sigdigits=4))
end

# %% [markdown]
# Both intervals contain $p_E$ here. The Wilson interval is shifted upward:
# with few hits, the distribution of $\hat{p}_E$ is skewed, and the Wald
# interval's symmetric Normal approximation does not capture that.
#
# The difference is starkest when no sample lands in $E$. Then $\hat{p}_E=0$,
# and the Wald interval collapses to the single point zero, claiming certainty
# from no evidence. The Wilson interval still gives a useful upper bound.

# %%
println("no hits in 10^5 samples:")
println("  Wald   ", wald_interval(0.0, 100_000))
println("  Wilson ", round.(wilson_interval(0.0, 100_000); sigdigits=3))

# %% [markdown]
# ## Example 2: do the intervals cover $p_E$?
#
# A 95% interval should contain the true value in 95% of experiments. We can
# test that directly. Below, each experiment draws the number of hits from a
# Binomial distribution with $p_E=10^{-3}$ and $N=2000$, so about two hits are
# expected, and checks whether each interval contains $p_E$.

# %%
let
    p_E = 1e-3
    N = 2_000
    M = 20_000    # experiments
    rng = StableRNG(9)

    covered_wald = 0
    covered_wilson = 0
    for _ in 1:M
        p_hat = rand(rng, Binomial(N, p_E)) / N
        lo, hi = wald_interval(p_hat, N)
        covered_wald += lo <= p_E <= hi
        lo, hi = wilson_interval(p_hat, N)
        covered_wilson += lo <= p_E <= hi
    end
    println("Wald   covers p_E in ", round(100 * covered_wald / M; digits=1), "% of experiments")
    println("Wilson covers p_E in ", round(100 * covered_wilson / M; digits=1), "% of experiments")
end

# %% [markdown]
# The Wald interval falls well short of its nominal 95%, while the Wilson
# interval delivers it. For rare events, where the number of hits is small,
# use the Wilson interval.

# %% [markdown]
# ## Example 3: the cost of a rare event
#
# The relative error of $\hat{p}_E$ is about $1/\sqrt{N p_E}$ (Chapter 3). To
# estimate $p_E$ within $\pm 10\%$ with 95% confidence, the half-width
# $1.96\sqrt{p_E(1-p_E)/N}$ must be at most $0.1\,p_E$, which requires
#
# $$N \geq \frac{1.96^2\,(1-p_E)}{0.1^2\,p_E} \approx \frac{384}{p_E}.$$
#
# The loop below checks this with the Wilson interval for $p_E=10^{-6}$:
# its total width reaches $2\times 10^{-7}$, that is $\pm 10\%$, only near
# $N=4\times 10^8$.

# %%
let
    p_E = 1e-6
    for N in 10 .^ (5:10)
        lo, hi = wilson_interval(p_E, N)
        println("N = 1e", round(Int, log10(N)), ":  width = ",
                round(hi - lo; sigdigits=3), "  (", round(Int, 50 * (hi - lo) / p_E), "% of p_E either side)")
    end
end

# %% [markdown]
# Four hundred million samples for a one-in-a-million event: this is the
# problem importance sampling exists to solve.

# %% [markdown]
# ## Example 4: events in two dimensions
#
# Let $\mathbf{X}=(\mathbf{X}_1,\mathbf{X}_2)$ have independent standard Normal
# components. In Julia this is `MvNormal(zeros(2), I(2))`, and each sample is a
# vector `x` with components `x[1]` and `x[2]`. Two events:
#
# - the **corner** $E_c=\{x_1>2 \text{ and } x_2>2\}$, a product event
#   (Chapter 1). Its probability factors:
#   $p_{E_c}=\Pr(\mathbf{X}_1>2)\Pr(\mathbf{X}_2>2)\approx 5.18\times 10^{-4}$;
# - the **half-plane** $E_s=\{x_1+x_2>4\}$, which is not a product event: whether
#   $x_2$ qualifies depends on $x_1$. Its probability does not factor, but
#   $\mathbf{X}_1+\mathbf{X}_2$ is Normal with variance 2, so
#   $p_{E_s}=\Pr\left(\mathcal{N}(0,2)>4\right)\approx 2.34\times 10^{-3}$.
#
# The indicators are written the same way in both cases.

# %%
let
    μ = MvNormal(zeros(2), I(2))
    in_corner(x) = x[1] > 2 && x[2] > 2
    in_halfplane(x) = x[1] + x[2] > 4

    rng = StableRNG(2026)
    r_c = naive_estimate(rng, μ, in_corner; N=100_000)
    r_s = naive_estimate(rng, μ, in_halfplane; N=100_000)
    report(r_c; exact=ccdf(Normal(), 2)^2, labels=["corner"])
    println()
    report(r_s; exact=ccdf(Normal(0, sqrt(2)), 4), labels=["half-plane"])
end

# %% [markdown]
# ## Example 5: an indicator in importance sampling
#
# Importance sampling estimates $p_E$ by averaging $\mathbf{1}_E(y_i)\,\ell(y_i)$
# over samples $y_i$ from $\nu$. The indicator does the same job as before: a
# sample outside $E$ contributes zero. A good $\nu$ therefore puts most of its
# samples inside $E$. Here $\nu$ is the same bivariate Normal shifted to
# $(2.5, 2.5)$, just inside the corner; Lesson 3 develops this idea as *mean
# translation*. The gain is computed from the exact naive variance.

# %%
let
    μ = MvNormal(zeros(2), I(2))
    ν = MvNormal([2.5, 2.5], I(2))
    in_corner(x) = x[1] > 2 && x[2] > 2
    p_E = ccdf(Normal(), 2)^2

    r = is_estimate(StableRNG(2026), μ, ν, in_corner; N=10_000)
    report(r; exact=p_E, σ²_naive=bernoulli_variance(p_E))
end

# %% [markdown]
# About half the samples land in the corner, against one in two thousand for
# naive sampling, and the gain is about 200: $10^4$ importance samples are
# worth about $2\times 10^6$ naive ones. The rest of this lesson asks how to
# choose $\nu$, and what goes wrong when it is chosen badly.

# %% [markdown]
# ## Problem 1: a product event (2 points)
#
# Let $\mathbf{X}=(\mathbf{X}_1,\mathbf{X}_2)$ be the standard bivariate Normal
# of Example 4, and $E_1=\{x_1>1.5 \text{ and } x_2<-1.5\}$. Write the indicator
# `in_E1(x)`, and compute the exact probability `p_E1` using the fact that
# $E_1$ is a product event of independent components. Use `ccdf` and `cdf`.

# %% nbgrader={"grade": false, "grade_id": "p1_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
μ = MvNormal(zeros(2), I(2))

# in_E1(x) = ...
# p_E1 = ...
#@solution p1
#@end

# %% nbgrader={"grade": true, "grade_id": "p1_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert in_E1([2.0, -2.0]) "This point is in E1"
@assert !in_E1([2.0, 2.0]) "This point is not in E1"
@assert 0 < p_E1 < 0.01 "p_E1 is a small probability"
#@hidden-tests p1
#@end

# %% [markdown]
# ## Problem 2: estimate with a confidence interval (2 points)
#
# Using the generator `rng2` and $N=20{,}000$ samples, estimate $p_{E_1}$ with
# `naive_estimate`. Store the result in `r2`, its estimate in `p_hat2`, and its
# Wilson 95% interval in `ci2`.

# %% nbgrader={"grade": false, "grade_id": "p2_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
rng2 = StableRNG(41)

# r2 = ...
# p_hat2 = ...
# ci2 = ...
#@solution p2
#@end

# %% nbgrader={"grade": true, "grade_id": "p2_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert r2 isa EstimateResult && length(r2) == 20_000 "Use naive_estimate with N = 20_000"
@assert p_hat2 == estimate(r2) "p_hat2 should be the estimate from r2"
@assert ci2[1] < p_hat2 < ci2[2] "The interval should contain the estimate"
#@hidden-tests p2
#@end

# %% [markdown]
# ## Problem 3: the sample burden (2 points)
#
# Write a function `N_needed(p; rel=0.1, z=1.96)` that returns the smallest
# integer $N$ for which the naive estimator of a probability $p$ has a 95%
# half-width $z\sqrt{p(1-p)/N}$ of at most `rel` times $p$. Use `ceil(Int, ...)`.

# %% nbgrader={"grade": false, "grade_id": "p3_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
# function N_needed(p; rel=0.1, z=1.96)
#     ...
# end
#@solution p3
#@end

# %% nbgrader={"grade": true, "grade_id": "p3_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert N_needed(1e-3) isa Integer "N_needed should return an integer"
@assert N_needed(1e-6) > N_needed(1e-3) "Rarer events need more samples"
@assert N_needed(1e-3; rel=0.2) < N_needed(1e-3) "A looser tolerance needs fewer samples"
#@hidden-tests p3
#@end

# %% [markdown]
# ## Problem 4: an event that is not a product (2 points)
#
# Let $E_2=\{x_1-x_2>3\}$ for the same $\mathbf{X}$. Write the indicator
# `in_E2(x)` and compute the exact `p_E2`. (Hint: what is the distribution of
# $\mathbf{X}_1-\mathbf{X}_2$?) Then set `E2_is_product` to `true` or `false`.

# %% nbgrader={"grade": false, "grade_id": "p4_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
# in_E2(x) = ...
# p_E2 = ...
# E2_is_product = ...
#@solution p4
#@end

# %% nbgrader={"grade": true, "grade_id": "p4_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert in_E2([2.0, -2.0]) && !in_E2([0.0, 0.0]) "Check in_E2 on a point inside and outside E2"
@assert 0 < p_E2 < 0.1 "p_E2 is a small probability"
@assert E2_is_product isa Bool "E2_is_product should be true or false"
#@hidden-tests p4
#@end

# %% [markdown]
# ## Problem 5: reading Example 2 (2 points)
#
# In Example 2, the Wald interval covered $p_E$ in far fewer than 95% of the
# experiments. Which statement explains this best? Set `answer5` to `:a`,
# `:b`, `:c` or `:d`.
#
# - (a) The random number generator is biased for small probabilities.
# - (b) The Wald interval relies on a Normal approximation to $\hat{p}_E$, which
#   is poor when the expected number of hits, here about two, is small.
# - (c) The Wilson interval uses more samples than the Wald interval.
# - (d) A 95% interval only needs to cover $p_E$ in 95% of *successful*
#   experiments.

# %% nbgrader={"grade": false, "grade_id": "p5_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
# answer5 = ...
#@solution p5
#@end

# %% nbgrader={"grade": true, "grade_id": "p5_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert answer5 in (:a, :b, :c, :d) "answer5 should be one of :a, :b, :c, :d"
#@hidden-tests p5
#@end
