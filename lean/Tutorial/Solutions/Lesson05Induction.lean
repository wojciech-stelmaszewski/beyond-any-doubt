/-
Solutions to Lesson 5.
-/
import Mathlib.Tactic

namespace Tutorial.Solutions.Lesson05

example (s : Nat → Nat) (h : ∀ n, s (n + 1) = s n + 3) (n : Nat) :
    s n = s 0 + 3 * n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [h n, ih]
    ring

example (f : Nat → Nat) (x : Nat) (n : Nat) : f^[n + 1] x = f (f^[n] x) :=
  Function.iterate_succ_apply' f n x

example (s : Nat → Nat) (h0 : s 0 = 1) (h : ∀ n, s (n + 1) = 2 * s n) (n : Nat) :
    s n = 2 ^ n := by
  induction n with
  | zero => simp [h0]
  | succ n ih =>
    rw [h n, ih]
    ring

end Tutorial.Solutions.Lesson05
