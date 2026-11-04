# Importance Sampling Fundamentals {#importancesamplingfundamentals}

## Magic Sampling {#magicsampling}

Say we have a random variable $\mathbf{X}$ with probability measure $\mu$ 
and we want to estimate a parameter 
$\xi$ from its distribution. We obtain the estimate by consulting a supernatural
power -- a genie or oracle -- which always responds with the exact correct value.
In this scanario every sample is $x_i=\xi$, the estimate is always 
$\hat{\boldsymbol{\xi}}=\xi$, and any independent estimates are $\hat{\xi}_j=\xi$.
This magic estimator has $\text{Var}\left(\hat{\boldsymbol{\xi}}\right)=0$. This
is the most efficient estimator imaginable, since we only need one sample to get
an accurate result.

By consulting the oracle, our experiment undergoes a **change of measure**. Instead
of naively sampling $\mathbf{X}$ with measure $\mu$, we sample a related oracular variable 
$\mathbf{Y}$ with oracular measure $\nu$, so

$$\mathcal{E}_\mu\left(\mathbf{X}\right) = \mathcal{E}_\nu\left(\mathbf{Y}\right).$$

The magical scanario is not really practical, but it highlights some useful ideas:
First, two different measures can have equal expectation; Second, if $\xi$ exists
then the zero-variance oracular estimator exists *in principle*. We don't know
what it is but we can try to approximate it.

## Change of Measure {#changeofmeasure}

The oracle demonstrates that a zero-variance estimator is possible via a change of
measure. If an oracle is unavailable, we may still be able to construct estimators
with reduced variance compared to naively sampling from the target distribution.
A random variable $\mathbf{X}$ has measure $\mu$ with parameter $\xi$. An alternative
random variable $\mathbf{Y}$ has measure $\nu$. We can bring their expectations into
agreement by applying a **weight function** to $\mathbf{Y}$, so that 
$\mathcal{E}_\mu\left(\mathbf{X}\right)=\mathcal{E}_\nu\left(w\left(\mathbf{Y}\right)\right).$

If $\mathbf{X}$ and $\mathbf{Y}$ are continuous real-valued variables with probability density
functions $f_X()$ and $f_Y$, then the weight function is the ratio of densities:

$$\begin{aligned}
\mathcal{E}_\mu\left(\mathbf{X}\right)&=\int_{-\infty}^{\infty} xf_X(x)dx & \text{~native measure}\\
=\mathcal{E}_\nu\left(w\left(\mathbf{Y}\right)\right)&=\int_{-\infty}^{\infty} y\left(\frac{f_X(y)}{f_Y(y)}\right)f_Y(y)dy & \text{~changed measure}
\end{aligned}$$
The weight function is 
$$w(y) = y\left(\frac{f_X(y)}{f_Y(y)}\right).$$
This suggests we can construct a sample mean estimator under measure $\nu$ to estimate
the mean of $\mathbf{X}$. applying a
sample correction weight:

$$\tilde{\theta}_X = \frac{1}{N}\sum_{i=1}^N y_i \left(\frac{f_X(y_i)}{f_Y(y_i)}\right).$$
For each individual sample, the weight function can be decomposed into a product

$$\begin{aligned}
w\left(y_i\right)&=y_i w_i & \\
\text{where~}w_i&=\frac{f_X(y_i)}{f_Y(y_i)}
\end{aligned}$$

If we choose a good distribution for $\mathbf{Y}$ then we should achieve
$\text{Var}\left( \tilde{\theta}_X\right)<\text{Var}\left( \hat{\theta}_X\right).$
The improvement is quantified by the **sampling gain** $G$:
$$G = \frac{\text{Var}\left( \hat{\theta}_X\right)}{\text{Var}\left( \tilde{\theta}_X\right)}.$$
The oracle has an infinite sampling gain. In practice we usually get a finite sampling gain
but it can still be pretty big.

The source code below is a straightforward implementation of importance sampling. The
`importance_sample` function produces `N` samples from measures $\mu$ and $\nu$, 
calculates the sample weights, and applies the (optional) indicator function to all
samples. This function is in the file `StochasticSimulationCourse.jl`.

```julia
using Random, Statistics, Distributions, Printf

function importance_sample(μ::Distribution,ν::Distribution;
                           N=100000,
                           indicator::Function=x->x)
    x = rand(μ,N)
    y = rand(ν,N)

    w = pdf(μ,y)./pdf(ν,y)
    μsamples = indicator.(x)
    νsamples = w.*indicator.(y)

    return Dict{String,Any}("μ"=>μ,"ν"=>ν,"N"=>N,"x"=>x,"y"=>y,"w"=>w,
                            "μsamples"=>μsamples,"νsamples"=>νsamples)
end
```



:::{.example title="Gaussian Variance Scaling"}

Let $\mathbf{X}$ have a unit-Normal distribution (Gaussian with $\theta_X=0$ and 
$\sigma_X=1$). To estimate the mean, we draw samples from a Gaussian distributed 
variable $\mathbf{Y}$ with $\theta_Y=0$ and $\sigma_Y<\sigma_X$. The importance
sampling estimator is defined by
$$\tilde{\theta}_X=\frac{1}{N}\sum_{i=1}^N y_i w_i.$$
The sample weights are 
$$w_i = \frac{f_X\left(y_i\right)}{f_Y\left(y_i\right)}$$
An example is simulated in the code block:

```julia
include("StochasticSimulationCourse.jl")

μ=Normal(0,1)     # Normal θ=0, σ=1
ν=Normal(0,.01)   # Normal θ=0, σ=0.01

results = importance_sample(μ,ν;N=10000)
print_summary(results)
```

Example output from the simulation:

```text
Method           Estimate  Estimator Variance
---------------  --------  ------------------
Naive X          +0.01    9.93e-05
Importance w(Y)  +0.00    3.58e-08
---------------------------------------------
Sampling Gain is 2.77e+03
```

:::

The variance scaling example suggests that the importance sampling
solution is more efficient than naive sampling. If the naive estimator
has variance $\text{Var}\left( \hat{\boldsymbol{\theta}}_X\right)$
with $N$ samples, we expect the importance estimator to have a 
comparable variance with only $N/G$ samples. This could be a huge
benefit for stochastic simulation algorithms, since the computational
effort is usually proportional to $N$.

But if we repeat the simulation we may notice some odd results. The
reported sampling gain has some big jumps: $G$ is 68k in one run,
then 11k in another, then 1k, 4k, 12k, 2k, and so on. Why is it not
consistent? 

[@Fig:variance_scaling_weights compares the two densities and the sample weight, and @fig:variance_scaling_trace traces the estimate and its variance as the sample count grows.]{.draft}

![Comparison of density functions and sample weight for variance-scaled Gaussian importance sampling.](figures/variance_scaling_gaussian_weights.tex){#fig:variance_scaling_weights}

![Estimate and sample variance with increasing sample count for variance-scaled Gaussian importance sampling.](figures/importance_sampling_variance_scaled.tex){#fig:variance_scaling_trace}


\clearpage

## Importance Sampling for Probability Estimation {#isforprobabilityestimation}


$\mathbf{X}$ has pdf $f_X(x)$ and we need to estimate the probability of event
$E$ with associated indicator function $\mathbf{1}_E\left(x\right)$. Then we are
trying to estimate the expectation integral 

$$p_E = \int \mathbf{1}_E\left(x\right) f_X(x)dX$$

If an alternative sampling distribution $f_Y(x)$ is used, the integral 
can be modified as:

$$p_E = \int \mathbf{1}_E\left(x\right) \frac{f_X(x)}{f_Y(x)}f_Y(x)dX.$$

For sub-intervals where $\mathbf{1}_E\left(x\right)=0$, there is no contribution
to the integral, so we can say any samples in those regions are "wasted". Consequently
we can write the optimal sampling density as

$$f_Y(y) = \mathbf{1}_E\left(x\right)f_X(x)/p_E.$$

:::{.example title="Gaussian Interval"}

$\mathbf{X}$ has a unit Normal distribution and we want to estimate
the probability that $\mathbf{X}\in [1,2]$. The ideal importance sampling density 
$f_Y(y)$ should: (1) only generate samples in this interval, and (2) should be
proportional to $f_X$ within the interval. We can easily achieve the first
condition by using a uniform sampling density in the interval $[1,2]$. While this
isn't a truly ideal sampling distribution, it can still yield a gain in sampling 
complexity. 

```Julia
include("StochasticSimulationCourse.jl")

μ=Normal()
ν=Uniform(1,2)

i(x)    = 1*(x>1) - 1*(x>2)
results = importance_sample(μ,ν;
                            N=1000000,
							indicator=i)

print_summary(results)

```

A sample output:

```text
Method           Estimate  Estimator Variance
---------------  --------  ------------------
Naive X          +1.36e-01    1.18e-07
Importance w(Y)  +1.36e-01    3.05e-09
---------------------------------------------
Sampling Gain is 3.86e+01
```

We see the sampling gain is around 38, which loosely means importance sampling 
converges 38 times faster than naive estimation. The convergence is especially
clear when comparing the naive and importance estimates for increasing sample
counts, as in @fig:gaussian_interval_trace.
:::




![[Naive and importance sampling estimates of $\Pr(1<\mathbf{X}<2)$ as the sample count grows.]{.draft}](figures/gaussian_interval_probability.tex){#fig:gaussian_interval_trace}


\clearpage


## Optimal Importance Sampling Distributions

An "optimal" importance sampling design should act like an oracle. In other
words, the weighted sample value should equal the precise value of the 
unknown parameter $\xi$. So for a sample $y$ we should have:

$$\begin{aligned}
w(y)&=\xi & \\
y\frac{f_X(y)}{f_Y(y)} &= \xi & \\
f_Y(y) &= \frac{yf_X(y)}{\xi} &
\end{aligned}$$


:::{.example title="Optimal Sampling for the Uniform Case"}

$\mathbf{X}$ is uniformly distributed in $[0,1]$ and we want to
estimate the mean $\hat{\theta}_X$. The optimal sampling 
distribution should be
$$f_Y(y) = \begin{cases}2y & 0 < y< 1 \\ 0 & \text{otherwise.}\end{cases}$$
You can verify that that $f_Y(y)$ is non-negative and 
$\int f_Y(y)dy=1$, so works as a pdf. Starting with samples
from $\mathbf{X}$, we can convert to the optimal sample 
density by applying the function $y=r(x)=(2x)^{-1}$.

```julia
using Random, Statistics

N=5

x = rand(N)
y = 1 ./ (2 .* x)
w = 1 ./ (2 .* y)

println("Importance weighted samples:")
show(w .* y)
```

On executing this code, you should see that all the weighted
samples are equal to 0.5. The variance of this estimation is zero.
If you're paying close attention, you may notice that we are just
canceling out the sample $x$ and replacing it with the desired
result $\xi$. We can't do this unless we already know $f_X$ and
$\xi$, so there is a vicious circularity. In practice we try to 
approximate and/or estimate the optimal distribution starting from
incomplete knowledge.

:::

