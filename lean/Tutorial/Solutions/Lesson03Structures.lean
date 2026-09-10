/-
Solutions to Lesson 3.
-/
import Mathlib.Tactic

namespace Tutorial.Solutions.Lesson03

example (P Q : Prop) (h : P ∧ Q) : Q ∧ P := ⟨h.2, h.1⟩

example : ∃ n : Nat, 5 < n ∧ n < 8 := ⟨6, by norm_num, by norm_num⟩

example (P Q R : Prop) (hpr : P → R) (hqr : Q → R) (h : P ∨ Q) : R := by
  rcases h with hp | hq
  · exact hpr hp
  · exact hqr hq

example (f : Nat → Nat) (h : ∃ n, f n = 3) : ∃ n, f n + 1 = 4 := by
  obtain ⟨n, hn⟩ := h
  exact ⟨n, by rw [hn]⟩

example : ∃! n : Nat, 2 * n = 10 := by
  refine ⟨5, by norm_num, ?_⟩
  intro m hm
  omega

end Tutorial.Solutions.Lesson03
