# test_course.jl — checks for StochasticSimulationCourse.jl.
# Run from this folder:  julia --project=<env> test_course.jl
# Needs Distributions, StableRNGs, Statistics, Test.

include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
using Distributions, Statistics, StableRNGs, Random, Test

μ = Normal()
in_E(x) = 3.2 < x < 3.3
p_E = interval_probability(μ, 3.2, 3.3)

@testset "StochasticSimulationCourse $(COURSE_VERSION)" begin
    @testset "naive matches a hand computation" begin
        r = naive_estimate(StableRNG(1), μ, in_E; N = 10_000)
        x = rand(StableRNG(1), μ, 10_000)
        @test estimate(r) == mean(in_E.(x))
        @test estimator_variance(r) ≈ var(in_E.(x)) / 10_000
        @test all(iszero, r.L)
    end

    @testset "IS matches a hand computation" begin
        ν = truncated(μ, 3.1, 3.4)
        r = is_estimate(StableRNG(2), μ, ν, in_E; N = 10_000)
        y = rand(StableRNG(2), ν, 10_000)
        w = in_E.(y) .* pdf.(μ, y) ./ pdf.(ν, y)
        @test estimate(r) ≈ mean(w) rtol = 1e-10
        @test likelihood_ratio(r) ≈ pdf.(μ, y) ./ pdf.(ν, y) rtol = 1e-10
    end

    @testset "oracle (1_Truncated) is reported as zero variance" begin
        r = is_estimate(StableRNG(3), μ, truncated(μ, 3.2, 3.3), in_E; N = 10_000)
        @test is_zero_variance(r)
        @test estimate(r) ≈ p_E rtol = 1e-10
        buf = IOBuffer(); report(buf, r)
        @test occursin("oracle", String(take!(buf)))
    end

    @testset "incomplete interval (3_Incomplete) converges to the wrong value" begin
        r = is_estimate(StableRNG(4), μ, truncated(μ, 3.25, 3.5), in_E; N = 100_000)
        @test estimate(r) ≈ interval_probability(μ, 3.25, 3.3) rtol = 0.02
        @test !isapprox(estimate(r), p_E; rtol = 0.3)
    end

    @testset "poor approximation (5_Bad) survives overflow" begin
        ν = Normal(3.3, 0.000625)
        r = is_estimate(StableRNG(5), μ, ν, in_E; N = 100_000)
        @test isfinite(N_eff(r)) || N_eff(r) == 0
        @test 0 <= max_weight_share(r) <= 1
        buf = IOBuffer(); report(buf, r; exact = p_E); s = String(take!(buf))
        @test estimate(r) < 0.1 * p_E   # falsely converged, far too low
        # forced overflow: a sample at the far edge of E
        L = [logpdf(μ, 3.2001) - logpdf(ν, 3.2001)]
        @test L[1] > 700   # exp(L) overflows Float64
    end

    @testset "zero hits gives a warning, not an error" begin
        r = naive_estimate(StableRNG(6), μ, in_E; N = 100)
        @test n_nonzero(r) == 0
        @test N_eff(r) == 0.0
        buf = IOBuffer(); report(buf, r); @test occursin("no nonzero", String(take!(buf)))
    end

    @testset "gain" begin
        rn = naive_estimate(StableRNG(7), μ, in_E; N = 100_000)
        ri = is_estimate(StableRNG(8), μ, truncated(μ, 3.1, 3.4), in_E; N = 100_000)
        c = interval_probability(μ, 3.1, 3.4)
        @test gain(bernoulli_variance(p_E), ri) ≈ (1 - p_E) / (c - p_E) rtol = 0.05
        @test gain(rn, ri) ≈ var(rn.terms) / var(ri.terms)
    end

    @testset "discrete and custom measures (royal flush)" begin
        struct Deck
            cards::Vector{Tuple{Int,Int}}   # (rank, suit)
        end
        Random.rand(rng::AbstractRNG, d::Deck) = Random.randperm(rng, length(d.cards))[1:5] |> k -> d.cards[k]
        Distributions.logpdf(d::Deck, hand) =
            all(c -> c in d.cards, hand) ? -log(binomial(length(d.cards), 5)) : -Inf
        full = Deck([(r, s) for r in 1:13 for s in 1:4])
        faces = Deck([(r, s) for r in 9:13 for s in 1:4])   # ten through ace
        royal(hand) = allequal(last.(hand))                 # all cards in `faces`
        r = is_estimate(StableRNG(9), full, faces, royal; N = 200_000)
        p_royal = 4 / binomial(52, 5)
        @test estimate(r) ≈ p_royal rtol = 0.25
        @test all(r.L .≈ log(binomial(20, 5) / binomial(52, 5)))
    end

    @testset "mixture proposal (Module 2, 3.3)" begin
        ν = MixtureModel([Normal(3.25, 0.1), Normal(0, 1)], [0.9, 0.1])
        r = is_estimate(StableRNG(10), μ, ν, in_E; N = 50_000)
        @test estimate(r) ≈ p_E rtol = 0.05
    end

    @testset "multivariate fallback" begin
        μ2 = MvNormal(zeros(2), [1.0 0; 0 1])
        ν2 = MvNormal([2.0, 2.0], [1.0 0; 0 1])
        corner(x) = x[1] > 2 && x[2] > 2
        r = is_estimate(StableRNG(11), μ2, ν2, corner; N = 50_000)
        @test estimate(r) ≈ ccdf(Normal(), 2)^2 rtol = 0.05
    end

    @testset "intervals and running statistics" begin
        # Wilson values from 4_EstimatingProbabilities Example 1 (N = 1e6)
        lo, hi = wilson_interval(1e-6, 10^6)
        @test isapprox(hi, 5.67e-6; rtol = 2e-3) && isapprox(lo, 1.77e-7; rtol = 5e-3)
        lo, hi = wald_interval(0.5, 100)
        @test hi - lo ≈ 2 * 1.96 * 0.05
        v = randn(StableRNG(12), 500)
        @test running_var(v)[end] ≈ var(v)
        @test running_mean(v)[end] ≈ mean(v)
        @test isnan(running_var(v)[1])
        t = trace(naive_estimate(StableRNG(13), μ, x -> x; N = 100))
        @test length(t.n) == 100
    end

    @testset "grading helpers" begin
        @test within_se(1.0, 1.3, 0.1)
        @test !within_se(1.0, 1.5, 0.1)
        @test_throws ErrorException check_version(v"9.0.0")
        @test check_version(v"0.1.0") === nothing
    end
end

println("\n--- sample report, 5_Bad_Approximate case ---")
report(naive_estimate(StableRNG(14), μ, in_E; N = 100_000),
       is_estimate(StableRNG(15), μ, Normal(3.3, 0.000625), in_E; N = 100_000);
       exact = p_E, σ²_naive = bernoulli_variance(p_E))
