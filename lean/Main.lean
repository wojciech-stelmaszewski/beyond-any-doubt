/-
A demonstration, not a proof.

`lake exe banach` iterates `x ↦ x/2 + 1` from `0` and prints each iterate beside
the error bound `Banach.exists_fixedPoint` guarantees for it. Nothing here is
verified — these are `Float`s, and `Float` arithmetic proves nothing — but the
theorem's rate is easier to believe once seen.

For this map the two columns come out equal rather than merely ordered, which is
worth noticing: on an affine map the geometric bound is attained, so the theorem's
estimate is not just correct but sharp.

Deliberately imports nothing: pulling Mathlib into an executable means linking it,
which costs minutes for output that carries no logical weight.
-/

/-- The contraction, at `Float` precision. Its fixed point is `2`. -/
def step (x : Float) : Float := x / 2 + 1

/-- `dist x₀ (f x₀) * K ^ n / (1 - K)` with `x₀ = 0`, `f x₀ = 1` and `K = 1/2`. -/
def bound (n : Nat) : Float := 2.0 * (0.5 : Float) ^ n.toFloat

def main : IO Unit := do
  IO.println "  n  iterate               |iterate - 2|          bound"
  let mut x : Float := 0
  for n in [0:12] do
    let err := (x - 2.0).abs
    IO.println s!"  {n}  {x}  {err}  {bound n}"
    x := step x
  IO.println ""
  IO.println "The last two columns agree: on an affine map the bound is attained."
