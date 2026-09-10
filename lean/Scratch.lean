/-
# Scratchpad

Lean has no line-by-line REPL, and does not need one: *this file is the REPL*.
Type into it and the infoview beside it re-evaluates as you go. Nothing here
belongs to any build target, so `lake build` and `scripts/verify.sh` ignore it
entirely and you can leave it in any state you like.

Three commands do the work of a REPL prompt:

* `#eval e` runs `e` and prints the result.
* `#check e` prints the *type* of `e` without running it.
* `#print axioms foo` lists what a proof rests on.

`import Mathlib.Tactic` below costs about two and a half seconds. Replacing it
with plain `import Mathlib` gets you everything at about twenty, which is worth
it when hunting for a lemma and not otherwise.
-/
import Mathlib.Tactic

#eval 2 + 2

#check fun n : Nat => n * n

-- Definitions work here too, and are usable on the next line.
def triple (n : Nat) : Nat := 3 * n

#eval triple 14

-- Proofs, likewise. Put the cursor between the lines to watch the goal.
example (a b : Nat) : a + b = b + a := by
  omega

-- Leave a `sorry` wherever you want to see what remains to be proved: the
-- infoview shows the open goal instead of an error.
example (x y : ℝ) (h : x ≤ y) : x - y ≤ 0 := by
  sorry
