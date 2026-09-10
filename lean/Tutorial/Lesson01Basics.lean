/-
# Lesson 1 — A proof is a value

Read the prose, then put your cursor inside each example and watch the infoview.
Nothing here needs running: Lean checks the file as you type, and watching it do
so is the entire exercise.

Finish the exercises at the bottom by replacing `sorry`. While a `sorry` is there
Lean reports "declaration uses `sorry`"; that warning going away is how you know
you are done. Solutions live in `Tutorial/Solutions/Lesson01Basics.lean` and are
worth less than five minutes of being stuck.
-/
import Mathlib.Tactic

namespace Tutorial.Lesson01

/-!
## Lean is a programming language before it is anything else

`def` defines a value, `#eval` runs it. Neither has anything to do with proving.
-/

def double (n : Nat) : Nat := 2 * n

#eval double 21

/-!
## Everything has a type, and `#check` reports it

`#check` computes nothing. It answers only "what sort of thing is this?". The
comments record what the infoview actually says — note that Mathlib prints `Nat`
as `ℕ`, so the type you declared and the type you are shown look different.
-/

#check 42                 -- 42 : ℕ
#check double             -- double (n : ℕ) : ℕ
#check double 21          -- double 21 : ℕ

/-!
## Statements are values too, of type `Prop`

`2 + 2 = 4` is not a command or a question. It is an expression whose type is
`Prop`, the type of things that can be asserted. `#check` answers `Prop` whether
or not the statement is true: being a statement and being true are different
matters.
-/

#check 2 + 2 = 4          -- 2 + 2 = 4 : Prop
#check 2 + 2 = 5          -- 2 + 2 = 5 : Prop, a perfectly good statement; just false

/-!
## The one idea in this lesson

If `P : Prop`, then a **proof of `P` is a value of type `P`**.

This is not an analogy. It is the same mechanism as `42 : Nat`. Where `42` is a
value of type `Nat`, a proof of `2 + 2 = 4` is a value of type `2 + 2 = 4`. So
`theorem` is `def` with a different keyword and no other difference.
-/

theorem two_plus_two : 2 + 2 = 4 := rfl

#check two_plus_two       -- 2 + 2 = 4

/-!
`rfl` proves that something equals itself. It works here because Lean can
*compute* both sides and see the same value. Most interesting statements cannot
be settled by computation, but where it works this is the cheapest proof there
is.
-/

example : double 21 = 42 := rfl

/-!
## `example` is a theorem you decline to name

Useful when the statement is the whole point and nothing will refer to it later.
The rest of this tutorial uses it constantly.

## `by` hands the work to tactics

Everything above supplied the proof directly, as a term. The alternative is
*tactic mode*: `by`, followed by commands that transform the goal until it is
gone. `norm_num` is the one that settles concrete arithmetic.
-/

example : 123 * 456 = 56088 := by norm_num

-- The same statement both ways. Both produce a value of the stated type, and
-- afterwards Lean cannot tell which you wrote.
example : 2 + 2 = 4 := rfl
example : 2 + 2 = 4 := by norm_num

/-!
## What a failed proof looks like

Uncomment the line below. Lean does not say "false" — it says it could not close
the goal, and the declaration turns red. A wrong proof is a type error, which is
why a file that compiles is a file whose theorems hold.
-/

-- example : 2 + 2 = 5 := by norm_num

/-!
## Exercises

All three fall to `rfl` or `norm_num`. The point is the shape of a declaration,
not the difficulty.
-/

-- Numbers Lean can simply compute.
example : 7 * 6 = 42 := by sorry

-- A lambda applied to an argument computes, so `rfl` reaches this one.
example : (fun n : Nat => n + 1) 3 = 4 := by sorry

-- Bigger numbers. `rfl` still works, but `norm_num` is the tool built for it.
example : 2 ^ 10 = 1024 := by sorry

end Tutorial.Lesson01
