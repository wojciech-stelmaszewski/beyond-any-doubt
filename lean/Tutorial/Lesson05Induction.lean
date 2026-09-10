/-
# Lesson 5 — Induction, and iterating a function

`Banach.dist_iterate_succ` is an induction over `n` about `f` applied `n` times.
Both halves of that sentence are new, so here they are.
-/
import Mathlib.Tactic

namespace Tutorial.Lesson05

/-!
## `induction` splits a goal about `n` into two goals

`induction n with | zero => … | succ n ih => …` gives you the statement at `0`,
and the statement at `n + 1` *together with a proof of it at `n`*, named `ih`.
That second gift is the whole method: you are allowed to assume what you are
proving, one step down.
-/

example (s : Nat → Nat) (h : ∀ n, s (n + 1) = s n) (n : Nat) : s n = s 0 := by
  induction n with
  | zero => rfl
  | succ n ih =>
    -- Goal: `s (n + 1) = s 0`, and `ih : s n = s 0` is available.
    -- `rw [h n]` turns the goal into `s n = s 0`, which `ih` then closes.
    rw [h n, ih]

/-!
A more useful shape, and the one the real proof has: a recurrence turned into a
closed form. Watch how `ih` enters — one `rw`, and the rest is algebra.
-/

example (s : Nat → Nat) (h : ∀ n, s (n + 1) = s n + 2) (n : Nat) :
    s n = s 0 + 2 * n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [h n, ih]
    ring

/-!
## `f^[n]` is `f` applied `n` times

`Function.iterate f n`, written `f^[n]`. So `f^[0] x = x` and `f^[3] x` is
`f (f (f x))`. The orbit of a point under a map is exactly this.
-/

example (f : Nat → Nat) (x : Nat) : f^[0] x = x := rfl
example (f : Nat → Nat) (x : Nat) : f^[2] x = f (f x) := rfl

/-!
## Two ways to peel one application off

There are two lemmas, and choosing the wrong one wastes an hour:

* `Function.iterate_succ_apply  f n x : f^[n + 1] x = f^[n] (f x)` — peels from
  the **inside**, so the extra `f` goes next to `x`.
* `Function.iterate_succ_apply' f n x : f^[n + 1] x = f (f^[n] x)` — peels from
  the **outside**, so the extra `f` ends up outermost.

The primed one is what you want when the next step applies a fact about `f` to
the outermost application, which is what a contraction hypothesis does.
-/

example (f : Nat → Nat) (x : Nat) (n : Nat) : f^[n + 1] x = f (f^[n] x) :=
  Function.iterate_succ_apply' f n x

/-!
## The two put together

A miniature of `dist_iterate_succ`: if every step of `f` adds at most one, then
`n` steps add at most `n`. Same skeleton as the real proof — induction, peel one
application, apply the hypothesis, then use `ih`.
-/

example (f : Nat → Nat) (hf : ∀ x, f x ≤ x + 1) (x : Nat) (n : Nat) :
    f^[n] x ≤ x + n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply' f n]
    calc f (f^[n] x) ≤ f^[n] x + 1 := hf _
      _ ≤ (x + n) + 1 := by omega
      _ = x + (n + 1) := by ring

/-!
## Exercises
-/

-- The same closed form as above, with a different constant.
example (s : Nat → Nat) (h : ∀ n, s (n + 1) = s n + 3) (n : Nat) :
    s n = s 0 + 3 * n := by sorry

-- Peel from the outside. One lemma, applied directly.
example (f : Nat → Nat) (x : Nat) (n : Nat) : f^[n + 1] x = f (f^[n] x) := by
  sorry

-- Induction where the step is a multiplication rather than an addition.
-- `ring` or `omega` will close the arithmetic once `ih` is in place.
example (s : Nat → Nat) (h0 : s 0 = 1) (h : ∀ n, s (n + 1) = 2 * s n) (n : Nat) :
    s n = 2 ^ n := by sorry

end Tutorial.Lesson05
