---
title: Sensitive dependence, and what a solver can promise
description: >-
  A benchmark post that exercises the whole pipeline at once: callouts, numbered
  equations with cross-references, four interactive 2D charts, three rotatable
  WebGL scenes, and a point cloud of four hundred thousand states.
published: 2026-09-06
tags: ["dynamical systems", "numerical analysis"]
---

A differential equation promises less than it appears to. It fixes the future
completely — and yet, for some systems, knowing the present to forty decimal
places buys you only a few dozen units of time. This post works through where
that boundary sits, and it doubles as the page every part of this site is
measured against: every figure below is drawn in your browser, and every one of
them can be poked at.

## What determinism actually gives you

> [!definition] Definition 1.1
> An initial value problem is a vector field $f : \mathbb{R} \times \mathbb{R}^n \to \mathbb{R}^n$
> together with a state $x_0$, asking for a curve $x(t)$ with $x'(t) = f(t, x(t))$
> and $x(0) = x_0$.

The classical existence theorem costs almost nothing to state, and it is worth
being precise about what it does *not* say.

> [!theorem] Theorem 1.2 (Picard–Lindelöf)
> If $f$ is continuous in $t$ and Lipschitz in $x$ on a neighbourhood of
> $(0, x_0)$, then the initial value problem has a unique solution on some
> interval around $t = 0$.

Uniqueness is a statement about exact real numbers. It says two solutions from
the *same* point agree; it says nothing about two solutions from points a
billionth apart. That gap is the whole subject.

Start with a case where the gap stays closed. The logistic equation

$$
\begin{equation}\label{eq:logistic}
x' = r\,x\left(1 - \frac{x}{K}\right), \qquad r > 0,\ K > 0,
\end{equation}
$$

has every solution converging to $x = K$, whatever it starts from. Nearby
starts stay nearby, forever: the flow is <mark>contracting</mark>, and a solver's
early rounding error gets forgotten rather than amplified.

```figure
{ "chart": "slope-field", "caption": "Four solutions of the logistic equation over its direction field. Every trajectory is drawn toward the carrying capacity, so the four curves that begin far apart end indistinguishable. Zoom in near <i>t</i> = 0 to see how quickly the fastest one turns." }
```

The same picture in the phase plane, for a damped oscillator rather than a
logistic growth, shows the other classical ending: everything spirals into a
single point.

```figure
{ "chart": "phase-portrait", "caption": "Phase portrait of a damped oscillator, four initial states. The origin is a stable spiral, so the long-run answer does not depend on where you started — only on how long you are prepared to wait." }
```

## Where it breaks

Lorenz's system is the standard counterexample, and it is worth writing out
because its nonlinearity is so slight — two quadratic terms, nothing more:

$$
\begin{equation}\label{eq:lorenz}
x' = \sigma(y - x), \qquad
y' = x(\rho - z) - y, \qquad
z' = xy - \beta z,
\end{equation}
$$

with the usual $\sigma = 10$, $\rho = 28$, $\beta = 8/3$.

```figure
{ "scene": "lorenz-attractor", "caption": "A single trajectory of the Lorenz system \\eqref{eq:lorenz}, coloured by height. Drag it: the two wings lie in planes that meet at an angle, which no fixed viewpoint shows honestly." }
```

Sampling one long orbit densely enough turns the trajectory into a picture of
the attractor itself — the set the system settles onto, of which any particular
trajectory is only one thread.

```figure
{ "scene": "lorenz-cloud", "caption": "Four hundred thousand states along one orbit, coloured by speed. The pale outer rims are where the system moves fastest; the dark cores are where it lingers. Because the points blend rather than occlude, density reads as opacity." }
```

> [!conjecture] Open in general
> No general criterion decides, from the algebraic form of $f$ alone, whether a
> polynomial vector field in $\mathbb{R}^3$ has a strange attractor. Lorenz's own
> case took until 2002 to settle, and it was settled by computer-assisted proof.

Compare that with the surface swept out by the logistic solutions of
$\eqref{eq:logistic}$ as the initial condition varies. Every slice at fixed
$x_0$ is one solution curve, and the whole sheet is smooth, monotone and dull —
which is exactly the point.

```figure
{ "scene": "solution-surface", "caption": "The logistic solution surface <i>x</i>(<i>t</i>; <i>x</i>₀), height also mapped to colour. Rotate to look along the <i>t</i> axis: every slice funnels to the same value, which is contraction seen end-on." }
```

## The cost of a billionth

Take two Lorenz trajectories whose starting points differ by $10^{-9}$ in the
$x$ coordinate alone, and watch the distance between them.

```figure
{ "chart": "sensitive-dependence", "caption": "Separation of two trajectories that begin 10⁻⁹ apart, on a logarithmic axis. Growth is exponential — a straight line here — until the separation reaches the size of the attractor, after which the two states are simply unrelated. Both start on the attractor rather than at the usual (1, 1, 1); see the remark below. Hover the curve to read the separation at any time." }
```

> [!remark] Where the pair has to start
> Perturbing the usual initial state $(1, 1, 1)$ gives a different picture: the
> separation sits at $10^{-9}$ for a dozen time units before it grows at all.
> That plateau is not a bug. The point $(1,1,1)$ is not on the attractor, and a
> perturbation there begins aligned with a contracting direction, so it must
> rotate into an expanding one before anything happens. It is a fact about the
> starting point rather than about the system, which is why the figure discards
> forty time units of approach first.

The straight section is the content of the figure: on a log axis,
exponential growth is a line, and its slope is the leading Lyapunov exponent
$\lambda \approx 0.906$. So

$$
\begin{equation}\label{eq:horizon}
|\Delta(t)| \approx |\Delta(0)|\,e^{\lambda t}
\quad\Longrightarrow\quad
t_{\text{horizon}} \approx \frac{1}{\lambda}\log\frac{\text{tolerance}}{|\Delta(0)|}.
\end{equation}
$$

The logarithm in $\eqref{eq:horizon}$ is the bad news. Buying ten more decimal
places of initial accuracy buys about $10\log 10 / \lambda \approx 25$ more time
units of prediction — and then you are back where you started.

> [!counterexample] What this rules out
> Take $\Delta(0) = 10^{-16}$, the best a double-precision float can offer, and a
> tolerance of one unit. Then $\eqref{eq:horizon}$ gives $t_{\text{horizon}} \approx 41$.
> No integrator, however accurate, extends that: the limit is in the equation,
> not in the arithmetic.

## Where the exponential comes from

Nothing so far explains *why* the separation should grow exponentially rather
than, say, quadratically. The answer is that a small perturbation obeys its own
linear equation — the variational equation — whose coefficient matrix is the
Jacobian of the field, evaluated along the trajectory:

$$
\begin{equation}\label{eq:variational}
\dot{\delta} = J\bigl(x(t)\bigr)\,\delta,
\qquad
J =
\begin{pmatrix}
-\sigma  & \sigma & 0      \\
\rho - z & -1     & -x     \\
y        & x      & -\beta
\end{pmatrix}.
\end{equation}
$$

Discretise $\eqref{eq:variational}$ on the same grid the solver uses, write
$M_k$ for the one-step amplification $I + h\,J(x_k) + O(h^2)$, and stack the
perturbations at every step into one vector. The whole history then satisfies a
single linear system:

$$
\begin{equation}\label{eq:bidiagonal}
\begin{pmatrix}
I      &        &        &          &   \\
-M_1   & I      &        &          &   \\
       & -M_2   & I      &          &   \\
       &        & \ddots & \ddots   &   \\
       &        &        & -M_{n-1} & I
\end{pmatrix}
\begin{pmatrix}
\delta_1 \\ \delta_2 \\ \delta_3 \\ \vdots \\ \delta_n
\end{pmatrix}
=
\begin{pmatrix}
M_0\,\delta_0 \\ 0 \\ 0 \\ \vdots \\ 0
\end{pmatrix}.
\end{equation}
$$

The blanks are genuine zeros, and there are a great many of them: of the $n^2$
blocks in $\eqref{eq:bidiagonal}$ only $2n - 1$ are non-zero, two per row at
worst. A matrix this sparse is never assembled, let alone inverted. It is lower
triangular, so forward substitution solves it in one sweep — which is precisely
what running the solver forward in time *is*:

$$
\begin{equation}\label{eq:product}
\delta_n = M_{n-1} M_{n-2} \cdots M_1 M_0 \, \delta_0 .
\end{equation}
$$

So the amplification of an initial error is a *product* of matrices, one per
step. Products grow or shrink geometrically, and the average logarithmic growth
rate of $\|M_{n-1}\cdots M_0\|$ is the definition of the leading Lyapunov
exponent. The straight line in [the separation plot](#fig-sensitive-dependence)
is $\eqref{eq:product}$ seen on a log axis, and $\lambda \approx 0.906$ is its
slope.

This also settles what a better integrator can and cannot do. A higher-order
method computes each $M_k$ more accurately; it does not make the product
smaller. The exponent belongs to $J$, and $J$ belongs to the equation.

## What the integrator controls

None of this excuses a sloppy solver. Over the interval where prediction is
meaningful, the method's order is exactly what decides how much work a given
accuracy costs.

| Method | Order $p$ | Evaluations per step | Error at $h = 1/64$ |
| --- | ---: | ---: | ---: |
| Euler | 1 | 1 | $2.89 \times 10^{-3}$ |
| Heun | 2 | 2 | $1.51 \times 10^{-5}$ |
| RK4 | 4 | 4 | $1.85 \times 10^{-10}$ |

A method of order $p$ has global error $O(h^p)$, so on log–log axes each method
should trace a straight line of slope $p$. That is a claim worth checking rather
than repeating:

```figure
{ "chart": "convergence", "caption": "Global error at <i>t</i> = 1 for <i>x</i>′ = −<i>x</i>, against step size, on log–log axes. The three slopes come out at 1.00, 2.00 and 4.01 — the orders the methods are advertised to have. Note the vertical span: at the smallest step, RK4 is nine orders of magnitude more accurate than Euler." }
```

> [!remark] On choosing step sizes
> The step sizes above are $h = 1/n$ for integer $n$, which is not fussiness. An
> $h$ that does not divide the interval leaves the last step landing beside
> $t = 1$ rather than on it, and that mismatch in time is larger than the
> discretisation error being measured. The plot then shows noise, and the noise
> looks plausible enough to publish.

The three orders come out of a Taylor expansion that each method truncates at a
different place:

```js
// One RK4 step. The weights are chosen so the error terms through h⁴ cancel.
export function rk4Step(fn, t, state, h) {
  const k1 = fn(t, state);
  const k2 = fn(t + h / 2, add(state, k1, h / 2));
  const k3 = fn(t + h / 2, add(state, k2, h / 2));
  const k4 = fn(t + h, add(state, k3, h));
  return state.map((v, i) => v + (h / 6) * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]));
}
```

> [!proof] Why the slope is the order
> Write the global error as $E(h) = Ch^{p} + o(h^{p})$. Then
> $\log E(h) = \log C + p \log h + o(1)$, so a log–log plot of $E$ against $h$ is
> a line of slope $p$ with intercept $\log C$. Reading the slope off the figure
> therefore measures the order, and reading the intercept measures the constant.

## What to take away

1. **Uniqueness is not predictability.** Theorem 1.2 holds for the Lorenz system
   as much as for the logistic one; it simply does not say what you want.
2. **The horizon grows logarithmically.** By $\eqref{eq:horizon}$, precision is
   the expensive way to buy time, and it is the only way.
3. **Order still matters.** Within the horizon, the difference between Euler and
   RK4 is seven orders of magnitude for four times the work.

> A theory is the more impressive the greater the simplicity of its premises,
> the more different kinds of things it relates, and the more extended its area
> of applicability.
>
> — Einstein, on why two quadratic terms deserve this much attention

Everything above renders from about three kilobytes of figure recipes; the
trajectories are integrated in your browser rather than shipped as data. See
[the spike notes](https://github.com/wojciech-stelmaszewski) for the measurements
behind that choice.
