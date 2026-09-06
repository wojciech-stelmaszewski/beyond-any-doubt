---
title: The Euler product, and why it is not a coincidence
description: >-
  A first post that exercises the whole pipeline: aligned derivations, numbered
  equations, and cross-references that actually resolve.
published: 2026-09-05
tags: ["analytic number theory", "zeta function"]
---

Euler's product formula is usually presented as a startling identity. It is more
useful to read it as a restatement of unique factorisation, written in a language
where analysis can get at it.

## The statement

For $\operatorname{Re}(s) > 1$,

$$
\begin{equation}\label{eq:euler-product}
\zeta(s) = \sum_{n=1}^{\infty} \frac{1}{n^{s}} = \prod_{p\ \mathrm{prime}} \frac{1}{1 - p^{-s}}.
\end{equation}
$$

Both sides converge absolutely there, which is what makes the rearrangement below
legitimate rather than merely suggestive.

## Where the product comes from

Expand each factor as a geometric series and multiply out:

$$
\begin{align}
\prod_{p \le N} \frac{1}{1 - p^{-s}}
  &= \prod_{p \le N} \left( 1 + p^{-s} + p^{-2s} + \cdots \right) \\
  &= \sum_{\substack{n \ge 1 \\ p \mid n \implies p \le N}} \frac{1}{n^{s}}.
\end{align}
$$

The second line is unique factorisation in disguise: every $n$ whose prime factors
are all at most $N$ appears exactly once, because it has exactly one factorisation.

Letting $N \to \infty$ recovers $\eqref{eq:euler-product}$. The error term is bounded by
$\sum_{n > N} n^{-\sigma}$ with $\sigma = \operatorname{Re}(s) > 1$, which vanishes.

## The consequence worth remembering

Taking $s \to 1^{+}$ makes the left-hand side of $\eqref{eq:euler-product}$ diverge. A
finite set of primes would give a finite product, so the primes must be infinite —
Euler's analytic proof of Euclid's theorem.

More precisely, comparing growth rates gives

$$
\begin{equation}\label{eq:mertens}
\sum_{p \le x} \frac{1}{p} = \log\log x + M + O\!\left(\frac{1}{\log x}\right),
\end{equation}
$$

where $M \approx 0.2615$ is the Meissel–Mertens constant. Estimate
$\eqref{eq:mertens}$ says the primes thin out, but only just: slowly enough that their
reciprocals still diverge.
