/-
Produces the expected verdicts for `scripts/check-automaton.mjs`.

The state diagram in the Talemi post is a drawing of `parse`. To keep the
drawing honest, the site's check compares it against this list rather than
against a second reading of the prose. Regenerate with:

    cd lean && lake env lean scripts/parse-verdicts.lean \
      | tr -d '"' | tail -1 > ../scripts/parse-verdicts.txt

The alphabet carries one representative of every behaviour the reader
distinguishes: two ordinary roots, the root `na` that is also the additive
linker, the linker `sa` that is only ever a linker, and the fused `tu`. Adding
the remaining roots would multiply the count without testing anything new,
since `parse` treats them all through `Syl.digit`.
-/
import Talemi

open Talemi Talemi.TNum

def alpha : List Syl := [.o, .ka, .na, .sa, .tu]

/-- Every word of the given length, first syllable varying slowest. -/
def words : Nat → List (List Syl)
  | 0     => [[]]
  | n + 1 => alpha.flatMap (fun s => (words n).map (fun w => s :: w))

def allWords : List (List Syl) :=
  ((List.range 5).map (fun i => words (i + 1))).flatten

#eval allWords.length
#eval String.join (allWords.map (fun w => if (parse w).isSome then "1" else "0"))
