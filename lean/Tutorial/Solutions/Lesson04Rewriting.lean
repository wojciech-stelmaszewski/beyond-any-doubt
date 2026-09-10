/-
Solutions to Lesson 4.
-/
import Mathlib.Tactic

namespace Tutorial.Solutions.Lesson04

example (a b c : Nat) (h₁ : a = b) (h₂ : b = c) : a + 1 = c + 1 := by
  rw [h₁, h₂]

-- `rw [h]` gets the goal to `b = c`; `h'` says `c = b`, so it has to be used
-- backwards to turn that `b` into a `c`.
example (a b c : Nat) (h : a = b) (h' : c = b) : a = c := by
  rw [h, ← h']

example (f : Nat → Nat) (a b : Nat) (h : a = b) (h' : f a = 3) : f b = 3 := by
  rw [h] at h'
  exact h'

example (x y z : Nat) (h₁ : x ≤ y) (h₂ : y = z) : x ≤ z := by
  calc x ≤ y := h₁
    _ = z := h₂

end Tutorial.Solutions.Lesson04
