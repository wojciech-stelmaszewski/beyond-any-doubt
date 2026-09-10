/-
Solutions to Lesson 7.
-/
import Mathlib.Tactic
import Mathlib.Analysis.SpecificLimits.Basic

namespace Tutorial.Solutions.Lesson07

variable {α : Type*} [MetricSpace α]

example (x y z : α) : dist x z ≤ dist y x + dist y z := by
  have h₁ : dist x z ≤ dist x y + dist y z := dist_triangle x y z
  have h₂ : dist x y = dist y x := dist_comm x y
  linarith

example (x y : α) (h : x = y) : dist x y = 0 := by
  rw [h, dist_self]

example {f : α → α} {K : ℝ} (hK₀ : 0 ≤ K)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y) (x y : α) :
    dist (f (f (f x))) (f (f (f y))) ≤ K * (K * (K * dist x y)) :=
  calc dist (f (f (f x))) (f (f (f y))) ≤ K * dist (f (f x)) (f (f y)) := hf _ _
    _ ≤ K * (K * dist (f x) (f y)) :=
        mul_le_mul_of_nonneg_left (hf _ _) hK₀
    _ ≤ K * (K * (K * dist x y)) :=
        mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left (hf x y) hK₀) hK₀

-- The complete proof of `Banach.fixedPoint_unique`.
example {f : α → α} {K : ℝ} (hK₁ : K < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    {a b : α} (hfa : f a = a) (hfb : f b = b) : a = b := by
  have h : dist a b ≤ K * dist a b :=
    calc dist a b = dist (f a) (f b) := by rw [hfa, hfb]
      _ ≤ K * dist a b := hf a b
  have hle : (1 - K) * dist a b ≤ 0 := by linarith
  have hzero : dist a b ≤ 0 := by nlinarith
  exact eq_of_dist_eq_zero (le_antisymm hzero dist_nonneg)

end Tutorial.Solutions.Lesson07
