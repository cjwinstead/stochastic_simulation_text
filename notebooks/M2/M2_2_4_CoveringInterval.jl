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
# # Sub-optimal Sampling: Covering Interval
#
# **Module 2, Lesson 2, item 4.** Text: Chapter 6 (Estimating Probabilities).
#
# After this notebook you will be able to:
#
# - build a truncated sampling distribution that covers an event,
# - compute its likelihood ratio and its exact sampling gain,
# - explain why an estimated gain can differ from the exact gain.
#
# Notation used here:
#
# | Math | Julia |
# |---|---|
# | $\mu$, $\nu$ | `μ`, `ν` |
# | $\mathbf{1}_E(x)$ | `in_E(x)` |
# | $\ell(y) = f_X(y)/f_Y(y)$, $L(y) = \log \ell(y)$ | `ℓ`, `L` |
# | $p_E$, $\hat{p}_E$, $\tilde{p}_E$ | `p_E`, `p_hat`, `p_tilde` |

# %%
include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
check_version(v"0.1.0")

using Distributions, Statistics, StableRNGs
include("course_plots.jl")

# %% [markdown]
# ## The problem
#
# Let $\mathbf{X}$ have a standard Normal distribution $\mu$, and let $E$ be the
# interval $(a, b) = (3.2, 3.3)$. The probability $p_E = \Pr(\mathbf{X} \in E)$ is
# about $2 \times 10^{-4}$, so naive sampling with $N = 10^5$ sees only about
# 20 samples in $E$.
#
# The oracle of item 2.2 truncates $\mu$ to exactly $E$. Here we suppose the
# boundaries are not known precisely, so we truncate to a wider **covering
# interval** $[a', b'] \supseteq [a, b]$:
#
# $$f_Y(y) = \frac{f_X(y)}{c}\,\mathbf{1}_{[a',b']}(y), \qquad c = \Pr(a' < \mathbf{X} < b').$$
#
# On the covering interval the likelihood ratio is constant, $\ell(y) = c$.
# Each term $\mathbf{1}_E(y_i)\,\ell(y_i)$ is either $c$ or $0$, and it equals $c$
# with probability $p_E / c$. Its variance under $\nu$ is
#
# $$\operatorname{Var}_\nu\!\left(\mathbf{1}_E(\mathbf{Y})\,\ell(\mathbf{Y})\right) = c^2 \frac{p_E}{c}\left(1 - \frac{p_E}{c}\right) = p_E\,c - p_E^2,$$
#
# so the sampling gain is
#
# $$G = \frac{p_E(1 - p_E)}{p_E\,c - p_E^2} = \frac{1 - p_E}{c - p_E}.$$
#
# A tighter cover makes $c$ closer to $p_E$ and $G$ larger. When $c = p_E$ the
# cover is exact and we are back to the oracle.

# %% [markdown]
# ## Example 1: naive sampling and a covering interval
#
# Both estimators use $N = 10^5$ samples. `report` prints both results side by
# side, with the gain estimated from the samples and the gain computed from the
# exact naive variance $p_E(1 - p_E)$.

# %%
let
    μ = Normal(0, 1)
    a, b = 3.2, 3.3
    a′, b′ = 3.1, 3.4
    ν = truncated(μ, a′, b′)
    in_E(x) = a < x < b

    p_E = interval_probability(μ, a, b)
    c = interval_probability(μ, a′, b′)

    rng = StableRNG(2026)
    r_naive = naive_estimate(rng, μ, in_E; N=100_000)
    r_is = is_estimate(rng, μ, ν, in_E; N=100_000)

    report(r_naive, r_is; exact=p_E, σ²_naive=bernoulli_variance(p_E))
    println("\nExact gain (1 - p_E)/(c - p_E) = ", round(Int, (1 - p_E) / (c - p_E)))
end

# %% [markdown]
# The likelihood ratio is the same at every sample; only the samples inside
# $E$ contribute to the estimate.

# %%
let
    μ = Normal(0, 1)
    ν = truncated(μ, 3.1, 3.4)
    in_E(x) = 3.2 < x < 3.3
    r_is = is_estimate(StableRNG(2026), μ, ν, in_E; N=2_000)
    plot_weights(r_is; size=(500, 250), ylims=(0, 0.002))
end

# %% [markdown]
# ## Example 2: why the estimated gain is noisy
#
# The estimated gain divides the naive sample variance by the importance
# sampling one. With only about 20 naive hits, the naive variance estimate has a
# relative error of roughly $1/\sqrt{20} \approx 22\%$, and the estimated gain
# inherits it. Each run below uses a fresh naive sample against the same
# importance sampling result.

# %%
let
    μ = Normal(0, 1)
    ν = truncated(μ, 3.1, 3.4)
    in_E(x) = 3.2 < x < 3.3
    p_E = interval_probability(μ, 3.2, 3.3)

    rng = StableRNG(7)
    r_is = is_estimate(rng, μ, ν, in_E; N=100_000)
    for k in 1:5
        r_naive = naive_estimate(rng, μ, in_E; N=100_000)
        println("run $k: ", lpad(n_nonzero(r_naive), 3), " hits, estimated gain ",
                round(Int, gain(r_naive, r_is)))
    end
    println("gain from the exact naive variance: ",
            round(Int, gain(bernoulli_variance(p_E), r_is)))
end

# %% [markdown]
# ## Problem 1: the likelihood ratio by hand (2 points)
#
# The cell below draws 1,000 samples `y` from $\nu$, the standard Normal
# truncated to $[3.1, 3.4]$. Compute the vector `L` of log-likelihood ratios
# $L(y_i) = \log f_X(y_i) - \log f_Y(y_i)$ using `logpdf`, then the vector `ℓ`
# of likelihood ratios. Do not use the course-file functions.

# %% nbgrader={"grade": false, "grade_id": "p1_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
μ = Normal(0, 1)
ν = truncated(μ, 3.1, 3.4)
y = rand(StableRNG(11), ν, 1_000)

# L = ...
# ℓ = ...
#@solution p1
#@end

# %% nbgrader={"grade": true, "grade_id": "p1_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert length(L) == 1_000 "L should have one entry per sample"
@assert length(ℓ) == 1_000 "ℓ should have one entry per sample"
@assert all(ℓ .> 0) "Likelihood ratios are positive"
#@hidden-tests p1
#@end

# %% [markdown]
# Every entry of `ℓ` should be the same number. Which quantity from the
# derivation above is it?

# %% [markdown]
# ## Problem 2: the exact gain (2 points)
#
# Write a function `covering_gain(a, b, a′, b′)` that returns the exact gain
# $G = (1 - p_E)/(c - p_E)$ for the standard Normal $\mu$, the event $(a, b)$,
# and the covering interval $[a', b']$. Assume $a' \le a$ and $b \le b'$.

# %% nbgrader={"grade": false, "grade_id": "p2_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
# function covering_gain(a, b, a′, b′)
#     ...
# end
#@solution p2
#@end

# %% nbgrader={"grade": true, "grade_id": "p2_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert covering_gain(3.2, 3.3, 3.1, 3.4) > 1 "A covering interval should give a gain above 1"
@assert covering_gain(3.2, 3.3, 3.15, 3.35) > covering_gain(3.2, 3.3, 3.1, 3.4) "A tighter cover should give a larger gain"
#@hidden-tests p2
#@end

# %% [markdown]
# ## Problem 3: the best cover of a given width (2 points)
#
# Suppose the covering interval must have total width $b' - a' = 0.4$ and must
# contain $[3.2, 3.3]$. Choose `a_cover` and `b_cover` to make the gain as large
# as possible. Use your `covering_gain` to compare candidates, and think about
# where $f_X$ is largest.

# %% nbgrader={"grade": false, "grade_id": "p3_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
# a_cover = ...
# b_cover = ...
#@solution p3
#@end

# %% nbgrader={"grade": true, "grade_id": "p3_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert a_cover <= 3.2 && b_cover >= 3.3 "The cover must contain [3.2, 3.3]"
@assert isapprox(b_cover - a_cover, 0.4; atol=1e-9) "The cover must have width 0.4"
#@hidden-tests p3
#@end

# %% [markdown]
# ## Problem 4: estimate with your cover (2 points)
#
# Use `is_estimate` with your covering interval from Problem 3, the random
# number generator `rng4` provided, and $N = 10^4$ samples. Store the result
# in `r_cover` and its estimate in `p_tilde`.

# %% nbgrader={"grade": false, "grade_id": "p4_solution", "locked": false, "schema_version": 3, "solution": true, "task": false}
rng4 = StableRNG(4)

# r_cover = is_estimate(...)
# p_tilde = ...
#@solution p4
#@end

# %% nbgrader={"grade": true, "grade_id": "p4_tests", "locked": true, "points": 2, "schema_version": 3, "solution": false, "task": false}
@assert r_cover isa EstimateResult "r_cover should be the result of is_estimate"
@assert length(r_cover) == 10_000 "Use N = 10_000 samples"
@assert p_tilde == estimate(r_cover) "p_tilde should be the estimate from r_cover"
#@hidden-tests p4
#@end

# %% [markdown]
# ## Reflection (2 points, graded by hand)
#
# In Example 2, the estimated gain changes from run to run while the exact
# gain does not. In two or three sentences: what causes the variation, and
# when would you trust an estimated gain? Write your answer in the next cell.

# %% [markdown] nbgrader={"grade": true, "grade_id": "reflection", "locked": false, "points": 2, "schema_version": 3, "solution": true, "task": false}
# #@solution reflection
# #@end
