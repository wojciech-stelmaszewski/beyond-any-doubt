/-
The Talemi numeral system: syntax, semantics, and surface form.

Talemi is a duodecimal system with signed digits. A numeral is a digit root
followed by a linker and another numeral, where `na` adds and `sa` subtracts:

    val(D-na-N) = d + 12·val(N)
    val(D-sa-N) = 12·val(N) - d

Three things are kept apart here, because the puzzle conflates them and the
conflation is where the mistakes live: the abstract syntax tree (`TNum`), its
value (`eval`), and the syllables that surface (`toks`).

Nothing in this file imports Mathlib. The arithmetic is `Int` and the proofs are
`rfl` and induction, so the whole library elaborates in about a second — and,
more to the point, every claim below is checked by the kernel rather than by the
compiler.
-/

namespace Talemi

/-! ## Digit roots

Twelve roots, `o` through `yu`. Their values are the residues of the base, so
`Digit` is the alphabet of a positional system and nothing more. -/

inductive Digit where
  | o | ka | mi | su | na | lo | te | ri | vo | ze | pe | yu
deriving DecidableEq, Repr

namespace Digit

def value : Digit → Int
  | .o  => 0  | .ka => 1  | .mi => 2  | .su => 3
  | .na => 4  | .lo => 5  | .te => 6  | .ri => 7
  | .vo => 8  | .ze => 9  | .pe => 10 | .yu => 11

def root : Digit → String
  | .o  => "o"  | .ka => "ka" | .mi => "mi" | .su => "su"
  | .na => "na" | .lo => "lo" | .te => "te" | .ri => "ri"
  | .vo => "vo" | .ze => "ze" | .pe => "pe" | .yu => "yu"

end Digit

/-! ## Abstract syntax

`atom` is a bare root; `add12` and `sub12` are the two linkers. The second
argument of a linker is a whole numeral, not a digit — that single choice is
what makes the system recursive. The corpus never reaches deep enough to
witness it; taking the rule unrestricted is the reconstruction's assumption,
and the alternative would need a clause that nothing attests. -/

inductive TNum where
  | atom  (d : Digit)
  | add12 (d : Digit) (rest : TNum)
  | sub12 (d : Digit) (rest : TNum)
deriving DecidableEq, Repr

namespace TNum

/-- The value of a numeral. Note the type: `Int`, not `Nat`. The grammar can
build `kasao` = 12·0 − 1, and pretending otherwise would mean a partial
function. -/
def eval : TNum → Int
  | .atom d       => d.value
  | .add12 d rest => d.value + 12 * eval rest
  | .sub12 d rest => 12 * eval rest - d.value

/-! ## Surface form

The corpus never shows `X-na-ka`. Thirteen is `katu`, not `kanaka`, so `tu` is
the fused realisation of the linker `na` with the root `ka` — not a separate
construction. `render` therefore emits `tu` for *every* `d + 12·1`, and the
abstract grammar needs no production for it. -/

/-- The syllables Talemi is spelled out of. `na` appears once, because the
digit 4 and the additive linker really are the same syllable — the ambiguity
this seems to invite is the subject of `parse_toks` below. `sa` and `tu` are
not digit roots, which is what makes the parse deterministic. -/
inductive Syl where
  | o | ka | mi | su | na | lo | te | ri | vo | ze | pe | yu
  | sa | tu
deriving DecidableEq, Repr

/-- A digit root in digit position. -/
def Syl.ofDigit : Digit → Syl
  | .o  => .o  | .ka => .ka | .mi => .mi | .su => .su
  | .na => .na | .lo => .lo | .te => .te | .ri => .ri
  | .vo => .vo | .ze => .ze | .pe => .pe | .yu => .yu

/-- The syllables of a numeral. -/
def toks : TNum → List Syl
  | .atom d              => [Syl.ofDigit d]
  | .add12 d (.atom .ka) =>
      if d = .o then [.tu] else [Syl.ofDigit d, .tu]
  | .add12 d rest        => Syl.ofDigit d :: .na :: toks rest
  | .sub12 d rest        => Syl.ofDigit d :: .sa :: toks rest

/-- The written word. -/
def render (t : TNum) : String :=
  String.join ((toks t).map fun
    | .o  => "o"  | .ka => "ka" | .mi => "mi" | .su => "su"
    | .na => "na" | .lo => "lo" | .te => "te" | .ri => "ri"
    | .vo => "vo" | .ze => "ze" | .pe => "pe" | .yu => "yu"
    | .sa => "sa" | .tu => "tu")

/-! ## The grammar is unambiguous

The informal solution calls the double life of `na` — the digit 4 and the
additive linker — an accidental homonymy, and moves on. It is better than that:
it costs nothing at all. Every root is one syllable, so the syllable sequence
is fixed, and in that sequence digit positions and linker positions alternate.
A parser reading left to right never has a choice to make.

The statement below is the machine-checked form of that claim. `parse` is
written independently of `toks` — it is the reader's job, not the writer's —
and recovers the tree from the syllables exactly. -/

/-- The digit a syllable denotes *in digit position*. `sa` and `tu` never occur
there. -/
def Syl.digit : Syl → Option Digit
  | .o  => some .o  | .ka => some .ka | .mi => some .mi | .su => some .su
  | .na => some .na | .lo => some .lo | .te => some .te | .ri => some .ri
  | .vo => some .vo | .ze => some .ze | .pe => some .pe | .yu => some .yu
  | .sa | .tu => none

def parse : List Syl → Option TNum
  | [.tu]    => some (.add12 .o (.atom .ka))
  | [s]      => (s.digit).map .atom
  | [s, .tu] =>
      (s.digit).map fun d => .add12 d (.atom .ka)
  | s :: .na :: rest =>
      match s.digit, parse rest with
      | some d, some n => some (.add12 d n)
      | _, _           => none
  | s :: .sa :: rest =>
      match s.digit, parse rest with
      | some d, some n => some (.sub12 d n)
      | _, _           => none
  | _ => none

theorem digit_ofDigit (d : Digit) : (Syl.ofDigit d).digit = some d := by
  cases d <;> rfl

/-- **Every Talemi numeral can be read back.** The surface form determines the
syntax tree, homophonous `na` and all. -/
theorem parse_toks (t : TNum) : parse (toks t) = some t := by
  induction t with
  | atom d => cases d <;> rfl
  | add12 d rest ih =>
    match rest with
    | .atom .ka =>
      by_cases h : d = .o
      · subst h; rfl
      · simp only [toks, if_neg h, parse, digit_ofDigit, Option.map_some]
    | .atom .o | .atom .mi | .atom .su | .atom .na | .atom .lo | .atom .te
    | .atom .ri | .atom .vo | .atom .ze | .atom .pe | .atom .yu
    | .add12 _ _ | .sub12 _ _ =>
      simp only [toks] at ih ⊢
      simp only [parse, digit_ofDigit, ih]
  | sub12 d rest ih =>
    simp only [toks, parse, digit_ofDigit, ih]

/-- Read-back is injective, which is the same fact stated the other way: two
different trees are two different words. -/
theorem toks_injective {s t : TNum}
    (h : toks s = toks t) : s = t := by
  have hs := parse_toks s
  rw [h, parse_toks t] at hs
  exact (Option.some.inj hs).symm

end TNum

end Talemi
