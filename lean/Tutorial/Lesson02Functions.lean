/-
# Lesson 2 — Implication and `∀` are function types

Lesson 1 said a proof of `P` is a value of type `P`. This lesson spends that
observation, because it settles what implication *is*.
-/
import Mathlib.Tactic

namespace Tutorial.Lesson02

/-!
## `P → Q` is the type of functions from proofs of `P` to proofs of `Q`

The arrow in `P → Q` is the same arrow as in `Nat → Nat`. There is no second
kind of arrow. So proving an implication means writing a function, and *using*
an implication means calling one.

Below, `hpq : P → Q` and `hp : P`, so `hpq hp : Q`. What logicians call modus
ponens is function application, and Lean does not distinguish them.
-/

example (P Q : Prop) (hp : P) (hpq : P → Q) : Q := hpq hp

/-!
## `intro` starts writing the function

To prove `P → Q` in tactic mode, say `intro hp`: "assume a proof of `P`, and
call it `hp`". The goal loses its arrow and gains a hypothesis. Put your cursor
on the line before and the line after, and watch the goal change.
-/

example (P Q : Prop) (hpq : P → Q) : P → Q := by
  intro hp
  exact hpq hp

-- Several arrows, several names, one `intro`.
example (P Q : Prop) : P → (Q → P) := by
  intro hp hq
  exact hp

-- The same proof as a term. `fun` and `intro` do the same job; `intro` is merely
-- easier to steer when the goal is complicated. The `_` is a name we decline to
-- give, because that assumption is never used.
example (P Q : Prop) : P → (Q → P) := fun hp _ => hp

/-!
## `∀` is the same thing, with the type allowed to depend on the argument

`∀ n : Nat, P n` is the type of functions taking `n` and returning a proof of
`P n`. Specialising a `∀` is therefore *also* function application: if
`h : ∀ n, f n = n + 1`, then `h 3 : f 3 = 3 + 1`.

This is why the proofs in `Banach/FixedPoint.lean` apply hypotheses like `hf x y`
without any ceremony — `hf` is a function of two arguments.
-/

example (f : Nat → Nat) (h : ∀ n, f n = n + 1) : f 3 = 3 + 1 := h 3

example (f : Nat → Nat) (h : ∀ n m, f n = f m) : f 1 = f 2 := h 1 2

-- And proving a `∀` is `intro` again: "take an arbitrary one".
example : ∀ n : Nat, n + 0 = n := by
  intro n
  rfl

/-!
## `exact` versus `apply`

`exact e` says "the term `e` is precisely a proof of the goal". It must match.

`apply e` works backwards: it takes a lemma whose *conclusion* matches the goal
and replaces the goal with that lemma's hypotheses. It is what you reach for when
you know the last step but not yet the earlier ones.
-/

example (P Q : Prop) (hp : P) (hpq : P → Q) : Q := by
  apply hpq        -- goal was `Q`; `hpq` concludes `Q`, so the goal becomes `P`
  exact hp

/-!
## Underscores let Lean fill in the obvious

`_` means "work this out from the surrounding information". In the example below
Lean knows which numbers are meant, because the goal says so. `Banach` uses this
as `hf _ _`, since repeating the two long iterate expressions would add nothing.
-/

example (f : Nat → Nat) (h : ∀ n m, f n = f m) : f 1 = f 2 := h _ _

/-!
## Exercises
-/

-- Compose two implications. Doable as a term or with `intro`; try both.
example (P Q R : Prop) (hpq : P → Q) (hqr : Q → R) : P → R := by sorry

-- The identity function, read as a proposition.
example (P : Prop) : P → P := by sorry

-- Specialise a `∀` twice.
example (f : Nat → Nat → Nat) (h : ∀ n m, f n m = f m n) : f 2 5 = f 5 2 := by
  sorry

-- A `∀` whose body is an implication is a function of two arguments.
example (P : Nat → Prop) (h : ∀ n, P n → P (n + 1)) (h0 : P 0) : P 2 := by sorry

end Tutorial.Lesson02
