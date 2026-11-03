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
# # Bad Sampling: Poor Approximation
#
# **Module 2, Lesson 2, item 6.** Text: Chapter 6 (Estimating Probabilities).
#
# After this notebook you will be able to:
#
# - recognize false convergence: a small reported error on a wrong answer,
# - measure how unevenly the weight is spread across samples,
# - use weight diagnostics to reject a sampling distribution, and fix it.
#
# Notation used here:
#
# | Math | Julia |
# |---|---|
# | $\mu$, $\nu$ | `μ`, `ν` |
# | $\mathbf{1}_E(x)$ | `in_E(x)` |
# | $\ell(y) = f_X(y)/f_Y(y)$, $L(y) = \log \ell(y)$ | `ℓ`, `L` |
# | $p_E$, $\tilde{p}_E$ | `p_E`, `p_tilde` |
# | $N_{\text{eff}}$ | `N_eff` |

# %%
include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
check_version(v"0.1.0")

using Distributions, Statistics, StableRNGs
include("course_plots.jl")

# %% [markdown]
# ## The problem
#
# Item 2.3 approximated the optimal density with $\nu = \mathcal{N}(m, s)$ and
# found that a very small $s$ made the gain collapse. Here we push that mistake
# further: $\nu = \mathcal{N}(3.3, 0.000625)$, centred on the **right edge** of
# $E = (3.2, 3.3)$ and far narrower than $E$.
#
# A Normal is positive everywhere, so the support condition of item 2.5 holds
# and the estimator is unbiased. But the left part of $E$ lies about 160
# standard deviations from the centre of $\nu$. Samples there almost never
# occur, and when one does, its likelihood ratio is astronomically large. The
# variance of the terms,
#
# $$\operatorname{Var}_\nu\!\left(\mathbf{1}_E \ell\right) = \int_E \frac{f_X(y)^2}{f_Y(y)}\,dy - p_E^2,$$
#
# is finite in principle, but so large that no feasible $N$ brings the error
# down. In practice the estimator behaves like the biased one of item 2.5,
# except that a single rare sample can suddenly swing it.

# %% [markdown]
# ## Example 1: false convergence

# %%
let
    μ = Normal(0, 1)
    ν = Normal(3.3, 0.000625)
    in_E(x) = 3.2 < x < 3.3
    p_E = interval_probability(μ, 3.2, 3.3)

    rng = StableRNG(2026)
    r_naive = naive_estimate(rng, μ, in_E; N = 100_000)
    r_is = is_estimate(rng, μ, ν, in_E; N = 100_000)
    report(r_naive, r_is; exact = p_E)
    println("\nTrue relative error of the IS estimate: ",
            round(100 * abs(estimate(r_is) - p_E) / p_E; digits = 1), "%")
end

# %% [markdown]
# The reported relative error is about 4% and the estimated gain is large, yet
# the estimate is about 98% below $p_E$. Unlike item 2.5, `report` does warn
# here: the effective sample size is about 500 out of 50,000 nonzero terms. The
# weight distribution shows why: the few samples that happened to land farthest
# from $3.3$ carry most of the estimate.

# %%
let
    μ = Normal(0, 1)
    r_is = is_estimate(StableRNG(2026), μ, Normal(3.3, 0.000625), x -> 3.2 < x < 3.3; N = 100_000)
    plot_weight_distribution(r_is; size = (600, 300))
end

# %% [markdown]
# ## Diagnostics checklist
#
# Items 2.5 and 2.6 show the two ways importance sampling fails while looking
# healthy. Before trusting an estimate, check:
#
# 1. **Support.** Does $\nu$ cover all of $E$ (`covers` from item 2.5)? A gap
#    causes bias that no sample count removes, and no sample diagnostic detects.
# 2. **Effective sample size.** Is `N_eff(r)` a reasonable fraction of
#    `n_nonzero(r)`? A collapse means a few samples decide the answer.
# 3. **Largest weight.** Is `max_weight_share(r)` small? A share above about
#    10% means one sample moves the estimate visibly.
# 4. **Stability.** Does the trace (`plot_trace`) settle, or does it jump when a
#    rare sample arrives? Do independent runs agree within their reported errors?
#
# Checks 2 to 4 can only raise doubt; passing them does not prove an estimate
# is right.

# %% [markdown]
# ## Problem 1: how uneven are the weights? (2 points)
#
# For $\nu = \mathcal{N}(3.3, 0.000625)$, compute the log-likelihood ratios
# `L_a` and `L_b` at the two ends of $E$, $y = 3.2$ and $y = 3.3$, using
# `logpdf`. Then compute `decades`, the number of powers of ten between the
# likelihood ratios at the two ends: $(L(a) - L(b)) / \ln 10$.

# %% nbgrader={"grade": false, "grade_id": "p1_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
μ = Normal(0, 1)
ν_bad = Normal(3.3, 0.000625)

# L_a     = ...
# L_b     = ...
# decades = ...
#@solution p1
#@end

# %% nbgrader={"grade": true, "grade_id": "p1_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert L_a > L_b "The likelihood ratio is far larger at the poorly sampled end"
@assert decades > 1000 "The ratios differ by thousands of orders of magnitude"
#@hidden-tests p1
#@end

# %% [markdown]
# `exp(L_a)` overflows to `Inf` in Float64. This is why the course file keeps
# log-likelihood ratios and computes its diagnostics in log space.

# %% [markdown]
# ## Problem 2: reported error versus true error (2 points)
#
# Now take a wider event, $E_2 = (3, 10)$, with the poorly placed proposal
# $\nu = \mathcal{N}(6, 0.1)$. Using `rng2` and $N = 10^5$, run `is_estimate`
# and store the result in `r2`. Then compute `reported_rel_err`, the relative
# error the run reports, and `true_rel_err`, the actual relative error against
# the exact `p_E2`.

# %% nbgrader={"grade": false, "grade_id": "p2_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
in_E2(x) = 3 < x < 10
p_E2 = interval_probability(μ, 3, 10)
rng2 = StableRNG(62)

# r2               = ...
# reported_rel_err = ...
# true_rel_err     = ...
#@solution p2
#@end

# %% nbgrader={"grade": true, "grade_id": "p2_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert r2 isa EstimateResult && length(r2) == 100_000 "Use is_estimate with N = 10^5"
@assert reported_rel_err == relative_error(r2) "Use relative_error for the reported error"
#@hidden-tests p2
#@end

# %% [markdown]
# ## Problem 3: fix the proposal (3 points)
#
# Choose a sampling distribution `ν_fix` for $E_2 = (3, 10)$ that passes the
# checklist. Using `rng3` and $N = 10^4$, run `is_estimate` and store the
# result in `r3`. To earn full credit, your estimate must be within 5% of
# `p_E2`, and `N_eff(r3)` must exceed 1,000. Do not use `truncated(μ, 3, 10)`,
# which is the oracle for this event.

# %% nbgrader={"grade": false, "grade_id": "p3_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
rng3 = StableRNG(63)

# ν_fix = ...
# r3    = ...
#@solution p3
#@end

# %% nbgrader={"grade": true, "grade_id": "p3_tests", "locked": true, "points": 3, "schema_version": 3, "solution": false, "task": false}
@assert r3 isa EstimateResult && length(r3) == 10_000 "Use is_estimate with N = 10^4"
@assert r3.ν == ν_fix "r3 should use ν_fix"
@assert !(ν_fix == truncated(μ, 3, 10)) "Choose a proposal other than the oracle"
#@hidden-tests p3
#@end

# %% [markdown]
# ## Reflection (2 points, graded by hand)
#
# The proposal in Example 1 satisfies the support condition, so the estimator
# is unbiased. Why did it still give a badly wrong answer at $N = 10^5$? In two
# or three sentences, connect your answer to item 2.5. Write it in the next cell.

# %% [markdown] nbgrader={"grade": true, "grade_id": "reflection", "locked": false, "points": 2, "schema_version": 3, "solution": true, "task": false}
# #@solution reflection
# #@end
