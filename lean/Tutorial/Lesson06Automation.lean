/-
# Lesson 6 — The automatic tactics, and what each one is for

`simp`, `norm_num`, `ring`, `linarith`, `nlinarith`, `omega`. Reaching for the
wrong one is the commonest way to be stuck on a step that is not hard, so this
lesson is mostly about their boundaries.
-/
import Mathlib.Tactic
import Mathlib.Data.Real.Basic

namespace Tutorial.Lesson06

/-!
## `ring` — identities true in any commutative ring

Both sides must be equal *as algebra*, with no hypotheses involved. `ring` will
not use anything from the context, and it does not care what the variables are.
-/

example (a b : ℝ) : (a + b) ^ 2 = a ^ 2 + 2 * a * b + b ^ 2 := by ring
-- This one is lifted verbatim from the last step of `Banach.dist_iterate_succ`.
example (K C : ℝ) (n : ℕ) : K * (C * K ^ n) = C * K ^ (n + 1) := by ring

/-!
## `norm_num` — concrete numbers

Arithmetic on literals, including comparisons. It also finishes goals where the
variables have already been eliminated.
-/

example : (2 : ℝ) + 2 = 4 := by norm_num
example : (7 : ℝ) / 2 < 4 := by norm_num
example : ¬ (5 : ℝ) < 3 := by norm_num

/-!
## `linarith` — linear inequalities, using the hypotheses

This is the one that reads the context. It combines the hypotheses linearly and
looks for a contradiction with the negated goal.
-/

example (x y : ℝ) (h : x ≤ y) : x + 3 ≤ y + 3 := by linarith
example (x : ℝ) (h : 2 * x = 6) : x = 3 := by linarith
example (x y : ℝ) (h₁ : x ≤ y) (h₂ : y ≤ 5) : x ≤ 5 := by linarith

/-!
## The important subtlety about `linarith`

"Linear" is judged after treating each nonlinear product as a single unknown. So
`K * d` counts as one atom, and a goal that is linear *in those atoms* is within
reach even though it contains a product.

This is exactly the step in `Banach.fixedPoint_unique`: from `d ≤ K * d` we get
`(1 - K) * d ≤ 0`, because `(1 - K) * d` expands to `d - K * d`, and in the atoms
`d` and `K * d` that is linear.
-/

example (K d : ℝ) (h : d ≤ K * d) : (1 - K) * d ≤ 0 := by linarith

/-!
## `nlinarith` — when the product genuinely has to be multiplied out

The next step in that proof is not linear in any reading: from `(1 - K) * d ≤ 0`
and `1 - K > 0`, concluding `d ≤ 0` requires multiplying two unknown quantities.
`linarith` fails; `nlinarith` tries products of hypotheses and succeeds.
-/

example (K d : ℝ) (hK : K < 1) (h : d ≤ K * d) : d ≤ 0 := by
  nlinarith

/-!
Note what is *absent* from that example: no assumption that `d` is non-negative.
It is not needed, because `d ≤ K * d` with `K < 1` already forces `d ≤ 0`. This
was worth discovering — the first draft of this lesson carried `0 ≤ d` as a
hypothesis, and Lean's unused-variable linter pointed out that the proof never
touched it. Non-negativity is needed only to get from `d ≤ 0` to `d = 0`, which
is the last exercise below.
-/

-- Square brackets add extra facts for it to multiply. Supply these when it fails
-- and you know which fact is missing.
example (x : ℝ) (h : 1 ≤ x) : x ≤ x ^ 2 := by nlinarith [sq_nonneg x]

/-!
## `omega` — linear arithmetic on `Nat` and `Int` only

Complete for its domain and very fast, but it knows nothing about `ℝ`, and
nothing about multiplication of two variables.
-/

example (n m : Nat) (h : n + 2 = m) : n < m := by omega
example (n : Nat) (h : 2 * n = 10) : n = 5 := by omega

/-!
## `simp` — rewrite with everything Mathlib marked as a simplification

Powerful and unpredictable in equal measure. `simp` is the right first guess for
goals that are true "by unfolding definitions and tidying up".

`simp only [h₁, h₂]` restricts it to the rules you name, which is what you want
in a proof meant to keep working next year: plain `simp` can change behaviour
when Mathlib adds a lemma.
-/

example (l : List Nat) : (l ++ []).length = l.length := by simp
example (s : Nat → Nat) (n : Nat) (h : ∀ m, s (m + 1) = s m) : s (n + 1) = s n := by
  simp only [h]

/-!
## When one fails, the message tells you which to try next

* `ring` failing means the two sides are not equal as algebra — you need a
  hypothesis, so `linarith` or `rw`.
* `linarith` failing on something you believe means it is nonlinear in the atoms:
  try `nlinarith`, and if that fails, give it hints.
* `simp` making no progress means none of its rules apply; naming your own
  lemma with `simp [my_lemma]` usually does.

## Exercises
-/

-- Algebra, no hypotheses.
example (a b : ℝ) : (a - b) * (a + b) = a ^ 2 - b ^ 2 := by sorry

-- Uses a hypothesis, and is linear.
example (x y : ℝ) (h₁ : x + y = 10) (h₂ : x - y = 2) : x = 6 := by sorry

-- Concrete numbers only.
example : (3 : ℝ) ^ 4 = 81 := by sorry

-- `Nat`, linear. One tactic.
example (n : Nat) (h : 3 * n + 1 = 16) : n = 5 := by sorry

-- The shape from the real proof. Which of the two inequality tactics is needed?
example (K d : ℝ) (hd : 0 ≤ d) (hK : K < 1) (h : d ≤ K * d) : d = 0 := by sorry

end Tutorial.Lesson06
