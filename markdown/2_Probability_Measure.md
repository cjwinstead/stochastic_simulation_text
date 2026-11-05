# Probability Measure {#probabilitymeasure}

## Continuous Random Variables {#continuousrandomvariables}

If a random variable has a continuous sample space (e.g. real numbers),
then the elementary events are **uncountable**. The elements of an
uncountable set cannot be arranged in a simple order, so probability
distributions cannot be defined by mass vectors. We require more sophisticated
mathematical tools.

In the continuous context, a *sample* is some
observation or measurement with limited precision. If the
measurement is a real number recorded as $m \pm \epsilon$ then it 
represents all the possibilities within the continuous interval
$(m-\epsilon,m+\epsilon)$. We can imagine that the "true" value
lies somewhere within that interval.

With continuous spaces there usually isn't a singular "true" value at all.
For instance, imagine measuring the boundary of a cloud using a cloud
sensor device. The device always returns a binary answer, there are definite
cloud and not-cloud regions, but there is no definite edge separating them.
Instead we have continuous intervals, each having an associated probability of
being detected as "cloud".

For a continuous random variable $\mathbf{X}$, we always consider the
probability of measuring within some interval, $\Pr(x-\epsilon < \mathbf{X} < x+\epsilon)$.
Every measurement has some uncertainty, so $\epsilon$ is always
greater than zero. We can improve the precision, making $\epsilon$ as
small as we want, but we can never take a true point measurement. The
probability of a point is therefore always zero: for any point $x\in \mathcal{U}_X$, 
$\Pr(\mathbf{X}=x)=0$. The same is true for any *countable* set of
points. Within a continuous space, discrete points have zero probability.

In order to have a non-zero probability, our measurement needs to
contain a "volume" of points; a continuous interval contains an
*uncountable* infinity of points, no matter how small the
interval. All the way back in 300 BCE, Euclid defined a **point** as
"that which has no part", i.e. it's empty. A (countable) collection of points is
just a collection of empties. But an *interval* contains an uncountable continuum, it
isn't empty. In measure theory, an isolated point has a well-defined measure, and that measure is zero.
Any countable set of isolated points also has measure zero, as illustrated in 
(@fig:measure_zero_points). An interval has positive measure^[There is a technical 
distinction between measureable and unmeasurable sets, which is settled by the $\sigma$-algebra theory 
explained in @sec:sigmaalgebras.].

![Isolated points form a set of measure zero; an interval has positive measure.](figures/measurable_interval.tex){#fig:measure_zero_points}

The "volume" contained within an interval is called its
**measure**, and probability is a sub-type of measure. Probability
is therefore contained within the mathematical framework of **measure
theory**. The next section introduces probability density informally, and the
section after it gives a summary introduction to measure theory. For a more information, check out the 
[Wikipedia page](https://en.wikipedia.org/wiki/Measure_(mathematics)), or
study [Zakon's open textbook on Mathematical
Analysis](https://math.libretexts.org/Bookshelves/Analysis/Mathematical_Analysis_(Zakon)). 


## Probability Density and Distribution {#probabilitydensity}

Probability measure is quantified by a **probability density
function** $f_X(x)$. Probability density is defined for a
real-valued random variable $\mathbf{X}\in\mathbb{R}$ as the
differential probability that $\mathbf{X}$ lies in a vanishingly
small interval $(x,x+dx)$: 
$$f_X(x)dx \triangleq \Pr(x < \mathbf{X} \leq x+dx).$$
The interval's width is $dx$, which is smaller than any
finite value but still greater than zero. No matter how small,
the interval contains a continuum of points, so it has positive measure.

The total probability in a measurable set $\mathcal{S}$ is
$$
\Pr(\mathbf{X}\in \mathcal{S})=\int_{\mathcal{S}} f_X(x)dx.
$$
If $\mathcal{S}$ is a continuous interval $(x-\epsilon,x+\epsilon)\subset\mathbb{R}$
then the probability is 
$$
\Pr(x-\epsilon < \mathbf{X} \leq x+\epsilon) =
\int_{x-\epsilon}^{x+\epsilon} f_X(u)du,
$$
where $u$ is an integration variable holding the place of $x$. 

The density function provides a complete representation of probability
on the event space $\Omega_X$, and it inherits the properties of
probability measure:

$$\begin{aligned}
 f_X(x) & \geq 0 \\
 \int_{\mathcal{U}_X} f_X(u)du & = 1
 \end{aligned}
$$

In other words, probability density is never negative (but could be
zero), and when integrated across the entire space, it comes to a
total probability of 1 (i.e. it covers all possible events).  

### Cumulative Distribution 

The **cumulative distribution function** $F_X(x)$ is defined along a
single real-valued dimension as

$$F_X(x) \triangleq \int_{-\infty}^x f_X(u)du.$$

The cumulative distribution is convenient for computing the
probability in a real interval $(a,b)$, since 
$$\Pr(a < \mathbf{X} < b) = F_X(b) - F_X(a).$$


## Sigma Algebras and Measure Spaces {#sec:sigmaalgebras}

A **sigma algebra** (or $\sigma$-algebra) is a set of rules for manipulating sets whether
they are countable or uncountable. A $\sigma$-algebra $\Omega$ on a set
$\mathcal{U}_X$ is a set of subsets of $\mathcal{U}_X$ that contains $\mathcal{U}_X$
itself and is closed under complements and *countable* unions. More precisely:

$$\begin{aligned}
\mathcal{U}_X \in \Omega & \text{~~~whole~space}\\
E \in \Omega \Rightarrow E^c \in \Omega & \text{~~~complement~closure}\\
E_1, E_2, \dots \in \Omega \Rightarrow \bigcup_i E_i \in \Omega & \text{~~~countable~union~closure}
\end{aligned}$$

Closure under countable intersections follows from the other two properties due to De Morgan's Laws, since 
$E_1 \bigcup E_2 = (E_1^c \bigcap E_2^c)^c$ (the reader is encouraged to complete the proof as an exercise).

A practical example of a $\sigma$-algebra is the **power set**:
given a set $\mathcal{U}_X$, the power set $\Omega_X$ is the set of all
subsets of $\mathcal{U}_X$. 

For a $\sigma$-algebra $\Omega_X$, a **measure** is a map $\mu:\Omega_X\rightarrow[0,\infty]$
with the following properties for $E\in\Omega_X$:

$$\begin{aligned}
\mu(E) & \geq 0 & \text{non-negativity}\\
\mu(\emptyset) &=0 & \text{empty set}
\end{aligned}
$$

Given a subset of pairwise disjoint\footnote{Pairwise disjoint means that
$E_i \cap E_j = \emptyset$ if $i\neq j$.}
elements $E_i\in \Omega$, with $i=1,2,\dots$,
the measure of the union equals the sum of the measures:

$$\begin{aligned}
\mu\left(\bigcup_i E_i\right) & = \sum_i \mu(E_i) & \sigma\text{~additivity}
\end{aligned}
$$


A **probability measure** is a measure with one additional property:

$$\begin{aligned}
\mu(\mathcal{U}_X) &= 1 & \text{Probability Measure}
\end{aligned}$$

From the properties of probability measure, we can obtain all the
properties of probability algebra:

$$\begin{aligned}
 \mu\left(A\right) & \geq 0 &  \text{non-negativity} \\
 \mu\left(\emptyset\right) & = 0 &  \text{empty set} \\
 \mu\left(\mathcal{U}_X\right) & = 1 &  \text{totality} \\
 \mu\left(A\right) & \leq \mu\left(B\right) \text{~if~} A\subseteq B &  \text{subset} \\
 \mu\left(A\right)+\mu\left(A^c\right) & = 1 & \text{complement} \\
 \mu\left(A \cup B\right) & = \mu\left(A\right) + \mu\left(B\right) - \mu\left(A\cap B\right) &  \text{union} 
\end{aligned}
$$


### Absolute Continuity and Change of Measure {#sec:absolutecontinuity}

Two probability measures $\mu$ and $\nu$ can be defined on the same sample space
and event space. We say that $\mu$ is **absolutely continuous** with respect to
$\nu$, written $\mu\ll\nu$, if every event that $\nu$ considers impossible is
also impossible under $\mu$:
$$\nu(E)=0 \;\Rightarrow\; \mu(E)=0 \qquad \text{for every } E\in\Omega_X.$$

For real-valued variables with densities $f_X$ (for $\mu$) and $f_Y$ (for $\nu$),
this means $f_Y(y)>0$ wherever $f_X(y)>0$. The **likelihood ratio**
$$\ell(y)=\frac{f_X(y)}{f_Y(y)}$$
then converts one measure into the other:
$$\mu(E)=\int_E f_X(y)\,dy=\int_E \ell(y)\,f_Y(y)\,dy.$$
For discrete variables the same holds with mass functions: $\ell(u)=p_X(u)/p_Y(u)$,
and $\mu(E)=\sum_{u\in E}\ell(u)\,p_Y(u)$.^[In measure theory, $\ell$ is the
Radon–Nikodym derivative $d\mu/d\nu$, which exists whenever $\mu\ll\nu$, with or
without densities. We will not need the general form.]

The likelihood ratio is the foundation of importance sampling
(@sec:importancesamplingfundamentals). It lets us compute probabilities and
expectations under $\mu$ while drawing samples from $\nu$. If absolute
continuity fails, some events that matter under $\mu$ are never sampled under
$\nu$, and no reweighting can recover them.



## Expectation

For a real-valued random variable $\mathbf{X}$ with probability measure
$\mu$ and density function $f_X(x)$, the **expected value** or **expectation** is defined as

$$ \mathcal{E}_\mu\left(\mathbf{X}\right) = \begin{cases*} \sum_{u \in \mathcal{U}_X} u\, p_X(u) & (discrete) \\
\int_{\mathcal{U}_X} x f_X(x) dx & (continuous)
\end{cases*} $$

Some properties of expectation:

$$\begin{aligned}
\mathcal{E}_\mu(a) &= a & \text{constant~} a\\
\mathcal{E}_\mu(a\mathbf{X}) &= a\mathcal{E}_\mu(\mathbf{X}) & \text{multiplication~by~constant}\\
\mathcal{E}_\mu(\mathbf{X}+\mathbf{Y}) &= \mathcal{E}_\mu(\mathbf{X})+\mathcal{E}_\mu(\mathbf{Y}) & \text{sum~of~random~variables}.
\end{aligned}$$

Additionally, if $\mathbf{X}$ and $\mathbf{Y}$ are independent, then $\mathcal{E}_\mu\left(\mathbf{X}\mathbf{Y}\right)=\mathcal{E}_\mu\left(\mathbf{X}\right)\mathcal{E}_\mu\left(\mathbf{Y}\right)$.



### Expectation of a Function {#sec:lotus}

We often need the expectation of a function of a random variable,
$h(\mathbf{X})$, such as $\mathbf{X}^2$ or an indicator $\mathbf{1}_E(\mathbf{X})$. It
is not necessary to find the distribution of $h(\mathbf{X})$ first; we can average
$h$ directly over the distribution of $\mathbf{X}$:
$$\mathcal{E}_\mu\left(h(\mathbf{X})\right)=\begin{cases*}\sum_{u\in\mathcal{U}_X} h(u)\,p_X(u) & (discrete)\\
\int_{\mathcal{U}_X} h(x)\,f_X(x)\,dx & (continuous)\end{cases*}$$ {#eq:lotus}
For example, if $\mathbf{X}$ is uniform on $(0,1)$, then we can solve for 
$\mathcal{E}_\mu(\mathbf{X}^2)=\int_0^1 x^2\,dx=1/3$, without having to solve for the density of
$\mathbf{X}^2$ (compare @sec:functionsofrandomvariables). 

In the important case where $h(x)$ is an
indicator, i.e. $h(x)=\mathbf{1}_E(x)$, the expectation is the probability of the event:
$\mathcal{E}_\mu\left(\mathbf{1}_E(\mathbf{X})\right)=\Pr(\mathbf{X}\in E)$. Every estimator
in the following chapters estimates an expectation of this form.



:::{.example title="Sum of Two Dice"}
Let $\mathbf{X}$ and $\mathbf{Y}$ be two six-sided dice. $\mathbf{X}$ is unbalanced with
probability mass vector $p_X$ and $\mathbf{Y}$ is well-balanced with probability
mass vector $p_Y$. Determine the distribution for the sum $\mathbf{S}=\mathbf{X}+\mathbf{Y}$. 
Then use the distributions to calculate $\mathcal{E}_\mu\left(\mathbf{X}\right)$, 
$\mathcal{E}_\mu\left(\mathbf{Y}\right)$, and $\mathcal{E}_\mu\left(\mathbf{S}\right)$. Confirm
that $\mathcal{E}_\mu\left(\mathbf{S}\right)=\mathcal{E}_\mu\left(\mathbf{X}\right)+\mathcal{E}_\mu\left(\mathbf{Y}\right)$.

```julia
using Plots

# Probability mass vectors
px = [6, 5, 4, 3, 2, 1] ./ 21    # unbalanced die X
py = fill(1/6, 6)                # balanced die Y

# Outcomes
UX = 1:6
UY = 1:6
US = 2:12

# Probability mass of S = X + Y (S = 2 is stored at index 1)
ps = zeros(length(US))
for x in UX, y in UY
    ps[x + y - 1] += px[x] * py[y]
end

# Expectations
EX = sum(UX .* px)
EY = sum(UY .* py)
ES = sum(US .* ps)

plot(bar(UX, px), bar(UY, py), bar(US, ps); layout = (1, 3), legend = false)

println("EX = $(round(EX; digits=4)), EY = $(round(EY; digits=4)), and ES = $(round(ES; digits=4))")
```

The output is `EX = 2.6667, EY = 3.5, and ES = 6.1667`, which confirms the sum.

The three distributions are plotted in [@fig:dice_mass_x; @fig:dice_mass_y; @fig:dice_mass_s].
:::

![Probability mass of the unbalanced die $\mathbf{X}$.](figures/dice_mass_x.tex){#fig:dice_mass_x}

![Probability mass of the balanced die $\mathbf{Y}$.](figures/dice_mass_y.tex){#fig:dice_mass_y}

![Probability mass of the sum $\mathbf{S}=\mathbf{X}+\mathbf{Y}$.](figures/dice_mass_s.tex){#fig:dice_mass_s}



## Variance

A distribution's variance $\text{Var}\left(\mathbf{X}\right)$ gives some indication
of its unpredictability within an interval around the mean. If $\text{Var}\left(\mathbf{X} \right)=0$
then $\mathbf{X}$ is not random at all. $\text{Var}\left( \mathbf{X}\right)$ is often denoted as $\sigma_X^2$, and $\sigma$ is called the **standard deviation**. Variance
is defined in terms of expectation as 
$$\text{Var}\left(\mathbf{X} \right)\triangleq\mathcal{E}_\mu\left(\left(\mathbf{X}-\theta_X\right)^2\right)$$

Properties of variance:

$$\begin{aligned}
  \text{Var}\left( a \right) &= 0 & \text{constant}\\
  \text{Var}\left( a\mathbf{X} \right) &= a^2\text{Var}\left(\mathbf{X}\right) & \text{scaling}\\
  \text{Var}\left( a+\mathbf{X} \right) &= \text{Var}\left(\mathbf{X}\right) & \text{translation}
\end{aligned}$$

If $\mathbf{X}$ and $\mathbf{Y}$ are independent variables then $\text{Var}\left( \mathbf{X}+\mathbf{Y}\right)=\text{Var}\left(\mathbf{X} \right)+\text{Var}\left(\mathbf{Y} \right).$ For more than two random variables $\mathbf{X_i}$, if they are all pairwise independent, then 
$$\begin{aligned}
\text{Var}\left( \sum_{i=1}^N \mathbf{X_i}\right)&= \sum_{i=1}^N\text{Var}\left( \mathbf{X_i}\right)& \text{(independent variables)}
\end{aligned}$$


## Example Continuous Distributions

Some of the most commonly encountered continuous distributions
are described in the following examples. In these examples,
the distributions are well characterized by their expectation, 
variance, and support. These example distributions are selected
because they will appear again later in the text.

:::{.example title="Uniform Distribution"}

The **uniform distribution** is one in which any measurement is
equally likely within a given interval. Suppose a random variable
$\mathbf{U}$ is known to be contained in the interval $(a,b)$ ($a<b$), but is
equally likely to be anywhere within that interval. Then 
$$f_U(x) = \begin{cases}\frac{1}{b-a}& \text{if~} x\in
(a,b)\\ 0 & \text{otherwise}\end{cases}$$
You can directly verify the properties $\int_{-\infty}^{\infty} f_U(x)dx=1$ and
$f_U(x)\geq 0$. 

Since $f_U(x)$ is constant when $x\in(a,b)$, its integral is a
straight line, and the cumulative distribution is 
$$F_U(x) = \int_{-\infty}^x f_U(\chi)d\chi = \begin{cases}
0 & \text{if~} x\leq a\\
\frac{x-a}{b-a} & \text{if~} x\in(a,b)\\
1 & \text{if~} x\geq b
\end{cases}$$

The expectation is 
$$\theta=\mathcal{E}_\mu\left(\mathbf{U}\right)=\int_a^b \frac{1}{b-a}xdx=\frac{b^2-a^2}{2(b-a)}=\frac{1}{2}(a+b).$$

The variance is 
$$\text{Var}\left(\mathbf{U}\right)=\int_a^b\frac{1}{b-a}x^2dx -\theta^2=\frac{b^3-a^3}{3(b-a)}-\frac{1}{4}(a+b)^2=\frac{1}{12}(b-a)^2.
$$

The density and the cumulative distribution are plotted in [@fig:uniform_density; @fig:uniform_cdf].
:::


:::{.example title="Gaussian Distribution"}

The **Gaussian distribution**, commonly called the "bell curve",
is one of the most common distributions in practice. It's defined by
two parameters: the mean $\theta$ and the **standard deviation**
$\sigma$. The density function is highest where $x=\theta$, and is
symmetric on either side of $\theta$:
$$f_G(x) = \frac{1}{\sigma\sqrt{2\pi}}\exp\left(-\frac{1}{2}\left(\frac{x-\theta}{\sigma}\right)^2\right)$$

The Gaussian distribution is standardized by the **Normal
Distribution**, which has zero mean and standard deviation of 1:
$$f_N(x) = \frac{1}{\sqrt{2\pi}}\exp\left(-\frac{x^2}{2}\right).$$
The Normal distribution can be transformed into a Gaussian distribution
with parameters $\theta$,$\sigma$:
$$f_G(x;\theta,\sigma) = \frac{1}{\sigma}f_N\left(\frac{x-\theta}{\sigma}\right).$$
The cumulative distribution function is usually indicated as a "special"
function. The **Standard Normal Cumulative Distribution** 
is indicated symbolically as $\Phi_N(x)$. For a
parameterized Gaussian distribution, we obtain the cumulative
distribution as 
$$F_G(x;\theta,\sigma) = \Phi_N\left(\frac{x-\theta}{\sigma}\right).$$

:::

![Uniform probability density function in the interval $(a,b)$.](figures/uniform_density.tex){#fig:uniform_density}

![Cumulative uniform distribution in the interval $(a,b)$.](figures/uniform_distribution.tex){#fig:uniform_cdf}


:::{.example title="Exponential Distribution"}

The exponential distribution is governed by a single parameter $\lambda$:

$$f_X(x)=\lambda e^{-\lambda x}, \qquad x\geq 0$$

The expectation is $\mathcal{E}_\mu\left(\mathbf{X}\right)=1/\lambda$
and the variance is $\text{Var}\left( \mathbf{X}\right)=1/\lambda^2$.

The exponential distribution typically arises when predicting the time 
between random events. It has the important property of being **memoryless**:
given $\mathbf{X}>t$, we can construct a new variable $\mathbf{Y}=\mathbf{X}-t$.
The distribution of $\mathbf{Y}$ turns out to be the same as that of $\mathbf{X}$.

For a practical example, suppose we are on a road trip and $\mathbf{X}$ represents the answer to
the question "how long until we stop?" in minutes. Stops occur at random at the rate 
of 0.02 stops per minute, so $\mathbf{X}$ 
is exponentially distributed with $\lambda=0.02$, then the answer is always
"another fifty minutes" no matter how many times you've already asked or 
how long you think we've been stuck in the car.

:::

## Functions of Random Variables {#sec:functionsofrandomvariables}

We often encounter situations where a random variable $\mathbf{X}$ has
a known density $f_X(x)$, and we need to determine the density of a
related random variable $\mathbf{Y}$. If the two variables are related
by a known function, e.g. $\mathbf{Y} = r(\mathbf{X})$, then we can
determine the density $f_Y(y)$ by a **change of variables**. With
this method, we first apply the mapping from the domain of $\mathbf{X}$
to the domain of $\mathbf{Y}$, and then integrate $f_X$ in the $\mathbf{Y}$
domain. If the relationship is one-to-one, i.e. if $r(x)$ is
invertible at every point, then we can simply say that 
$$f_Y(y)dy = f_X(x)dx$$
where $x=r^{-1}(y)$. So we have 
$$f_Y(y) = \frac{f_X(x)}{\left|dy/dx\right|} = \frac{f_X(x)}{\left|r^\prime(x)\right|}.$$

If the function $r()$ is not one-to-one, then multiple intervals along
the domain of $\mathbf{X}$ could fold into a single interval
along the domain of $\mathbf{Y}$.
If $r(x)=y$, we say that $y$ is the **image** of $x$, and $x$ is a
**preimage** of $y$. Suppose $y$ has $K\in\mathbb{Z}^+$ preimages
$x_1,\dots,x_K$. Around each preimage, a small interval of width
$\left|dx_k\right|$ maps onto the interval $(y,y+dy)$, so the total
accumulated measure is
$$f_Y(y)dy = \sum_{k=1}^K f_X(x_k)\left|dx_k\right|.$$
Since $\left|dx_k\right| = dy/\left|r^\prime(x_k)\right|$, the transformed
density is a sum:
$$f_Y(y) = \sum_{k=1}^K \frac{f_X(x_k)}{\left|r^\prime\left(x_k\right)\right|}.$$


:::{.example title="$\mathbf{Y}=\mathbf{X}^2$"}

Given a random variable $\mathbf{X}\in\mathbb{R}$ with a uniform
density in the interval $[-2,2]$, determine the probability density of
the related random variable $\mathbf{Y}=r(\mathbf{X})$, where the
relationship is given by the function $r(x) = x^2$.

In this example, $\mathbf{Y}$ takes values in the 
interval $[0,4]$. Each $y\in(0,4]$ is the image of two points, $x=\sqrt{y}$ in
$(0,2]$ and $x=-\sqrt{y}$ in $[-2,0)$. At both of the preimages, $\left|r^\prime(x)\right|=2\sqrt{y}$.
The density of $\mathbf{Y}$ therefore has two components:
$$f_Y(y) = \frac{f_X(\sqrt{y})}{2\sqrt{y}} + \frac{f_X(-\sqrt{y})}{2\sqrt{y}}.$$
Since $\mathbf{X}$ is uniform, $f_X$ equals $1/4$ everywhere on $[-2,2]$, so
$$f_Y(y) = \begin{cases}\frac{1}{4\sqrt{y}} & \text{if~} 0 < y \leq 4\\0 & \text{otherwise} \end{cases}$$
which integrates to one over $[0,4]$.

The foregoing analysis does not work for the point $y=0$, which has only one
preimage, $x=0$. Because it is an isolated point rather than an interval, it
has measure zero: $\Pr(\mathbf{Y}=0)=0$. It therefore has no consequence for the
distribution. We say that our result holds **almost everywhere**, or "up to
sets of measure zero", to indicate that such points exist but do not matter.

:::

\newpage

## Key Terms {#probabilitymeasurekeyterms}

Continuous Sample Space $\mathcal{U}_X$

: A set of uncountably many points.

Sigma Algebra (Event Space) $\Omega_X$

: A set of sets that is closed under complements, intersections,
and countable unions, and contains the whole space.

Measure $\mu$

: A non-negative map from $\Omega$ to $[0,\infty]$, additive over countable disjoint unions.

$\sigma$-Additivity

: The measure of a countable union of disjoint sets equals the
sum of the sets' measures.

Measure Zero

: An isolated point, a countable set of points, and the empty set
all have measure zero.

Probability Measure

: A measure for which $\mu(\mathcal{U}_X)=1$.

Measure Space $(\mathcal{U}_X,\Omega_X,\mu)$

: A tuple that defines the sample space, event space, and
measure for random variable $\mathbf{X}$.

Almost Everywhere

: A statement holds almost everywhere if the set of points where it fails has
measure zero.

Probability Density $f_X(x)$

: A function that defines the differential probability measure for $\mathbf{X}$
on $\mathbb{R}$ in one dimension, $f_X(x)dx=d\mu$.

Cumulative Distribution $F_X(x)$

: The probability that $\mathbf{X}\leq x$.

Expectation $\theta_X=\mathcal{E}_\mu(\mathbf{X})$

: Subject to probability measure $\mu$, $\mathcal{E}_\mu(\mathbf{X})=\int_{\mathcal{U}_X}xd\mu=\int_{\mathcal{U}_X}xf_X(x)dx$. Usually interpreted as "average outcome".

Variance $\text{Var}(\mathbf{X})$

: Subject to probability measure $\mu$, $\text{Var}(\mathbf{X})=\mathcal{E}_\mu(\mathbf{X}^2)-\theta_X^2.$

Uniform Distribution $f_U(x)$

: A probability density that is constant within an interval $(a,b)$ and zero elsewhere.

Gaussian Distribution

: The "bell curve" probability density with mean $\theta$ and variance $\sigma^2$.

Normal Distribution

: A Gaussian distribution with $\theta=0$ and $\sigma^2=1$.

