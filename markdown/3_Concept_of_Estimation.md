# The Concept of an Estimator {#conceptofanestimator}

An **estimator** is an algorithm for infering the value of an
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
the same estimation using the exact same procedure. The $i^\textrm{th}$
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
$$\lim_{N\rightarrow\infty}\Pr\left(\left|\hat{\boldsymbol{\xi}}-\xi\right|>0\right)=0\text{~~~(consistency)}.$$
This property is called *convergence in probability*, and means the estimator's absolute
error can be made as small as desired by including a sufficient number of samples. We will
use the shorthand $\hat{\boldsymbol{\xi}}\rightarrow\xi$ to indicate that $\hat{\boldsymbol{\xi}}$
converges in probability to $\xi$.

We will say that an estimator $\boldsymbol{\xi}$ is **efficient** if the 
**estimator variance** $\text{Var}\left(\hat{\boldsymbol{\xi}}\right)$ converges to a 
small value. 

## Examples {#examples}

:::{.example title="Sample Mean Estimator (unbiased, consistent, efficient, MMSE)"}
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
$$\hat{\theta}_Y=\frac{1}{N}\sum_{i=1}^N x^2$$
Is this one unbiased? We should look closely at the estimator mean:
$$\mathcal{E}_\mu\left(\hat{\boldsymbol{\theta}}_Y\right)=\frac{1}{N}\sum_{i=1}^N \mathcal{E}_\mu\left(\mathbf{X^2}\right).$$
From a previous example, we know the density of $\mathbf{X}^2$ is 
$$f_Y(y) = \frac{f_X(\sqrt{y})}{2\sqrt{y}} - \frac{f_X(-\sqrt{y})}{2\sqrt{y}}.$$
A circle can't have negative radius, so we can assume $f_X(-\sqrt{y})=0$. Then
the distribution simplifies as
$$f_Y(y) = \frac{f_X(\sqrt{y})}{2\sqrt{y}} = \begin{cases} \frac{1}{2\sqrt{y}} & 1\leq y \leq 4\\ 0 & \text{otherwise.}\end{cases}$$
The precise expectation of $\mathbf{Y}$ is 
$$\begin{aligned}
\mathcal{E}_\mu\left(\mathbf{Y}\right)&=\int_0^{\infty} yf_Y(y)dy & \\
&=\int_1^4 \left(\frac{1}{2}\right)y^{1/2}dy & \\
&= \left.\left(\frac{1}{3}\right)y^{3/2}\right|_{1}^4 & \\
&= 2.33 &
\end{aligned}$$

:::


:::{.example title="Representative Sample (unbiased, not consistent)"}
Given $N$ iid samples of $\mathbf{X}$, a bad estimator for the mean is
to choose $x_N$ as a "representative sample", ignoring all previous
samples. Then $\hat{\theta}_X=x_N$. Clearly this estimator is unbiased,
but it doesn't converge with increasing samples, so it is not consistent.
:::

:::{.example title="Sample Mean w/Constant Term (biased and consistent)"}
We are given $N-1$ iid samples of $\mathbf{X}$, but the $N^\textrm{th}$ sample
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
\hat{\sigma}_X^2 &= \frac{1}{N}\sum_{i=1}^N \left(\mathbf{X}-\hat{\theta}_X\right)^2 & 
\end{aligned}$$ 
This procedure turns out to be biased:
$$\begin{aligned}
\mathcal{E}_\mu\left(\hat{\sigma}_X^2\right)& =\mathcal{E}_\mu\left(\frac{1}{N}\sum_{i=1}^N \left(\mathbf{X}-\hat{\theta}_X\right)^2\right)& \\
&= \frac{1}{N} \mathcal{E}_\mu\left(\sum_{i=1}^N \left(\mathbf{X}_i-\sum_{j=1}^N\mathbf{X}_j\right)^2\right) & 
\end{aligned}$$
The sum has terms where $i=j$, so one of the samples is canceled out. This causes a 
bias equal to the missing sample's contribution:
$$\mathcal{E}_\mu\left(\hat{\sigma}_X^2\right)=\sigma_X^2\left(1-\frac{1}{N}\right).$$
:::

:::{.example title="Sample Variance (unbiased)"}
The simultaneous estimation of $\theta_X$ and $\text{Var}\left(\mathbf{X}\right)$
results in one sample being canceled out. To correct for this, we can adjust
the denominator to account for the missing sample:
$$\hat{\sigma}_X^2 = \frac{1}{N-1}\sum_{i=1}^N \left(x_i-\sum_{j=1}^Nx_j\right)^2.$$
This estimator is unbiased.
:::


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
using Random, Statistics

N=100000
x=rand(N)
θx=mean(x)

println("θx = $(θx)")
```

An instance of this simulation produced the result 0.5007827786800374, which
is correct to the third decimal. After repeating the simulation, we get a slightly
different result each time. @Fig:uniformhistogram shows a histogram of results
from ten thousand repeated simulations. The estimation result resembles a Gaussian
distribution with mean equal to the true value. This variability raises two questions: 
(1) How accurate is a given Monte Carlo integration result? and (2) How many samples 
do we need to achieve a specified accuracy?

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
using Random,Statistics

N=100000

# Generate coordinates in [-1,+1]
x=-1 .+ 2.0*rand(N)
y=-1 .+ 2.0*rand(N)

# Compute indicator function
i=(x.^2 + y.^2) .< 1

pc=mean(i)

println("Pi estimation is $(4.0*pc)")
```

One run of this example produced the estimate 3.14712 from $10^5$ samples. Subsequent runs yielded
3.1488, 3.14608, 3.13488, 3.13564, and so on. The results appear to be consistent to the first 
decimal point, but we need still some tools to quantify the precision of Monte Carlo results.
:::


## Estimator Variance {#estimatorvariance}

The efficiency of an estimator is closely related to its variance, 
$\text{Var}\left( \hat{\boldsymbol{\xi}}\right)$. For our purposes
we treat variance as a proxy for efficiency. If we compare two estimators 
$\hat{\boldsymbol{\xi}_1}$ and $\hat{\boldsymbol{\xi}_2}$,
we can say that $\hat{\boldsymbol{\xi}_1}$ is more efficient than $\hat{\boldsymbol{\xi}_2}$
if $\text{Var}\left(\hat{\boldsymbol{\xi}_1}\right)<\text{Var}\left(\hat{\boldsymbol{\xi}_2}\right)$.
If $\hat{\boldsymbol{\xi}}$ is an unbiased and consistent estimator, then $\text{Var}\left( \hat{\boldsymbol{\xi}}\right)$ is equal to the estimator's **mean squared error**, which predicts 
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
\hat{\theta}_X &= \frac{1}{N}\sum_{i=1}^N x_i & \text{sample mean} \\
\hat{\text{Var}}\left(h\left(\mathbf{X}\right)\right)&= \frac{1}{N-1}\sum_{i=1}^N h\left(x_i\right)^2-\theta_X^2& \text{sample variance}\\
\hat{\text{Var}}\left(\hat{\boldsymbol{\xi}}\right) &= \frac{1}{N}\hat{\text{Var}}\left(h\left(\mathbf{X}\right)\right) & \text{estimator variance}
\end{aligned}$$

The simplest case is $h(x)=x$. In this case we have the ordinary sample mean
estimator for $\hat{\boldsymbol{\theta}_X}$. If the underlying random variable 
$\mathbf{X}$ has a well defined mean and variance, then the sample variance is
$$\text{Var}\left(\hat{\boldsymbol{\xi}}\right)=\frac{1}{N}\text{Var}\left(\mathbf{X} \right).$$
This means the expected error decreases in proportion to the number of samples.

Given a group of $M$ independept experiments, each computing
the sample mean across $N$ iid samples of a random variable $\mathbf{X}$. 
Each experiment yields a sample estimate $\xi_i$. From these samples, we 
want to know $\text{Var}\left( \hat{\boldsymbol{\xi}}\right)$. Our analysis 
predicts that it should be $\text{Var}\left( \mathbf{X}\right)/N$. We can
compute two different sample variances which *should* turn out to be 
equal:
$$\frac{1}{N^2}\sum_{i=1}^N x_i \approx \frac{1}{M}\sum_{j=1}^M \xi_j.$$
This scenario is simulated in the code example shown below.

:::{.example title="Sample Mean Variance Simulation"}

$\mathbf{X}$ is a Normally distributed random variable with $\theta_X=0$
and $\sigma_X^2=1$. We conduct $M=1000$ estimates of the sample mean, each 
over $N=10^5$ samples. The expected estimator variance is 
$\text{Var}\left(\mathbf{X}\right)/N=10^{-5}$.  

```julia
using Random

N=100000 # Number of samples per estimator
M=1000   # Number of independent estimators

estimates = Vector{Float64}()
variances = Vector{Float64}()

for i=1:M
    samples=randn(N)
    m=sum(samples)/(N)
    v=(sum(samples.^2) .- m^2)/(N-1)
    push!(estimates,m)
    push!(variances,v)
end

em=sum(estimates)/M
ev=sum(((estimates).^2) .- em^2)/(M-1)

```

Upon execution, this simulation returned $\text{Var}\left( \mathbf{X}\right)/N=1.002\times 10^{-5}$
and $\text{Var}\left( \hat{\boldsymbol{\xi}}\right)=1.014\times 10^{-5}$, pretty close to the 
expected result.
:::



:::{.example title="Chi-Squared Variance Simulation"}

$\mathbf{X}$ is a Normally distributed random variable with $\theta_X=0$
and $\sigma_X^2=1$. We want to estimate $\mathcal{E}_\mu\left(\mathbf{X}^2\right)$
using the sample mean procedure with $h(x)=x^2$. With these parameters, $\mathbf{X}^2$
should have a Chi-Squared distribution with mean 1 and variance 2, so the estimator
variance should be $\text{Var}\left( \mathbf{X}\right)/N=2\times 10^{-5}.$

```julia
using Random

N=100000 # Number of samples per estimator
M=1000   # Number of independent estimators

function h(x)
    return x.^2
end

estimates = Vector{Float64}()
variances = Vector{Float64}()

for i=1:M
    samples=h(randn(N))
    m=sum(samples)/(N)

    v=sum((samples .- m).^2)/(N-1)
    push!(estimates,m)
    push!(variances,v)
end

em=sum(estimates)/M
ev=sum(((estimates).^2) .- em^2)/(M-1)
```

Upon execution, this simulation returned $\text{Var}\left( \mathbf{X}\right)/N=1.959\times 10^{-5}$
and $\text{Var}\left( \hat{\boldsymbol{\xi}}\right)=2.074\times 10^{-5}$, again pretty close to the 
expected result.
 
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


### "Pathological" Cases {#pathologicalcases}

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
using Random
using Plots

N=100000 # Number of samples per estimator
M=1000   # Number of independent estimators

function h(x)
    return tan.(pi .* (x .- 0.5))
end

estimates = Vector{Float64}()
variances = Vector{Float64}()

for i=1:M
    samples=h(rand(N))
    m=sum(samples)/(N)

    v=sum((samples .- m).^2)/(N-1)
    push!(estimates,m)
    push!(variances,v)
end

plot(
  plot(estimates,xlabel="Estimator",ylabel="Sample Mean"),
  plot(variances,xlabel="Estimator",ylabel="Sample Variance"))

```
:::


![100 independent sample mean estimations of a Cauchy distributed random variable. There is no consistency among the estimates.](figures/cauchy_means.tex)

![100 independent sample variance estimations for a Cauchy distributed random variable. The results are spread out across five orders of magnitude.](figures/cauchy_vars.tex)


![A sample mean that gives the appearance of converging, until a "rogue sample" appears near the 900th sample. This is not an outlier; it's a symptom of the Cauchy distribution's pathology.](figures/cauchy_sampling.tex)

![Predicted estimator variance based on sample variance. It gives the illusion of smooth convergence to a low variance, but the illusion is eventually shattered.](figures/cauchy_sampling_vars.tex)



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

: Satisfies $\mathcal{E}_\mu\left(\hat{\boldsymbol{\xi}}\right)\rightarrow\xi$.

Efficient Estimator

: An estimator with minimal variance (loose definition).


