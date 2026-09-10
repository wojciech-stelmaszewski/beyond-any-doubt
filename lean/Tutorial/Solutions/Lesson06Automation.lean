/-
Solutions to Lesson 6.
-/
import Mathlib.Tactic
import Mathlib.Data.Real.Basic

namespace Tutorial.Solutions.Lesson06

example (a b : ℝ) : (a - b) * (a + b) = a ^ 2 - b ^ 2 := by ring

example (x y : ℝ) (h₁ : x + y = 10) (h₂ : x - y = 2) : x = 6 := by linarith

example : (3 : ℝ) ^ 4 = 81 := by norm_num

example (n : Nat) (h : 3 * n + 1 = 16) : n = 5 := by omega

-- `nlinarith` for the hard direction, and `hd` for the easy one. `linarith`
-- alone cannot do the first: it needs `(1 - K) * d ≤ 0` multiplied by the fact
-- that `1 - K` is positive, and that is a product of two unknowns.
example (K d : ℝ) (hd : 0 ≤ d) (hK : K < 1) (h : d ≤ K * d) : d = 0 :=
  le_antisymm (by nlinarith) hd

end Tutorial.Solutions.Lesson06
