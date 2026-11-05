# course_plots.jl
#
# Plotting helpers for the Stochastic Verification course. Kept separate from
# StochasticSimulationCourse.jl so that notebooks without plots (and the
# autograder) do not pay the cost of loading Plots.
#
# Usage, after loading the course file:
#
#     include("course_plots.jl")

using Plots
using .StochasticSimulationCourse

_positive(x, y) = (k = findall(v -> isfinite(v) && v > 0, y); (x[k], y[k]))

"""
    plot_trace(r; exact=nothing, kwargs...)

Two panels: the running estimate (with the exact value if given) and the
running estimated estimator variance, both against sample count.
"""
function plot_trace(r::EstimateResult; exact=nothing,
                    label=r.method === :naive ? "Naive" : "Importance", kwargs...)
    t = trace(r)
    p1 = plot(t.n, t.estimate; label, xscale=:log10,
              xlabel="Sample count", ylabel="Estimate")
    exact === nothing || hline!(p1, [exact]; label="exact", linestyle=:dash)
    p2 = plot(_positive(t.n, t.estimator_variance)...; label, xscale=:log10, yscale=:log10,
              xlabel="Sample count", ylabel="Estimator variance")
    return plot(p1, p2; layout=(2, 1), kwargs...)
end

"""
    plot_weights(r; kwargs...)

The likelihood ratio ℓ(y) at each sample, sorted by y, with the samples that
contribute (h(y) ≠ 0) marked. Univariate real-valued samples only.
"""
function plot_weights(r::EstimateResult; kwargs...)
    k = sortperm(r.y)
    y, ℓ, hit = r.y[k], exp.(r.L[k]), .!iszero.(r.h[k])
    p = plot(y, ℓ; label="ℓ(y)", xlabel="y", ylabel="Likelihood ratio", kwargs...)
    scatter!(p, y[hit], ℓ[hit]; label="h(y) ≠ 0", markersize=2, markerstrokewidth=0)
    return p
end

"""
    plot_weight_distribution(r; kwargs...)

The nonzero terms |h(yᵢ)| ℓ(yᵢ) in sorted order, on a log scale. A flat curve
means evenly shared weight; a sharp rise at the right means a few samples
dominate the estimate.
"""
function plot_weight_distribution(r::EstimateResult; kwargs...)
    t = sort(abs.(filter(!iszero, r.terms)))
    return plot(1:length(t), t; label=:none, yscale=:log10,
                xlabel="Rank", ylabel="|h(y) ℓ(y)|", kwargs...)
end
