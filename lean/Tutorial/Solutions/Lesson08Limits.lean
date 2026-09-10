/-
Solutions to Lesson 8.
-/
import Mathlib.Tactic
import Mathlib.Analysis.SpecificLimits.Basic

open Filter Topology

namespace Tutorial.Solutions.Lesson08

example (u : ℕ → ℝ) (a b : ℝ) (ha : Tendsto u atTop (𝓝 a))
    (hb : Tendsto u atTop (𝓝 b)) : b = a := tendsto_nhds_unique hb ha

example (u : ℕ → ℝ) (a : ℝ) (h : Tendsto u atTop (𝓝 a)) :
    Tendsto (fun n => u (n + 2)) atTop (𝓝 a) := h.comp (tendsto_add_atTop_nat 2)

example (u : ℕ → ℝ) (h : CauchySeq u) : ∃ a, Tendsto u atTop (𝓝 a) :=
  cauchySeq_tendsto_of_complete h

-- The central step of Banach's theorem: one sequence, described twice.
example (f : ℝ → ℝ) (hcont : Continuous f) (u : ℕ → ℝ) (a : ℝ)
    (hu : Tendsto u atTop (𝓝 a)) (hstep : ∀ n, u (n + 1) = f (u n)) : f a = a := by
  have hshift : Tendsto (fun n => u (n + 1)) atTop (𝓝 a) :=
    hu.comp (tendsto_add_atTop_nat 1)
  have hfa : Tendsto (fun n => u (n + 1)) atTop (𝓝 (f a)) := by
    simp only [hstep]
    exact (hcont.tendsto a).comp hu
  exact tendsto_nhds_unique hfa hshift

end Tutorial.Solutions.Lesson08
