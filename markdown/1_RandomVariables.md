# Random Variables {#randomvariables}

A **random variable** $\mathbf{X}$ is a placeholder for an experiment,
observation, event, or proposition with an uncertain outcome. A single
measurement, observation or generated value is called a **sample** $x$. The
specific result for a measurement is called an **outcome**.  Usually
we indicate a random variable using bold font, upper-case, like $\mathbf{X}$.
Outcomes and sample values are written using normal font, lower-case.
An experiment's possible outcomes are defined by a set, written in fancy font like
$\mathcal{U}_X$. [The elements of $\mathcal{U}_X$ are written $u$, or $u_i$ when
we number them.]{.draft}
Samples
are often annotated with an integer subscript like $x_i$, where $i\geq 1$,
signifying the $i^{\text{th}}$ repetition of the experiment. A collection of samples
is an array of outcomes, signified by an arrow like $\vec{x}$. The difference between sample arrays
and outcome sets is important, and should always be evident from the context
(be sure to watch for it).

A random variable can also represent a quantity that cannot be
directly observed or measured, such as the internal state of a machine or
system. The system definitely has a quantifiable state, but there may
not be any practical experiment that can measure it. In that case,
probabilistic models allow us to reason about the system's state based
on indirect measurements and prior information.


## Probability Definitions {#probabilitydefinitions}

Since there are experimental and non-experimental uses for the concept of random variable,
there are competing interpretations of "probability". Much of statistical theory was
developed around a purely data-driven "frequentist" interpretation of probability. In
recent decades the more abstract "Bayesian" interpretation grew to greater prominence.


### Frequentist Interpretation {#frequentist}

When a random variable is associated with a repeatable direct experiment, it can be
understood using the **frequentist probability interpretation**. In the
frequentist theory, probability is defined as the frequency of
observation for a particular **event**. An event $E$ refers to a
set of outcomes (e.g. $E=\left\{x\in\mathcal{U}_X\,:\,x<4\right\}$).
For a random variable $\mathbf{X}$, the frequentist probability of an event $E$ is
defined as

```{=latex}
\begin{equation}
  \Pr\left\{\mathbf{X}\in E\right\} = \lim_{N\rightarrow\infty} \frac{N_E}{N} 
  \text{~~(frequentist~definition)}
\end{equation}
```
where $N$ is the total number of experimental trials and $N_E$ is the number of
trial outcomes that fall within $E$. To tally the sample score, it's relatively common to use a binary
**indicator function** defined as 

$$\mathbf{1}_E(x) = \begin{cases*}1 & if $x \in E$ \\ 0 & otherwise.\end{cases*}$$


This definition of probability is sometimes awkward since it invokes a limit with
infinitely repeated experiments. In practice we satisfy ourselves with
"sufficiently large $N$", and there are a number of tools to help
judge how large is "sufficient". There are, however, situations where
those tools fail, resulting in bad frequentist estimations.




### Bayesian Interpretation {#bayesian}

When a random variable is not connected to a direct experimental measurement, it can
be associated with the **Bayesian interpretation** where probability is
defined as *degree of belief* or confidence or certainty. We will still
use the word "outcomes" when referring to the hypothetical
possibilities, but we have no direct way to observe them, so we must
make inferences from indirect evidence. In Bayesian
statistics, we are obliged to specify a *prior probability* that
quantifies our initial confidence in the outcome. The prior
probability is then incrementally adjusted by accounting for indirect
evidence or information.

There is not a firm separation between frequentist and Bayesian
interpretations. Both are consistent with the modern mathematical
framework of probability theory. In this course we will primarily
adhere to frequentist methods and interpretations.


:::{.example title="Height Measuring Experiment"}
Suppose the random variable $\mathbf{X}$ symbolizes the
height of a randomly selected person in a community. This implies
an experiment (at least hypothetically) in which we choose a person
and measure them. If we measure the height in rounded centimeters,
then set of possible outcomes is the set of positive integers. Each
individual sample is a specific integer. After measuring $N$ people,
we may find that all the samples satisfy $100\text{cm}<x_i<200\text{cm}$.
We therefore conclude from our data that (nearly) 100% of the population
is within this range.

The [tallest person ever measured](https://en.wikipedia.org/wiki/List_of_tallest_people)
was recorded as 272cm. As we go around measuring people, we are not likely to ever obtain a
sample greater than 272cm; this is a very low-probability outcome. But it *could* happen;
the probability is not zero. We can assign a probability to the outcome $\mathbf{X}\geq 272$,
but it won't be based on data from our experiment. It would be a *prior* probability based
on information (or intuition) that precedes the actual experiment.

:::


:::{.example title="Dice Roll"}
Suppose $\mathbf{D}$ represents rolling a 
six-sided die. We roll the dice $N$
times to get $N$ samples. We record each sample as a number, between 1
and 6. After each roll, we check to see if the sample $d$ matches a
specific event, say $d<4$. When this happens we call it a "success".
After $N$ trials with $N_s$ successes, we estimate the probability of
success as $\hat{p}=N_s/N$. If the die is perfectly balanced so that all outcomes are
equally likely, then we expect the probability to converge to $1/2$. @Tbl:dice_rolls
shows successive probability estimations for ten sample throws. You can see
that the estimation doesn't get very close to 0.5. Continuing to 10,000 repetitions,
we get an estimate of 0.5021, which is closer but still not exact. The remainder of
this text should give you an intimate understanding of estimation error, ways to
reduce it, and the seductive traps that accompany it.

| Trial $N$ | 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       |
|-----------------|----------|----------|----------|----------|----------|----------|----------|----------|----------|----------|
| $d$    | 1 | 3 | 6 | 2 | 3 | 2 | 4 | 6 | 1 | 5 |
| $\mathbf{1}_E(d)$   | 1        | 1        | 0        | 1        | 1        | 1        | 0        | 0        | 1        | 0        |
| $N_E$     | 1        | 2        | 2        | 3        | 4        | 5        | 5        | 5        | 6        | 6        |
| $\hat{p}$ | 1.00     | 1.00     | 0.67     | 0.75     | 0.80     | 0.83     | 0.71     | 0.62     | 0.67     | 0.60     |

Table: Ten rolls of a fair die, and the running estimate $\hat{p}$ of $\Pr(d<4)$. {#tbl:dice_rolls}

:::

## Probability Algebra {#probabilityalgebra}

Probability theory is intimately related to set theory. A
random variable $\mathbf{X}$ is associated with a set of distinct outcomes
called the **sample space**, $\mathcal{U}_X$. Every experimental trial
results in a single element drawn from the sample space.
For any outcome $x\in \mathcal{U}_X$,
the corresponding singleton set $\{x\}$ is called an **elementary event**. We can define an
**event** $E$ as a union of elementary events satisfying a proposition $\phi(x)$. 
In set builder notation, $E=\{x\in\mathcal{U}_X\,:\,\phi(x)\}$.
The **event space** $\Omega_X$
is a set containing all elementary events along with all unions of elementary events.
For completeness, $\Omega_X$ also contains the empty set, $\emptyset$.



### Event Probabilities {#eventprobabilities}

Given an event $E\in \Omega_X$, $\Pr(E)$ denotes the probability that a sample
from $\mathbf{X}$ is an outcome in $E$. A **probability distribution** is a
function that assigns $\Pr(E)$ to every event $E\in\Omega_X$; Chapter 2 defines this
concept more precisely as a probability measure $\mu(E)$. 

Elementary events have the property of
being mutually exclusive, i.e. if $e_1$ and $e_2$ are elementary events, then
$\Pr\left(e_1 \cup e_2\right)=\Pr\left(e_1\right)+\Pr\left(e_2\right)$. In general 
an event $E=\bigcup_i e_i$ where $e_i$ is a finite (or countable) collection of
elementary events. Then $\Pr\left(E\right)=\sum_i \Pr\left(e_i\right)$. In words,
the event's probability is the sum of the elementary event probabilities that 
comprise the event. From this point we can obtain some basic properties. For any
events $A,B\in\Omega_X$:

$$\begin{aligned}
 \Pr\left(A\right) & \geq 0 &  \text{non-negativity} \\
 \Pr\left(\emptyset\right) & = 0 &  \text{empty set} \\
 \Pr\left(\mathcal{U}_X\right) & = 1 &  \text{totality} \\
 \Pr\left(A\right) & \leq \Pr\left(B\right) \text{~if~} A\subseteq B &  \text{subset} \\
 \Pr\left(E\right)+\Pr\left(E^c\right) & = 1 & \text{complement} \\
 \Pr\left(A \cup B\right) & = \Pr\left(A\right) + \Pr\left(B\right) - \Pr\left(A\cap B\right) &  \text{union} 
\end{aligned}
$$

It is easy to prove each of the above properties using set theory and 
elementary events (the proofs are also a good exercise). 

Next we review some important definitions. Two events $A$ and $B$
in $\Omega_X$ can have the following basic relationships:

* **Mutually Exclusive:** $A \cap B = \emptyset$.
  Then $\Pr(A \cup B) = \Pr(A) + \Pr(B)$.
* **Independent:** if $\Pr(A \cap B) = \Pr(A)\Pr(B)$.
* **Conditional Probability:** $\Pr(A\,\left| B\right.)=\Pr(A\cap B)/\Pr(B)$.

All elementary events are by definition mutually exclusive. A pair of events
with nonzero probabilities cannot be both independent and mutually exclusive.

### Multiple Random Variables {#multiplerandomvariables}

When jointly considering two random variables $\mathbf{X}$ and $\mathbf{Y}$,
they can be combined into a joint variable $\left(\mathbf{X},\mathbf{Y}\right)$,
very much like a vector. The joint sample space is
$\mathcal{U}_{XY}=\mathcal{U}_X\times\mathcal{U}_Y$, the set of ordered pairs of
outcomes. [The joint event space $\Omega_{XY}$ contains every set of such pairs.
Among them are the **product events** $E_X\times E_Y$ with $E_X\in\Omega_X$ and
$E_Y\in\Omega_Y$. A product event is also called a **rectangle**, defined formally
as $(E_X,E_Y) = \left\{(e_x,e_y) : e_x \in E_X, e_y \in E_y\right\}$.

The joint probability distribution assigns a probability $\Pr(E)$ to each event
$E\in \Omega_{XY}$. In the context of a joint distribution, the
separated distributions [$\Pr(\mathbf{X}\in E_X)$ and $\Pr(\mathbf{Y}\in E_Y)$]{.draft} are called the 
**marginal distributions**. Usually we can extract the marginal distributions
if the joint distribution is given. Two random variables are **independent** 
if $\Pr\left((E_X,E_Y)\right)=\Pr(\mathbf{X}\in E_X)\Pr(\mathbf{Y}\in E_Y)$ for every
product event. 

:::{.example title="Joint and Marginal Coin Toss Events"}

Let $\mathbf{X}$ and $\mathbf{Y}$ correspond to two coin tosses 
with $\mathcal{U}_X=\mathcal{U}_Y=\{H,T\}.$ Each random variable 
has event space $\Omega_X=\Omega_Y=\left\{\emptyset, \{H\}, \{T\}, \{H,T\}\right\}$. 
The joint event space $\Omega_{XY}$ contains the product events listed in 
@tbl:coin_joint_events, among other events.

| Event             | Description                                                  |
|-------------------|--------------------------------------------------------------|
| $\emptyset$       | No outcome for either coin                                   |
| $(\{H\},\{H\})$   | $\mathbf{X}$ and $\mathbf{Y}$ both heads                     |
| $(\{T\},\{H\})$   | $\mathbf{X}$ is tails, $\mathbf{Y}$ is heads                 |
| $\dots$           | $\dots$                                                      |
| $(\{H\},\{H,T\})$ | $\mathbf{X}$ is heads, $\mathbf{Y}$ is either heads or tails |
| $(\{T\},\{H,T\})$ | $\mathbf{X}$ is tails, $\mathbf{Y}$ is either heads or tails |
| $(\{H,T\},\{H\})$ | $\mathbf{X}$ is either heads or tails, $\mathbf{Y}$ is heads |
| $(\{H,T\},\{T\})$ | $\mathbf{X}$ is either heads or tails, $\mathbf{Y}$ is tails |
| $(\{H,T\},\{H,T\})$ | $\mathbf{X}$ is either heads or tails, $\mathbf{Y}$ is either heads or tails |

Table: Product events in the joint event space of two coin tosses. {#tbl:coin_joint_events}

Embedded within $\Omega_{XY}$ are the marginal event spaces. 
@Tbl:coin_marginal_events shows events that are indifferent to $\mathbf{Y}$.
We say that $\mathbf{Y}$ is **marginalized** because it's been
rendered irrelevant:

| Event             | Description                                                  |
|-------------------|--------------------------------------------------------------|
| $\emptyset$       | No outcome for either coin                                   |
| $(\{H\},\{H,T\})$ | $\mathbf{X}$ is heads, $\mathbf{Y}$ is either heads or tails |
| $(\{T\},\{H,T\})$ | $\mathbf{X}$ is tails, $\mathbf{Y}$ is either heads or tails |
| $(\{H,T\},\{H,T\})$ | $\mathbf{X}$ is either heads or tails, $\mathbf{Y}$ is either heads or tails |

Table: Joint events that are indifferent to $\mathbf{Y}$. {#tbl:coin_marginal_events}

The distribution of these events is equal to the marginal distribution of $\mathbf{X}$. 
After a variable is marginalized we need no longer speak of it, so the $\mathbf{Y}$
dimension can just be cut out from the marginal events, leaving $\mathbf{X}$.
:::


:::{.example title="Independent Coin Tosses"}

Let $\mathbf{X}$ and $\mathbf{Y}$ correspond to two coin tosses 
with $\mathcal{U}_X=\mathcal{U}_Y=\{H,T\}.$ Each random variable 
has event space $\Omega_X=\Omega_Y=\left\{\emptyset, \{H\}, \{T\}, \{H,T\}\right\}$. 
The joint probability distribution is given in @tbl:coin_joint_probability.

| Event               | Probability |
|---------------------|-------------|
| $\emptyset$         | 0           |
| $(\{H\},\{H\})$     | 0.25        |
| $(\{T\},\{H\})$     | 0.25        |
| $(\{H\},\{T\})$     | 0.25        |
| $(\{T\},\{T\})$     | 0.25        |
| $(\{H\},\{H,T\})$   | 0.5         |
| $(\{T\},\{H,T\})$   | 0.5         |
| $(\{H,T\},\{H\})$   | 0.5         |
| $(\{H,T\},\{T\})$   | 0.5         |
| $(\{H,T\},\{H,T\})$ | 1.0         |

Table: Joint probabilities of two independent fair coin tosses. {#tbl:coin_joint_probability}

You can verify that the joint probabilities equal the product of the
marginals, for instance 
$\Pr\left((\{H\},\{T\})\right)=\Pr\left((\{H\},\{H,T\})\right)\Pr\left((\{H,T\},\{T\})\right)=\Pr(\mathbf{X}=H)\Pr(\mathbf{Y}=T)$.
Therefore $\mathbf{X}$ and $\mathbf{Y}$ are independent.

:::


### Discrete Probability Mass {#discreteprobabilitymass}

A random variable is of the **discrete** type if its elementary events
are **countable**. A set is countable if its elements can be ordered so
that there is one "first" element, and every element has a unique
"next" element. Every finite set is countable. A non-finite set is
countable if there is an algorithm to count its elements (the algorithm
runs forever but reaches every element).

For every outcome $u\in \mathcal{U}_{X}$, there is an associated
probability 

```{=latex}
\begin{equation}
 p_{X}(u) \triangleq \Pr\left(\mathbf{X} = u\right)
\end{equation}
```
Note that the notation $\mathbf{X} = u$ means the same thing as
$\mathbf{X}\in \{u\}$, where $\{u\}$ is the elementary event
corresponding to outcome $u$.

Since the elements of $\mathcal{U}_{X}$ are countable, they can
be arranged in a sensible order and enumerated as outcome 1, 2, 3, and so
on\footnote{We start from 1 to be consistent with array indexing in Julia programming exmaples.}. 
When so ordered, the outcome probabilities are arranged as a
vector, called the **probability mass vector** $\vec{p}_{X}$. The
individual elements of $\vec{p}_{X}$ are written as $p_{X,i}$ 
where $i$ is a positive integer. When there is no risk of 
ambiguity, we may also indicate the elements more simply as $p_i$.

Altogether, the vector $\vec{p}_{X}$ constitutes a **probability
distribution**, meaning it reports the probability for every elementary
event, and therefore generates the probability for any event in 
$\Omega_X$.

:::{.example title="Dice Roll"}
Let $\mathbf{X}$ represent the integer result of a single dice roll. The possible
outcomes are $\mathcal{U}_X=\left\{1,2,3,4,5,6\right\}$. The elementary
events are $\{1\}$, $\{2\}$, $\{3\}$, $\{4\}$, $\{5\}$, $\{6\}$. The
complete event space $\Omega_X$ contains all unions of elementary events.
For example, the event "$\mathbf{X}$ is odd" is the set $\{1,3,5\}$. The event
"$\mathbf{X}<4$" is the set $\{1,2,3\}$. In total there are $2^6=64$ events in
$\Omega_X$.
:::


:::{.example title="Rolling Two Dice"}

Previously we considered a single dice roll. If we roll a pair of dice,
call them $\mathbf{A}$ and $\mathbf{B}$, the elementary events are all
ordered pairs of the dice values $(a,b)$, with $a$ and $b$ each taking
a value between 1 and 6, making 36 mutually exclusive outcomes in $\mathcal{U}_X$,
i.e. 36 elementary events. The event space $\Omega_X$ contains $2^{36}$ 
combinations of elementary events.
:::


:::{.example title="Marginalization"} 

In the dice roll example, suppose $E$ is the
event that $\mathbf{A}=1$, ignoring the outcome on $\mathbf{B}$. Since
$\mathbf{B}$ could be anything from 1 to 6, $E$ contains the six
elementary events where $\mathbf{A}=1$: (1,1), (1,2), up to (1,6). 
In this example, $\Omega$ includes events for two random
variables, but the event $E$ is only concerned with one variable. In
this situation, the ignored variable is said to be
**marginalized**. The event specified for $\mathbf{A}$ carries along
all the non-contradicting outcomes for $\mathbf{B}$.

:::


:::{.example title="Elementary Events, Outcomes, and Probability Mass"}
We roll two dice, named $A$ and $B$. The
individual dice correspond to random variables $\mathbf{A}$ and
$\mathbf{B}$, each having integer outcomes between 1 and 6. Taken
together, the elementary events are the 36 distinct ordered pairs $(a,b)$.
If the dice are identical and fair, then their probability distribution is
**uniform**, meaning $p_i=1/36$ for each elementary event.

Now suppose the *events* of interest are the sum of the two dice, $s=\mathbf{A}+\mathbf{B}$, 
which can be any integer between 2 and 12. Each sum event corresponds to a union of
elementary events listed in @tbl:two_dice_sums. The probability for each event is the sum of
its constituent elementary probabilities.

| Event $S_j=\mathbf{A}+\mathbf{B}$  | Elementary Events $(a,b)$                                            | $\Pr\left(S_j\right)$ |
|------------------------------|--------------------------------------------------|---------------|
| 2           | $(1,1)$                                                                         | 1/36 |
| 3           | $(1,2)$\, $(2,1)$                                                           | 2/36 |
| 4           | $(1,3)$\, $(2,2)$\, $(3,1)$                                             | 3/36 |
| 5           | $(1,4)$\, $(2,3)$\, $(3,2)$\, $(4,1)$                               | 4/36 |
| 6           | $(1,5)$\, $(2,4)$\, $(3,3)$\, $(4,2)$\, $(5,1)$                 | 5/36 |
| 7           | $(1,6)$\, $(2,5)$\, $(3,4)$\, $(4,3)$\, $(5,2)$\, $(6,1)$   | 6/36 |
| 8           | $(2,6)$\, $(3,5)$\, $(4,4)$\, $(5,3)$\, $(6,2)$                 | 5/36 |
| 9           | $(3,6)$\, $(4,5)$\, $(5,4)$\, $(6,3)$                               | 4/36 |
| 10          | $(4,6)$\, $(5,5)$\, $(6,4)$                                             | 3/36 |
| 11          | $(5,6)$\, $(6,5)$                                                           | 2/36 |
| 12          | $(6,6)$                                                                         | 1/36 |

Table: Outcomes composed of elementary events with two dice. {#tbl:two_dice_sums}

Based on the above analysis, we can re-package the experiment into a random variable $\mathbf{S}$ 
defined as the sum $\mathbf{A}+\mathbf{B}$. The outcomes for $\mathbf{S}$ are the integers $2,\,\dots,\,12$ 
and the probability distribution is the vector $\vec{q}$ for which $q_j=\Pr\left(S_j\right)$.
:::






## Key Terms {#randomvariableskeyterms}

Random Variable $\mathbf{X}$

: Symbol representing a random experiment. 

  
Sample $x$

: The observed or recorded result from a single random experiment. 

Sample Space $\mathcal{U}_X$

: The set of all possible sample values that may be recorded from a random experiment. 


Outcome $\mathbf{X}=x$

: The actual result of a single random trial, or the actual truth of a
  proposition.

Event $E$

: A set of outcomes to which a probability can be assigned.

Elementary Event $\{x\}$

: A singleton event containing one outcome $x\in \mathcal{U}_X$.

Event Space $\Omega_X$

: The set of all events associated with $\mathbf{X}$, often the power set
of $\mathcal{U}_X$.

Probability $\Pr(E)$

: The relative frequency of observing a particular event $E$ (frequentist
  interpretation); or degree of belief/confidence in the truth of $E$ (Bayesian
  interpretation). 
  
Probability Distribution

: A function that reports the probability for every event $E\in\Omega_X$.
  
Probability Mass Vector $\vec{p}$

: A vector that expresses a discrete probability distribution function. The
  vector's length is equal to the number of outcomes in the sample
  space, which could be countably infinite.
  

Indicator Function $\mathbf{1}_E(x)$

: A binary function that returns 1 if $x\in E$, otherwise returns 0.
