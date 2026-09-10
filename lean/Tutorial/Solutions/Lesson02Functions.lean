/-
Solutions to Lesson 2.
-/
import Mathlib.Tactic

namespace Tutorial.Solutions.Lesson02

-- Composition of implications is composition of functions.
example (P Q R : Prop) (hpq : P → Q) (hqr : Q → R) : P → R := fun hp => hqr (hpq hp)

-- The same, in tactic mode.
example (P Q R : Prop) (hpq : P → Q) (hqr : Q → R) : P → R := by
  intro hp
  exact hqr (hpq hp)

example (P : Prop) : P → P := fun hp => hp

example (f : Nat → Nat → Nat) (h : ∀ n m, f n m = f m n) : f 2 5 = f 5 2 := h 2 5

-- `h 0 h0 : P (0 + 1)`, and `0 + 1` is `1` by computation, so it serves as `P 1`.
example (P : Nat → Prop) (h : ∀ n, P n → P (n + 1)) (h0 : P 0) : P 2 :=
  h 1 (h 0 h0)

end Tutorial.Solutions.Lesson02
