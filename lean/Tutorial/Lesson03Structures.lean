/-
# Lesson 3 — And, or, exists: packing and unpacking

`Banach/FixedPoint.lean` states its main theorem as
`∃ a, f a = a ∧ Tendsto … ∧ ∀ n, …`, and builds it with
`refine ⟨a, ?_, ha, fun n => ?_⟩`. This lesson is that one line.
-/
import Mathlib.Tactic

namespace Tutorial.Lesson03

/-!
## `∧` is a pair

A proof of `P ∧ Q` is a proof of `P` alongside a proof of `Q`, packaged
together. The angle brackets `⟨…⟩` are the *anonymous constructor*: they build
whatever structure the goal calls for, without you having to name its type.
-/

example (P Q : Prop) (hp : P) (hq : Q) : P ∧ Q := ⟨hp, hq⟩

-- Unpacking is `.1` and `.2`, exactly as with a pair of numbers.
example (P Q : Prop) (h : P ∧ Q) : Q := h.2

/-!
## `obtain` takes a hypothesis apart and names the pieces

The brackets work in reverse too. `obtain ⟨hp, hq⟩ := h` destroys `h` and
replaces it with its two halves.
-/

example (P Q : Prop) (h : P ∧ Q) : Q ∧ P := by
  obtain ⟨hp, hq⟩ := h
  exact ⟨hq, hp⟩

/-!
## `∃` is a pair as well: a witness, and a proof about it

To prove something exists, supply it. Nothing here is different from `∧` — the
only novelty is that the second component's *statement* mentions the first
component's *value*.
-/

example : ∃ n : Nat, n * n = 49 := ⟨7, by norm_num⟩

-- And `obtain` unpacks an existential into the witness and the fact about it.
-- This is exactly how `FixedPoint.lean` gets the limit out of completeness.
example (f : Nat → Nat) (h : ∃ n, f n = 0) : ∃ m, f m + 1 = 1 := by
  obtain ⟨n, hn⟩ := h
  exact ⟨n, by rw [hn]⟩

/-!
## Nested brackets flatten

`P ∧ Q ∧ R` is `P ∧ (Q ∧ R)`, so its proof is `⟨hp, hq, hr⟩` — Lean inserts the
nesting for you. The same holds for an existential over a conjunction, which is
why `⟨a, hfa, ha, hbound⟩` proves `∃ a, _ ∧ _ ∧ _`.
-/

example : ∃ n : Nat, 5 < n ∧ n < 8 ∧ n ≠ 7 := ⟨6, by norm_num, by norm_num, by norm_num⟩

/-!
## `refine` is `exact` with holes

Sometimes you know the shape of the answer but not yet every part. `refine`
takes a term containing `?_` placeholders, accepts the parts you gave, and turns
each hole into a remaining goal. The `·` bullets then focus on them one at a
time.
-/

example : ∃ n : Nat, 5 < n ∧ n < 8 := by
  refine ⟨6, ?_, ?_⟩
  · norm_num
  · norm_num

/-!
## `∨` is a choice, so using it means handling both cases

A proof of `P ∨ Q` is one or the other, and you are not told which. `rcases … with
h | h` splits the proof in two, once per possibility.
-/

example (P Q : Prop) (h : P ∨ Q) (hpq : P → Q) : Q := by
  rcases h with hp | hq
  · exact hpq hp
  · exact hq

-- Building one is `Or.inl` (left) or `Or.inr` (right).
example : 2 = 2 ∨ 2 = 3 := Or.inl rfl

/-!
## `∃!` is "exists, and is unique"

It unfolds to `∃ a, P a ∧ ∀ b, P b → b = a`: a witness, a proof it works, and a
proof that anything else that works is it. So the proof is a triple, which is
precisely how `Banach.existsUnique_fixedPoint` closes.
-/

example : ∃! n : Nat, n + 3 = 5 := by
  refine ⟨2, by norm_num, ?_⟩
  intro m hm
  omega

/-!
## Exercises
-/

-- Swap the halves of a conjunction.
example (P Q : Prop) (h : P ∧ Q) : Q ∧ P := by sorry

-- Supply a witness. Any of 6 or 7 will do.
example : ∃ n : Nat, 5 < n ∧ n < 8 := by sorry

-- Both cases have to be dealt with, and neither is hard.
example (P Q R : Prop) (hpr : P → R) (hqr : Q → R) (h : P ∨ Q) : R := by sorry

-- Unpack, then repack around the same witness.
example (f : Nat → Nat) (h : ∃ n, f n = 3) : ∃ n, f n + 1 = 4 := by sorry

-- Uniqueness as well as existence. `omega` will finish the arithmetic.
example : ∃! n : Nat, 2 * n = 10 := by sorry

end Tutorial.Lesson03
