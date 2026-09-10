# Banach's fixed point theorem, in Lean

A machine-checked proof of the contraction mapping theorem, written out from the
definition of a contraction rather than assembled from library lemmas.

The site's prose proofs are checked by whoever reads them. This directory checks
one of them the other way: Lean refuses to compile a proof with a gap, so a green
build is a claim that every step follows, down to the axioms. It is the same
theorem either way — what differs is who is trusted.

Mathlib already has this result as `ContractingWith.exists_fixedPoint`, and real
work would call it. It is reproved here because the argument is the interesting
part, and it is short enough to read in one sitting.

## Setup

Lean comes through `elan`, its version multiplexer — [INSTALL.md](INSTALL.md) has
the macOS instructions, the editor setup, and what to do when it misbehaves. The
short version:

```sh
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- -y
source "$HOME/.elan/env"

cd lean
lake exe cache get   # prebuilt Mathlib, ~7.5 GB in .lake; not optional
lake build
```

The cache works only because `lean-toolchain` and the `rev` in `lakefile.toml`
name the same version — Lean `v4.33.1` and the Mathlib tag built against it. Bump
one and you must bump the other, or the cache silently misses and the build falls
back to compiling everything from source: an hour rather than two minutes.

## If none of this reads as mathematics yet

Start with [`Tutorial/`](Tutorial/README.md): eight lessons and 32 exercises that
build up exactly the constructions this proof uses and nothing else, ending with
the two exercises that reconstruct its central steps. It assumes no Lean at all.

It is a separate library, outside `defaultTargets`, because its exercises are
full of `sorry` by design — build it with `lake build Tutorial`.

## Checking the proofs

`lake build` *is* the test run. Lean type-checks every proof term it compiles, and
a theorem that does not follow from its hypotheses is a type error. There is no
separate assertion to write and no test that can pass for the wrong reason.

```sh
./scripts/verify.sh
```

The script builds, then covers the one thing a green build does not: `sorry`
compiles fine, and marks a goal as admitted rather than proved. Two checks, both
reading Lean's own output rather than the source — grepping the source for the
word `sorry` also finds it in comments explaining what `sorry` is, which is how
the first version of this script failed on its own documentation.

The first check looks for Lean's warning that a declaration reaches `sorry`. The
second reads the `#print axioms` lines that `Banach/Examples.lean` emits:

```
'Banach.existsUnique_fixedPoint' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Those three are Mathlib's classical foundation, and the script fails on anything
else in that list. `sorryAx` would appear there if any part of the proof, however
deep, were admitted; `Lean.ofReduceBool` would appear if a step had been delegated
to compiled code instead of checked by the kernel. It is the closest thing to a
certificate that Lean offers.

Both checks were tested the only way a check can be: by planting a `sorry` and
confirming the script goes red, then removing it and confirming it goes green.

`Banach/Examples.lean` carries the rest of the testing. A theorem can be
unimpeachable and still useless — `False → anything` type-checks too — so the
examples instantiate it on affine maps of the line, confirm the hypotheses are
satisfiable, confirm the fixed point of `x ↦ x/2 + 1` really is `2`, and check the
degenerate cases (`K = 0`, and uniqueness applied where no fixed point exists).

## Running it

There is nothing to run, in the usual sense: the output of this project is the
fact that it compiles. But for a look at the convergence rate:

```sh
lake exe banach
```

which iterates `x ↦ x/2 + 1` from `0` and prints each iterate beside the error
bound the theorem guarantees. The two agree exactly rather than merely being
ordered, because on an affine map the geometric bound is attained — the estimate
is sharp, not just valid. `Main.lean` deliberately imports nothing: it is `Float`
arithmetic, illustration rather than evidence.

## Editing

Install the **Lean 4** extension (`leanprover.lean4`) and the infoview opens
beside the file, showing the proof state at the cursor — the goal still
outstanding and everything in scope that might close it. Writing Lean without it
is possible in roughly the way writing assembly without a debugger is possible.
[INSTALL.md](INSTALL.md#editor) covers the setup, including why an editor started
from the Dock may fail to find `lake` when the terminal finds it fine.

Visual Studio proper is not part of this: no MSBuild, no solution file. Lake is
the build tool, and `lean/` is independent of the Astro site around it.

## The proof

`Banach/FixedPoint.lean`, four declarations.

The hypothesis throughout is that `f : α → α` satisfies
`dist (f x) (f y) ≤ K * dist x y` for some `0 ≤ K < 1`, with `α` a metric space.
`K` is a plain `ℝ` rather than Mathlib's `ℝ≥0`, which means carrying `0 ≤ K`
around by hand; that is the price of statements that read the way the textbook
writes them.

**`dist_iterate_succ`** is the entire mathematical content: consecutive points of
an orbit satisfy `dist (fⁿ x₀) (fⁿ⁺¹ x₀) ≤ dist x₀ (f x₀) · Kⁿ`. Induction, one
line per step. Everything after it is bookkeeping about limits.

**`exists_fixedPoint`** turns that into convergence. Geometrically shrinking steps
make the orbit Cauchy; completeness gives it a limit `a`; and `a` is fixed because
the sequence `fⁿ⁺¹ x₀` converges to `a` (dropping a first term changes no limit)
and to `f a` (`f` is continuous, being Lipschitz), and limits are unique.

The statement bundles in the error bound
`dist (fⁿ x₀) a ≤ dist x₀ (f x₀) · Kⁿ / (1 - K)`, which is what makes the theorem
a numerical method rather than an existence claim: it is computable from the first
step alone, before anything about the limit is known.

**`fixedPoint_unique`** needs no completeness and no nonemptiness. If `f a = a` and
`f b = b` then `dist a b = dist (f a) (f b) ≤ K · dist a b`, so `(1 - K) · dist a b ≤ 0`
with `1 - K > 0`, so the distance is zero. Uniqueness is unconditional; only
existence needs the space to be complete, and the separation is worth keeping
visible.

**`existsUnique_fixedPoint`** is the two of them together, in textbook form.

What is borrowed from Mathlib is only the analysis that has nothing to do with
contractions: `cauchySeq_of_le_geometric` (a geometric bound on consecutive terms
makes a sequence Cauchy), `cauchySeq_tendsto_of_complete`, and
`dist_le_of_le_geometric_of_tendsto` for summing the tail. Reproving those would
mean reproving the geometric series, which is a different lecture.

## Layout

```
lean/
  INSTALL.md            getting Lean onto a macOS machine
  lakefile.toml         package, the Mathlib pin, the demo executable
  lake-manifest.json    Lake's lockfile: the exact commit behind each tag
  lean-toolchain        the Lean version, which must match that pin
  Banach.lean           library root; imports the rest
  Banach/
    FixedPoint.lean     the theorem and its proof
    Examples.lean       instances, degenerate cases, #print axioms
  Tutorial/             eight lessons from zero to reading the above
    Solutions/          one per lesson, and the proof they are solvable
  Main.lean             `lake exe banach`; illustration, imports nothing
  scripts/verify.sh     build, then check for admitted goals
```

`lake-manifest.json` is committed on purpose. `lakefile.toml` names a tag, which
is a moving target in principle; the manifest records the commit that tag pointed
at, so a checkout years from now resolves to the same Mathlib.

`.lake/` holds the build output and the Mathlib checkout. It is gitignored and
entirely reproducible; delete it and rerun `lake exe cache get` if anything looks
stale.
