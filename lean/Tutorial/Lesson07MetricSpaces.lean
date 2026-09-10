/-
# Lesson 7 — Typeclasses, distances, and contractions

Everything so far worked on `Nat` and `ℝ`. The real proof is stated for *any*
metric space, and that generality is carried by a piece of machinery worth
understanding on its own: typeclasses.
-/
import Mathlib.Tactic
import Mathlib.Analysis.SpecificLimits.Basic

namespace Tutorial.Lesson07

/-!
## Three kinds of argument

You have already met round brackets. There are two more:

* `(x : α)` — **explicit**. You pass it.
* `{x : α}` — **implicit**. Lean works it out from the other arguments, and you
  are not allowed to pass it positionally.
* `[MetricSpace α]` — **instance**. Lean searches a global table for something
  of that type and supplies it. You neither pass it nor name it.

The third is how `dist` becomes available. Writing `[MetricSpace α]` does not
name a hypothesis you will use by hand; it makes a *structure* on `α` — its
distance function and the axioms that function obeys — visible to everything in
scope.
-/

variable {α : Type*} [MetricSpace α]

#check (dist : α → α → ℝ)

/-!
Note that the distance lands in `ℝ`, not in `α`. That is why `K` in the real
theorem is a real number even when the space is something else entirely.

## The axioms, as usable lemmas

These five are the whole interface. `Banach/FixedPoint.lean` uses exactly two of
them, the first and the last.
-/

example (x y : α) : 0 ≤ dist x y := dist_nonneg
example (x : α) : dist x x = 0 := dist_self x
example (x y : α) : dist x y = dist y x := dist_comm x y
example (x y z : α) : dist x z ≤ dist x y + dist y z := dist_triangle x y z
example (x y : α) (h : dist x y = 0) : x = y := eq_of_dist_eq_zero h

/-!
Note the shapes. `dist_nonneg` needs no arguments at all — its `x` and `y` are
implicit, and Lean reads them off the goal. `dist_comm x y` takes its two
explicitly. There is no rule to memorise; hover over a name and Lean tells you.

## `ℝ` is a metric space, so all of the above applies to it

The instance is already in Mathlib's table, which is why nothing had to be
declared. And for `ℝ` the distance is what you would expect:
-/

example (x y : ℝ) : dist x y = |x - y| := Real.dist_eq x y

example (x y : ℝ) (h : x ≤ y) : dist x y = y - x := by
  rw [Real.dist_eq, abs_sub_comm, abs_of_nonneg (by linarith)]

/-!
## Contractions

There is no special syntax for "let `f` be a contraction". It is an ordinary
hypothesis, of the shape you met in Lesson 2:

  `hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y`

Applying it is `hf x y`, or `hf _ _` when the goal already says which points are
meant. Two applications compose, which is the seed of the whole theorem:
-/

example {f : α → α} {K : ℝ} (hK₀ : 0 ≤ K)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y) (x y : α) :
    dist (f (f x)) (f (f y)) ≤ K * (K * dist x y) :=
  calc dist (f (f x)) (f (f y)) ≤ K * dist (f x) (f y) := hf _ _
    _ ≤ K * (K * dist x y) := mul_le_mul_of_nonneg_left (hf x y) hK₀

/-!
`mul_le_mul_of_nonneg_left : b ≤ c → 0 ≤ a → a * b ≤ a * c` is where `0 ≤ K`
earns its place: multiplying an inequality by a negative number would flip it.

## Why a contraction has at most one fixed point

If `f a = a` and `f b = b`, then `dist a b` equals `dist (f a) (f b)`, which the
hypothesis bounds by `K * dist a b`. With `K < 1` the only non-negative number
satisfying `d ≤ K * d` is zero, and `eq_of_dist_eq_zero` finishes.

That is the last exercise, and it is the complete proof of
`Banach.fixedPoint_unique` — you will have written a fifth of the real file.

## Exercises
-/

-- Symmetry and the triangle inequality, combined. `linarith` closes it once the
-- two facts are in the context.
example (x y z : α) : dist x z ≤ dist y x + dist y z := by sorry

-- Distance zero, in the other direction from `eq_of_dist_eq_zero`.
example (x y : α) (h : x = y) : dist x y = 0 := by sorry

-- Three applications of the contraction hypothesis, composed.
example {f : α → α} {K : ℝ} (hK₀ : 0 ≤ K)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y) (x y : α) :
    dist (f (f (f x))) (f (f (f y))) ≤ K * (K * (K * dist x y)) := by sorry

-- The real thing: uniqueness of the fixed point.
-- Sketch: get `dist a b ≤ K * dist a b` by a `calc`, then `(1 - K) * dist a b ≤ 0`
-- by `linarith`, then `dist a b ≤ 0` by `nlinarith`, then `le_antisymm` and
-- `eq_of_dist_eq_zero`.
example {f : α → α} {K : ℝ} (hK₁ : K < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    {a b : α} (hfa : f a = a) (hfb : f b = b) : a = b := by sorry

end Tutorial.Lesson07
