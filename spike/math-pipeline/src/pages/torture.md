---
title: Math torture test
layout: ../layouts/Spike.astro
---

# Math torture test

Inline: the map $f:\mathbb{R}\to\mathbb{R}$ with $\varepsilon>0$ and $\lVert x \rVert_{2}$.

Aligned block:

$$
\begin{align}
\zeta(s) &= \sum_{n=1}^{\infty} \frac{1}{n^{s}} \\
         &= \prod_{p\ \mathrm{prime}} \frac{1}{1-p^{-s}}
\end{align}
$$

Cases:

$$
\operatorname{sgn}(x) =
\begin{cases}
 1  & \text{if } x > 0, \\
 0  & \text{if } x = 0, \\
 -1 & \text{if } x < 0.
\end{cases}
$$

Matrix and large operators:

$$
A = \begin{pmatrix} a_{11} & a_{12} \\ a_{21} & a_{22} \end{pmatrix},
\qquad
\bigoplus_{i \in I} V_i,
\qquad
\underbrace{x + \cdots + x}_{n \text{ times}}
$$

Substack and nested fractions:

$$
\sum_{\substack{1 \le i \le n \\ i \ne j}} a_i
\qquad
\cfrac{1}{1+\cfrac{1}{1+\cfrac{1}{1+\ddots}}}
$$

Tagged equation:

$$
\int_{-\infty}^{\infty} e^{-x^{2}}\,dx = \sqrt{\pi} \tag{3.7}
$$

Labelled equation — `\label` needs a numbered environment, not a bare `$$`:

$$
\begin{equation}\label{eq:euler} e^{i\pi} + 1 = 0 \end{equation}
$$

Reference to it: $\eqref{eq:euler}$ — the whole point of document-scope rendering.

Forward reference, defined further down: $\eqref{eq:gauss}$.

$$
\begin{equation}\label{eq:gauss} \int_{-\infty}^{\infty} e^{-x^{2}}\,dx = \sqrt{\pi} \end{equation}
$$

Currency guard: this costs $50 to $100 in prose.
