/-
How short can a Talemi word be?

`Range.lean` shows that the subtractive linker names no natural number that
addition cannot. That leaves it one job to apply for: brevity. A system with
signed digits ought to be able to say 143 as "one short of a gross" and save a
breath, the way Roman `IX` beats `VIIII`.

It cannot. The theorem below says that the plain additive spelling of a
non-negative number is never longer than any other spelling of it — so `sa`
buys nothing at all above zero, neither reach nor economy.

The proof turns on a single function. `cap k` is the largest value any word of
`k` syllables can denote, and it satisfies a two-step recurrence rather than a
one-step one, because the fusion `na ka → tu` lets one rung of the ladder cost
one syllable instead of two.
-/
import Talemi.Range

namespace Talemi

namespace TNum

/-! ## Length in syllables

`len` is `(toks ·).length`, spelled out so that it reduces. The nested pattern
in the second line is the fusion: `d-na-ka` surfaces as two syllables, or as
the single syllable `tu` when the digit is `o`. -/

def len : TNum → Nat
  | .atom _              => 1
  | .add12 d (.atom .ka) => if d = .o then 1 else 2
  | .add12 _ rest        => 2 + len rest
  | .sub12 _ rest        => 2 + len rest

/-- The unfused case of `len`, extracted because the nested pattern above means
`simp` cannot fire on `add12` without knowing what `rest` is. -/
theorem len_add12 {d : Digit} : ∀ {rest : TNum}, rest ≠ .atom .ka →
    len (.add12 d rest) = 2 + len rest
  | .atom .ka, h => absurd rfl h
  | .atom .o, _ | .atom .mi, _ | .atom .su, _ | .atom .na, _
  | .atom .lo, _ | .atom .te, _ | .atom .ri, _ | .atom .vo, _
  | .atom .ze, _ | .atom .pe, _ | .atom .yu, _
  | .add12 _ _, _ | .sub12 _ _, _ => rfl

theorem toks_add12 {d : Digit} : ∀ {rest : TNum}, rest ≠ .atom .ka →
    toks (.add12 d rest) = Syl.ofDigit d :: .na :: toks rest
  | .atom .ka, h => absurd rfl h
  | .atom .o, _ | .atom .mi, _ | .atom .su, _ | .atom .na, _
  | .atom .lo, _ | .atom .te, _ | .atom .ri, _ | .atom .vo, _
  | .atom .ze, _ | .atom .pe, _ | .atom .yu, _
  | .add12 _ _, _ | .sub12 _ _, _ => rfl

theorem len_pos (t : TNum) : 1 ≤ len t := by
  cases t with
  | atom => exact Nat.le_refl 1
  | add12 d rest =>
    by_cases h : rest = .atom .ka
    · subst h; simp only [len]; split <;> omega
    · rw [len_add12 h]; omega
  | sub12 => simp only [len]; omega

/-- `len` really is the number of syllables. -/
theorem length_toks (t : TNum) : (toks t).length = len t := by
  induction t with
  | atom => rfl
  | add12 d rest ih =>
    by_cases h : rest = .atom .ka
    · subst h; by_cases hd : d = .o
      · subst hd; rfl
      · simp only [toks, len, if_neg hd]; rfl
    · rw [toks_add12 h, len_add12 h]
      simp only [List.length_cons, ih]
      omega
  | sub12 d rest ih =>
    simp only [toks, len, List.length_cons, ih]
    omega

/-! ## The ceiling for a given length

`cap k` is the largest value a `k`-syllable word can denote. The first three
entries are read off the grammar: nothing has length zero, one syllable reaches
`tu` = 12, two syllables reach `yutu` = 23. After that a word is a digit, a
linker, and a shorter word, which costs two syllables and multiplies the reach
by twelve — with eleven to spare for the digit. -/

def cap : Nat → Int
  | 0     => -1
  | 1     => 12
  | 2     => 23
  | k + 3 => 11 + 12 * cap (k + 1)

/-- **No word of `k` syllables denotes more than `cap k`.** The subtractive
case is where the claim earns its keep: `12·v − d` is bounded by the same
ceiling as `d + 12·v`, so subtraction never extends the reach of a given
length. -/
theorem eval_le_cap (t : TNum) : eval t ≤ cap (len t) := by
  induction t with
  | atom d =>
    have := Digit.value_lt_twelve d
    show d.value ≤ cap 1
    simp only [cap]; omega
  | add12 d rest ih =>
    by_cases h : rest = .atom .ka
    · subst h
      by_cases hd : d = .o
      · subst hd; decide
      · have := Digit.value_lt_twelve d
        show d.value + 12 * eval (.atom .ka) ≤ cap (if d = .o then 1 else 2)
        rw [if_neg hd]
        show d.value + 12 * (1 : Int) ≤ 23
        omega
    · obtain ⟨m, hm⟩ : ∃ m, len rest = m + 1 :=
        ⟨len rest - 1, by have := len_pos rest; omega⟩
      have hk : 2 + len rest = m + 3 := by omega
      have := Digit.value_lt_twelve d
      rw [len_add12 h, hk]
      rw [hm] at ih
      show d.value + 12 * eval rest ≤ cap (m + 3)
      simp only [cap]; omega
  | sub12 d rest ih =>
    obtain ⟨m, hm⟩ : ∃ m, len rest = m + 1 :=
      ⟨len rest - 1, by have := len_pos rest; omega⟩
    have hk : 2 + len rest = m + 3 := by omega
    have := Digit.value_nonneg d
    rw [hm] at ih
    show 12 * eval rest - d.value ≤ cap (2 + len rest)
    rw [hk]
    simp only [cap]; omega

/-- **A subtractive word never comes within eleven of the ceiling.** Where
`d-na-X` reaches `11 + 12·cap`, `d-sa-X` reaches only `12·cap`, the digit
working against it instead of for it. So the top eleven values at every length
are out of the subtractive construction's reach entirely — which is where the
blocks in `Enumeration.lean` come from. -/
theorem sub_le_cap_sub_eleven (d : Digit) (rest : TNum) :
    eval (.sub12 d rest) ≤ cap (len (.sub12 d rest)) - 11 := by
  obtain ⟨m, hm⟩ : ∃ m, len rest = m + 1 :=
    ⟨len rest - 1, by have := len_pos rest; omega⟩
  have hk : 2 + len rest = m + 3 := by omega
  have := Digit.value_nonneg d
  have ih := eval_le_cap rest
  rw [hm] at ih
  show 12 * eval rest - d.value ≤ cap (2 + len rest) - 11
  rw [hk]
  simp only [cap]; omega

/-! ## The additive spelling reaches the ceiling

The converse: if a number fits under `cap k`, then `encode` spells it in at
most `k` syllables. Together with `eval_le_cap` this closes the argument, since
any rival spelling of `n` puts `n` under its own ceiling. -/

theorem encode_one : encode 1 = .atom .ka := by rw [encode]; rfl

theorem ofResidue_ne_o : ∀ (m : Nat), 1 ≤ m → m < 12 → Digit.ofResidue m ≠ .o
  | 0, h, _ => absurd h (by decide)
  | 1, _, _ | 2, _, _ | 3, _, _ | 4,  _, _ | 5,  _, _ | 6, _, _
  | 7, _, _ | 8, _, _ | 9, _, _ | 10, _, _ | 11, _, _ => by decide
  | _ + 12, _, h => absurd h (by omega)

theorem ofResidue_ne_ka : ∀ (m : Nat), 2 ≤ m → m < 12 → Digit.ofResidue m ≠ .ka
  | 0, h, _ | 1, h, _ => absurd h (by decide)
  | 2, _, _ | 3, _, _ | 4, _, _ | 5,  _, _ | 6,  _, _
  | 7, _, _ | 8, _, _ | 9, _, _ | 10, _, _ | 11, _, _ => by decide
  | _ + 12, _, h => absurd h (by omega)

/-- Two is the first quotient that does not fuse, and `encode` bottoming out
anywhere but at `ka` is exactly what makes the word cost two more syllables. -/
theorem encode_ne_atom_ka {m : Nat} (h : 2 ≤ m) : encode m ≠ .atom .ka := by
  rw [encode]
  by_cases hm : m < 12
  · rw [if_pos hm]
    simpa using ofResidue_ne_ka m h hm
  · rw [if_neg hm]; simp

theorem len_encode_le : ∀ (n k : Nat), (n : Int) ≤ cap k → len (encode n) ≤ k := by
  intro n
  induction n using encode.induct with
  | case1 n h =>
    intro k hk
    rw [encode, if_pos h]
    show 1 ≤ k
    match k, hk with
    | 0,     hk => simp only [cap] at hk; omega
    | _ + 1, _  => omega
  | case2 n h ih =>
    intro k hk
    rw [encode, if_neg h]
    by_cases hq : n / 12 = 1
    · rw [hq, encode_one]
      by_cases hr : n % 12 = 0
      · rw [hr]
        show (1 : Nat) ≤ k
        match k, hk with
        | 0,     hk => simp only [cap] at hk; omega
        | _ + 1, _  => omega
      · have hne := ofResidue_ne_o (n % 12) (by omega) (Nat.mod_lt _ (by omega))
        show (if Digit.ofResidue (n % 12) = .o then 1 else 2) ≤ k
        rw [if_neg hne]
        match k, hk with
        | 0,     hk => simp only [cap] at hk; omega
        | 1,     hk => simp only [cap] at hk; omega
        | _ + 2, _  => omega
    · have hq2 : 2 ≤ n / 12 := by omega
      rw [len_add12 (encode_ne_atom_ka hq2)]
      match k, hk with
      | 0, hk => simp only [cap] at hk; omega
      | 1, hk => simp only [cap] at hk; omega
      | 2, hk => simp only [cap] at hk; omega
      | j + 3, hk =>
        simp only [cap] at hk
        have := ih (j + 1) (by omega)
        omega

/-! ## The theorem

Every spelling of a non-negative number is at least as long as the additive
one. Note what is *not* claimed: nothing here says the shortest spelling is
unique. It is not, and `Enumeration.lean` says how badly. -/

/-- **The additive spelling is a shortest spelling.** -/
theorem encode_shortest (n : Nat) (t : TNum) (h : eval t = (n : Int)) :
    (toks (encode n)).length ≤ (toks t).length := by
  rw [length_toks, length_toks]
  exact len_encode_le n (len t) (h ▸ eval_le_cap t)

/-- **The subtractive linker never shortens a non-negative number.** Same fact,
stated against the thing it rules out: for any word using `sa`, the purely
additive spelling of its value is no longer. -/
theorem sub_never_shorter (t : TNum) (h : 0 ≤ eval t) :
    (toks (encode (eval t).toNat)).length ≤ (toks t).length :=
  encode_shortest _ t (by omega)

end TNum

end Talemi
