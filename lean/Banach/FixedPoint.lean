/-
Banach's fixed point theorem, proved from the definition of a contraction.

Mathlib already has this as `ContractingWith.exists_fixedPoint`, and in real work
that is what one would call. It is written out here instead, because the point of
the file is the argument, not the result: a contraction shortens every distance by
at least a constant factor, so the orbit of any point has geometrically shrinking
steps, so it is Cauchy, so it converges — and the limit cannot help being fixed.

What is borrowed from Mathlib is the analysis that has nothing to do with
contractions: that a geometric bound on consecutive terms makes a sequence Cauchy,
and that Cauchy sequences in a complete space converge.
-/
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Topology.MetricSpace.Lipschitz

open Filter Topology

namespace Banach

/-!
Throughout, `f` maps a metric space to itself and `K < 1` is the factor by which
it contracts. `K` is a plain real rather than a `ℝ≥0`, so that `0 ≤ K` has to be
carried around explicitly; that is the honest form of the hypothesis, and it keeps
the statements readable to someone who does not know `NNReal`.
-/

variable {α : Type*} [MetricSpace α]

/-- A contraction is Lipschitz, and Lipschitz maps are continuous. This is the only
place the `0 ≤ K` hypothesis is genuinely needed rather than merely convenient:
`LipschitzWith` is indexed by a nonnegative real. -/
theorem continuous_of_contraction {f : α → α} {K : ℝ} (hK₀ : 0 ≤ K)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y) : Continuous f := by
  have hlip : LipschitzWith K.toNNReal f := by
    apply LipschitzWith.of_dist_le_mul
    intro x y
    rw [Real.coe_toNNReal K hK₀]
    exact hf x y
  exact hlip.continuous

/-- Consecutive points of an orbit get closer geometrically:
`dist (fⁿ x₀) (fⁿ⁺¹ x₀) ≤ dist x₀ (f x₀) · Kⁿ`.

This is the whole content of the theorem. Everything after it is bookkeeping about
limits. The right-hand side is written `C * K ^ n` rather than the more natural
`K ^ n * C` only to match the shape Mathlib's geometric-series lemmas expect. -/
theorem dist_iterate_succ {f : α → α} {K : ℝ} (hK₀ : 0 ≤ K)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y) (x₀ : α) (n : ℕ) :
    dist (f^[n] x₀) (f^[n + 1] x₀) ≤ dist x₀ (f x₀) * K ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
    -- Peel the outermost `f` off both iterates, so the contraction hypothesis applies.
    -- Rewriting the goal rather than a `calc` step matters: the goal's right-hand side
    -- mentions no iterate, so there is nothing there for `rw` to disturb.
    rw [Function.iterate_succ_apply' f n, Function.iterate_succ_apply' f (n + 1)]
    calc dist (f (f^[n] x₀)) (f (f^[n + 1] x₀))
        ≤ K * dist (f^[n] x₀) (f^[n + 1] x₀) := hf _ _
      _ ≤ K * (dist x₀ (f x₀) * K ^ n) := mul_le_mul_of_nonneg_left ih hK₀
      _ = dist x₀ (f x₀) * K ^ (n + 1) := by ring

/-- **Banach's fixed point theorem**, in the form that is actually useful: the
fixed point exists, the orbit of *any* starting point finds it, and the `n`-th
iterate is already within `dist x₀ (f x₀) · Kⁿ / (1 - K)` of it.

That last clause is what makes the theorem a numerical method rather than an
existence statement — it is computable from the first step alone, before anything
about the limit is known. -/
theorem exists_fixedPoint [CompleteSpace α] {f : α → α} {K : ℝ} (hK₀ : 0 ≤ K) (hK₁ : K < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y) (x₀ : α) :
    ∃ a, f a = a ∧ Tendsto (fun n => f^[n] x₀) atTop (𝓝 a) ∧
      ∀ n, dist (f^[n] x₀) a ≤ dist x₀ (f x₀) * K ^ n / (1 - K) := by
  -- The orbit, and the geometric bound on its steps.
  have hstep : ∀ n, dist (f^[n] x₀) (f^[n + 1] x₀) ≤ dist x₀ (f x₀) * K ^ n :=
    dist_iterate_succ hK₀ hf x₀
  -- Geometrically shrinking steps make a sequence Cauchy; completeness gives a limit.
  have hcauchy : CauchySeq fun n => f^[n] x₀ :=
    cauchySeq_of_le_geometric K (dist x₀ (f x₀)) hK₁ hstep
  obtain ⟨a, ha⟩ := cauchySeq_tendsto_of_complete hcauchy
  refine ⟨a, ?_, ha, fun n => ?_⟩
  · -- The limit is fixed. Two descriptions of the same shifted sequence: it converges
    -- to `a` because dropping the first term changes no limit, and to `f a` because
    -- `f` is continuous. A limit is unique, so `f a = a`.
    have hshift : Tendsto (fun n => f^[n + 1] x₀) atTop (𝓝 a) :=
      ha.comp (tendsto_add_atTop_nat 1)
    have hiter : (fun n => f^[n + 1] x₀) = fun n => f (f^[n] x₀) :=
      funext fun n => Function.iterate_succ_apply' f n x₀
    have hfa : Tendsto (fun n => f^[n + 1] x₀) atTop (𝓝 (f a)) := by
      rw [hiter]
      exact ((continuous_of_contraction hK₀ hf).tendsto a).comp ha
    exact tendsto_nhds_unique hfa hshift
  · -- The error bound is the geometric tail, summed.
    exact dist_le_of_le_geometric_of_tendsto K (dist x₀ (f x₀)) hK₁ hstep ha n

/-- A contraction cannot fix two points: it would have to shorten the distance
between them, and there is nothing shorter than zero to shorten it to.

Note what is *not* assumed here — neither completeness nor nonemptiness. Uniqueness
is cheap and unconditional; only existence needs the space to be complete. -/
theorem fixedPoint_unique {f : α → α} {K : ℝ} (hK₁ : K < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y) {a b : α} (hfa : f a = a) (hfb : f b = b) :
    a = b := by
  have h : dist a b ≤ K * dist a b :=
    calc dist a b = dist (f a) (f b) := by rw [hfa, hfb]
      _ ≤ K * dist a b := hf a b
  have hpos : 0 < 1 - K := by linarith
  -- `linarith` treats `K * dist a b` as an atom, which is all the linearity needed.
  have hle : (1 - K) * dist a b ≤ 0 := by linarith
  have hzero : dist a b ≤ 0 := by nlinarith [dist_nonneg (x := a) (y := b)]
  exact eq_of_dist_eq_zero (le_antisymm hzero dist_nonneg)

/-- The textbook statement: a contraction of a nonempty complete metric space has
exactly one fixed point. -/
theorem existsUnique_fixedPoint [Nonempty α] [CompleteSpace α] {f : α → α} {K : ℝ}
    (hK₀ : 0 ≤ K) (hK₁ : K < 1) (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    ∃! a, f a = a := by
  obtain ⟨a, hfa, -, -⟩ := exists_fixedPoint hK₀ hK₁ hf (Classical.arbitrary α)
  exact ⟨a, hfa, fun b hb => fixedPoint_unique hK₁ hf hb hfa⟩

end Banach
