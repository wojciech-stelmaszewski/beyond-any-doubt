/-
# Lesson 8 — Limits, completeness, and the last step of the theorem

The final piece of vocabulary. After this lesson `Banach/FixedPoint.lean` should
read as ordinary mathematics, and the last exercise here is its central step.
-/
import Mathlib.Tactic
import Mathlib.Analysis.SpecificLimits.Basic

open Filter Topology

namespace Tutorial.Lesson08

/-!
## How Mathlib writes "the sequence `u` converges to `a`"

  `Tendsto u atTop (𝓝 a)`

Three parts. `u` is the sequence. `atTop` describes `n` growing without bound.
`𝓝 a` — typed `\nhds` — describes closeness to `a`. Both are *filters*, and
filters are a genuine subject, but none of it is needed to use this: read the
whole phrase as "u(n) → a".

If you want reassurance that it is the definition you already know, here it is
spelled out — the familiar epsilon and N:
-/

#check @Metric.tendsto_atTop

/-!
## Three facts about limits, which is all the real proof uses

First, a constant sequence converges to its constant.
-/

example (a : ℝ) : Tendsto (fun _ : ℕ => a) atTop (𝓝 a) := tendsto_const_nhds

/-!
Second, and this is the one that does the work: **limits are unique**. If a
single sequence converges to `a` and also to `b`, then `a = b`.

The trick in Banach's theorem is to describe one sequence two different ways and
then apply this.
-/

example (u : ℕ → ℝ) (a b : ℝ) (ha : Tendsto u atTop (𝓝 a))
    (hb : Tendsto u atTop (𝓝 b)) : a = b := tendsto_nhds_unique ha hb

/-!
Third, dropping the first term changes nothing. `tendsto_add_atTop_nat 1` says
`n ↦ n + 1` also grows without bound, and `.comp` composes the two limits.
-/

example (u : ℕ → ℝ) (a : ℝ) (h : Tendsto u atTop (𝓝 a)) :
    Tendsto (fun n => u (n + 1)) atTop (𝓝 a) := h.comp (tendsto_add_atTop_nat 1)

/-!
## Continuity, as a statement about limits

`Continuous f` gives `f`'s behaviour at every point via `Continuous.tendsto`:
`hcont.tendsto a : Tendsto f (𝓝 a) (𝓝 (f a))`. Composed with a sequence
converging to `a`, it says `f (u n) → f a` — which is exactly the licence to
move `f` inside a limit.
-/

example (f : ℝ → ℝ) (hcont : Continuous f) (u : ℕ → ℝ) (a : ℝ)
    (hu : Tendsto u atTop (𝓝 a)) : Tendsto (fun n => f (u n)) atTop (𝓝 (f a)) :=
  (hcont.tendsto a).comp hu

/-!
## Cauchy sequences and completeness

A sequence is `CauchySeq` when its terms eventually get arbitrarily close *to
each other* — a condition that mentions no limit, and so can be checked without
knowing one.

Completeness is the promise that such a sequence has a limit after all. It is an
instance, `[CompleteSpace α]`, and `ℝ` has one. The lemma that cashes it in:

  `cauchySeq_tendsto_of_complete : CauchySeq u → ∃ a, Tendsto u atTop (𝓝 a)`

Note the `∃`: completeness hands you a point, which is why the real proof uses
`obtain ⟨a, ha⟩ :=` at that line. The fixed point is never constructed by
formula; it arrives as the witness of an existential.
-/

#check @cauchySeq_tendsto_of_complete

/-!
## The bridge from Lesson 5 to here

The one Mathlib lemma that connects a geometric bound to Cauchyness:

  `cauchySeq_of_le_geometric r C (hr : r < 1) (∀ n, dist (u n) (u (n+1)) ≤ C * r ^ n)`

Compare its shape with what Lesson 5 proved by induction. That is the entire
reason `dist_iterate_succ` states its bound as `C * K ^ n` rather than the more
natural `K ^ n * C`: to fit this lemma without an intervening `ring`.
-/

#check @cauchySeq_of_le_geometric

/-!
## Exercises

The last one is the heart of Banach's theorem. Everything needed is above.
-/

-- Limits are unique; one lemma.
example (u : ℕ → ℝ) (a b : ℝ) (ha : Tendsto u atTop (𝓝 a))
    (hb : Tendsto u atTop (𝓝 b)) : b = a := by sorry

-- Shift by two rather than one.
example (u : ℕ → ℝ) (a : ℝ) (h : Tendsto u atTop (𝓝 a)) :
    Tendsto (fun n => u (n + 2)) atTop (𝓝 a) := by sorry

-- Completeness gives a limit. Unpack the existential and hand it back.
example (u : ℕ → ℝ) (h : CauchySeq u) : ∃ a, Tendsto u atTop (𝓝 a) := by sorry

-- The central step of the whole theorem. A sequence defined by `u (n+1) = f (u n)`
-- converges to `a`; show `a` is a fixed point.
--
-- Sketch: the shifted sequence `n ↦ u (n + 1)` converges to `a`, because shifting
-- changes no limit. It also converges to `f a`, because it *is* `n ↦ f (u n)` and
-- `f` is continuous. Limits are unique.
example (f : ℝ → ℝ) (hcont : Continuous f) (u : ℕ → ℝ) (a : ℝ)
    (hu : Tendsto u atTop (𝓝 a)) (hstep : ∀ n, u (n + 1) = f (u n)) : f a = a := by
  sorry

/-!
## Now read the real thing

Open `Banach/FixedPoint.lean`. Every construction in it has appeared here:

* the three bracket kinds and `[MetricSpace α]` — Lesson 7
* `hf x y` and `hf _ _`, applying a `∀` — Lesson 2
* `⟨…⟩`, `obtain`, `refine ⟨a, ?_, ha, fun n => ?_⟩` — Lesson 3
* `rw`, `calc`, and why the first draft's `rw` misfired — Lesson 4
* `induction … with | zero | succ n ih`, and `f^[n]` — Lesson 5
* `ring`, `linarith`, `nlinarith`, and the `K * d`-as-an-atom trick — Lesson 6
* `dist_nonneg`, `eq_of_dist_eq_zero` — Lesson 7
* `Tendsto`, `CauchySeq`, `tendsto_nhds_unique` — this lesson

The only things left unexplained are the two Mathlib lemmas that sum the
geometric series, and those are borrowed on purpose: they have nothing to do with
contractions.
-/

end Tutorial.Lesson08
