/-
# Lesson 4 — Equality, `rw`, and how it bites

Rewriting is the workhorse tactic and the one that misleads beginners most, so
this lesson ends by reproducing an actual bug from `Banach/FixedPoint.lean`.
-/
import Mathlib.Tactic

namespace Tutorial.Lesson04

/-!
## `rw [h]` replaces the left side of `h` with its right side, in the goal

If `h : a = b`, then `rw [h]` turns every `a` in the goal into `b`.
-/

example (a b c : Nat) (h : a = b) : a + c = b + c := by
  rw [h]

/-!
Notice there was nothing after the `rw`. Once the goal became `b + c = b + c`,
`rw` finished it: after rewriting it always tries `rfl`, and often that is enough.
That is convenient and also confusing, because a successful `rw` sometimes leaves
work and sometimes does not.

## `rw [← h]` goes the other way

The arrow is typed `\l`. Use it when the goal is written in terms of the right
side and you want the left.
-/

example (a b c : Nat) (h : a = b) : b + c = a + c := by
  rw [← h]

/-!
## `rw [h] at h'` rewrites inside a hypothesis instead of the goal
-/

example (a b : Nat) (h : a = b) (h' : a + 1 = 5) : b + 1 = 5 := by
  rw [h] at h'
  exact h'

/-!
## Several rewrites in order

`rw [h₁, h₂]` is `rw [h₁]` then `rw [h₂]`. The order matters, as the last
section will make painfully clear.
-/

example (a b c : Nat) (h₁ : a = b) (h₂ : b = c) : a = c := by
  rw [h₁, h₂]

/-!
## `calc` writes a chain the way you would on paper

Each line states one step and justifies it after `:=`. The `_` stands for the
previous line's right-hand side. Lean composes the relations, so a chain of `=`
and `≤` proves `≤`.
-/

example (a b c d : Nat) (h₁ : a = b) (h₂ : b ≤ c) (h₃ : c = d) : a ≤ d :=
  calc a = b := h₁
    _ ≤ c := h₂
    _ = d := h₃

/-!
## The trap: `rw` rewrites everywhere, including where you were heading

Here is the shape of the bug that broke the real proof. Take a sequence `s` with
a recurrence, and note that the goal below mentions `s (n + 1)` on *both* sides.
-/

section Trap

variable (s : Nat → Nat) (n : Nat) (h : ∀ m, s (m + 1) = s m + 1)

-- What we want is to unfold the two terms on the left. What actually happens is
-- that `rw [h n]` also unfolds the `s (n + 1)` sitting on the right, so the two
-- sides stop matching and the goal cannot be closed. Uncomment to see it fail:
--
-- example : s (n + 1) + s (n + 1 + 1) = (s n + 1) + (s (n + 1) + 1) := by
--   rw [h n, h (n + 1)]
--
-- The remaining goal is
--   (s n + 1) + (s (n + 1) + 1) = (s n + 1) + ((s n + 1) + 1)
-- where the left still says `s (n + 1)` and the right has been unfolded a step
-- further than intended. Nothing is false here — the two sides *are* equal — but
-- `rw` left them in different shapes and `rfl` cannot see it.

/-!
Fix one: `simp only` instead of `rw`. Where `rw` performs one surgical
replacement, `simp only` keeps applying the rule until nothing changes, on both
sides. Both sides therefore reach the same normal form.
-/

example : s (n + 1) + s (n + 1 + 1) = (s n + 1) + (s (n + 1) + 1) := by
  simp only [h]

/-!
Fix two, and the one used in the real proof: do not aim at a hand-written form
at all. Rewrite the goal when its other side has nothing rewritable in it, and
there is nothing to disturb.
-/

example (h' : s n + 1 + (s n + 1 + 1) = 7) : s (n + 1) + s (n + 1 + 1) = 7 := by
  rw [h n, h (n + 1), h n]
  exact h'

end Trap

/-!
The moral is worth stating plainly, because it is not obvious and it costs an
afternoon to learn the hard way: **`rw` acts on the whole goal, not on the part
you are looking at.** When a rewrite reports success and the goal still will not
close, check whether it changed something on the far side of the equation.

## Exercises
-/

-- Two rewrites, in the right order.
example (a b c : Nat) (h₁ : a = b) (h₂ : b = c) : a + 1 = c + 1 := by sorry

-- One of these hypotheses points the wrong way, so one rewrite needs `← `.
example (a b c : Nat) (h : a = b) (h' : c = b) : a = c := by sorry

-- Rewrite inside a hypothesis, then use it.
example (f : Nat → Nat) (a b : Nat) (h : a = b) (h' : f a = 3) : f b = 3 := by
  sorry

-- A `calc` chain. Fill in both justifications.
example (x y z : Nat) (h₁ : x ≤ y) (h₂ : y = z) : x ≤ z := by sorry

end Tutorial.Lesson04
