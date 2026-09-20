/-
The Talemi numeral system, as reconstructed in the post of the same name.

`Talemi/Numerals.lean` is the model: syntax, semantics, surface form, and the
proof that the surface determines the syntax.

`Talemi/Range.lean` asks which numbers the system names. Every natural number,
by a construction that never uses the subtractive linker; every integer, by one
that uses it exactly for the negatives.

`Talemi/Shortest.lean` asks whether the subtractive linker at least saves
breath. It does not: the additive spelling of a non-negative number is never
longer than any rival.

`Talemi/Enumeration.lean` asks how often the shortest spelling is unique, and
has to enumerate spellings to answer, so it first proves the enumeration both
complete and sound.

`Talemi/Examples.lean` is the evidence: the manuscript's corpus, then — kept
separate from it — the words the reconstruction supplies, then the facts about
the system that the corpus leaves open.

Unlike `Banach`, this library imports no Mathlib. It needs `Int` and induction
and nothing else, which means the whole thing can be read without knowing a
library. The one expensive step is the enumeration at the end of
`Enumeration.lean`, which the kernel checks by brute force.
-/
import Talemi.Numerals
import Talemi.Range
import Talemi.Shortest
import Talemi.Enumeration
import Talemi.Examples
