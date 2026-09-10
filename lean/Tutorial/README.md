# Learning Lean, in eight lessons

A path from "what is this file even saying" to reading `Banach/FixedPoint.lean`
line by line. Nothing else is assumed: not Lean, not functional programming, not
type theory. Some comfort with undergraduate analysis helps only in the last two
lessons, and only to recognise the statements.

Every construction in the target file appears in some lesson, and nothing appears
that the target file does not use. That is the whole selection principle — this is
not a tour of Lean, it is the shortest road to one proof.

## How to work through it

Open a lesson in the editor, not in a terminal. The lessons are written to be
read with the infoview open beside them, because the thing being taught is what
Lean shows you at each step, and that cannot be printed.

Read the prose, put the cursor inside each worked example, and watch the goal in
the infoview change as you move between lines. Then do the exercises at the
bottom by replacing `sorry` with a real proof.

While a `sorry` is present Lean reports `declaration uses 'sorry'` and marks the
line. **That warning disappearing is the entire feedback loop.** There is no test
to run and no output to compare: if Lean stops complaining, you proved it.

To check a whole lesson from the terminal instead:

```sh
lake build Tutorial
```

Every remaining `sorry` shows up as one warning, so the warning count is your
progress bar. It starts at 32.

## Why this directory is not part of the build

`lake build` and `scripts/verify.sh` deliberately ignore it. Unfinished exercises
are the normal state of a tutorial, and `verify.sh` exists to fail on exactly
that — an admitted goal. Mixing the two would mean either a permanently red
verification or a check that has learned to tolerate `sorry`, and the second is
worse. Hence a separate `lean_lib` outside `defaultTargets`.

## The lessons

| # | File | What it gives you |
| --- | --- | --- |
| 1 | `Lesson01Basics.lean` | Types, terms, and the one idea: a proof is a value |
| 2 | `Lesson02Functions.lean` | `→` and `∀` are function types; `intro`, `exact`, `apply` |
| 3 | `Lesson03Structures.lean` | `∧ ∨ ∃ ∃!`, and `⟨…⟩`, `obtain`, `refine` |
| 4 | `Lesson04Rewriting.lean` | `rw`, `calc`, and the way `rw` misfires |
| 5 | `Lesson05Induction.lean` | `induction`, the hypothesis `ih`, and `f^[n]` |
| 6 | `Lesson06Automation.lean` | `simp`, `ring`, `linarith`, `nlinarith`, `omega` |
| 7 | `Lesson07MetricSpaces.lean` | Typeclasses, `dist`, and what a contraction is |
| 8 | `Lesson08Limits.lean` | `Tendsto`, `CauchySeq`, completeness |

Lesson 4 is the one to slow down on. It reproduces a bug that actually broke the
real proof: `rw` rewrote a term on the far side of the equation, both sides
stopped matching, and the error message pointed at a goal that looked correct.
Understanding why costs ten minutes here and an afternoon in the wild.

Two exercises are worth naming in advance, because they are not drills. The last
one in Lesson 7 is the complete proof of `Banach.fixedPoint_unique` — finish it
and you have written a fifth of the real file. The last one in Lesson 8 is the
central step of the theorem itself: one sequence, described two ways, and limits
being unique.

## Solutions

In `Solutions/`, one file per lesson. They exist for two reasons, and only the
second one is about you: they are the guarantee that every exercise is solvable
as stated, since if the solutions compile then the exercises are well posed.

Read them after being stuck, not instead of being stuck. A solution read early
teaches the shape of an answer, which is the least valuable part.

## Getting unstuck

Ask Lean before asking anyone. Four things it will tell you:

`exact?` searches the library for a term that closes the goal outright, and
prints what it found. `apply?` does the same for lemmas that close it partly.
Both are slow and both are worth it.

`simp?` runs `simp` and reports which lemmas it used, so you can replace it with
the `simp only [...]` that a durable proof wants.

Hovering over any name gives its statement and which of its arguments are
implicit. This answers the question that trips up everyone early: why
`dist_nonneg` takes no arguments while `dist_comm x y` takes two.

`#check foo` in the file does the same thing for expressions, and `#check @foo`
shows every argument including the implicit ones.

## Typing the symbols

Lean's editor support turns backslash sequences into Unicode as you type. The
ones these lessons need:

| Type | Get | | Type | Get |
| --- | --- | --- | --- | --- |
| `\to` | `→` | | `\forall` | `∀` |
| `\and` | `∧` | | `\exists` | `∃` |
| `\or` | `∨` | | `\le` | `≤` |
| `\<` `\>` | `⟨` `⟩` | | `\l` | `←` |
| `\a` | `α` | | `\R` | `ℝ` |
| `\N` | `ℕ` | | `\nhds` | `𝓝` |
| `\.` | `·` | | `\^[` | `^[` |

Subscripts are `\0` through `\9`, which is where names like `hK₀` and `x₀` come
from. If you forget one, hover over the character in an existing lesson and the
editor shows you how it was typed.
