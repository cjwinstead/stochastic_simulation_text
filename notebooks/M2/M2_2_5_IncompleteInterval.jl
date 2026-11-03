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
# # Bad Sampling: Incomplete Interval
#
# **Module 2, Lesson 2, item 5.** Text: Chapter 6 (Estimating Probabilities).
#
# After this notebook you will be able to:
#
# - explain why a sampling distribution must cover the whole event,
# - compute the value a biased importance sampling estimator converges to,
# - compare estimators by mean squared error when one of them is biased,
# - check the support of a sampling distribution before trusting it.
#
# Notation used here:
#
# | Math | Julia |
# |---|---|
# | $\mu$, $\nu$ | `μ`, `ν` |
# | $\mathbf{1}_E(x)$ | `in_E(x)` |
# | $p_E$, $\tilde{p}_E$ | `p_E`, `p_tilde` |

# %%
include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
check_version(v"0.1.0")

using Distributions, Statistics, StableRNGs
include("course_plots.jl")

# %% [markdown]
# ## The problem
#
# Item 2.4 truncated $\mu$ to an interval $[a', b']$ that covers
# $E = (a, b) = (3.2, 3.3)$. Suppose instead the chosen interval misses part of
# $E$: here $[a', b'] = [3.25, 3.5]$, which leaves out $(3.2, 3.25)$.
#
# Importance sampling is unbiased only when $f_Y(y) > 0$ wherever
# $\mathbf{1}_E(y) f_X(y) > 0$ (Module 1, item 3.2). When that **support
# condition** fails, the part of $E$ outside the support of $\nu$ is never
# sampled, and the estimator converges to the probability of the part it can
# see:
#
# $$\mathcal{E}_\nu\!\left(\mathbf{1}_E(\mathbf{Y})\,\ell(\mathbf{Y})\right) = \int_{E \,\cap\, \operatorname{supp} f_Y} f_X(y)\,dy = \Pr(3.25 < \mathbf{X} < 3.3) \neq p_E.$$
#
# Nothing in the samples reveals the gap: every sample is drawn where $\nu$ is
# positive, so every term looks reasonable.

# %% [markdown]
# ## Example 1: a confident wrong answer

# %%
let
    μ = Normal(0, 1)
    ν = truncated(μ, 3.25, 3.5)
    in_E(x) = 3.2 < x < 3.3
    p_E = interval_probability(μ, 3.2, 3.3)

    rng = StableRNG(2026)
    r_naive = naive_estimate(rng, μ, in_E; N = 100_000)
    r_is = is_estimate(rng, μ, ν, in_E; N = 100_000)
    report(r_naive, r_is; exact = p_E)

    lo, hi = confidence_interval(r_is)
    println("\n95% interval from the IS run: (", round(lo; sigdigits = 4), ", ",
            round(hi; sigdigits = 4), "); it does not contain p_E.")
end

# %% [markdown]
# The importance sampling run reports a relative error under 1%, no warnings,
# and a large gain over naive sampling, and it is wrong by about half. A gain
# compares variances; it says nothing about bias.

# %%
let
    μ = Normal(0, 1)
    r_is = is_estimate(StableRNG(2026), μ, truncated(μ, 3.25, 3.5), x -> 3.2 < x < 3.3; N = 100_000)
    plot_trace(r_is; exact = interval_probability(μ, 3.2, 3.3), size = (600, 400))
end

# %% [markdown]
# ## Comparing a biased and an unbiased estimator
#
# For a biased estimator, variance is the wrong measure of quality. The
# **mean squared error** combines both:
#
# $$\operatorname{MSE}(\tilde{p}_E) = \mathcal{E}\!\left((\tilde{p}_E - p_E)^2\right) = \operatorname{bias}^2 + \operatorname{Var}(\tilde{p}_E).$$
#
# The naive estimator is unbiased, so its MSE is its variance $p_E(1-p_E)/N$,
# which falls as $N$ grows. The biased estimator's MSE falls toward
# $\operatorname{bias}^2$ and stops there. For small $N$ the biased estimator
# can still win; for large $N$ it always loses.

# %% [markdown]
# ## Problem 1: the limit (2 points)
#
# Compute `p_lim`, the value the importance sampling estimator above converges
# to, and `bias = p_lim - p_E`. Use `interval_probability`.

# %% nbgrader={"grade": false, "grade_id": "p1_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
μ = Normal(0, 1)
p_E = interval_probability(μ, 3.2, 3.3)

# p_lim = ...
# bias  = ...
#@solution p1
#@end

# %% nbgrader={"grade": true, "grade_id": "p1_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert 0 < p_lim < p_E "The estimator sees only part of E, so p_lim is smaller than p_E"
@assert bias < 0 "The bias is negative"
#@hidden-tests p1
#@end

# %% [markdown]
# ## Problem 2: when does naive sampling win? (3 points)
#
# On the covered part $[3.25, 3.3)$ the terms equal $c = \Pr(3.25 < \mathbf{X} < 3.5)$,
# so, as in item 2.4, the per-sample variance of the importance sampling terms
# is $p_{\lim}\,c - p_{\lim}^2$.
#
# Write `mse_naive(N)` and `mse_is(N)`, the exact mean squared errors of the two
# estimators with $N$ samples. Then compute `N_cross`, the sample count at which
# they are equal; above it, naive sampling is better. Solve for `N_cross`
# exactly rather than by searching.

# %% nbgrader={"grade": false, "grade_id": "p2_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
c = interval_probability(μ, 3.25, 3.5)

# mse_naive(N) = ...
# mse_is(N)    = ...
# N_cross      = ...
#@solution p2
#@end

# %% nbgrader={"grade": true, "grade_id": "p2_tests", "locked": true, "points": 3, "schema_version": 3, "solution": false, "task": false}
@assert mse_is(10^3) < mse_naive(10^3) "At N = 1000 the biased estimator should still win"
@assert mse_is(10^6) > mse_naive(10^6) "At N = 10^6 naive sampling should win"
#@hidden-tests p2
#@end

# %% [markdown]
# ## Problem 3: check the support (2 points)
#
# The gap cannot be detected from samples, but it can be detected from the
# sampling distribution itself. Write `covers(ν, a, b)`, which returns `true`
# when the support of the univariate distribution `ν` contains the whole
# interval $[a, b]$. Use `minimum(ν)` and `maximum(ν)`, which return the ends of
# the support.

# %% nbgrader={"grade": false, "grade_id": "p3_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
# covers(ν, a, b) = ...
#@solution p3
#@end

# %% nbgrader={"grade": true, "grade_id": "p3_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert covers(truncated(Normal(), 3.1, 3.4), 3.2, 3.3) "A covering interval covers E"
@assert !covers(truncated(Normal(), 3.25, 3.5), 3.2, 3.3) "This interval misses (3.2, 3.25)"
#@hidden-tests p3
#@end

# %% [markdown]
# `covers(Normal(3.3, 0.01), 3.2, 3.3)` is `true`: a Normal is positive
# everywhere, so the support condition holds. Yet such a proposal reaches $3.2$
# so rarely that, in practice, it behaves as if the gap were there. Item 2.6
# examines this case.
