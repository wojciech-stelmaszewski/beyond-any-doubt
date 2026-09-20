---
title: The Talemi numerals, and the saint who did not invent them
description: >-
  A few manuscript leaves hide a duodecimal system with signed digits.
  Reconstructing it from six equations, then checking the reconstruction in
  Lean.
published: 2026-09-19
tags: ["numeral systems", "formalisation", "Lean"]
---

It was a bright afternoon in Venice, and I had spent most of it in an
antiquarian shop going along the shelves in no particular order — old printed
books for the most part, and among them a case of manuscript material sold by
the leaf.

I came on them there: a few leaves plainly older than anything shelved with
them. Being a cautious sort of reader I assumed at first that I had misjudged
the hand, which is easy enough to do if you would like it to be old. The
assumption held less well the longer I stood there, and by the time I reached
the sums I had stopped asking it to.

My Latin is basic and my Greek is worse, so what I could establish standing at
the case was only the kind of thing I was holding: a puzzle, with numbers in
it, set in a language that was neither of the two I was struggling with.

What held me was not the age of the leaves, though that was part of it. It was
the flat fact that the thing on the page worked. Six statements in an unknown
tongue, six sums beside them in Greek and in Latin, and between the two a
relation that either holds or does not. Whatever else about the leaves was open
to doubt — and nearly everything was — the arithmetic on them was true in an
absolute sense, and would go on being true whether or not I ever established
where they had come from, or who had written them, or in what language.

I did not buy them. The price was a long way past what I had come out with, and
the dealer, who had shown no interest in me at all until the moment I stopped
turning pages, became attentive in the way that makes a camera impossible. So I
copied them out by hand instead, as faithfully as I could manage, on the
understanding that I would study the copy properly later. This is later.

Everything that follows rests on that copy and on nothing else. It is the first
thing to hold against anything surprising below, and one surprise in particular
turns out to need it.

The leaves credit the puzzle to Eutychios of Mokissos, a holy man of Justinian's
Cappadocia, patron — one is tempted to suppose — of inconvenient notation and
recreational arithmetic.
The provenance is doubtful at nearly every link in the chain, and the one link
that holds turns out to matter. The puzzle is excellent.

## The manuscript

The page is headed `DE QVAESTIONE SANCTI EVTYCHII`, *on the question of Saint
Eutychius*, and opens with the scribe explaining at some length how little he
is prepared to vouch for:

> Temporibus Iustiniani imperatoris fuit in Cappadocia vir quidam sanctus,
> Eutychius nomine, qui apud Mocissum habitabat. Hic hanc quaestionem
> discipulis suis proposuisse **fertur**.
>
> Ex codice Graeco antiquo, qui ad manus meas pervenit, haec transfero. Verbum
> de verbo in Latinum reddo, quantum Latinitas pati potest, nihil de sententia
> sponte mutans.

In the time of the emperor Justinian there was in Cappadocia a certain holy
man, Eutychius by name, who lived at Mokissos. He is *said* to have set this
question to his disciples; the scribe is working from an old Greek codex that
came into his hands; he renders it word for word so far as Latin will bear,
altering nothing of the sense *on purpose*. Four hedges, and the only sentence
that carries no hedge at all is the one giving a place and a date.

Which is convenient, because a place and a date can be checked. The place holds
up well: Mokissos was a real town in Cappadocia, rebuilt by Justinian and
raised to the rank of a metropolis, and both its history and its site are
reasonably well established.[^mokissos] Eutychios is another matter. On him the
sources are silent.

The scribe then reports a note in the margin of the Greek original, in an older
hand:

> Ταῦτα ὁ ὅσιος Εὐτύχιος ὁ ἀπὸ Μωκισσοῦ ἐξ ἑτέρας γλώσσης εἰς τὴν Ἑλληνικὴν
> γλῶσσαν μετήνεγκεν.

*These things the blessed Eutychios of Mokissos translated out of another
tongue into Greek.* The epithet is ὅσιος rather than ἅγιος — the word used of a
monastic, an ascetic, rather than of a martyr — which fits a man remembered for
setting puzzles to disciples. And it means the saint is not the author either:
he is one more copyist in the chain. Then the sentence that turns a text into a
puzzle:

> Cuius autem gentis sive linguae verba primum fuerint, neque auctor nominat
> neque ego invenire potui.

Of what people or language the words first were, the author does not say and I
could not find out. The language is not merely lost; it was never named — though
a damaged gloss may preserve a corner of the name. I call it **Talemi**
below.[^talemi]

One more editorial note, and it is the one that makes the page worth
photographing:

> Numeros, qui in exemplari Graecis litteris notati sunt, sicut scriptos inveni
> servavi; iuxta eos autem eosdem Latinis notis posui. Voces vero peregrinas
> similiter primum Graecis litteris, deinde Latinis litteris reddidi.

He has kept the Greek numerals as he found them and set Roman ones beside them,
and done the same for the foreign words. Everything below therefore appears
twice, which is a considerable gift: it lets a reader check the transcription
against itself.

### The six computations

| As the Greek codex has them | Beside them, in Roman numerals |
| --- | --- |
| ιʹ καὶ ηʹ γίνονται ιηʹ | X et VIII faciunt XVIII. |
| ιεʹ καὶ ζʹ γίνονται κβʹ | XV et VII faciunt XXII. |
| κβʹ καὶ ιγʹ γίνονται λεʹ | XXII et XIII faciunt XXXV. |
| λδʹ καὶ ιαʹ γίνονται μεʹ | XXXIIII et XI faciunt XXXXV. |
| κζʹ καὶ κʹ γίνονται μζʹ | XXVII et XX faciunt XXXXVII. |
| μαʹ καὶ ιηʹ γίνονται νθʹ | XXXXI et XVIII faciunt LVIIII. |

### The same six in the unnamed language

The scribe is careful to warn that the order has been changed — *ordo autem
computationum mutatus est* — so the reader may not simply read down the two
lists in parallel.

| Greek letters | Latin letters |
| --- | --- |
| πετου καὶ κατου γίνονται κασασου | petu et katu faciunt kasasu. |
| σουτου καὶ ρι γίνονται πετου | sutu et ri faciunt petu. |
| σουναμι καὶ βοτου γίνονται κασανα | sunami et votu faciunt kasana. |
| πεναμι καὶ ιου γίνονται σουσανα | penami et iu faciunt susana. |
| λονασου καὶ τετου γίνονται κασαλο | lonasu et tetu faciunt kasalo. |
| πε καὶ βο γίνονται τετου | pe et vo faciunt tetu. |

### What is asked

Four tasks, in the manuscript's own order. First, which of the six sentences
answers to which computation. Second, and this is the real one:

> Deinde ex ipsis vocibus inveniendum est qua ratione homines illius linguae
> numeros componant.

From the words themselves it must be discovered *by what method* the people of
that language compose their numbers. Third, four further words are given for
the reader to evaluate:

| Greek letters | Latin letters |
| --- | --- |
| ιουτου | iutu |
| μινασου | minasu |
| σουσαλο | susalo |
| ρινανα | rinana |

And last, four numbers to be put back into the language:

| Greek letters | Roman numerals |
| --- | --- |
| ιζʹ | XVII |
| κθʹ | XXVIIII |
| μϛʹ | XXXXVI |
| οαʹ | LXXI |

*Explicit quaestio sancti Eutychii.*

### The hand that wrote it down

Below the explicit, the scribe signs off without signing:

> Scriptum Patavii, anno ab incarnatione Domini MCLXXVII, imperante Friderico
> augusto et Alexandro papa sedente, a fratre qui sub regula beati Benedicti
> militat. Qui legis, ora pro scriptore.

Written at Padua, in the year 1177 from the Incarnation, under the emperor
Frederick and with Pope Alexander on the throne, by a brother serving under the
Rule of Saint Benedict; you who read, pray for the writer. A place, a year, two
men he dates by, an order, and no name.

He does not say which house he belonged to, but the place and the year narrow
it, and a little reading narrows it further. A Benedictine at Padua in 1177
points to the abbey of Santa Giustina, which had been the Benedictine house of
the city for two centuries by then.[^trolese] If that is where he was writing,
the least likely part of his story turns ordinary: an old Greek codex — coming
out of Byzantium, in all probability — reaching his hands there in one form or
another.

[^mokissos]: Procopius of Caesarea, *De aedificiis* V.4.15–18
    ([the Loeb text and translation](https://penelope.uchicago.edu/Thayer/E/Roman/Texts/Procopius/Buildings/5*.html)):
    a decayed Cappadocian fortress pulled down, rebuilt on ground too steep to
    assault, given churches and hospices and baths, and raised to a
    metropolis. On where that actually was, see Friedrich Hild, "Jerphanion und
    die Probleme der historischen Geographie Kappadokiens. Neue Forschungen und
    deren Ergebnisse", *Mélanges de l'École française de Rome. Moyen-Âge*
    110/2 (1998), 941–951,
    [on Persée](https://www.persee.fr/doc/mefr_1123-9883_1998_num_110_2_3664).
    Hild follows Honigmann against Jerphanion in placing Mokissos at
    Viranşehir near Helvadere, high on the slopes of Hasan Dağı, where the city
    ruins are sixth-century and the terrain answers to Procopius's description.
    Procopius gives the name as Μωκησός where the leaves have Μωκισσός; both
    forms circulate. None of this literature knows anything of a Eutychios
    there, and looking for him is not helped by the fact that Justinian's reign
    already has a well-known Eutychius — the patriarch of Constantinople —
    against whom every search promptly silts up.

[^talemi]: The name of the language has not survived. The Greek text designates
    it only as "another tongue", ἑτέρα γλῶσσα. A damaged gloss standing beside
    the text does, however, yield the sequence …λημ…, which might be
    reconstructed as part of an otherwise unattested ethnonym — Ταλημοί. I use
    *Talemi* throughout as a working label, and it should be read as exactly
    that: a reconstruction, and not an attested autonym. Nothing below depends
    on it. If the gloss turns out to say something else, every theorem stands
    and only the word for it changes.

[^trolese]: Francesco G. B. Trolese, *S. Giustina di Padova nel quadro del
    monachesimo italiano. Studi di storia e cultura monastica*, ed.
    G. Carraro, R. Frison Segafredo and C. Marcon, Rome: Istituto Storico
    Italiano per il Medio Evo, 2014 (Italia Sacra, new series, 1);
    [the volume, and its presentation in Padua](https://www.centrostoricobenedettinoitaliano.it/f-g-b-trolese-s-giustina-di-padova).
    A caution on wording that I nearly got wrong: it is the *abbey* of Santa
    Giustina in 1177, not the congregation. The Congregation of Santa Giustina
    is a fifteenth-century reform movement, founded by Ludovico Barbo in 1419,
    and calling the house by that name in the twelfth century backdates it by
    some two hundred and fifty years. As for how a Greek book reaches such a
    house: Padua is some forty kilometres from Venice, which traded with
    Constantinople throughout the period, and Greek manuscripts came west along
    that route in quantity.

## The puzzle in modern notation

Three things have to be changed before any of this can be worked on, and none
of them is mathematics. They are worth doing carefully, because two of the
three are places where a transcription can quietly destroy the puzzle.

**The numerals.** Greek alphabetic numerals run α to θ for 1 to 9, ι to ϙ for
the tens, and take a keraia — the mark ʹ — to show they are numbers rather than
letters. So ιηʹ is $10 + 8 = 18$ and νθʹ is $50 + 9 = 59$. One of them is a
trap for the unwary: μϛʹ uses stigma, ϛ, the obsolete letter that holds the
place of 6, so μϛʹ is 46 and not something involving a sigma. The Roman
numerals agree throughout, and they are worth a second look: the scribe writes
`XXXXV`, `XXXXVII`, `LVIIII`, never `XLV` or `LIX`. His own numerals are purely
additive. That he did not modernise them is a small sign he was not
modernising anything else either — and it is quietly funny, given that the
system he is transmitting turns out to subtract.

**The transliteration.** Greek ου spells `u`, and β at this date spells `v`, so
βοτου is `votu`. The one that matters is ιου, which the scribe Latinises as
`iu`: Greek has no letter for the glide, and writes it with iota. It is a
single syllable, and I will write it `yu` from here on, so that every root in
the lexicon is one syllable spelled one way. Nothing hangs on the choice; it is
the same sound the codex writes ιου and the scribe writes `iu`.

**The numbers themselves.** With both of those done, the first table is six
equations over $\mathbb{N}$,

```text
10 + 8  = 18      34 + 11 = 45
15 + 7  = 22      27 + 20 = 47
22 + 13 = 35      41 + 18 = 59
```

and the second is six equations over words, in an order the scribe has told us
is not the same:

```text
A)  petu   + katu = kasasu    D)  penami + yu   = susana
B)  sutu   + ri   = petu      E)  lonasu + tetu = kasalo
C)  sunami + votu = kasana    F)  pe     + vo   = tetu
```

Now the task can be stated. Sixteen distinct words appear. We are looking for a
valuation $\operatorname{val}$ assigning each an integer, together with a
matching $\sigma$ pairing the lettered sentences with the numbered equations,
such that every sentence is true under $\operatorname{val}$ and agrees with the
equation $\sigma$ sends it to.

Put that baldly and the problem is hopeless, because it is also trivial: the
six equations constrain sixteen unknowns, and one can satisfy them in
enormously many ways by simply declaring sixteen numbers. What rules those out
is a condition the manuscript states in a single word. *Qua ratione numeros
componant* — by what method they **compose** numbers. We are not to find
sixteen values. We are to find a way of *building* values, so that
$\operatorname{val}$ is not a table but a function of the shape of the word.

That is what turns the problem into a well-posed one, and it is the whole
reason the last two tasks are there. Four words the reader has never seen must
come out right, and four numbers never yet spelled must be spellable. A table
of sixteen entries can do neither. In modern terms the manuscript has handed us
a training set of six equations and a held-out test set of eight items, and it
is asking for a grammar and a semantics rather than a lookup.

So the object to be recovered is a triple: an alphabet of roots, a grammar
saying how roots combine into words, and a valuation defined by recursion on
that grammar. The rest of this post finds all three, and then checks them.

> [!remark] A word before the solution
> Everything needed is above, and the pleasure of the thing is in finding the
> base yourself. The rest of this post gives it away in the next section.

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
after it is forced — forced, that is, under the syllable hypothesis, and it is
worth saying out loud how much that hypothesis is carrying. It holds that one
syllable is one element of the numeral, that a bare root is a digit, that a
recurring fragment means the same arithmetic thing every time it recurs, and
that a word like `tetu` comes apart at all rather than being a single name for
eighteen. Grant those and there is nothing further to choose. Refuse them and
the six equations admit readings this post never looks at. The check on the
guess, and on the hypothesis carrying it, is that all six equations close and
the eight items the manuscript holds back fall out of the same machinery.

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

## The manuscript's own test

That is the first task answered and the second one guessed at. The third and
fourth are what decide whether the guess was worth making, because nothing in
them was used to arrive at it.

The four words read off without further comment. Each segments into roots and
linkers exactly one way, and $\eqref{eq:add}$ and $\eqref{eq:sub}$ do the rest
— with the manuscript's `iutu` written `yutu`, as agreed:

```text
yutu   = yu-tu        11 + 12       = 23
minasu = mi-na-su      2 + 12 · 3   = 38
susalo = su-sa-lo     12 · 5 - 3    = 57
rinana = ri-na-na      7 + 12 · 4   = 55
```

`rinana` is the nicest of the four, because it puts the two lives of `na` next
to each other — linker then digit — and still reads only one way.

The four numbers go back the other way, and here something happens that the
manuscript gives no sign of noticing:

```text
17  =  5 + 12        lotu
29  =  5 + 12 · 2    lonami
46  = 10 + 12 · 3    penasu     or   12 · 4 - 2    misana
71  = 11 + 12 · 5    yunalo     or   12 · 6 - 1    kasate
```

Two of the four have two answers apiece, of the same length, with nothing to
choose between them. A puzzle that asks the reader to *express* a number has
quietly assumed there is one way to do it, and for 46 and 71 there is not. That
is the first crack in the system, it appears in the manuscript's own exercises,
and the rest of this post is largely about how wide it goes.

## The hole in the middle

Collect the roots the corpus has given us, and something is wrong with the
list:

```text
ka = 1     lo = 5      ?? = 9
mi = 2     te = 6      pe = 10
su = 3     ri = 7      yu = 11
na = 4     vo = 8
```

Every digit from 1 to 11 turns up somewhere in the corpus except nine. Not
"nine is rare" — nine is absent, and there is no arithmetic reason for it. Nor
is there a zero, though that is a different kind of absence and I will come
back to it.

The gap is hard to explain away, because everything else about the puzzle is
carefully made. The six equations are ordered so that each new root is forced
by the ones before it. The two tasks aim squarely at the machinery those
equations establish — reading in one direction, writing in the other — and if
one of them stumbles into an ambiguity the author seems not to have seen, it
still stumbles into it at exactly the interesting place. This is not the work
of somebody who would lose a digit.

So I think something is missing from what I have, and I can see three places it
could have gone. The Greek codex may already have been incomplete when it
reached Padua. The scribe may have dropped a line he did not understand — he
was, after all, copying words in a language nobody had been able to name. Or —
and I cannot rule this out either — I did, copying by hand at speed in a shop
where I was not welcome to linger.

Of the three I think the middle one is the least likely, which is an odd thing
to say about the only person in the chain who was doing the job properly, and
is precisely why. A man who keeps `XXXXV` rather than tidying it to `XLV`,
who hedges four times in two sentences, and who tells you outright that he has
reordered the computations, is not a man who quietly loses a line. Note also
what his promise actually says: he alters nothing of the sense *sponte*, on
purpose. It is a careful word, and it covers nothing accidental — but a
scriptorium is the one place in this story with a discipline against accidents.

Which leaves the codex and me. I would rather it were me, because that is the
only one of the two that can still be fixed.

It is worth being plain about what this means. Something came away from the
text somewhere on its way to this page, and the part that is gone is not a
decoration but a digit — one of the eleven pieces the mechanism needs in order
to run at all. What I have is a fragment of a fragment, and I cannot tell you
at which pair of hands it became one.

Three more things are missing along with the ninth root, and once they are
listed together they look less like four gaps than like one:

- nothing says how to say an exact multiple of twelve;
- nothing says whether the two linkers are interchangeable where both fit;
- nothing says whether the $N$ in $\eqref{eq:add}$ may be more than a single
  root.

## Completing the system

From here I stop reading and start proposing. What follows is a reconstruction
— the smallest set of assumptions I can find that turns the fragment into a
numeral system — and none of it is attested. I mark each assumption where it
arrives.

**A root for nine.** The inventory needs one, and nothing tells me what it
sounded like. I need a name to state theorems about, so I will write it `ze`,
chosen to fit the shape of the others and meaning nothing more than "the ninth
root, whatever it was". Every claim below that mentions `ze` is a claim about
the slot, not about the syllable.

**A zero remainder.** This much is forced; whether the language had an overt
root for it is not. An exact multiple of twelve needs a zero in the units
place: twenty-four is $0 + 12 \cdot 2$, and no other digit will do, because
$\eqref{eq:add}$ with $d \ge 1$ gives at least $1 + 12k$ and $\eqref{eq:sub}$
would need a digit of twelve. So the units slot has to be fillable by something
that contributes nothing. For the formal model I give that slot the
conventional root `o`, and then exact multiples of twelve go `onate` $= 72$,
`onari` $= 84$, `onaze` $= 108$.

> [!remark] How much of a zero?
> Saying that the arithmetic needs a zero remainder is not the same as saying
> the language had a word for nothing, and at least three arrangements fit
> equally well. There may have been an overt root, as reconstructed here, used
> inside compounds and perhaps never as an answer to "how many?". There may
> have been a zero morpheme, nothing at all pronounced in the units position,
> so that twenty-four was $\varnothing\text{-na-}\mathrm{mi}$ where I write
> `onami`. Or exact multiples of twelve may have had a construction of their
> own that does not use the units slot.
>
> The second is the linguistically interesting one, and nothing here can touch
> it, for a reason worth stating: of the twenty words the manuscript actually
> spells — sixteen in the equations, four more set for reading — not one
> denotes an exact multiple of twelve. The corpus never exercises the slot at
> all, so it cannot distinguish a root that is pronounced from one that is not.
>
> The formalisation is then more generous than the argument that motivates it,
> and the gap is worth naming rather than hiding. `o` is an ordinary digit in
> the type, so the bare word `o` is well-formed and denotes zero on its own —
> which is precisely the thing the paragraph above declines to claim. Nothing
> below depends on it, but it is assumed rather than deduced.

**Both linkers live.** The corpus uses `na` and `sa` both, and gives no sign
that either is preferred where the two would fit. I assume they are simply
alternatives, which is the weaker assumption — and the manuscript's own
exercises have already shown what it costs, since 46 is both `penasu` and
`misana` and 71 is both `yunalo` and `kasate`. What a grammar permits and what
a speaker would prefer are separate questions, and the second needs usage data
that six equations cannot supply.

**Unbounded recursion.** Here parsimony decides. If the $N$ in
$\eqref{eq:add}$ must be a bare root, the language stops at
$11 + 12 \cdot 11 = 143$ and the rule needs an extra clause to say so. If $N$
may be any numeral, no clause is needed and the language goes on forever. The
corpus reaches 59 and so cannot tell the two apart, but one of them requires a
restriction that nothing supports, and the other is what you get by writing the
rule down and leaving it alone. So depth is unbounded, and 1731 is a word:

$$
\text{sunaonatu} = 3 + 12 \cdot 144.
$$

Which is Horner's method,[^horner] $a_0 + 12(a_1 + 12(a_2 + \cdots))$, spelled
out in morphology — with the subtractive linker allowing a local digit to be
negative.

[^horner]: Horner's method is the ordinary way of evaluating a polynomial
    without computing any powers: $a_0 + a_1x + a_2x^2 + a_3x^3$ is rewritten
    as $a_0 + x(a_1 + x(a_2 + x a_3))$, which costs one multiplication per
    coefficient instead of growing quadratically. The name comes from
    W. G. Horner, "A new method of solving numerical equations of all orders,
    by continuous approximation", *Philosophical Transactions of the Royal
    Society of London* 109 (1819), 308–335,
    [doi:10.1098/rstl.1819.0023](https://doi.org/10.1098/rstl.1819.0023) — a
    paper about finding roots, in which the nested evaluation is the inner step
    rather than the point. Like most things named after somebody it is older
    than its name: Newton was using the nested form a century earlier, and it
    appears in thirteenth-century China in the work of Qin Jiushao. Donald
    Knuth gives the method and its history in *The Art of Computer
    Programming*, vol. 2, §4.6.4; for the Chinese side, the standard study is
    Ulrich Libbrecht, *Chinese Mathematics in the Thirteenth Century: The
    Shu-shu Chiu-chang of Ch'in Chiu-shao* (MIT Press, 1973).

    What makes it worth naming here is that the nesting is not an optimisation
    applied to the language from outside; it is the shape of the language. Each
    `na` is one set of brackets. So `sunaonatu` is
    $3 + 12(0 + 12(0 + 12 \cdot 1)) = 1731$, and its roots spell the
    base-twelve digits 3, 0, 0, 1 of that number, least significant first. The
    subtractive linker is the one departure from the textbook scheme, since it
    lets a coefficient come out negative.

Everything after this point is about the reconstructed system. Where it turns
out to behave badly — and it does, in a way I did not expect — the fault may be
the language's or may be mine, and I will say which cases I think are which.

## The grammar

One subtlety deserves to be stated before the grammar rather than after it.
Thirteen is `katu`, never `kanaka`. By $\eqref{eq:add}$ those would be the same
number, $1 + 12 \cdot 1$, and only one of them is Talemi. So `tu` is not a
construction of its own: it is the fused realisation of the linker `na`
followed by a `ka` that ends the word. Writing $D\text{tu}$ as a separate
production would generate both forms and get the language wrong.

That leaves two productions:

$$
\begin{array}{rcll}
\mathit{Numeral} & \Coloneqq & \mathit{Digit} \\[2pt]
 & \mid & \mathit{Digit}\;\,\mathrm{na}\;\,\mathit{Numeral}
       & \quad d + 12N \\[2pt]
 & \mid & \mathit{Digit}\;\,\mathrm{sa}\;\,\mathit{Numeral}
       & \quad 12N - d
\end{array}
$$

with $\eqref{eq:add}$ and $\eqref{eq:sub}$ as the semantics, and the fusion
applied to the finished word.

That fusion is narrower than "`na ka` surfaces as `tu`" makes it sound, in two
ways worth pinning down. It reaches the bottom rung only, where `ka` is the
whole remainder rather than a digit with more word behind it: thirteen padded
out to `kanakanao` keeps its internal `na ka` intact and does not collapse to
`katunao`. And where the digit on that bottom rung is `o`, the `o` goes unsaid
as well, so twelve is `tu` and not `otu`, and $145$ is `kanatu` and not
`kanaotu`. Stated on the syllable string, the two rules are: word-final
`na ka` becomes `tu`, and then word-final `o tu` becomes `tu`.

> [!remark] Where this sits in the Chomsky hierarchy
> Lower than the recursion makes it look. `Digit` expands to one of twelve
> roots and to nothing else, so substituting it out leaves every production in
> the form `Numeral → w` or `Numeral → w Numeral`. That is a right-linear
> grammar, and the language is therefore regular rather than merely
> context-free: it is
> $\text{Digit}\,\bigl((\mathrm{na} \mid \mathrm{sa})\ \text{Digit}\bigr)^{*}$,
> and two states recognise it — one expecting a root, one expecting a linker
> or the end of the word.[^rightlinear]
>
> The fusion is the part that looks as though it might push the system higher,
> a rule conditioned by its environment being the shape of a context-sensitive
> production. It does not. It is a realisation rule applied to the output
> rather than a production of the grammar, and it is itself finite-state, so
> the surface forms are a rational image of a regular language and regular in
> turn.[^rational] Which is why the reader below can be a single left-to-right
> pass with nothing to backtrack over — three states rather than two, once the
> fused `tu` is given one of its own.

```figure
{ "diagram": "talemi-reader", "caption": "The reader as a finite automaton. Two states carry the grammar proper — one wanting a root, one wanting a linker — and the third is what the fusion costs, since <code>tu</code> closes a word and nothing may follow it. A double ring marks a state a word may end in, which is why <code>kana</code> is refused: it stops having promised the linker something to link. Pick a word to walk it through, or click a syllable to stop there." }
```

[^rightlinear]: The equivalence is the standard one between right-linear
    grammars and finite automata: read a production $N \to w\,N'$ as "emit $w$
    and go to the state for $N'$", and $N \to w$ as "emit $w$ and stop". What
    makes it available here is that `Digit` is a nonterminal with only
    terminal right-hand sides, so substituting it out leaves no recursion
    except at the right end — and recursion at the right end is iteration,
    which is exactly what a loop in an automaton is. The class is fixed by the
    *shape* of the productions rather than by how recursive the definition
    looks: a grammar with the nonterminal in the middle, `Numeral → a Numeral
    b`, is not right-linear, and grammars of that shape can generate languages
    no automaton recognises. The classification is Chomsky's: N. Chomsky, "On
    certain formal properties of grammars", *Information and Control* 2/2
    (1959), 137–167,
    [doi:10.1016/S0019-9958(59)90362-6](https://doi.org/10.1016/S0019-9958(59)90362-6);
    the finite-state case had been worked out the year before in N. Chomsky
    and G. A. Miller, "Finite state languages", *Information and Control* 1/2
    (1958), 91–112,
    [doi:10.1016/S0019-9958(58)90082-2](https://doi.org/10.1016/S0019-9958(58)90082-2).
    Both are open archive at Elsevier.

[^rational]: A transduction a finite-state transducer can perform is called
    rational, and rational transductions carry regular languages to regular
    languages — so a fusion applied to the output of a regular grammar cannot
    push the result out of the class, however context-sensitive the rule reads
    on the page. The argument is Nivat's: every rational transduction factors
    as $\tau(X) = \psi\bigl(\varphi^{-1}(X) \cap K\bigr)$ for morphisms
    $\varphi, \psi$ and a regular $K$, and inverse morphism, intersection with
    a regular set, and morphic image each preserve regularity. Jean Berstel,
    *Transductions and Context-Free Languages* (Stuttgart: Teubner, 1979),
    gives Nivat's theorem as III.4.1 and the closure as III.4.2; the book is
    [available from the author](http://www-igm.univ-mlv.fr/~berstel/LivreTransductions/LivreTransductions.pdf).
    Berstel writes "rational" where this post writes "regular"; over a free
    monoid the two words name the same family.

## Writing it down so a machine can check it

Everything from here on is a theorem in a small Lean library, which you can
[read or download](#the-lean-sources) at the end. The statements and their
proofs are given here in words; what the library adds is that a machine has
checked every step of them, and the tactic scripts are of no interest to
anybody who is not writing tactic scripts.

Three things have to be kept apart, and the prose solution above runs them
together: a numeral as a *tree*, the *number* that tree denotes, and the
*syllables* it is said with. Most of the benefit of formalising is the
discipline of not letting those merge.

The tree is the grammar read as an inductive definition: a numeral is a bare
digit, or a digit joined by `na` to a numeral, or a digit joined by `sa` to a
numeral. The recursive occurrence — "a numeral", not "a digit" — is the
unbounded depth assumed above.

The number is the fold: $\eqref{eq:add}$ and $\eqref{eq:sub}$, with
$\operatorname{val}$ of a bare digit being the digit. Its values are integers
and not naturals, which is already a finding rather than a design choice. The
grammar builds `kasao` $= 12 \cdot 0 - 1$, so insisting on $\mathbb{N}$ would
make $\operatorname{val}$ a partial function and every later theorem uglier.

The syllables are a second fold, $\operatorname{say}$, which sends a numeral to
a *sequence of syllables* rather than to a string — the theorem worth proving
is about syllables, and a string would have thrown away the boundaries. It has
four clauses where $\operatorname{val}$ has three:

$$
\begin{aligned}
\operatorname{say}(d) &= \langle d \rangle, \\
\operatorname{say}(d\text{-na-}\mathrm{ka}) &= \langle d, \text{tu} \rangle,
  \quad\text{or } \langle \text{tu} \rangle \text{ when } d = \mathrm{o}, \\
\operatorname{say}(d\text{-na-}N) &= \langle d, \text{na} \rangle
  \frown \operatorname{say}(N), \\
\operatorname{say}(d\text{-sa-}N) &= \langle d, \text{sa} \rangle
  \frown \operatorname{say}(N).
\end{aligned}
$$

The second clause claims $d\text{-na-}\mathrm{ka}$ before the third can, and
that is the whole of the fusion: `kanaka` is not discouraged, it is unsayable,
because nothing in $\operatorname{say}$ can emit it. Note where the fusion
lives — in the speller, where it cannot reach a value.

## The double life of `na` costs nothing

The digit 4 and the additive linker are the same syllable. Call that an
accidental homonymy and move on, and you have conceded more than you need to:
it introduces no ambiguity whatsoever. Every root is one syllable, so the
syllable sequence is fixed; in that sequence digit positions and linker
positions alternate; a reader going left to right never faces a choice.

The way to say that so it can be checked is to write the reader as a function
in its own right, without looking at the speller, and then prove the two
agree. Call it $\operatorname{read}$; it takes a sequence of syllables to a
numeral or to nothing, and it decides by looking at the front of the sequence.
A lone `tu` is twelve. A lone root is that bare digit. A root followed by `tu`
is that digit plus twelve. A root, then `na` or `sa`, then anything that reads,
is the corresponding compound. Nothing else reads at all.

> [!theorem] Every Talemi numeral can be read back
> For every numeral $N$, reading the syllables of $N$ returns $N$ itself:
> $\operatorname{read}(\operatorname{say}(N)) = N$. Distinct numerals are
> therefore distinct words — $\operatorname{say}$ is injective.

> [!proof]
> Induction on the structure of $N$, one case per clause of
> $\operatorname{say}$.
>
> If $N$ is a bare digit $d$, then $\operatorname{say}(N) = \langle d \rangle$,
> a single syllable. The reader's rule for a one-syllable word asks whether
> that syllable is `tu`; a digit root never is, so it falls through to the
> rule that returns the bare digit, and that digit is $d$.
>
> If $N = d\text{-na-}\mathrm{ka}$ and $d = \mathrm{o}$, then
> $\operatorname{say}(N) = \langle \text{tu} \rangle$ and the reader's first
> rule returns $\mathrm{o}\text{-na-}\mathrm{ka}$, which is $N$. If instead
> $d \ne \mathrm{o}$, then $\operatorname{say}(N)$ is the root of $d$ followed
> by `tu`, and the reader's rule for that shape reads the first syllable as a
> digit, recovering $d$, and rebuilds the rung the `tu` stands for.
>
> If $N = d\text{-na-}M$ with $M$ not the bare $\mathrm{ka}$, then
> $\operatorname{say}(N)$ is the root of $d$, then `na`, then
> $\operatorname{say}(M)$. Every spelling is at least one syllable long, so
> this word has at least three, which rules out all three of the reader's
> short-word rules and leaves the one that matches a root, a linker and a
> tail. It reads the first syllable as a digit, giving $d$; it recurses on
> $\operatorname{say}(M)$, which by the induction hypothesis gives $M$; and it
> assembles $d\text{-na-}M$. The case of `sa` is the same with one fewer
> subtlety, since no `sa` word ever fuses.
>
> Injectivity follows at once. If $\operatorname{say}(S) = \operatorname{say}(T)$,
> apply $\operatorname{read}$ to both sides: the left gives $S$ and the right
> gives $T$, so $S = T$.

The load-bearing step is the third one. The reader is never in doubt about
whether a `na` in front of it is the digit 4 or the linker, because it is not
deciding by *syllable* but by *position*, and the positions cannot drift: every
root is exactly one syllable, so digits sit at even offsets and linkers at odd
ones, all the way down. That is a stronger claim than the informal solution
makes, and it is the sort of claim that is very easy to believe wrongly.

> [!remark] What the theorem does not say
> It says the reader recovers what the writer meant. It does not say the reader
> rejects what no writer would produce, and mine does not: $\operatorname{read}$
> takes `kanaka` for thirteen quite happily, although $\operatorname{say}$ will
> only ever emit `katu`. The grammar of comprehension is wider here than the
> grammar of production. Tightening the reader would be a few lines; whether a
> language ought to have a reader stricter than its speakers is not a question
> six equations can answer.

## The corpus as a test suite

A grammar that compiles is not yet a grammar worth having; $\text{False} \to
\text{anything}$ compiles too. So every attested word is written out as a tree
and checked twice over: that $\operatorname{say}$ sends each tree to the string
the manuscript actually prints, and that $\operatorname{val}$ sends it to the
number the manuscript actually counts.

Both halves are needed. Without the spelling check the arithmetic would say
only that some arithmetic is consistent — not that it is the arithmetic of
*these* words.

The manuscript's own test set is checked the same way, including the part the
manuscript got wrong: that `misana` and `penasu` are distinct words of equal
length both worth 46, and likewise `kasate` and `yunalo` for 71. It is a small
satisfaction to have the flaw in a twelfth-century exercise recorded as a
theorem.

## What formalising it exposes

**Syntax is not semantics.** `kasatu` and `yunayu` are different trees that
$\operatorname{val}$ sends to the same 143, and `penasu` and `misana` both to
46. The redundancy is a property of the language, not a defect of the
reconstruction.

**Surface is not structure.** The fusion of `na ka` into `tu` lives in
$\operatorname{say}$ alone. The tree behind `katu` still holds a rung with two
parts, and $\operatorname{val}$ never learns that they were said as one
syllable.

**The grammar is permissive, and says so.** `kasao` is a well-formed word
denoting $-1$. Whether Talemi speakers would utter it is a question about
speakers, of whom we have none; if the answer is no, the fix is a
well-formedness predicate, and it belongs in the type, not in a footnote.

**And counting spellings is the wrong question.** My first instinct was to ask
whether every number has finitely many Talemi forms. It does not, and not for
an interesting reason: a zero remainder stacks without limit, so `ka`, `kanao`,
`kanaonao`, `kanaonaonao` are all the number 1, and the same trick pads
anything.

> [!theorem] One has infinitely many spellings
> Write $\mathrm{ka}\text{-na-}\mathrm{o}^{n}$ for `ka` under a stack of $n$
> zero rungs. Every one of them has value 1, and they are pairwise distinct, so
> the spellings of 1 form an infinite set. The same padding works above any
> numeral, so this holds of every value.

> [!proof]
> Let $Z_0 = \mathrm{o}$ and $Z_{n+1} = \mathrm{o}\text{-na-}Z_n$, and put
> $P_n = \mathrm{ka}\text{-na-}Z_n$. Then $\operatorname{val}(Z_n) = 0$ for
> every $n$, by induction: the base is the digit zero, and the step is
> $0 + 12 \cdot 0 = 0$. Hence $\operatorname{val}(P_n) = 1 + 12 \cdot 0 = 1$,
> for every $n$ at once.
>
> The $P_n$ are pairwise distinct because $Z_m = Z_n$ forces $m = n$: the two
> sides carry $m$ and $n$ nested linkers, and peeling them off one at a time
> matches the counts. So $n \mapsto P_n$ injects $\mathbb{N}$ into the
> spellings of 1.
>
> For an arbitrary value the same move works one level down. In any numeral,
> replace the innermost root $d$ by $d\text{-na-}\mathrm{o}$; since
> $d = d + 12 \cdot 0$ the value is untouched, while the tree gains a rung. So
> iterating gives trees of strictly increasing size, which are pairwise
> distinct, and distinct trees are distinct words by the injectivity of
> $\operatorname{say}$ above.
>
> It is tempting to count syllables instead and say the word grows by two each
> time, and that is false: padding underneath a fused rung destroys the fusion.
> `katu` is two syllables, and padding its lower `ka` yields `kanakanao` at
> five. The growth is strict but not constant, which is exactly why the
> argument is better made on trees.

The question worth asking is about forms without padding, or about a canonical
shortest spelling. Which turns out to be the thread that unravels the rest of
the system.

## Can Talemi name every number?

The corpus gives twenty-odd words and stops. That leaves open whether Talemi is
a notation for arithmetic at all, or a list of number names that happens to run
out — and the way to settle it is a construction rather than an existence
argument. The construction is long division, read backwards: a number below
twelve is its own root, and anything else is its remainder on division by
twelve, then `na`, then the word for the quotient. Write $\operatorname{enc}(n)$
for the result. The recursion terminates because dividing by twelve shrinks
anything that is at least twelve.

> [!theorem] Every natural number has a Talemi word
> $\operatorname{val}(\operatorname{enc}(n)) = n$ for every natural number $n$.
> The proof is a construction, so it does not merely assert the word exists —
> it hands you the word.

> [!proof]
> First, $\operatorname{enc}$ is defined on every $n$: the recursive call is
> made only when $n \ge 12$, and then $\lfloor n/12 \rfloor < n$, so the
> argument strictly decreases and the recursion halts.
>
> Now induct along that recursion. If $n < 12$ then $\operatorname{enc}(n)$ is
> the root for $n$, and the roots are precisely the values $0$ through $11$, so
> its value is $n$. If $n \ge 12$ then
> $$
> \begin{aligned}
> \operatorname{val}(\operatorname{enc}(n))
>   &= (n \bmod 12)
>      + 12 \operatorname{val}(\operatorname{enc}(\lfloor n/12 \rfloor)) \\
>   &= (n \bmod 12) + 12 \lfloor n/12 \rfloor \;=\; n,
> \end{aligned}
> $$
> the middle step by the induction hypothesis and the last by division with
> remainder. The digit is legitimate because $n \bmod 12$ lies in $0$ to $11$,
> which is exactly the range the roots cover.

So 144 is `onatu`, 1728 is `onaonatu`, and 20735 is `yunayunayunayu`. None of
those needed a manuscript entry — the grammar generates them, which is the only
credential a numeral system can offer.

But the construction has a property worth more than the theorem it proves.
Look at what it never writes. Long division produces remainders between zero
and eleven, which is precisely the range the additive linker covers, so `sa` is
never reached — not as an optimisation, but because there is never an occasion
for it.

## What the subtractive linker is for

If `na` alone names every natural number, then `sa` adds nothing above zero. It
does add something, and the formal statement says exactly what.

> [!theorem] The additive fragment is exactly the non-negative integers
> Call a numeral *additive* when `sa` occurs nowhere inside it. Then an integer
> $v$ is the value of some additive numeral if and only if $v \ge 0$.

> [!proof]
> For the forward direction, induct on an additive $N$. If $N$ is a bare digit
> its value is one of $0$ to $11$, so non-negative. If $N = d\text{-na-}M$ then
> $M$ is additive too, so $\operatorname{val}(M) \ge 0$ by the induction
> hypothesis, and $\operatorname{val}(N) = d + 12\operatorname{val}(M)$ is a
> sum of two non-negative terms. The subtractive case cannot arise, because a
> numeral containing `sa` is not additive.
>
> For the converse, take $v \ge 0$ and use $\operatorname{enc}(v)$. Its value
> is $v$ by the previous theorem, and it is additive by the same induction
> that defines it: each step builds either a bare root or an `na` rung, and
> `sa` is never reached, because the remainders long division produces already
> lie in $0$ to $11$.

Read left to right that says no additive word is negative; right to left, that
$\operatorname{enc}$ reaches everything that is not. And below zero the system
does not give out either — a second construction bottoms out at
$d\text{-sa-o}$, which is $12 \cdot 0 - d$, and reaches the rest of the
integers from there.

> [!theorem] Every integer has a Talemi word
> For every integer $v$, positive or negative, there is a numeral whose value
> is $v$. Below zero every such numeral must contain `sa`, by the theorem
> above.

> [!proof]
> Extend the construction with a second base case. For $0 \le v < 12$ take the
> root for $v$, as before. For $-12 < v < 0$ take $d\text{-sa-}\mathrm{o}$
> where $d$ is the root for $-v$, whose value is
> $12 \cdot 0 - (-v) = v$. Otherwise take
> $(v \bmod 12)\text{-na-}\operatorname{encInt}(\lfloor v/12 \rfloor)$.
>
> The division here is the flooring one, rounding towards $-\infty$, and that
> is what makes the construction work below zero: it keeps the remainder in
> $0$ to $11$ on both sides of zero, so the digit is always a genuine root.
> Outside the two base ranges $|\lfloor v/12 \rfloor| < |v|$, so the recursion
> halts, and induction on $|v|$ gives
> $(v \bmod 12) + 12\lfloor v/12 \rfloor = v$ exactly as before.
>
> That every negative value needs `sa` is the previous theorem read
> contrapositively: an additive numeral has non-negative value, so a numeral
> of negative value is not additive.

Minus one is `kasao`, minus thirteen is `yunamisao`, minus a hundred is
`vonazesao`, and every one of them contains `sa`, necessarily.

That is a sharper answer than the manuscript could give to the question of why
the language has two linkers, and it is slightly deflating. Across the whole
manuscript `sa` appears five times, and every one of those five words is a
positive number — `kasasu` is 35 and could equally have been `yunami`. The one
job only `sa` can do is a job the monk never asks it to do.

## Nor does it save breath

The remaining defence of the subtractive linker is economy. Roman numerals
subtract for exactly that reason: `IX` spends two characters where `VIIII`
spends five, and that is the whole of its justification. `kasasu` reads as "one
short of three twelves", and if that were a syllable cheaper than "eleven and
two twelves" then `sa` would have earned its place after all.

It is not, and the theorem is general.

> [!theorem] The additive spelling is always a shortest spelling
> If a numeral $N$ has value $n \ge 0$, then $\operatorname{enc}(n)$ has no
> more syllables than $N$. No spelling of a non-negative number ever beats the
> plain long-division one.

The proof turns on a single function. Let $\operatorname{cap}(k)$ be the
largest value any word of $k$ syllables can denote:

$$
\operatorname{cap}(0) = -1, \qquad
\operatorname{cap}(1) = 12, \qquad
\operatorname{cap}(2) = 23,
$$

$$
\operatorname{cap}(k+3) = 11 + 12 \operatorname{cap}(k+1).
$$

The recurrence steps by two rather than by one, and that is the fusion showing
up in the arithmetic. A rung normally costs two syllables, a digit and a
linker; the bottom rung costs one when it fuses into `tu`. So one syllable
already reaches `tu` $= 12$, two reach `yutu` $= 23$, and from there each
further pair of syllables multiplies the reach by twelve and adds eleven for
the new digit. The first few values are $-1$, $12$, $23$, $155$, $287$,
$1871$ — the $-1$ recording that no word is empty.

The theorem is then two inductions that meet in the middle.

> [!proof]
> **The ceiling holds.** Every numeral $N$ satisfies
> $\operatorname{val}(N) \le \operatorname{cap}(\operatorname{len} N)$, by
> induction on $N$.
>
> A bare digit has length 1 and value at most 11, and
> $\operatorname{cap}(1) = 12$. For $d\text{-na-}\mathrm{ka}$ there are two
> shapes: if $d = \mathrm{o}$ the word is the single syllable `tu` of value
> 12, meeting $\operatorname{cap}(1)$ exactly; otherwise it is two syllables
> of value $d + 12 \le 23 = \operatorname{cap}(2)$.
>
> Otherwise $N$ has a rung over some $M$, and
> $\operatorname{len} N = 2 + \operatorname{len} M$. Every word is at least
> one syllable, so write $\operatorname{len} M = m + 1$ and
> $\operatorname{len} N = m + 3$. If the rung is additive,
> $$
> \operatorname{val}(N) = d + 12\operatorname{val}(M)
>   \le 11 + 12 \operatorname{cap}(m+1) = \operatorname{cap}(m+3),
> $$
> using the induction hypothesis and the recurrence. If it is subtractive,
> $$
> \operatorname{val}(N) = 12\operatorname{val}(M) - d
>   \le 12 \operatorname{cap}(m+1) \le \operatorname{cap}(m+3),
> $$
> because $d \ge 0$. This is where the claim earns its keep: the same ceiling
> holds either way, so subtraction buys no extra reach at any length.
>
> **The ceiling is attained by long division.** If
> $n \le \operatorname{cap}(k)$ then
> $\operatorname{len}(\operatorname{enc}(n)) \le k$, by induction along the
> recursion of $\operatorname{enc}$.
>
> If $n < 12$ the word is one syllable, and $k \ge 1$ because
> $\operatorname{cap}(0) = -1$ is below every natural number. If $n \ge 12$,
> let $q = \lfloor n/12 \rfloor$. When $q = 1$ the word fuses: it is the
> single syllable `tu` if $n = 12$, and two syllables otherwise, and in the
> second case $n > 12 = \operatorname{cap}(1)$ forces $k \ge 2$. When
> $q \ge 2$ there is no fusion, so
> $\operatorname{len}(\operatorname{enc}(n)) = 2 + \operatorname{len}(\operatorname{enc}(q))$.
> Here $n \ge 24 > \operatorname{cap}(2)$, so $k \ge 3$; write $k = j + 3$.
> From $12q \le n \le 11 + 12\operatorname{cap}(j+1)$ we get
> $12\,(q - \operatorname{cap}(j+1)) \le 11$, and a multiple of twelve that is
> at most eleven is at most zero, so $q \le \operatorname{cap}(j+1)$. The
> induction hypothesis gives
> $\operatorname{len}(\operatorname{enc}(q)) \le j+1$, hence
> $\operatorname{len}(\operatorname{enc}(n)) \le j + 3 = k$.
>
> **They meet.** Let $N$ be any numeral of value $n \ge 0$. The first half
> puts $n \le \operatorname{cap}(\operatorname{len} N)$; the second then gives
> $\operatorname{len}(\operatorname{enc}(n)) \le \operatorname{len} N$.

So subtraction in Talemi is not the subtraction of Roman numerals. It reaches
no new number and shortens no old one.

## Where uniqueness comes from

What subtraction does do is create ties. `kasasu` and `yunami` are both 35,
both three syllables, and neither can be improved on.

> [!theorem] Thirty-five has two shortest spellings, not one
> `kasasu` and `yunami` are distinct numerals, both of value 35, and no numeral
> of value 35 has fewer than three syllables. Both are shortest, so "the"
> shortest spelling is not a well-defined notion.

> [!proof]
> `kasasu` is $\mathrm{ka}\text{-sa-}\mathrm{su}$, worth
> $12 \cdot 3 - 1 = 35$; `yunami` is $\mathrm{yu}\text{-na-}\mathrm{mi}$,
> worth $11 + 12 \cdot 2 = 35$. They are distinct — one has `sa` where the
> other has `na` — and both are three syllables long.
>
> Nothing shorter reaches 35. By the ceiling, a two-syllable word denotes at
> most $\operatorname{cap}(2) = 23$ and a one-syllable word at most
> $\operatorname{cap}(1) = 12$, both below 35. So every spelling of 35 has at
> least three syllables, and these two attain the bound.

How typical is that? Counting requires enumerating, and an enumeration is worth
nothing until it is known to be exactly right, so both halves are proved before
anything is counted: that the enumeration misses no numeral of the given value,
and that it invents none.

The enumeration is smaller than it looks, for a reason worth pausing on. At
each rung the value fixes the digit. If $v = d + 12w$ with $0 \le d < 12$ then
$d$ must be $v \bmod 12$ and $w$ must be $\lfloor v/12 \rfloor$, with nothing
left to choose, and the subtractive rung is pinned the same way. A
Talemi numeral is therefore not a free choice of digits at all. It is a
sequence of choices between `na` and `sa`, one per rung — a binary tree, and a
shallow one, since the ceiling bounds a shortest spelling below 1872 at five
syllables and so at three rungs.

> [!theorem] Forty-six numbers in four hundred, in three blocks
> Among the natural numbers below 400, the shortest spelling is unique for
> exactly forty-six of them: those from 0 to 23, those from 145 to 155, and
> those from 277 to 287. Every other number below 400 is tied.

> [!proof]
> The work is in making the question finite; once it is, the answer is a
> computation.
>
> **Three rungs suffice.** Each rung costs two syllables, except a fused
> bottom rung which costs one, so a numeral with $r$ rungs has
> $2r \le \operatorname{len} + 1$. A word of at most five syllables therefore
> has at most three rungs.
>
> **Five syllables suffice.** For $n < 1872 = \operatorname{cap}(5)$, the
> reach half of the previous proof gives
> $\operatorname{len}(\operatorname{enc}(n)) \le 5$. A shortest spelling of
> $n$ is no longer than that one, so it too is at most five syllables, hence
> at most three rungs. Nothing relevant lies outside the search.
>
> **The search is exact.** Enumerating to depth three returns every numeral
> of the target value with at most three rungs and nothing else — the first
> half by induction on the numeral, the second by induction on the
> enumeration. So the least length appearing in the enumerated list is the
> true minimum over *all* numerals, not merely over the searched ones, and
> the enumerated words attaining it are exactly the shortest spellings.
>
> **The computation.** Uniqueness at $n$ is now decidable: enumerate, keep
> the shortest, and ask whether two distinct words survive. Running that for
> each $n < 400$ yields precisely $\{0,\dots,23\}$, $\{145,\dots,155\}$ and
> $\{277,\dots,287\}$. That last equality is where a reader has to trust
> something, and what is trusted is the kernel evaluating a closed term, not
> a program I wrote and ran.

Three runs — 0 to 23, 145 to 155, 277 to 287 — and not a scatter. Blocks want
an explanation, and the ceiling turns out to be it. Those runs end at 23, 155 and
287, which are $\operatorname{cap}(2)$, $\operatorname{cap}(3)$ and
$\operatorname{cap}(4)$: exactly the most that two, three and four syllables can
say.

The reason is one line of the ceiling argument, read the other way round.

> [!theorem] No subtractive word comes within eleven of the ceiling
> If a numeral $N$ of $k$ syllables uses `sa` anywhere at all, then
> $\operatorname{val}(N) \le \operatorname{cap}(k) - 11$.

> [!proof]
> Take first the case where the subtraction is outermost, $N = d\text{-sa-}M$.
> As before $k = 2 + \operatorname{len} M$, so with
> $\operatorname{len} M = m+1$ we have $k = m+3$. Then
> $$
> \operatorname{val}(N) = 12\operatorname{val}(M) - d
>   \le 12\operatorname{cap}(m+1)
>    = \operatorname{cap}(m+3) - 11,
> $$
> the inequality because $d \ge 0$ and $\operatorname{val}(M) \le
> \operatorname{cap}(m+1)$, and the last step by the recurrence
> $\operatorname{cap}(m+3) = 11 + 12\operatorname{cap}(m+1)$.
>
> The eleven is exactly the digit the additive rung gets to add and the
> subtractive rung has to give back.
>
> That much only rules out words that subtract *last*, which would leave room
> for a rival hiding its `sa` under an additive rung. It cannot hide there.
> Suppose $N = d\text{-na-}M$ where $M$ uses `sa` somewhere, and let $M$ be
> $m+1$ syllables, so $N$ is $m+3$. The inductive hypothesis gives
> $\operatorname{val}(M) \le \operatorname{cap}(m+1) - 11$, and therefore
> $$
> \operatorname{val}(N) = d + 12\operatorname{val}(M)
>   \le 11 + 12\bigl(\operatorname{cap}(m+1) - 11\bigr)
>    = \operatorname{cap}(m+3) - 132.
> $$
> Burying the subtraction costs more than leaving it on top: the rung above
> multiplies the shortfall by twelve while handing back at most eleven. So the
> bound holds at every depth, with room to spare below the top one.

Eleven short, every time — and for every word that subtracts anywhere, not
merely for those that subtract last. That is what makes the conclusion go
through: in the eleven values immediately under each ceiling there is no
subtractive rival to be had at any depth, so only purely additive words are
left in contention, and among those the value fixes every digit. One of them
is shortest, and it is alone. Everywhere else there is slack, the two
constructions come out level, and the tie stands. Uniqueness in Talemi is not
a property of a number so much as of how tightly it is wedged under a ceiling.

It keeps going, too, and counting rather than merely asking yes or no makes the
shape clearer. Below three hundred the number of shortest spellings is not
scattered either: it is 1 up to 23, then 2 as far as 144, then 1 again through
155, then 2 to 276, then 1 through 287, then 4. Constant between ceilings, and
dropping to 1 over the eleven values before each of them.

Plotted against $n$ the stretches look nothing alike — the three-syllable band
is 132 numbers wide and the five-syllable band is 1584 — but that is the wrong
variable to plot against. Measured *downwards from the ceiling* they are the
same stretch. Start at $\operatorname{cap}(k)$ for any $k$ from three up and
walk down: 1 for eleven steps, then 2 for a hundred and twenty-one, then 3 for
eleven more, then 4. All that changes with the length is how far you can walk
before the band runs out underneath you.

What is proved is the near end of that. The library checks the uniqueness
pattern below four hundred and the exact counts below three hundred, and both
are theorems. That the same profile recurs under every ceiling is something I
have computed and not proved, which is why it is a paragraph here and not a
box.

The two stragglers are 0 and 1, bare roots that nothing three syllables long
can tie.

Which leaves the reconstruction's elegant feature looking thin. Above zero,
signed digits earn nothing whatever — not a number, not a syllable, not a
canonical form — and the one place the language does name a number uniquely is
the place where its signed digits cannot reach.

## The reconstruction

```text
o  = 0     lo = 5      pe = 10
ka = 1     te = 6      yu = 11
mi = 2     ri = 7
su = 3     vo = 8
na = 4     ze = 9
```

Two constructions, $\eqref{eq:add}$ and $\eqref{eq:sub}$, recursive in $N$,
with `na ka` fused to `tu`. A signed-digit duodecimal system written as
morphology, unambiguous despite appearances, able to name every integer, and —
above zero — redundant twice over, since the subtractive half of it neither
reaches a number the additive half misses nor says any number faster.

Two of those roots I supplied myself, and the recursion and the free choice of
linker are assumptions rather than readings. What the corpus attests is a
fragment; what is proved above is a system, and the joins between them are
marked. Whether Eutychios would recognise the result is a matter for
palaeography, and whether my ninth root is anywhere near the right syllable is
a matter for somebody with better Greek and access to those leaves.

I have not been back for them. The price will not have moved in my favour, and
I am not sure I would trust my own excitement a second time. What I have
instead is a transcription made standing at a shelf, and twelve hundred lines
of Lean that a machine rechecks from nothing in about fifteen seconds every
time this page is built.

I am aware that this is the wrong way round. The manuscript is the real object,
and the formalisation is a commentary on a copy of a translation of a copy. But
the commentary is the part that is whole. Every piece the system needs is in
it, including the pieces I had to supply, and it cannot quietly lose one the
way a codex can: take a line out and the whole thing refuses to build, at once
and in the open.

So I have stopped thinking of those files as a check on the reconstruction and
started thinking of them as where the reconstruction lives. The leaves are in a
case in Venice, priced beyond me, and the sums on them are still true. The
system they belong to is here — complete, with its ninth root borrowed and its
zero argued for. The arithmetic checks out, and this time that is not a figure
of speech.

One line in those leaves was addressed to me, and I was slow to notice it. The
scribe gave a place, a year, two men to date himself by and an order, and no
name; then he closed with the only request the document makes of anyone. *Qui
legis, ora pro scriptore.* You who read, pray for the writer. It is the single
sentence in the whole manuscript I did not have to reconstruct, hedge, or
supply a missing root for. It arrived whole, it was meant for whoever got this
far, and it asks for the one thing I was in a position to give. So I gave it.
He left no name to thank and asked for nothing else, and after months of taking
from him it was not much to have been asked for.

Behind him stands the holy man at Mokissos, on whom the sources are silent and
who is only *said* to have set the question at all. If he did, he set it to his
disciples, which means he set it to be understood. And it is worth
understanding. Strange as it looks on the page, once it gives way it is very
simple: count in twelves, and let a digit be owed as readily as held. That is
the whole of it — a small, clean idea, and a durable one. It survived a Greek
codex, a translation by a man who said outright that he could not follow it,
the loss of at least one line, and eight centuries of being worth nobody's
attention.

Would he be proud that I solved it? I have thought about that more than the
question can really bear. I do not think he would have been very interested in
me, and I find I do not mind. He set it so that someone would come to see what
he had seen, and someone did — late, and by a route he could not have pictured,
and needing a great deal more help than his disciples were given. The seeing is
the same seeing. A man in Cappadocia arranged twelve syllables so that a mind
meeting them fifteen hundred years later would end up standing where he had
stood. I got there. Of everything written here, that is the part I am glad of.

## The Lean sources

Every proof written out above is also a proof in a small Lean library, checked
from its axioms each time this site is built. The prose and the library follow
the same arguments in the same order, so a paragraph above should correspond
to a recognisable stretch of a file below. The library imports no mathematics
library: integers, induction and reflexivity are the whole toolkit, which also
means it can be read by someone who does not know one.

> [!remark] Why the proofs avoid native_decide
> Keeping the toolkit that small is a decision, and one tactic in particular is
> kept out of it. On goals that are pure computation it is tempting to reach
> for `native_decide`, which hands the step to the compiler rather than to the
> kernel. It is deliberately absent throughout: it leaves an extra axiom in the
> theorem's list, and a theorem resting on that is a theorem about a compiled
> binary. Exactly which axiom depends on the toolchain — Lean once recorded a
> single `Lean.ofReduceBool` for every such step and now mints a fresh one per
> call site — which is why the check the build actually runs is an allowlist
> rather than a blocklist: every result quoted here stands on the three axioms
> Lean's own logic uses and nothing further, whatever a delegated step would
> have been called. The honest tactic is also, here, fast enough.

The six files, in dependency order:

- [Talemi.lean](/lean/Talemi.lean) — the library root, and a map of the rest
- [Numerals.lean](/lean/Talemi/Numerals.lean) — trees, values, syllables, and
  the reading-back theorem
- [Range.lean](/lean/Talemi/Range.lean) — which numbers the system can name
- [Shortest.lean](/lean/Talemi/Shortest.lean) — the ceiling argument
- [Enumeration.lean](/lean/Talemi/Enumeration.lean) — enumerating spellings,
  and the count below four hundred
- [Examples.lean](/lean/Talemi/Examples.lean) — the corpus, and every word
  quoted in this post

The boxes above are prose, so here is what they are called in the files, for
anyone who wants to check that I have quoted them faithfully. Reading back is
`parse_toks` and `toks_injective`; the infinity of spellings is
`padded_injective`; the argument that the reconstruction had no choice about a
zero remainder is `multiple_needs_zero_head`; the reach of the system is
`eval_encode`
for the naturals,
`eval_encodeInt` for the integers, and `additive_range` for the fragment
without `sa`; the ceiling argument is `encode_shortest` and
`sub_le_cap_sub_eleven`, with the extension to a buried `sa` in
`usesSub_le_cap_sub_eleven`; the tie at thirty-five is `both_shortest_35`; the
count below four hundred is `unique_shortest_below_400`, sharpened from a
yes-or-no answer to the counts themselves by `tie_counts_below_300`.

The names in the prose map across too: $\operatorname{val}$ is `eval`,
$\operatorname{say}$ is `toks`, $\operatorname{read}$ is `parse`, and
$\operatorname{enc}$ is `encode`.
