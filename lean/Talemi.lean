/-
The Talemi numeral system, as reconstructed in the post of the same name.

`Talemi/Numerals.lean` is the model: syntax, semantics, surface form, and the
proof that the surface determines the syntax. `Talemi/Examples.lean` is the
evidence: the manuscript's corpus, and the facts about the system that the
corpus leaves open.

Unlike `Banach`, this library imports no Mathlib. It needs `Int` and induction
and nothing else, which is worth a second of build time and — more usefully —
means the whole thing can be read without knowing a library.
-/
import Talemi.Numerals
import Talemi.Examples
