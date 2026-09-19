---
title: The Talemi numerals, and the saint who did not invent them
description: >-
  A marginal note hides a duodecimal system with signed digits. Reconstructing
  it from six equations, then checking the reconstruction in Lean.
published: 2026-09-19
tags: ["numeral systems", "formalisation", "Lean"]
---

Leafing through a twelfth-century manuscript I had found in a Venetian
antiquarian bookshop, I came across a curious marginal note. The manuscript was
already suspiciously eclectic — a few pages of theology, several medical
recipes of questionable value, a drawing of what might have been either a comet
or a turnip — and then, on folio 73r, a numerical puzzle.

The note was copied, it says, by a monk of the *Order of the Most Sacred Heart
of Padua*, an order that has left remarkably little trace in any serious history
of medieval Italy. The monk in turn credits the sixth-century Saint Mukosolvan,
patron, one is tempted to suppose, of inconvenient notation and recreational
arithmetic.

The provenance is therefore doubtful. The puzzle is excellent.

## The puzzle

The monk gives six ordinary equations:

```text
10 + 8  = 18      34 + 11 = 45
15 + 7  = 22      27 + 20 = 47
22 + 13 = 35      41 + 18 = 59
```

He then writes the same six equations in a language he calls **Talemi**, in a
different order:

```text
A)  petu   + katu = kasasu        D)  penami + yu   = susana
B)  sutu   + ri   = petu          E)  lonasu + tetu = kasalo
C)  sunami + votu = kasana        F)  pe     + vo   = tetu
```

That is the whole of the data. Recover the numeral system.

> [!remark] A word before the solution
> Everything needed is above, and the pleasure of the thing is in finding the
> base yourself. The rest of this post gives it away in the second section.

## Form before meaning

The first useful move is not to guess at meanings. It is to look at shapes.

Four Talemi words are a single syllable — `pe`, `vo`, `ri`, `yu` — and every
other word in the corpus has two or three. The natural hypothesis is that one
syllable is one root, and that the longer words are built out of them.

If that is right, then equation F is special: it is the only one whose two
addends are both bare roots. Among the decimal equations, only $10 + 8 = 18$
has both addends small enough to be plausible as bare roots at all; the others
add 15, 22, 34, 27 or 41 to something. So F translates $10 + 8 = 18$.

This is the one genuinely abductive step in the reconstruction. Everything
after it is forced, and the check on the guess is that all six equations close.

Now look at B, whose result `petu` begins with the `pe` of F and ends with the
`tu` of F's own result `tetu`. Its second addend `ri` is a bare root, so B must
be $15 + 7 = 22$. Reading off:

```text
pe = 10      petu = 22
vo = 8       tetu = 18
ri = 7       sutu = 15
```

## The ending that means twelve

Compare `pe` with `petu`. Ten against twenty-two: the ending `tu` contributes
exactly twelve. That immediately predicts `su` $= 15 - 12 = 3$ and
`te` $= 18 - 12 = 6$, and it tells us what kind of system this is.

> [!definition] Talemi is duodecimal
> The grouping unit is twelve, inferred not from a guess at the base but from a
> repeated morphological relation: the same visible fragment appearing in words
> whose values differ by a constant.

That last point is the transferable one. In a puzzle of this kind, the base
announces itself as a *difference*, long before any word for it turns up.

## The remaining four equations

With `petu` $= 22$ in hand, equation A is determined: the only decimal equation
with 22 as an addend is $22 + 13 = 35$, so `katu` $= 13$ and therefore
`ka` $= 1$.

Equation D has a bare root, `yu`, as its second addend. Of the equations still
unassigned, only $34 + 11 = 45$ has an addend small enough to be one, so
`yu` $= 11$ and `penami` $= 34$. Since `pe` is ten and $34 - 10 = 24 = 2 \cdot
12$, the word segments as `pe-na-mi`, which asks us to read `mi` as 2 and the
medial `na` as an instruction to add twelve times what follows:

$$
\begin{equation}\label{eq:add}
\operatorname{val}(D\text{-na-}N) = d + 12 \operatorname{val}(N).
\end{equation}
$$

Two words later this stops being a hypothesis and starts being a prediction.
Equation C opens with `sunami`, which $\eqref{eq:add}$ reads as $3 + 12 \cdot 2
= 27$ — and 27 is exactly what C needs.

The results of A, D and E are a different shape. A gives `kasasu` $= 35$, and
$35 = 3 \cdot 12 - 1$ with `ka` $= 1$ and `su` $= 3$ already known. So `sa` is
the mirror of `na`:

$$
\begin{equation}\label{eq:sub}
\operatorname{val}(D\text{-sa-}N) = 12 \operatorname{val}(N) - d.
\end{equation}
$$

Both remaining results fall out. D's `susana` is $12 \cdot 4 - 3 = 45$, which
fixes `na` $= 4$; E's `kasalo` is $12 \cdot 5 - 1 = 59$, which fixes `lo` $= 5$.
Everything else in the corpus now checks itself — `votu` $= 20$,
`lonasu` $= 41$, `kasana` $= 47$ — and the correspondence is:

```text
F)  10 + 8  = 18       D)  34 + 11 = 45
B)  15 + 7  = 22       C)  27 + 20 = 47
A)  22 + 13 = 35       E)  41 + 18 = 59
```

Note that `na` leads a double life: the digit 4, and the additive linker. I will
come back to that, because it looks like trouble and turns out not to be.

## What the first leaf does not say

Eleven roots, and a gap at 9:

```text
ka = 1     lo = 5      ?? = 9
mi = 2     te = 6      pe = 10
su = 3     ri = 7      yu = 11
na = 4     vo = 8
```

Nothing so far says whether Talemi has a zero, how an exact multiple of twelve
is said, whether the additive and subtractive forms are interchangeable, or
whether the $N$ in $\eqref{eq:add}$ can be anything more complicated than a
single root. Those are open questions, not gaps in the analysis, and the second
leaf answers all four.

## The second leaf

Bound in after folio 73 is a damaged leaf carrying five more attestations:

```text
ze     = 9        onatu  = 144
zitu   = 21       pesana = 38
onari  = 84
```

**The gap closes.** `ze` is 9, and the digit inventory runs 1 to 11 without
interruption.

**A root bends.** Twenty-one is $9 + 12$, so we would expect `zetu`. The
manuscript writes `zitu`. This is the first morphophonological alternation in
the language, and it is worth stating narrowly — `ze` becomes `zi` before `tu`,
and nowhere else. The corpus gives no licence to touch `ze` in other
environments, and in fact `zenate` $= 81$ shows it surviving intact before `na`.

**Zero exists.** Since `ri` is 7 and $84 = 12 \cdot 7$, reading `onari` by
$\eqref{eq:add}$ forces $0 + 12 \cdot 7$, so `o` is the zero remainder. Exact
multiples of twelve are `onate` $= 72$, `onari` $= 84$, `onaze` $= 108$.

> [!remark] How much of a zero?
> `o` is attested only as a remainder inside a compound, never standing alone.
> That it is the digit zero in the arithmetic is beyond doubt; that a Talemi
> speaker would answer "`o`" when asked how many turnips are in an empty sack
> is a different claim, and the manuscript does not make it.

**Both linkers are live.** `pesana` is $12 \cdot 4 - 10 = 38$. But the grammar
already generates `minasu` $= 2 + 36 = 38$. The same integer has at least two
spellings, and nothing in the corpus makes one of them canonical. What the
grammar permits and what a speaker would prefer are separate questions; the
second needs usage data, and six equations are not usage data.

**And the system recurses.** `onatu` $= 144$ is $0 + 12 \cdot 12$, so the $N$ in
$\eqref{eq:add}$ is not restricted to a single root. It can be a whole numeral.
Depth is unbounded, and 1731 is a word:

$$
\text{sunaonatu} = 3 + 12 \cdot 144.
$$

Which is Horner's method, $a_0 + 12(a_1 + 12(a_2 + \cdots))$, spelled out in
morphology — with the subtractive linker allowing a local digit to be negative.

## The grammar

One subtlety deserves to be stated before the grammar rather than after it.
Thirteen is `katu`, never `kanaka`. By $\eqref{eq:add}$ those would be the same
number, $1 + 12 \cdot 1$, and only one of them is Talemi. So `tu` is not a
construction of its own: it is the fused realisation of the linker `na`
followed by the root `ka`. Writing $D\text{tu}$ as a separate production would
generate both forms and get the language wrong.

That leaves two productions:

```text
Numeral ::= Digit
          | Digit na Numeral      -- d + 12·N
          | Digit sa Numeral      -- 12·N - d
```

with $\eqref{eq:add}$ and $\eqref{eq:sub}$ as the semantics, `na ka` surfacing
as `tu`, and `ze` surfacing as `zi` before it.

## Putting it in Lean

The grammar is an inductive type, the semantics is a fold, and the spelling is
a second fold that happens not to be injective on values. Keeping those three
apart is most of the benefit of writing it down formally.

```lean
inductive Digit where
  | o | ka | mi | su | na | lo | te | ri | vo | ze | pe | yu
deriving DecidableEq, Repr

inductive TNum where
  | atom  (d : Digit)
  | add12 (d : Digit) (rest : TNum)
  | sub12 (d : Digit) (rest : TNum)
deriving DecidableEq, Repr

def eval : TNum → Int
  | .atom d       => d.value
  | .add12 d rest => d.value + 12 * eval rest
  | .sub12 d rest => 12 * eval rest - d.value
```

The type of `eval` is `Int` and not `Nat`, which is already a finding: the
grammar builds `kasao` $= 12 \cdot 0 - 1$, and pretending otherwise would mean
a partial function.

Surface form goes through syllables rather than straight to a string, because
the interesting theorem is about syllables:

```lean
def toks : TNum → List Syl
  | .atom d              => [Syl.ofDigit d]
  | .add12 d (.atom .ka) =>
      if d = .o then [.tu] else [Syl.ofDigitBeforeTu d, .tu]
  | .add12 d rest        => Syl.ofDigit d :: .na :: toks rest
  | .sub12 d rest        => Syl.ofDigit d :: .sa :: toks rest
```

The second clause is the fusion: every $d + 12 \cdot 1$ surfaces with `tu`, and
`kanaka` is unwriteable. `Syl.ofDigitBeforeTu` is the `ze → zi` allomorph, and
it lives here, in the renderer, where it cannot affect a value.

## The double life of `na` costs nothing

The digit 4 and the additive linker are the same syllable. Call that an
accidental homonymy and move on, and you have conceded more than you need to:
it introduces no ambiguity whatsoever. Every root is one syllable, so the
syllable sequence is fixed; in that sequence digit positions and linker
positions alternate; a reader going left to right never faces a choice.

The way to say that so it can be checked is to write the reader — independently
of the writer — and prove they agree:

```lean
def parse : List Syl → Option TNum
  | [.tu]    => some (.add12 .o (.atom .ka))
  | [s]      => (s.digit).map .atom
  | [s, .tu] =>
      (s.digitBeforeTu).map fun d => .add12 d (.atom .ka)
  | s :: .na :: rest =>
      match s.digit, parse rest with
      | some d, some n => some (.add12 d n)
      | _, _           => none
  | s :: .sa :: rest =>
      match s.digit, parse rest with
      | some d, some n => some (.sub12 d n)
      | _, _           => none
  | _ => none
```

> [!theorem] Every Talemi numeral can be read back
> ```lean
> theorem parse_toks (t : TNum) : parse (toks t) = some t
> ```
> and therefore, immediately, that distinct trees are distinct words:
> ```lean
> theorem toks_injective {s t : TNum}
>     (h : toks s = toks t) : s = t
> ```

The proof is an induction with one interesting case — the fused `tu`, which
splits on whether the digit is `o` — and the `Option` plumbing does the rest.
That is a stronger claim than the informal solution makes, and it is the sort
of claim that is very easy to believe wrongly.

## The corpus as a test suite

A grammar that compiles is not yet a grammar worth having; `False → anything`
compiles too. So the sixteen attested words are spelled out as trees and
checked both ways — that they read as the manuscript writes them, and that they
value as the manuscript counts them:

```lean
theorem spelling :
    [pe, vo, ri, yu, katu, sutu, tetu, votu, petu,
      sunami, penami, lonasu,
      kasasu, kasana, susana, kasalo].map render
      = ["pe", "vo", "ri", "yu",
        "katu", "sutu", "tetu", "votu", "petu",
        "sunami", "penami", "lonasu",
        "kasasu", "kasana", "susana", "kasalo"] := by
  rfl

theorem equation_A :
    (eval petu, eval katu, eval kasasu) = (22, 13, 35) := by
  rfl
```

Without `spelling`, the equations would only say that some arithmetic is
consistent — not that it is the arithmetic of *these* words.

> [!remark] Why the proofs avoid native_decide
> Every proof here closes by `rfl` or induction. It is tempting to reach for
> `native_decide` on goals that are pure computation, and it would be the wrong
> instinct on this site: `native_decide` hands the step to the compiler instead
> of the kernel and leaves `Lean.ofReduceBool` in the theorem's axiom list,
> which is exactly what [`scripts/verify.sh`](https://github.com/wojciech-stelmaszewski/beyond-any-doubt/blob/main/lean/scripts/verify.sh)
> fails the build on. The honest tactic is also, here, the fast one.

## What formalising it exposes

**Syntax is not semantics.** `kasatu` and `yunayu` are different trees that
`eval` sends to the same 143, and `minasu` and `pesana` both to 38. The
redundancy is a property of the language, not a defect of the reconstruction.

**Surface is not structure.** The `ze → zi` alternation lives in `toks`. The
tree behind `zitu` still holds the digit nine, and `eval` never learns that
anything happened.

**The grammar is permissive, and says so.** `kasao` is a well-formed word
denoting $-1$. Whether Talemi speakers would utter it is a question about
speakers, of whom we have none; if the answer is no, the fix is a
well-formedness predicate, and it belongs in the type, not in a footnote.

**And counting spellings is the wrong question.** My first instinct was to ask
whether every number has finitely many Talemi forms. It does not, and not for
an interesting reason: a zero remainder stacks without limit, so `ka`, `kanao`,
`kanaonao`, `kanaonaonao` are all the number 1, and the same trick pads
anything.

```lean
def zeros : Nat → TNum
  | 0     => .atom .o
  | n + 1 => .add12 .o (zeros n)

def padded (n : Nat) : TNum := .add12 .ka (zeros n)

theorem eval_padded (n : Nat) : eval (padded n) = 1

theorem padded_injective (m n : Nat)
    (h : padded m = padded n) : m = n
```

The question worth asking is about forms without padding, or about a canonical
shortest spelling. Once a system admits negative local digits, choosing that
canonical form is a small but genuinely rich problem — it is the same question
that non-adjacent form answers for binary.

The next step, and the one I have not taken, is the converse of `eval`:

```lean
def encode : Nat → TNum
theorem eval_encode (n : Nat) : eval (encode n) = n
```

which would say that Talemi can name every number, rather than merely that it
names the ones the monk happened to write down.

## The reconstruction

```text
o  = 0     lo = 5      pe = 10
ka = 1     te = 6      yu = 11
mi = 2     ri = 7
su = 3     vo = 8
na = 4     ze = 9
```

Two constructions, $\eqref{eq:add}$ and $\eqref{eq:sub}$, recursive in $N$;
`na ka` fused to `tu`; and `ze` bent to `zi` before it. A signed-digit
duodecimal system written as morphology, unambiguous despite appearances, and
redundant on purpose or by accident — the manuscript does not say which.

Whether Saint Mukosolvan ever used any of it is a matter for palaeography. The
arithmetic checks out, and this time that is not a figure of speech: the model,
the corpus and the unambiguity theorem are in
[`lean/Talemi/`](https://github.com/wojciech-stelmaszewski/beyond-any-doubt/tree/main/lean/Talemi),
and they are rechecked from their axioms on every build.
