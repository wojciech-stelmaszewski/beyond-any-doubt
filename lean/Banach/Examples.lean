/-
Worked instances of the theorem, which double as its test suite.

A theorem that compiles is not yet a theorem worth having: `False → anything`
compiles too. The examples below check that the hypotheses can actually be met,
that the conclusion is the one intended, and — via `#print axioms` — that no
`sorry` is hiding anywhere underneath.
-/
import Banach.FixedPoint

namespace Banach.Examples

/-- An affine map of the line. Named rather than written inline because `∃! a, f a = a`
has to unify `f` with something, and Lean will not guess a lambda for it. -/
def affine (c d : ℝ) : ℝ → ℝ := fun x => c * x + d

/-- `affine c d` contracts by exactly `|c|`: the slope is the whole story. -/
theorem affine_dist (c d x y : ℝ) :
    dist (affine c d x) (affine c d y) ≤ |c| * dist x y := by
  simp only [affine, Real.dist_eq]
  rw [show c * x + d - (c * y + d) = c * (x - y) by ring, abs_mul]

/-- Every affine map of the line with slope of modulus below one has exactly one
fixed point. Nothing about `ℝ` is used beyond its being a complete metric space. -/
theorem affine_existsUnique_fixedPoint (c d : ℝ) (hc : |c| < 1) :
    ∃! a : ℝ, affine c d a = a :=
  existsUnique_fixedPoint (abs_nonneg c) hc (affine_dist c d)

/-! ### A concrete case

`x ↦ x/2 + 1` halves the distance to anything, and fixes `2`.
-/

example : ∃! a : ℝ, affine (1 / 2) 1 a = a := by
  refine affine_existsUnique_fixedPoint _ _ ?_
  rw [abs_of_pos (by norm_num : (0 : ℝ) < 1 / 2)]
  norm_num

example : affine (1 / 2) 1 2 = 2 := by norm_num [affine]

/-- The iterates from `0` converge to it, with the error bound the theorem promises.
Starting point `0` is arbitrary — that is the point of the `∀ x₀` in the theorem. -/
example : ∃ a, affine (1 / 2) 1 a = a ∧
    Filter.Tendsto (fun n => (affine (1 / 2) 1)^[n] 0) Filter.atTop (nhds a) ∧
    ∀ n, dist ((affine (1 / 2) 1)^[n] 0) a
          ≤ dist (0 : ℝ) (affine (1 / 2) 1 0) * (1 / 2 : ℝ) ^ n / (1 - 1 / 2) := by
  refine exists_fixedPoint (by norm_num) (by norm_num) ?_ 0
  intro x y
  have h := affine_dist (1 / 2) 1 x y
  rwa [abs_of_pos (by norm_num : (0 : ℝ) < 1 / 2)] at h

/-! ### Degenerate cases the statement had better survive

A constant map is a contraction with `K = 0`, and the identity is not a contraction
at all — `K = 1` is excluded, and must be, since translations fix nothing.
-/

example (d : ℝ) : ∃! a : ℝ, affine 0 d a = a := by
  refine affine_existsUnique_fixedPoint _ _ ?_
  norm_num

/-- Uniqueness needs neither completeness nor a nonempty space, so it applies to
maps that have no fixed point at all — vacuously, but correctly. -/
example (x y : ℝ) (hx : affine (1 / 2) 1 x = x) (hy : affine (1 / 2) 1 y = y) : x = y := by
  refine fixedPoint_unique (K := |1 / 2|) ?_ (affine_dist _ _) hx hy
  rw [abs_of_pos (by norm_num : (0 : ℝ) < 1 / 2)]
  norm_num

/-! ### Provenance

Lean lists every axiom a proof depends on. Anything reached by `sorry` shows up as
`sorryAx`, so the expected output below — the three standard axioms of Mathlib's
classical foundation, and nothing else — is a machine-checked claim that the proof
is complete.
-/

-- Expect: `propext`, `Classical.choice`, `Quot.sound`. In particular no `sorryAx`.
#print axioms Banach.existsUnique_fixedPoint
#print axioms Banach.exists_fixedPoint
#print axioms Banach.fixedPoint_unique

end Banach.Examples
