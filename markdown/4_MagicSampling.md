# Importance Sampling Fundamentals {#importancesamplingfundamentals}

## Magic Sampling {#magicsampling}

Say we have a random variable $\mathbf{X}$ with probability measure $\mu$ 
and we want to estimate a parameter 
$\xi$ from its distribution. We obtain the estimate by consulting a supernatural
power -- a genie or oracle -- which always responds with the exact correct value.
In this scenario every sample is $x_i=\xi$, the estimate is always 
$\hat{\boldsymbol{\xi}}=\xi$, and any independent estimates are $\hat{\xi}_j=\xi$.
This magic estimator has $\text{Var}\left(\hat{\boldsymbol{\xi}}\right)=0$. This
is the most efficient estimator imaginable, since we only need one sample to get
an accurate result.

By consulting the oracle, our experiment undergoes a **change of measure**. Instead
of naively sampling $\mathbf{X}$ with measure $\mu$, we sample a related oracular variable 
$\mathbf{Y}$ with oracular measure $\nu$, so

$$\mathcal{E}_\mu\left(\mathbf{X}\right) = \mathcal{E}_\nu\left(\mathbf{Y}\right).$$

The magical scenario is not really practical, but it highlights some useful ideas:
First, two different measures can have equal expectation; Second, if $\xi$ exists
then the zero-variance oracular estimator exists *in principle*. We don't know
what it is but we can try to approximate it.

## Change of Measure {#changeofmeasure}

The oracle demonstrates that a zero-variance estimator is possible via a change of
measure. If an oracle is unavailable, we may still be able to construct estimators
with reduced variance compared to naively sampling from the target distribution.
[A random variable $\mathbf{X}$ has measure $\mu$, and we want
$\xi=\mathcal{E}_\mu\left(h(\mathbf{X})\right)$ for some function $h$. An alternative
random variable $\mathbf{Y}$ has measure $\nu$. If $\mathbf{X}$ and $\mathbf{Y}$ have
densities $f_X$ and $f_Y$, we can multiply and divide by $f_Y$ inside the
expectation integral:

$$\begin{aligned}
\xi=\mathcal{E}_\mu\left(h(\mathbf{X})\right)&=\int h(x)\,f_X(x)\,dx & \text{~native measure}\\
&=\int h(y)\,\frac{f_X(y)}{f_Y(y)}\,f_Y(y)\,dy=\mathcal{E}_\nu\left(h(\mathbf{Y})\,\ell(\mathbf{Y})\right) & \text{~changed measure}
\end{aligned}$$

The ratio of densities

$$\ell(y)=\frac{f_X(y)}{f_Y(y)}$$

is the **likelihood ratio**. It is the weight that restores the native measure:
samples where $\nu$ is more likely than $\mu$ are weighted down, and samples where
it is less likely are weighted up. The step is valid only if $f_Y(y)>0$
wherever $h(y)f_X(y)\neq 0$; otherwise part of the integral is never sampled.
This suggests a sample mean estimator under measure $\nu$, the **importance
sampling estimator**:

$$\tilde{\xi}=\frac{1}{N}\sum_{i=1}^N h(y_i)\,\ell(y_i).$$

For the mean of $\mathbf{X}$, $h(x)=x$ and we write $\tilde{\theta}_X$.]{.draft}

If we choose a good distribution for $\mathbf{Y}$ then we should achieve
$\text{Var}\left( \tilde{\boldsymbol{\xi}}\right)<\text{Var}\left( \hat{\boldsymbol{\xi}}\right).$
The improvement is quantified by the **sampling gain** $G$:
$$G = \frac{\text{Var}\left( \hat{\boldsymbol{\xi}}\right)}{\text{Var}\left( \tilde{\boldsymbol{\xi}}\right)}.$$
The oracle has an infinite sampling gain. In practice we usually get a finite sampling gain
but it can still be pretty big.

[The code below is a direct implementation of the importance sampling estimator.
It computes the likelihood ratio through `logpdf`, the logarithm of the density,
because ratios of very small densities can underflow to zero in floating point.]{.draft}

```julia
using Distributions, Statistics

# Importance sampling estimate of 𝓔_μ(h(X)) from N samples of ν
function importance_estimate(rng, μ, ν, h; N = 10_000)
    y = rand(rng, ν, N)
    ℓ = exp.(logpdf.(μ, y) .- logpdf.(ν, y))   # likelihood ratios f_X(y)/f_Y(y)
    terms = h.(y) .* ℓ
    return mean(terms), var(terms) / N          # estimate and its estimated variance
end
```

[The course file `StochasticSimulationCourse.jl` (in `notebooks/lib`) provides the
same computation as `is_estimate`, together with `naive_estimate` and `report`,
which prints the results side by side with diagnostics. The examples below use
those functions.]{.draft}



:::{.example title="Gaussian Variance Scaling"}

Let $\mathbf{X}$ have a unit-Normal distribution (Gaussian with $\theta_X=0$ and 
$\sigma_X=1$). To estimate the mean, we draw samples from a Gaussian distributed 
variable $\mathbf{Y}$ with $\theta_Y=0$ and $\sigma_Y<\sigma_X$. The importance
sampling estimator is defined by
$$\tilde{\theta}_X=\frac{1}{N}\sum_{i=1}^N y_i\,\ell(y_i), \qquad \ell(y_i) = \frac{f_X\left(y_i\right)}{f_Y\left(y_i\right)}.$$
An example is simulated in the code block:

```julia
include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
using Distributions, StableRNGs

μ = Normal(0, 1)      # θ = 0, σ = 1
ν = Normal(0, 0.01)   # θ = 0, σ = 0.01
h(x) = x

rng = StableRNG(2026)
r_naive = naive_estimate(rng, μ, h; N = 10_000)
r_is = is_estimate(rng, μ, ν, h; N = 10_000)
report(r_naive, r_is)
```

The output from this run:

```text
                             Naive    Importance
N                            10000         10000
estimate                -5.816e-03    -7.500e-05
standard error           9.988e-03     1.564e-04
relative error             171.73%       208.53%
nonzero terms                10000         10000
N_eff                       6394.0          26.2
max weight share             0.05%        15.06%
gain vs first                    —        4077.9
  ⚠ Importance: one sample carries 15.06% of the estimate
  ⚠ Importance: N_eff is 26.2 out of 10000 nonzero terms; a few samples dominate
```

:::

The variance scaling example suggests that the importance sampling
solution is more efficient than naive sampling. If the naive estimator
has variance $\text{Var}\left( \hat{\boldsymbol{\theta}}_X\right)$
with $N$ samples, we expect the importance estimator to have a 
comparable variance with only $N/G$ samples. This could be a huge
benefit for stochastic simulation algorithms, since the computational
effort is usually proportional to $N$.

But if we repeat the simulation we may notice some odd results. [The
reported sampling gain jumps around: six repetitions gave 1464, 3402, 277,
9482, 54397 and 463. The warnings in the report hint at the reason: a few
samples carry most of the weight. Why is the gain so unstable?]{.draft}

[@Fig:variance_scaling_weights compares the two densities and the sample weight, and @fig:variance_scaling_trace traces the estimate and its variance as the sample count grows.]{.draft}

![Comparison of density functions and sample weight for variance-scaled Gaussian importance sampling.](figures/variance_scaling_gaussian_weights.tex){#fig:variance_scaling_weights}

![Estimate and sample variance with increasing sample count for variance-scaled Gaussian importance sampling.](figures/importance_sampling_variance_scaled.tex){#fig:variance_scaling_trace}


\clearpage

## Importance Sampling for Probability Estimation {#isforprobabilityestimation}


$\mathbf{X}$ has pdf $f_X(x)$ and we need to estimate the probability of event
$E$ with associated indicator function $\mathbf{1}_E\left(x\right)$. Then we are
trying to estimate the expectation integral 

$$p_E = \int \mathbf{1}_E\left(x\right) f_X(x)dx$$

If an alternative sampling distribution $f_Y(x)$ is used, the integral 
can be modified as:

$$p_E = \int \mathbf{1}_E\left(x\right) \frac{f_X(x)}{f_Y(x)}f_Y(x)dx.$$

For sub-intervals where $\mathbf{1}_E\left(x\right)=0$, there is no contribution
to the integral, so we can say any samples in those regions are "wasted". Consequently
we can write the optimal sampling density as

$$f_Y(y) = \mathbf{1}_E\left(y\right)f_X(y)/p_E.$$

:::{.example title="Gaussian Interval"}

$\mathbf{X}$ has a unit Normal distribution and we want to estimate
the probability that $\mathbf{X}\in [1,2]$. The ideal importance sampling density 
$f_Y(y)$ should: (1) only generate samples in this interval, and (2) should be
proportional to $f_X$ within the interval. We can easily achieve the first
condition by using a uniform sampling density in the interval $[1,2]$. While this
isn't a truly ideal sampling distribution, it can still yield a gain in sampling 
complexity. 

```julia
include("StochasticSimulationCourse.jl")
using .StochasticSimulationCourse
using Distributions, StableRNGs

μ = Normal()
ν = Uniform(1, 2)
in_E(x) = 1 < x < 2

rng = StableRNG(2026)
r_naive = naive_estimate(rng, μ, in_E; N = 1_000_000)
r_is = is_estimate(rng, μ, ν, in_E; N = 1_000_000)
report(r_naive, r_is; exact = interval_probability(μ, 1, 2))
```

The output from this run:

```text
                             Naive    Importance
N                          1000000       1000000
estimate                 1.361e-01     1.358e-01
standard error           3.429e-04     5.525e-05
relative error               0.25%         0.04%
nonzero terms               136090       1000000
N_eff                     136090.0      858049.6
max weight share             0.00%         0.00%
gain vs first                    —          38.5
exact                    1.359e-01
```

We see the sampling gain is around 38, which means importance sampling
[needs about 38 times fewer samples for the same estimator variance]{.draft}. The convergence is especially
clear when comparing the naive and importance estimates for increasing sample
counts, as in @fig:gaussian_interval_trace.
:::




![[Naive and importance sampling estimates of $\Pr(1<\mathbf{X}<2)$ as the sample count grows.]{.draft}](figures/gaussian_interval_probability.tex){#fig:gaussian_interval_trace}


\clearpage


## Optimal Importance Sampling Distributions {#sec:optimalis}

An "optimal" importance sampling design should act like an oracle. In other
words, the weighted sample value should equal the precise value of the 
unknown parameter $\xi$. So for a sample $y$ we should have:

$$\begin{aligned}
h(y)\,\ell(y)&=\xi & \\
h(y)\frac{f_X(y)}{f_Y(y)} &= \xi & \\
f_Y(y) &= \frac{h(y)f_X(y)}{\xi} &
\end{aligned}$$

[This is a valid density only if $h(y)\geq 0$ everywhere (or $\leq 0$ everywhere).
When $h$ takes both signs, no sampling density makes every term equal: the best
achievable is $f_Y\propto\left|h\right|f_X$, which still leaves some variance. The
Gaussian variance scaling example is such a case: $h(x)=x$ has both signs and
$\xi=0$, so no zero-variance density exists for it.]{.draft}


:::{.example title="Optimal Sampling for the Uniform Case"}

$\mathbf{X}$ is uniformly distributed in $[0,1]$ and we want to
estimate the mean $\hat{\theta}_X$. The optimal sampling 
distribution should be
$$f_Y(y) = \begin{cases}2y & 0 < y< 1 \\ 0 & \text{otherwise.}\end{cases}$$
You can verify that $f_Y(y)$ is non-negative and 
$\int f_Y(y)dy=1$, so works as a pdf. Starting with samples
from $\mathbf{X}$, we can convert to the optimal sample 
density by applying the function [$y=r(x)=\sqrt{x}$: the cumulative distribution
of $f_Y$ is $F_Y(y)=y^2$, and $\sqrt{x}$ is its inverse]{.draft}.

```julia
using StableRNGs

rng = StableRNG(2026)
N = 5

x = rand(rng, N)      # samples of X, uniform on (0,1)
y = sqrt.(x)          # transformed to the optimal density f_Y(y) = 2y
ℓ = 1 ./ (2 .* y)     # likelihood ratio f_X(y)/f_Y(y)

println("Importance weighted samples:")
show(y .* ℓ)
```

On executing this code, you should see that all the weighted
samples are equal to 0.5. The variance of this estimation is zero.
[Because $y\,\ell(y)=y/(2y)=1/2$ cancels algebraically, this code would print
0.5 even if `y` were drawn from the wrong distribution: zero variance alone does
not show that the sampling is correct.]{.draft}
If you're paying close attention, you may notice that we are just
canceling out the sample $x$ and replacing it with the desired
result $\xi$. We can't do this unless we already know $f_X$ and
$\xi$, so there is a vicious circularity. In practice we try to 
approximate and/or estimate the optimal distribution starting from
incomplete knowledge.

:::

