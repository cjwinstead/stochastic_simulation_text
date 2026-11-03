# StochasticSimulationCourse.jl
#
# Shared code for the Stochastic Verification course notebooks.
# Version 0.1.1: scope is Modules 1 and 2.
#
# Usage, in the setup cell of a notebook:
#
#     include("StochasticSimulationCourse.jl")
#     using .StochasticSimulationCourse
#     check_version(v"0.1.0")
#
# Notation follows the course plan's notation-to-Julia crosswalk:
#
#     μ, ν      native and sampling measures (Distribution objects)
#     h(x)      function whose expectation ξ = 𝓔_μ(h(𝐗)) is estimated
#     in_E(x)   indicator of the event E, returning a Bool
#     ℓ(y)      likelihood ratio f_X(y) / f_Y(y)
#     L(y)      log-likelihood ratio, log ℓ(y)
#
# Any μ or ν that supports `rand(rng, ν)` and `logpdf(ν, y)` works,
# including Distributions.jl's MixtureModel and user-defined types.

module StochasticSimulationCourse

using Random, Statistics, Printf
using Distributions

# Distributions.jl exports its own `estimate` (for fitting distributions).
# Adding a method to it, rather than defining a new function, avoids an
# ambiguous name in notebooks that load both modules.
import Distributions: estimate

export COURSE_VERSION, check_version
export EstimateResult, naive_estimate, is_estimate
export estimate, estimator_variance, standard_error, relative_error,
       confidence_interval, n_nonzero, likelihood_ratio, is_zero_variance
export N_eff, max_weight_share, gain, bernoulli_variance
export interval_probability, wald_interval, wilson_interval
export running_mean, running_var, trace
export report, within_se

const COURSE_VERSION = v"0.1.1"

"""
    check_version(required)

Stop with a clear message when this course file is older than `required`.
"""
function check_version(required::VersionNumber)
    COURSE_VERSION >= required || error(
        "This notebook needs StochasticSimulationCourse.jl version $required " *
        "or later, but version $COURSE_VERSION is loaded.")
    return nothing
end

# ---------------------------------------------------------------------------
# Result type
# ---------------------------------------------------------------------------

"""
    EstimateResult

The record of one sample-mean estimation. Fields:

- `method`: `:naive` or `:is`
- `μ`, `ν`: native and sampling measures (`ν === μ` for naive sampling)
- `y`: the samples, drawn from `ν`
- `h`: the values h(yᵢ)
- `L`: the log-likelihood ratios L(yᵢ) = log ℓ(yᵢ); all zero for naive sampling
- `terms`: the summands h(yᵢ) ℓ(yᵢ), whose mean is the estimate

Use the accessor functions (`estimate`, `standard_error`, `N_eff`, ...)
rather than computing statistics from the fields by hand.
"""
struct EstimateResult{M,V,S}
    method::Symbol
    μ::M
    ν::V
    y::Vector{S}
    h::Vector{Float64}
    L::Vector{Float64}
    terms::Vector{Float64}
end

Base.length(r::EstimateResult) = length(r.y)

_draw(rng::AbstractRNG, ν::UnivariateDistribution, N::Integer) = rand(rng, ν, N)
_draw(rng::AbstractRNG, ν, N::Integer) = [rand(rng, ν) for _ in 1:N]

# A term is zero wherever h is zero, even if ℓ overflows to Inf there.
function _terms(h::Vector{Float64}, L::Vector{Float64})
    t = similar(h)
    @inbounds for i in eachindex(h, L)
        t[i] = iszero(h[i]) ? 0.0 : h[i] * exp(L[i])
    end
    return t
end

"""
    naive_estimate(rng, μ, h; N = 10_000)

Estimate ξ = 𝓔_μ(h(𝐗)) by the sample mean of h over `N` samples drawn from `μ`.
"""
function naive_estimate(rng::AbstractRNG, μ, h; N::Integer = 10_000)
    x = _draw(rng, μ, N)
    hx = Float64.(h.(x))
    return EstimateResult(:naive, μ, μ, x, hx, zeros(length(x)), copy(hx))
end

"""
    is_estimate(rng, μ, ν, h; N = 10_000)

Estimate ξ = 𝓔_μ(h(𝐗)) by importance sampling: draw `N` samples yᵢ from `ν`
and average h(yᵢ) ℓ(yᵢ), with ℓ(y) = f_X(y) / f_Y(y) computed in log space.

The estimate is unbiased only if f_Y(y) > 0 wherever h(y) f_X(y) ≠ 0.
That condition cannot be checked from the samples.
"""
function is_estimate(rng::AbstractRNG, μ, ν, h; N::Integer = 10_000)
    y = _draw(rng, ν, N)
    hy = Float64.(h.(y))
    L = [Float64(logpdf(μ, yi) - logpdf(ν, yi)) for yi in y]
    return EstimateResult(:is, μ, ν, y, hy, L, _terms(hy, L))
end

# ---------------------------------------------------------------------------
# Accessors
# ---------------------------------------------------------------------------

"Sample mean of the terms h(yᵢ) ℓ(yᵢ): the estimate of ξ."
estimate(r::EstimateResult) = mean(r.terms)

"Estimated variance of the estimate: the sample variance of the terms divided by N."
estimator_variance(r::EstimateResult) = var(r.terms) / length(r)

"Square root of `estimator_variance`."
standard_error(r::EstimateResult) = sqrt(estimator_variance(r))

"Standard error divided by the magnitude of the estimate."
relative_error(r::EstimateResult) = standard_error(r) / abs(estimate(r))

"Number of samples that contribute to the estimate (nonzero terms)."
n_nonzero(r::EstimateResult) = count(!iszero, r.terms)

"The likelihood ratios ℓ(yᵢ) = exp(L(yᵢ))."
likelihood_ratio(r::EstimateResult) = exp.(r.L)

"""
    confidence_interval(r; z = 1.96)

Normal-approximation interval `estimate ± z·standard_error`. It is meaningful
only when the terms have finite variance and enough of them are nonzero.
"""
function confidence_interval(r::EstimateResult; z::Real = 1.96)
    m, s = estimate(r), standard_error(r)
    return (m - z * s, m + z * s)
end

"""
    is_zero_variance(r)

True when the terms are constant to machine precision, as they are for an
oracle (zero-variance) sampling distribution.
"""
function is_zero_variance(r::EstimateResult)
    return std(r.terms) <= 1e-10 * abs(mean(r.terms))
end

# ---------------------------------------------------------------------------
# Weight diagnostics (computed in log space, so they survive overflow)
# ---------------------------------------------------------------------------

function _logsumexp(a::AbstractVector{<:Real})
    m = maximum(a)
    isfinite(m) || return m
    return m + log(sum(x -> exp(x - m), a))
end

_log_abs_terms(r::EstimateResult) =
    [log(abs(r.h[i])) + r.L[i] for i in eachindex(r.h) if !iszero(r.h[i])]

"""
    N_eff(w)
    N_eff(r)

Effective sample size (Σw)² / Σw². For a result `r`, `w` is the magnitudes
of the nonzero terms |h(yᵢ)| ℓ(yᵢ): the number of equally weighted samples
that would carry the same information. A value far below `n_nonzero(r)`
means a few samples dominate the estimate.
"""
N_eff(w::AbstractVector{<:Real}) = sum(w)^2 / sum(abs2, w)

function N_eff(r::EstimateResult)
    a = _log_abs_terms(r)
    isempty(a) && return 0.0
    return exp(2 * _logsumexp(a) - _logsumexp(2 .* a))
end

"""
    max_weight_share(r)

Share of the total Σ|h(yᵢ)| ℓ(yᵢ) carried by the single largest term.
Values near 1 mean one sample decides the estimate.
"""
function max_weight_share(r::EstimateResult)
    a = _log_abs_terms(r)
    isempty(a) && return NaN
    return exp(maximum(a) - _logsumexp(a))
end

"""
    gain(r_naive, r_is)
    gain(σ²_naive, r_is)

Sampling gain: the ratio of per-sample variances, naive over importance.
It equals Var(ξ̂)/Var(ξ̃) at equal N. Pass the exact per-sample naive variance
`σ²_naive` when it is known (for a probability, `bernoulli_variance(p_E)`):
an estimated naive variance from few nonzero terms makes the gain noisy.
The gain is meaningless when the importance sampling estimator is biased.
"""
gain(r_naive::EstimateResult, r_is::EstimateResult) = var(r_naive.terms) / var(r_is.terms)
gain(σ²_naive::Real, r_is::EstimateResult) = σ²_naive / var(r_is.terms)

"Per-sample variance p(1 − p) of an indicator with success probability `p`."
bernoulli_variance(p::Real) = p * (1 - p)

# ---------------------------------------------------------------------------
# Probabilities and intervals
# ---------------------------------------------------------------------------

"Exact Pr(a < 𝐗 < b) for a univariate distribution μ."
interval_probability(μ::UnivariateDistribution, a::Real, b::Real) = cdf(μ, b) - cdf(μ, a)

"""
    wald_interval(p_hat, N; z = 1.96)

Wald interval p̂ ± z √(p̂(1 − p̂)/N) for a proportion.
"""
function wald_interval(p_hat::Real, N::Integer; z::Real = 1.96)
    half = z * sqrt(p_hat * (1 - p_hat) / N)
    return (p_hat - half, p_hat + half)
end

"""
    wilson_interval(p_hat, N; z = 1.96)

Wilson score interval for a proportion; better than the Wald interval when
p̂ is small or N p̂ is only a few counts.
"""
function wilson_interval(p_hat::Real, N::Integer; z::Real = 1.96)
    z² = z^2
    denom = 1 + z² / N
    center = (p_hat + z² / (2N)) / denom
    half = z * sqrt(p_hat * (1 - p_hat) / N + z² / (4N^2)) / denom
    return (center - half, center + half)
end

# ---------------------------------------------------------------------------
# Running statistics
# ---------------------------------------------------------------------------

"Running sample mean: element k is the mean of v[1:k]."
running_mean(v::AbstractVector{<:Real}) = cumsum(v) ./ (1:length(v))

"""
    running_var(v)

Running sample variance (divisor k − 1), computed with Welford's method.
Element 1 is NaN.
"""
function running_var(v::AbstractVector{<:Real})
    out = fill(NaN, length(v))
    m, s = 0.0, 0.0
    for k in eachindex(v)
        δ = v[k] - m
        m += δ / k
        s += δ * (v[k] - m)
        k > 1 && (out[k] = s / (k - 1))
    end
    return out
end

"""
    trace(r)

Named tuple `(n, estimate, estimator_variance)` giving the running estimate
and its estimated variance after each sample.
"""
function trace(r::EstimateResult)
    n = collect(1:length(r))
    return (n = n,
            estimate = running_mean(r.terms),
            estimator_variance = running_var(r.terms) ./ n)
end

# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

_label(r::EstimateResult) = r.method === :naive ? "Naive" : "Importance"

function _fmt(x::Real)
    isnan(x) && return "NaN"
    isinf(x) && return x > 0 ? "Inf" : "-Inf"
    return @sprintf("%.3e", x)
end

_pct(x::Real) = isfinite(x) ? @sprintf("%.2f%%", 100x) : _fmt(x)

"""
    report([io,] results...; exact = nothing, σ²_naive = nothing, labels = nothing)

Print a side-by-side summary of one or more results, with diagnostics and
warnings. Gains are computed against the first result. Pass `exact` to show
the true value, and `σ²_naive` (the exact per-sample naive variance) to add
an exact gain.
"""
function report(io::IO, results::EstimateResult...;
                exact = nothing, σ²_naive = nothing, labels = nothing)
    isempty(results) && return nothing
    names = labels === nothing ? [_label(r) for r in results] : collect(string.(labels))
    w = 14
    row(name, vals) = println(io, rpad(name, 20), join(lpad.(vals, w)))

    row("", names)
    row("N", [string(length(r)) for r in results])
    row("estimate", [_fmt(estimate(r)) for r in results])
    row("standard error", [is_zero_variance(r) ? "0 (oracle)" : _fmt(standard_error(r)) for r in results])
    row("relative error", [is_zero_variance(r) ? "0" : _pct(relative_error(r)) for r in results])
    row("nonzero terms", [string(n_nonzero(r)) for r in results])
    row("N_eff", [@sprintf("%.1f", N_eff(r)) for r in results])
    row("max weight share", [_pct(max_weight_share(r)) for r in results])
    if length(results) > 1
        row("gain vs first", ["—"; [is_zero_variance(r) ? "Inf" : @sprintf("%.1f", gain(results[1], r))
                                    for r in results[2:end]]])
    end
    if σ²_naive !== nothing
        row("gain, exact naive", [r.method === :naive ? "—" :
                                  is_zero_variance(r) ? "Inf" : @sprintf("%.1f", gain(σ²_naive, r))
                                  for r in results])
    end
    exact === nothing || row("exact", [_fmt(exact); fill("", length(results) - 1)])

    for (name, r) in zip(names, results)
        for msg in _warnings(r)
            println(io, "  ⚠ ", name, ": ", msg)
        end
    end
    return nothing
end

report(results::EstimateResult...; kwargs...) = report(stdout, results...; kwargs...)

function _warnings(r::EstimateResult)
    msgs = String[]
    k = n_nonzero(r)
    if k == 0
        push!(msgs, "no nonzero terms; the estimate is 0 and its variance is unknown")
    elseif is_zero_variance(r)
        push!(msgs, "terms are constant: this sampling distribution is an oracle")
    else
        k < 30 && push!(msgs, "only $k nonzero terms; the variance estimate is unreliable")
        s = max_weight_share(r)
        s > 0.1 && push!(msgs, "one sample carries " * _pct(s) * " of the estimate")
        ne = N_eff(r)
        k >= 100 && ne < 0.05k && push!(msgs, @sprintf(
            "N_eff is %.1f out of %d nonzero terms; a few samples dominate", ne, k))
        any(isinf, r.terms) && push!(msgs, "a term overflowed to Inf")
    end
    return msgs
end

function Base.show(io::IO, ::MIME"text/plain", r::EstimateResult)
    println(io, "EstimateResult (", _label(r), " sampling)")
    report(io, r)
end

Base.show(io::IO, r::EstimateResult) =
    print(io, "EstimateResult(:", r.method, ", N=", length(r), ", estimate=", _fmt(estimate(r)), ")")

# ---------------------------------------------------------------------------
# Grading helpers
# ---------------------------------------------------------------------------

"""
    within_se(x, exact, se; k = 4)

True when |x − exact| ≤ k·se. With k = 4 a correct, unbiased answer fails
about 6 times in 100,000. Compute `se` from the exact distribution when
possible, not from the student's samples.
"""
within_se(x::Real, exact::Real, se::Real; k::Real = 4) = abs(x - exact) <= k * se

end # module
