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
import Talemi.Enumeration

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

/-! ### The manuscript's own test

None of the eight items below was used to fit the system, which is what makes
them worth checking. Four words the reader is asked to evaluate, and four
numbers the reader is asked to spell. -/

def yutu   : TNum := .add12 .yu (.atom .ka)
def minasu : TNum := .add12 .mi (.atom .su)
def susalo : TNum := .sub12 .su (.atom .lo)
def rinana : TNum := .add12 .ri (.atom .na)

theorem reading_task :
    [yutu, minasu, susalo, rinana].map (fun t => (render t, eval t))
      = [("yutu", 23), ("minasu", 38), ("susalo", 57), ("rinana", 55)] := by
  rfl

def lotu   : TNum := .add12 .lo (.atom .ka)
def lonami : TNum := .add12 .lo (.atom .mi)
def penasu : TNum := .add12 .pe (.atom .su)
def yunalo : TNum := .add12 .yu (.atom .lo)

theorem writing_task :
    [lotu, lonami, penasu, yunalo].map (fun t => (render t, eval t))
      = [("lotu", 17), ("lonami", 29), ("penasu", 46), ("yunalo", 71)] := by
  rfl

/-- Two of the four numbers the manuscript asks for have a second answer of
exactly the same length, which the question does not allow for. -/
def misana : TNum := .sub12 .mi (.atom .na)
def kasate : TNum := .sub12 .ka (.atom .te)

theorem writing_task_ambiguous :
    (render misana, eval misana) = ("misana", 46) ∧
    (render kasate, eval kasate) = ("kasate", 71) ∧
    len misana = len penasu ∧ len kasate = len yunalo ∧
    misana ≠ penasu ∧ kasate ≠ yunalo := by
  refine ⟨rfl, rfl, rfl, rfl, ?_, ?_⟩ <;> decide

/-! ### The reconstructed part

None of the words below is attested. Two roots the corpus never shows — the
ninth digit and the zero — and two freedoms it never exercises, unbounded
recursion and a free choice of linker, are assumptions of the reconstruction
rather than readings of the manuscript. They are stated here as words so that
the assumptions have a concrete shape, and are kept apart from the corpus above
so that nothing can quietly borrow the corpus's authority. -/

def ze     : TNum := .atom .ze
def zetu   : TNum := .add12 .ze (.atom .ka)
def onari  : TNum := .add12 .o (.atom .ri)
def onatu  : TNum := .add12 .o (.add12 .o (.atom .ka))

theorem reconstructed_words :
    [ze, zetu, onari, onatu].map (fun t => (render t, eval t))
      = [("ze", 9), ("zetu", 21), ("onari", 84), ("onatu", 144)] := by
  rfl

/-- **Why a zero is forced.** A compound denoting an exact multiple of twelve
must have the zero root in its leading position, under either linker. So
without a zero digit the language cannot say 24 at all, and the reconstruction
has no choice about this one. -/
theorem multiple_needs_zero_head (d : Digit) (rest : TNum) (k : Int)
    (h : eval (.add12 d rest) = 12 * k ∨ eval (.sub12 d rest) = 12 * k) :
    d = .o := by
  cases d
  · rfl
  all_goals
    rcases h with h | h <;>
      simp only [eval, Digit.value] at h <;> omega

/-! ### What the corpus does not settle

Four facts that the informal solution states in prose, where each of them is
easy to state slightly wrongly. -/

/-- **Redundancy.** Two different trees, one number — twice over. The corpus
gives no ground for calling either spelling canonical, and in the case of 46 it
is the manuscript's own exercise that asks for "the" answer. -/
theorem redundant_46 :
    eval penasu = eval misana ∧ penasu ≠ misana :=
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

/-! ### The system named

`encode` is long division read backwards, and it gives a word to every natural
number. Nothing below needed a corpus entry: the word for 20735 is as much
Talemi as `petu` is.

`encode` recurses on a shrinking quotient rather than on a constructor, so it
does not reduce on its own and the examples name the trees explicitly. -/

def yunami         : TNum := .add12 .yu (.atom .mi)
def onaonatu       : TNum := .add12 .o (.add12 .o (.add12 .o (.atom .ka)))
def yunayunayunayu : TNum := .add12 .yu (.add12 .yu (.add12 .yu (.atom .yu)))

theorem encode_words :
    encode 35 = yunami ∧ encode 1728 = onaonatu ∧
      encode 20735 = yunayunayunayu := by
  refine ⟨?_, ?_, ?_⟩ <;>
    simp [yunami, onaonatu, yunayunayunayu, encode, Digit.ofResidue]

theorem naming :
    [yunami, onaonatu, yunayunayunayu].map (fun t => (render t, eval t))
      = [("yunami", 35), ("onaonatu", 1728), ("yunayunayunayu", 20735)] := by
  rfl

/-- **Nothing above zero needs `sa`.** `encode` reaches every natural number
and never once reaches for the subtractive linker, so the sixteen attested
words could have got by with `na` alone. -/
theorem additive_suffices (n : Nat) :
    additive (encode n) = true ∧ eval (encode n) = (n : Int) :=
  ⟨additive_encode n, eval_encode n⟩

/-! ### What `sa` is for

The additive fragment is exactly the non-negative integers — `additive_range`
— so `sa` reaches nothing above zero and everything below it. These are the
words for four negative numbers, and every one of them contains `sa`. -/

def kasao     : TNum := .sub12 .ka (.atom .o)
def onakasao  : TNum := .add12 .o (.sub12 .ka (.atom .o))
def yunamisao : TNum := .add12 .yu (.sub12 .mi (.atom .o))
def vonazesao : TNum := .add12 .vo (.sub12 .ze (.atom .o))

theorem encode_negatives :
    encodeInt (-1) = kasao ∧ encodeInt (-12) = onakasao ∧
      encodeInt (-13) = yunamisao ∧ encodeInt (-100) = vonazesao := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp [kasao, onakasao, yunamisao, vonazesao, encodeInt, Digit.ofResidue]

theorem negatives :
    [kasao, onakasao, yunamisao, vonazesao].map
        (fun t => (render t, eval t, additive t))
      = [("kasao", -1, false), ("onakasao", -12, false),
        ("yunamisao", -13, false), ("vonazesao", -100, false)] := by
  rfl

/-! ### `sa` buys no brevity either

Having failed to add a number, the subtractive linker might still have earned
its place by saving a syllable, the way `IX` beats `VIIII`. It does not: the
additive spelling is always among the shortest. -/

/-- The corpus word for 35 and the additive word for 35 are different words of
the same length. -/
theorem tie_at_35 :
    render kasasu = "kasasu" ∧ render yunami = "yunami" ∧
      eval kasasu = 35 ∧ eval yunami = 35 ∧ kasasu ≠ yunami ∧
      (toks kasasu).length = (toks yunami).length :=
  ⟨rfl, rfl, rfl, rfl, by decide, rfl⟩

/-- And both of them are as short as 35 can be said, so the tie is real: there
is no shortest spelling of 35, only two of them. -/
theorem both_shortest_35 : IsShortest 35 kasasu ∧ IsShortest 35 yunami :=
  ⟨isShortest_of_mem (by decide) (w := yunami) (by decide) (by decide),
    isShortest_of_mem (by decide) (w := yunami) (by decide) (by decide)⟩

/-- Thirteen, by contrast, has one shortest spelling and no other. The
difference is the fusion: `katu` saves a syllable that no subtractive rival
can save. -/
theorem thirteen_unique (t u : TNum)
    (ht : IsShortest 13 t) (hu : IsShortest 13 u) : t = u :=
  unique_of_uniqueShortest (by decide) (w := katu) (by decide) (by decide) ht hu

theorem thirteen_spelled : render katu = "katu" ∧ eval katu = 13 :=
  ⟨rfl, rfl⟩

/-! ### Reading is easier than speaking

`parse_toks` says every word can be read back. It does not say the reader
rejects everything that is not a word, and `parse` does not: it happily takes
`kanaka` for thirteen. No speaker would say it — `toks` emits `katu` — so the
grammar of comprehension here is strictly wider than the grammar of
production. Tightening `parse` would be easy; whether a language ought to have
a reader stricter than its speakers is not a question the manuscript
answers. -/

theorem kanaka_readable :
    parse [.ka, .na, .ka] = some (.add12 .ka (.atom .ka)) := by rfl

theorem kanaka_unsayable :
    toks (.add12 .ka (.atom .ka)) = [.ka, .tu] ∧
      toks (.add12 .ka (.atom .ka)) ≠ [.ka, .na, .ka] :=
  ⟨rfl, by decide⟩

/-! ### Provenance

Lean lists the axioms each theorem rests on. Expect `propext` where `simp` was
used, and `Quot.sound` with `Classical.choice` wherever `encode` is involved,
since it recurses on a shrinking quotient rather than on a constructor. What
must *not* appear is `Lean.ofReduceBool`: that is what `native_decide` leaves
behind, and it means a step was handed to the compiler instead of being checked
by the kernel. This repository's verification step fails the build on it, which
is why the count of ties is a `decide` — slow, and checked. -/

#print axioms TNum.parse_toks
#print axioms TNum.toks_injective
#print axioms spelling
#print axioms sums
#print axioms reading_task
#print axioms writing_task
#print axioms writing_task_ambiguous
#print axioms reconstructed_words
#print axioms multiple_needs_zero_head
#print axioms padded_injective
#print axioms TNum.eval_encode
#print axioms TNum.eval_encodeInt
#print axioms TNum.additive_range
#print axioms TNum.encode_shortest
#print axioms TNum.unique_shortest_below_400
#print axioms TNum.tie_counts_below_300

end Talemi.Corpus
