/-
The Talemi corpus, checked against the model — and the model checked against
the things the corpus does *not* settle.

A grammar that compiles is not yet a grammar worth having. What follows is the
evidence: every attested word spelled and valued, the six equations of the
manuscript closed as arithmetic, and then the four facts about the system that
are easy to state wrongly in prose — redundancy, negativity, recursion, and the
unbounded padding that makes "how many spellings does a number have?" the wrong
question.
-/
import Talemi.Numerals

namespace Talemi.Corpus

open Talemi.TNum

/-! ### The manuscript's six equations

The words, as trees. Nothing here records a value: the value is `eval`'s job,
and the point of the theorems below is that it agrees with the manuscript. -/

def pe     : TNum := .atom .pe
def vo     : TNum := .atom .vo
def ri     : TNum := .atom .ri
def yu     : TNum := .atom .yu
def katu   : TNum := .add12 .ka (.atom .ka)
def sutu   : TNum := .add12 .su (.atom .ka)
def tetu   : TNum := .add12 .te (.atom .ka)
def votu   : TNum := .add12 .vo (.atom .ka)
def petu   : TNum := .add12 .pe (.atom .ka)
def sunami : TNum := .add12 .su (.atom .mi)
def penami : TNum := .add12 .pe (.atom .mi)
def lonasu : TNum := .add12 .lo (.atom .su)
def kasasu : TNum := .sub12 .ka (.atom .su)
def kasana : TNum := .sub12 .ka (.atom .na)
def susana : TNum := .sub12 .su (.atom .na)
def kasalo : TNum := .sub12 .ka (.atom .lo)

/-- The trees spell the words the manuscript actually shows. Without this, the
theorems below would only say that some arithmetic is consistent — not that it
is the arithmetic of these sixteen words. -/
theorem spelling :
    [pe, vo, ri, yu, katu, sutu, tetu, votu, petu,
      sunami, penami, lonasu,
      kasasu, kasana, susana, kasalo].map render
      = ["pe", "vo", "ri", "yu",
        "katu", "sutu", "tetu", "votu", "petu",
        "sunami", "penami", "lonasu",
        "kasasu", "kasana", "susana", "kasalo"] := by
  rfl

/-- Each Talemi equation, matched to the decimal one it translates. -/
theorem equation_F :
    (eval pe, eval vo, eval tetu) = (10, 8, 18) := by
  rfl
theorem equation_B :
    (eval sutu, eval ri, eval petu) = (15, 7, 22) := by
  rfl
theorem equation_A :
    (eval petu, eval katu, eval kasasu) = (22, 13, 35) := by
  rfl
theorem equation_D :
    (eval penami, eval yu, eval susana) = (34, 11, 45) := by
  rfl
theorem equation_C :
    (eval sunami, eval votu, eval kasana) = (27, 20, 47) := by
  rfl
theorem equation_E :
    (eval lonasu, eval tetu, eval kasalo) = (41, 18, 59) := by
  rfl

/-- And each of them is a true addition. -/
theorem sums :
    eval pe + eval vo = eval tetu ∧
    eval sutu + eval ri = eval petu ∧
    eval petu + eval katu = eval kasasu ∧
    eval penami + eval yu = eval susana ∧
    eval sunami + eval votu = eval kasana ∧
    eval lonasu + eval tetu = eval kasalo := by
  refine ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-! ### The second leaf -/

def ze     : TNum := .atom .ze
def zitu   : TNum := .add12 .ze (.atom .ka)
def onari  : TNum := .add12 .o (.atom .ri)
def onatu  : TNum := .add12 .o (.add12 .o (.atom .ka))
def pesana : TNum := .sub12 .pe (.atom .na)

theorem second_leaf :
    [ze, zitu, onari, onatu, pesana].map (fun t => (render t, eval t))
      = [("ze", 9), ("zitu", 21), ("onari", 84), ("onatu", 144),
        ("pesana", 38)] := by
  rfl

/-- The allomorph is surface only. `zitu` is spelled with `zi`, but the tree it
spells holds the digit `ze` — nine — and `eval` never sees the alternation. -/
theorem zitu_holds_ze : zitu = .add12 .ze (.atom .ka) ∧ eval zitu = 21 :=
  ⟨rfl, rfl⟩

/-- `ze` survives intact before the additive linker, which is why the
alternation must be stated for the `_tu` environment and not in general. -/
theorem ze_intact_before_na : render (.add12 .ze (.atom .te)) = "zenate" := by rfl

/-! ### What the corpus does not settle

Four facts that the informal solution states in prose, where each of them is
easy to state slightly wrongly. -/

/-- **Redundancy.** Two different trees, one number — twice over. The corpus
gives no ground for calling either spelling canonical. -/
theorem redundant_38 :
    eval (.add12 .mi (.atom .su)) = eval pesana ∧
      (.add12 .mi (.atom .su) : TNum) ≠ pesana :=
  ⟨rfl, by decide⟩

theorem redundant_143 :
    eval (.sub12 .ka (.add12 .o (.atom .ka))) = eval (.add12 .yu (.atom .yu)) ∧
      (.sub12 .ka (.add12 .o (.atom .ka)) : TNum) ≠ .add12 .yu (.atom .yu) :=
  ⟨rfl, by decide⟩

/-- **Negativity.** The subtractive linker is not restricted to cases where it
lands above zero, so the grammar as reconstructed generates negative values.
`kasao` is 12·0 − 1. Whether Talemi speakers would say it is a question about
Talemi speakers, of whom we have none. -/
theorem kasao_is_negative :
    render (.sub12 .ka (.atom .o)) = "kasao" ∧
      eval (.sub12 .ka (.atom .o)) = -1 :=
  ⟨rfl, rfl⟩

/-- **Recursion.** The argument of a linker is a numeral, not a digit, so depth
is unbounded: `sunaonatu` = 3 + 12·144. -/
theorem sunaonatu :
    render (.add12 .su onatu) = "sunaonatu" ∧ eval (.add12 .su onatu) = 1731 :=
  ⟨rfl, rfl⟩

/-- **Fusion.** Thirteen is `katu`, never `kanaka`: `tu` is the fused linker
`na` with the root `ka`, so `render` has no way to emit the unfused form. A
grammar listing `Digit tu` as a production separate from `Digit na Numeral`
would generate both, and only one of them is Talemi. -/
theorem thirteen_is_katu :
    render (.add12 .ka (.atom .ka)) = "katu" := by rfl

/-! ### Why "how many spellings?" is the wrong question

A zero remainder can be stacked without limit, so *every* value has infinitely
many spellings and the count says nothing. The question worth asking is about
spellings without padding, or about a canonical shortest form. -/

/-- `atom o`, `onao`, `onaonao`, … -/
def zeros : Nat → TNum
  | 0     => .atom .o
  | n + 1 => .add12 .o (zeros n)

theorem eval_zeros (n : Nat) : eval (zeros n) = 0 := by
  induction n with
  | zero => rfl
  | succ n ih => simp [zeros, eval, Digit.value, ih]

/-- `ka`, `kanao`, `kanaonao`, … — each of them the number 1. -/
def padded (n : Nat) : TNum := .add12 .ka (zeros n)

theorem eval_padded (n : Nat) : eval (padded n) = 1 := by
  simp [padded, eval, Digit.value, eval_zeros]

theorem zeros_injective : ∀ m n : Nat, zeros m = zeros n → m = n
  | 0,     0,     _ => rfl
  | 0,     _ + 1, h => by simp [zeros] at h
  | _ + 1, 0,     h => by simp [zeros] at h
  | m + 1, n + 1, h => by
      simp only [zeros, TNum.add12.injEq, true_and] at h
      exact congrArg (· + 1) (zeros_injective m n h)

/-- **1 has infinitely many spellings**, and so does everything else. -/
theorem padded_injective (m n : Nat)
    (h : padded m = padded n) : m = n := by
  simp only [padded, TNum.add12.injEq, true_and] at h
  exact zeros_injective m n h

theorem padding_examples :
    [(.atom .ka : TNum),
      .add12 .ka (.atom .o),
      .add12 .ka (.add12 .o (.atom .o)),
      .add12 .ka (.add12 .o (.add12 .o (.atom .o)))].map (fun t => (render t, eval t))
      = [("ka", 1), ("kanao", 1), ("kanaonao", 1), ("kanaonaonao", 1)] := by
  rfl

/-! ### Provenance

Lean lists the axioms each theorem rests on. Expect `propext` where `simp` was
used and nothing at all where it was not. What must *not* appear is
`Lean.ofReduceBool`: that is what `native_decide` leaves behind, and it means a
step was handed to the compiler instead of being checked by the kernel.
`scripts/verify.sh` fails the build on it. -/

#print axioms TNum.parse_toks
#print axioms TNum.toks_injective
#print axioms spelling
#print axioms sums
#print axioms second_leaf
#print axioms padded_injective

end Talemi.Corpus
