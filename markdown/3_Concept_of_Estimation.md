# The Concept of an Estimator {#conceptofanestimator}

An **estimator** is an algorithm for inferring the value of an
unknown statistical parameter. We'll use the symbol $\xi$ to 
represent the parameter, and $\hat{\boldsymbol{\xi}}$ for its estimate. 
The estimation is itself a random variable; it is typically a statistic
derived from data. The 
parameter of interest could be the mean, the variance, the 
probability of a particular event, or any other quantity related
to the random variable.

There are good estimators and bad estimators. Here is a bad one:
$\hat{\xi}=0$, i.e. we just assume the parameter is zero. This is 
usually a bad estimator because it doesn't actually utilize any 
observations. It could be "accidentally good" if it so happens
that $\xi=0$, but that would just be dumb luck. 

We have already seen a "good" estimator, the sample mean, but
what makes it a good estimator? To compare the quality of
different estimators, we analyze the distribution of $\hat{\boldsymbol{\xi}}$.
We can imagine a community of $R$ researchers independently repeating
the same estimation using the exact same procedure. The $i^{\textrm{th}}$
researcher calculates an estimation $\hat{\xi}_i$, which is itself a sample 
of $\hat{\boldsymbol{\xi}}$. If the estimator is good, then the researchers
should be able to obtain repeatable results within a tolerable margin of error.

## Estimator Attributes {#estimatorattributes}

A good estimator should be **unbiased**, meaning $\mathcal{E}_\mu\left(\hat{\boldsymbol{\xi}}\right)=\xi.$ It should also be **consistent**, meaning all the estimates $\hat{\boldsymbol{\xi}}$
converge to $\xi$ as the number of samples grows to infinity. It should preferably be 
**efficient**, meaning we can achieve a precise estimation with a practical number of
samples\footnote{Formal definitions of efficiency are complicated, we will avoid the 
full treatment and use simplified approaches in this text.}.

An estimator is **unbiased** if $\mathcal{E}_\mu\left(\hat{\boldsymbol{\xi}}\right)=\xi,$ 
i.e. the expected value of the estimation is equal to the actual value of the parameter 
being estimated. An estimator is **consistent** if independent estimations $\hat{\xi}_i$ are likely to 
converge to $\xi$ as $N\rightarrow\infty$. This is distinct from bias; an estimator
can be unbiased but not consistent (and vice versa). In more formal language: given any
error tolerance $\epsilon>0$,
$$\lim_{N\rightarrow\infty}\Pr\left(\left|\hat{\boldsymbol{\xi}}-\xi\right|>\epsilon\right)=0\text{~~~(consistency)}.$$
This property is called *convergence in probability*, and means the estimator's absolute
error can be made as small as desired by including a sufficient number of samples. We will
use the shorthand $\hat{\boldsymbol{\xi}}\rightarrow\xi$ to indicate that $\hat{\boldsymbol{\xi}}$
converges in probability to $\xi$.

We will say that an estimator $\hat{\boldsymbol{\xi}}$ is **efficient** if the 
**estimator variance** $\text{Var}\left(\hat{\boldsymbol{\xi}}\right)$ converges to a 
small value. 

## Examples {#examples}

:::{.example title="Sample Mean Estimator (unbiased, consistent, efficient)"}
A random variable $\mathbf{X}$ has mean $\theta_X=\mathcal{E}_\mu\left(\mathbf{X}\right)$.
We are given $N$ independent, identically distributed samples $x_i$. The sample mean is
$$ \hat{\theta}_X = \frac{1}{N}\sum_{i=1}^N x_i.$$
We can view this estimator as a sum of pairwise independent random variables:
$$ \hat{\boldsymbol{\theta}}_X=\frac{1}{N}\sum_{i=1}^N \mathbf{X}_i,$$
where each $\mathbf{X}_i$ has the same distribution and parameters as $\mathbf{X}$.
Then we take the expectation of both sides:
$$\begin{aligned}
\mathcal{E}_\mu\left(\hat{\boldsymbol{\theta}}_X\right)&=\mathcal{E}_\mu\left(\frac{1}{N}\sum_{i=1}^N\mathbf{X}_i\right) & \\
& = \frac{1}{N}\left(N\mathcal{E}_\mu\left(\mathbf{X}\right)\right) & \\
& = \mathcal{E}_\mu\left(\mathbf{X}\right) = \theta_X.
\end{aligned}$$
Therefore the sample mean estimator is unbiased. It is also known to be
consistent and efficient. The estimator variance is
$$\text{Var}\left(\hat{\boldsymbol{\theta}}_X\right)=\text{Var}\left( \frac{1}{N}\sum_{i=1}^N\mathbf{X}_i\right)=\frac{1}{N}\text{Var}\left(\mathbf{X}_i\right).$$
:::

:::{.example title="Area of Random Circles (biased estimation)"}
Let $\mathbf{X}$ represent the random radius of a circle, perhaps formed by
paint splatter, with a uniform density in the interval $[1,2]$. From a population
of iid splattered circles,
we collect samples $x_i$ to estimate the mean radius $\hat{\theta}_X$. Next
we need to estimate the mean area; it should be $\pi \hat{\theta}_X^2$, right?
To determine if this estimator is biased, we ask:
$$\mathcal{E}_\mu\left(\hat{\boldsymbol{\theta}}_X^2\right) \stackrel{?}{=} \mathcal{E}_\mu\left(\mathbf{X}^2\right).$$
Let's hypothesize that $\hat{\theta}_X^2$ converges to $\theta_X^2$, since that's
what we wanted. Recall that $\text{Var}\left( \mathbf{X}\right) = \mathcal{E}_\mu\left(\mathbf{X}^2\right)-\theta_X^2.$ If $\text{Var}\left( \mathbf{X}\right)>0$ then the equality
cannot be satisfied, so this estimator has to be biased.
:::

:::{.example title="Area of Random Circles (unbiased estimator)"}
To obtain an unbiased estimation of the area, we need to estimate the mean of
a transformed variable $\mathbf{Y}=\mathbf{X}^2$. This suggests a modified
sample estimator:
$$\hat{\theta}_Y=\frac{1}{N}\sum_{i=1}^N x_i^2$$
Is this one unbiased? We should look closely at the estimator mean:
$$\mathcal{E}_\mu\left(\hat{\boldsymbol{\theta}}_Y\right)=\frac{1}{N}\sum_{i=1}^N \mathcal{E}_\mu\left(\mathbf{X^2}\right).$$
From a previous example, we know the density of $\mathbf{X}^2$ is 
$$f_Y(y) = \frac{f_X(\sqrt{y})}{2\sqrt{y}} + \frac{f_X(-\sqrt{y})}{2\sqrt{y}}.$$
A circle can't have negative radius, so we can assume $f_X(-\sqrt{y})=0$. Then
the distribution simplifies as
$$f_Y(y) = \frac{f_X(\sqrt{y})}{2\sqrt{y}} = \begin{cases} \frac{1}{2\sqrt{y}} & 1\leq y \leq 4\\ 0 & \text{otherwise.}\end{cases}$$
The precise expectation of $\mathbf{Y}$ is 
$$\begin{aligned}
\mathcal{E}_\mu\left(\mathbf{Y}\right)&=\int_0^{\infty} yf_Y(y)dy & \\
&=\int_1^4 \left(\frac{1}{2}\right)y^{1/2}dy & \\
&= \left.\left(\frac{1}{3}\right)y^{3/2}\right|_{1}^4 & \\
&= \frac{7}{3} \approx 2.33 &
\end{aligned}$$
[Each term of $\hat{\theta}_Y$ has expectation $\mathcal{E}_\mu(\mathbf{X}^2)=7/3$, so
$\mathcal{E}_\mu(\hat{\boldsymbol{\theta}}_Y)=7/3$ and the estimator is unbiased. The mean
area is $\pi\cdot 7/3\approx 7.33$, whereas the biased estimator of the previous
example converges to $\pi\theta_X^2=\pi\cdot 9/4\approx 7.07$.]{.draft}

:::


:::{.example title="Representative Sample (unbiased, not consistent)"}
Given $N$ iid samples of $\mathbf{X}$, a bad estimator for the mean is
to choose $x_N$ as a "representative sample", ignoring all previous
samples. Then $\hat{\theta}_X=x_N$. Clearly this estimator is unbiased,
but it doesn't converge with increasing samples, so it is not consistent.
:::

:::{.example title="Sample Mean w/Constant Term (biased and consistent)"}
We are given $N-1$ iid samples of $\mathbf{X}$, but the $N^{\textrm{th}}$ sample
is non-random at $x_N=1$ (perhaps due to a faulty sensor or recording error).
Then the sample mean becomes
$$\hat{\theta}_X=\frac{1}{N}\left(\sum_{i=1}^{N-1}x_i + 1\right).$$
As $N\rightarrow\infty$, this estimator converges to $\theta_X$, the
one bad sample becomes irrelevant. Nevertheless the estimator is biased
for all $N$.
:::


:::{.example title="Sample Variance (biased)"}
We want to simultaneously estimate $\mathcal{E}_\mu\left(\mathbf{X}\right)$ 
and $\text{Var}\left( \mathbf{X}\right)$, so we
collect $N$ samples and run a two-step estimation:
$$\begin{aligned}
\hat{\theta}_X & = \frac{1}{N}\sum_{i=1}^N x_i & \\
\hat{\sigma}_X^2 &= \frac{1}{N}\sum_{i=1}^N \left(x_i-\hat{\theta}_X\right)^2 & 
\end{aligned}$$ 
This procedure turns out to be biased. [Expanding the square,
$\sum_i(\mathbf{X}_i-\hat{\boldsymbol{\theta}}_X)^2=\sum_i\mathbf{X}_i^2-N\hat{\boldsymbol{\theta}}_X^2$.
Each $\mathbf{X}_i^2$ has expectation $\sigma_X^2+\theta_X^2$, and the sample mean has
$\mathcal{E}_\mu(\hat{\boldsymbol{\theta}}_X^2)=\sigma_X^2/N+\theta_X^2$, so
$$\mathcal{E}_\mu\left(\sum_{i=1}^N(\mathbf{X}_i-\hat{\boldsymbol{\theta}}_X)^2\right)=N(\sigma_X^2+\theta_X^2)-N\left(\frac{\sigma_X^2}{N}+\theta_X^2\right)=(N-1)\,\sigma_X^2.$$
Estimating the mean from the same samples uses up one sample's worth of
information, and dividing by $N$ gives]{.draft}
$$\mathcal{E}_\mu\left(\hat{\sigma}_X^2\right)=\sigma_X^2\left(1-\frac{1}{N}\right).$$
:::

:::{.example title="Sample Variance (unbiased)"}
The simultaneous estimation of $\theta_X$ and $\text{Var}\left(\mathbf{X}\right)$
results in one sample being canceled out. To correct for this, we can adjust
the denominator to account for the missing sample:
$$\hat{\sigma}_X^2 = \frac{1}{N-1}\sum_{i=1}^N \left(x_i-\hat{\theta}_X\right)^2.$$
This estimator is unbiased.
:::


## Estimator Variance {#estimatorvariance}

The efficiency of an estimator is closely related to its variance, 
$\text{Var}\left( \hat{\boldsymbol{\xi}}\right)$. For our purposes
we treat variance as a proxy for efficiency. If we compare two estimators 
$\hat{\boldsymbol{\xi}_1}$ and $\hat{\boldsymbol{\xi}_2}$,
we can say that $\hat{\boldsymbol{\xi}_1}$ is more efficient than $\hat{\boldsymbol{\xi}_2}$
if $\text{Var}\left(\hat{\boldsymbol{\xi}_1}\right)<\text{Var}\left(\hat{\boldsymbol{\xi}_2}\right)$.
If $\hat{\boldsymbol{\xi}}$ is an unbiased estimator, then $\text{Var}\left( \hat{\boldsymbol{\xi}}\right)$ is equal to the estimator's **mean squared error**, which predicts 
how far the estimate might be from the true parameter value on average. 

### Variance of Sample Means {#varianceofsamplemeans}

In this text we will usually perform estimations of expectations, 
$\mathcal{E}_\mu\left(h\left(\mathbf{X}\right)\right)$ for a random
variable $\mathbf{X}$ and function $h()$. We use the sample mean
estimator, applying the function to $N$ iid samples. The result is
a sum of independent random variables:
$$\hat{\boldsymbol{\xi}}=\frac{1}{N}\sum_{i=1}^N h\left(\mathbf{X}_i\right),$$
This estimator can be used if the distribution of $h\left(\mathbf{X}\right)$ 
has finite mean and variance.
Applying the properties
of variance, namely scaling and independent summation, the estimator's
variance takes on this form:
$$\begin{aligned}
\text{Var}\left( \hat{\boldsymbol{\xi}}\right) &=\frac{1}{N^2}\sum_{i=1}^N \text{Var}\left(h\left(\mathbf{X}_i\right)\right) & \\ 
&=\frac{1}{N}\text{Var}\left(h\left(\mathbf{X}\right)\right) & 
\end{aligned}$$
This suggests that the estimator variance is proportional to $\text{Var}\left( h\left(\mathbf{X}\right)\right)$, so we could use the sample variance to estimate $\text{Var}\left( h\left(\mathbf{X}\right)\right)$ then divide by $N$ to estimate $\text{Var}\left( \hat{\boldsymbol{\xi}}\right)$:
$$\begin{aligned}
\hat{\xi} &= \frac{1}{N}\sum_{i=1}^N h\left(x_i\right) & \text{sample mean} \\
\hat{\text{Var}}\left(h\left(\mathbf{X}\right)\right)&= \frac{1}{N-1}\sum_{i=1}^N \left(h\left(x_i\right)-\hat{\xi}\right)^2& \text{sample variance}\\
\hat{\text{Var}}\left(\hat{\boldsymbol{\xi}}\right) &= \frac{1}{N}\hat{\text{Var}}\left(h\left(\mathbf{X}\right)\right) & \text{estimator variance}
\end{aligned}$$

The simplest case is $h(x)=x$. In this case we have the ordinary sample mean
estimator for $\hat{\boldsymbol{\theta}_X}$. If the underlying random variable 
$\mathbf{X}$ has a well defined mean and variance, then the estimator variance is
$$\text{Var}\left(\hat{\boldsymbol{\xi}}\right)=\frac{1}{N}\text{Var}\left(\mathbf{X} \right).$$
[The estimator *variance* decreases in proportion to $1/N$, so the typical
error, the standard deviation of $\hat{\boldsymbol{\xi}}$, decreases as $1/\sqrt{N}$:
four times as many samples halve the error.]{.draft}

Given a group of $M$ independent experiments, each computing
the sample mean across $N$ iid samples of a random variable $\mathbf{X}$. 
Each experiment yields an estimate $\hat{\xi}_j$. From these estimates, we 
want to know $\text{Var}\left( \hat{\boldsymbol{\xi}}\right)$. Our analysis 
predicts that it should be $\text{Var}\left( \mathbf{X}\right)/N$. [We can
compute it two ways, which *should* agree: from the sample variance $s_j^2$
within each experiment, and from the spread of the $M$ estimates around their
mean $\bar{\xi}$:
$$\frac{1}{M}\sum_{j=1}^M \frac{s_j^2}{N} \approx \frac{1}{M-1}\sum_{j=1}^M \left(\hat{\xi}_j-\bar{\xi}\right)^2.$$]{.draft}
This scenario is simulated in the code example shown below.

:::{.example title="Sample Mean Variance Simulation"}

$\mathbf{X}$ is a Normally distributed random variable with $\theta_X=0$
and $\sigma_X^2=1$. We conduct $M=1000$ estimates of the sample mean, each 
over $N=10^5$ samples. The expected estimator variance is 
$\text{Var}\left(\mathbf{X}\right)/N=10^{-5}$.  

```julia
using StableRNGs, Statistics

rng = StableRNG(2026)
N = 100_000   # samples per estimate
M = 1_000     # independent estimates

estimates = zeros(M)   # the sample means
variances = zeros(M)   # the sample variances (divisor N - 1)

for j in 1:M
    x = randn(rng, N)
    estimates[j] = mean(x)
    variances[j] = var(x)
end

println("predicted, mean(s²)/N:   ", mean(variances) / N)
println("observed,  var(ξ̂):       ", var(estimates))
```

This simulation prints a predicted estimator variance of $1.000\times 10^{-5}$ and
an observed variance of $0.956\times 10^{-5}$. [The observed value is itself estimated
from only $M=1000$ numbers, so it has a relative error of about
$\sqrt{2/M}\approx 4.5\%$; the two agree within that.]{.draft}
:::



:::{.example title="Chi-Squared Variance Simulation"}

$\mathbf{X}$ is a Normally distributed random variable with $\theta_X=0$
and $\sigma_X^2=1$. We want to estimate $\mathcal{E}_\mu\left(\mathbf{X}^2\right)$
using the sample mean procedure with $h(x)=x^2$. With these parameters, $\mathbf{X}^2$
should have a Chi-Squared distribution with mean 1 and variance 2, so the estimator
variance should be $\text{Var}\left( \mathbf{X}^2\right)/N=2\times 10^{-5}.$

```julia
using StableRNGs, Statistics

rng = StableRNG(2026)
N = 100_000   # samples per estimate
M = 1_000     # independent estimates
h(x) = x^2

estimates = zeros(M)
variances = zeros(M)

for j in 1:M
    hx = h.(randn(rng, N))
    estimates[j] = mean(hx)
    variances[j] = var(hx)
end

println("predicted, mean(s²)/N:   ", mean(variances) / N)
println("observed,  var(ξ̂):       ", var(estimates))
```

This simulation prints a predicted estimator variance of $2.000\times 10^{-5}$ and an
observed variance of $1.77\times 10^{-5}$. [The observed value is 12% low, about 2.6
times the $\sqrt{2/M}$ relative error expected from $M=1000$ estimates: an unlucky
draw, and a reminder that a variance computed from a modest number of repeats
is itself noisy.]{.draft}
 
:::



### Probability Estimator Variance {#probabilityestimatorvariance}

Let $E$ be some event in $\Omega_X$ with probability $p_E$. We can estimate 
the probability by using an indicator function:
$$\hat{p}_E = \frac{1}{N} \sum_{i=1}^N \mathbf{1}_E\left(x_i\right).$$
The indicator function simplifies the $\mathbf{X}_i$ by transforming
them to a Bernoulli process with success probability $p_E$. The variance
of a Bernoulli trial is $p_E\left(1-p_E\right)$, so the estimator 
variance should be
$$\text{Var}\left( \hat{p}_E\right)=\frac{p_E\left(1-p_E\right)}{N}.$$


## Monte Carlo Simulation Methods {#montecarlosimulationmethods}

Estimator concepts can be applied to a variety of numerical computation and 
simulation problems. In these applications, samples are obtained from a 
random number generator (RNG) algorithm. An important example is **Monte Carlo
integration**: we can numerically approximate an integral of the form 
$\int xf(x)dx$. If $f(x)\geq 0$ and $\int_{-\infty}^{\infty}f(x)dx=1$, then
the integral has the form of an expectation:
$$\int xf(x)dx = \mathcal{E}_\mu\left(\mathbf{X}\right)$$
where $\mathbf{X}$ is a random variable with density function $f(x)$.

If we have a way to generate random samples from the distribution $f(x)$,
then we can use the sample mean $\hat\theta_X$ to approximate the integral.

:::{.example title="Monte Carlo Integration"}
Let's estimate the integral $\int_a^b xdx$ with $a=0$ and $b=1$. We construct 
a random variable $\mathbf{X}$ with uniform density in the interval $(0,1)$,
so the density function is 
$$f_X=\begin{cases}
1 & 0 < x\leq 1\\
0 & \text{otherwise}
\end{cases}
$$
Then we collect $N$ samples of $\mathbf{X}$. The integral is approximately 
$$\int_0^1 xf(x)dx \approx \frac{1}{N}\sum_{i=1}^N x_i.$$
In this example we can easily solve the exact value of the expectation integral,
$\mathcal{E}_\mu\left(\mathbf{X}\right)=0.5$. The Monte Carlo estimation should
converge to the exact value as $N\rightarrow\infty$.

```julia
# Monte Carlo integration of x over (0,1)
using StableRNGs, Statistics

rng = StableRNG(2026)
N = 100_000
x = rand(rng, N)
θ_hat = mean(x)

println("θ_hat = $(θ_hat)")
```

This simulation produced the result 0.5007117398359223, which
is correct to the third decimal. After repeating the simulation, we get a slightly
different result each time. @Fig:uniformhistogram shows a histogram of results
from ten thousand repeated simulations. The estimation result resembles a Gaussian
distribution with mean equal to the true value. [This variability is the estimator variance of the previous section. It
tells us how accurate a given Monte Carlo result is, and how many samples a
specified accuracy requires.]{.draft}

:::


![Histogram of Monte Carlo integrations $\int_0^1xdx$. Each result was computed from $N=10^5$ samples.](figures/uniform_histogram.tex){#fig:uniformhistogram}


:::{.example title="Estimating $\pi$"}

We know that $\pi$ is the area of a unit circle. Suppose the circle is contained
within a square of area 4, with corners at $(\pm 1, \pm 1)$. Let $\mathbf{X}$ and
$\mathbf{Y}$ be uniformly distributed horizontal and vertical coordinates within
the square. Define indicator function for the event that $(x,y)$ is within the
circle:
$$\mathbf{1}_C\left(x,y\right)=\begin{cases}1 & x^2 + y^2 < 1\\ 0 & \text{otherwise.}\end{cases}$$
Then collect $N$ samples each from $\mathbf{X}$,$\mathbf{Y}$ and compute the
sample mean of the indicator function:
$$\hat{p}_C = \frac{1}{N}\sum_{i=1}^N \mathbf{1}_C\left(x_i,y_i\right).$$
Now $\hat{p}_C$ estimates the probability that a point lands in the circle,
which should equal the area of the circle divided by the total area of the
square region, $p_C=\pi/4$. 

```julia
using StableRNGs, Statistics

rng = StableRNG(2026)
N = 100_000
in_C(x, y) = x^2 + y^2 < 1   # indicator of the unit circle

for run in 1:5
    x = -1 .+ 2 .* rand(rng, N)   # coordinates in [-1, +1]
    y = -1 .+ 2 .* rand(rng, N)
    p_hat = mean(in_C.(x, y))
    println("π estimate: $(4 * p_hat)")
end
```

The five runs, each from $10^5$ samples, produced 3.1336, 3.15452, 3.13428,
3.13896 and 3.14512. [The estimates agree to the first decimal place, as expected:
$\hat{p}_C$ has standard deviation $\sqrt{p_C(1-p_C)/N}\approx 0.0013$, so
$4\hat{p}_C$ varies by about $0.005$.]{.draft}
:::


## "Pathological" Cases {#pathologicalcases}

There are distributions for which the mean and variance are undefined.
The Cauchy Distribution is a commonly cited example. Let $\mathbf{U}$
be a uniformly distributed random variable in the interval $[0,1]$.
Then define a transformed variable 
$\mathbf{X}=\tan \left(\pi\left(\mathbf{U}-0.5\right)\right)$. Now
$\mathbf{X}$ has a Cauchy Distribution. Estimating its sample mean
or variance can be frustrating and deceiving, since it has no such
parameters.

:::{.example title="Cauchy Distribution Simulation"}
What happens if we try to estimate the parameters of a Cauchy Distributed
variable? 

```julia
using StableRNGs, Statistics
using Plots

rng = StableRNG(2026)
N = 100_000   # samples per estimate
M = 100       # independent estimates

r(u) = tan(π * (u - 0.5))   # transforms Uniform(0,1) samples to Cauchy samples

estimates = zeros(M)
variances = zeros(M)

for j in 1:M
    x = r.(rand(rng, N))
    estimates[j] = mean(x)
    variances[j] = var(x)
end

plot(plot(estimates; xlabel = "Estimate index", ylabel = "Sample mean", legend = false),
     plot(variances; xlabel = "Estimate index", ylabel = "Sample variance",
          yscale = :log10, legend = false))
```

[The estimates are plotted in [@fig:cauchy_means; @fig:cauchy_vars]. A single estimate, followed sample by sample, is traced in [@fig:cauchy_trace; @fig:cauchy_trace_variance].]{.draft}
:::


![100 independent sample mean estimations of a Cauchy distributed random variable. There is no consistency among the estimates.](figures/cauchy_means.tex){#fig:cauchy_means}

![100 independent sample variance estimations for a Cauchy distributed random variable. The results are spread out across five orders of magnitude.](figures/cauchy_vars.tex){#fig:cauchy_vars}


![A sample mean that gives the appearance of converging, until a "rogue sample" appears near the 900th sample. This is not an outlier; it's a symptom of the Cauchy distribution's pathology.](figures/cauchy_sampling.tex){#fig:cauchy_trace}

![Predicted estimator variance based on sample variance. It gives the illusion of smooth convergence to a low variance, but the illusion is eventually shattered.](figures/cauchy_sampling_vars.tex){#fig:cauchy_trace_variance}

\newpage

## Key Terms {#keytermsestimation}

Parameter $\xi$

: A property of a random distribution.

Estimator $\hat{\boldsymbol{\xi}}$

: An algorithm for inferring the value of $\xi$ based on sampled data; 
also denotes the random variable that results from applying the algorithm to
randomly sampled data.

Estimate $\hat{\xi}$

: A numerical result from applying the estimator on sampled data.

Sample Mean Estimator 

: Has the form $\hat{\xi}=\frac{1}{N}\sum_{i=1}^N h\left(x_i\right)$ for 
some function $h(x)$ applied to iid samples $x_i$.

Well-Behaved Distribution

: $h\left(\mathbf{X}\right)$ has finite expectation and variance.

Pathological Distribution

: $h\left(\mathbf{X}\right)$ has undefined expectation and/or variance (e.g. Cauchy Distribution).

Estimator Variance $\text{Var}\left(\hat{\boldsymbol{\xi}}\right)$

: Variance of the estimator's result. For well-behaved sample mean estimations
$\text{Var}\left( \hat{\boldsymbol{\xi}}\right)=\frac{1}{N}\text{Var}\left(h\left(\mathbf{X}\right) \right)$.

Unbiased Estimator

: Satisfies $\mathcal{E}_\mu\left(\hat{\boldsymbol{\xi}}\right)=\xi$.

Consistent Estimator

: Satisfies $\Pr\left(\left|\hat{\boldsymbol{\xi}}-\xi\right|>\epsilon\right)\rightarrow 0$ for every $\epsilon>0$ as $N\rightarrow\infty$ (convergence in probability).

Efficient Estimator

: An estimator with minimal variance (loose definition).


