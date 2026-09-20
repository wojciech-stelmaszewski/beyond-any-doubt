/-
Which numbers does Talemi name?

The corpus shows sixteen words and stops. That leaves the obvious question
unanswered: is the system a notation for arithmetic, or a list of number names
that happens to run out? The answer here is that it is a notation — every
natural number has a Talemi word — and the proof is a construction that names
the number, not an abstract existence argument.

The construction has one property worth more than the theorem it proves: it
never uses `sa`. Whatever the subtractive linker is for, it is not for reaching
numbers that addition cannot reach.
-/
import Talemi.Numerals

namespace Talemi

namespace Digit

/-- The root for a residue. Values from twelve up are folded onto `yu` so the
function is total; every use below is guarded by a proof that the argument is
small. -/
def ofResidue : Nat → Digit
  | 0 => .o  | 1 => .ka | 2  => .mi | 3  => .su
  | 4 => .na | 5 => .lo | 6  => .te | 7  => .ri
  | 8 => .vo | 9 => .ze | 10 => .pe | _  => .yu

theorem value_ofResidue : ∀ {n : Nat}, n < 12 → (ofResidue n).value = (n : Int)
  | 0, _ | 1, _ | 2, _ | 3,  _ | 4,  _ | 5,  _
  | 6, _ | 7, _ | 8, _ | 9,  _ | 10, _ | 11, _ => rfl
  | _ + 12, h => absurd h (by omega)

theorem value_nonneg (d : Digit) : 0 ≤ d.value := by
  cases d <;> decide

theorem value_lt_twelve (d : Digit) : d.value < 12 := by
  cases d <;> decide

end Digit

namespace TNum

/-! ## Naming every natural number

Read `encode` as long division written backwards. A number below twelve is a
bare root; anything else is its remainder, the linker `na`, and the word for
the quotient. The recursion terminates because dividing by twelve shrinks a
number that is at least twelve. -/

def encode (n : Nat) : TNum :=
  if n < 12 then .atom (Digit.ofResidue n)
  else .add12 (Digit.ofResidue (n % 12)) (encode (n / 12))
decreasing_by exact Nat.div_lt_self (by omega) (by omega)

/-- **Every natural number has a Talemi word.** -/
theorem eval_encode (n : Nat) : eval (encode n) = (n : Int) := by
  induction n using encode.induct with
  | case1 n h => rw [encode, if_pos h, eval, Digit.value_ofResidue h]
  | case2 n h ih =>
    rw [encode, if_neg h, eval, ih, Digit.value_ofResidue (Nat.mod_lt _ (by omega))]
    omega

theorem exists_spelling (n : Nat) : ∃ t : TNum, eval t = (n : Int) :=
  ⟨encode n, eval_encode n⟩

/-! ## The subtractive linker adds no natural number

`additive` says that a numeral is built from `na` alone. Every word `encode`
produces is additive, and every additive word denotes something non-negative.
Together those two facts pin `sa` down exactly: on the natural numbers it is
pure redundancy. -/

def additive : TNum → Bool
  | .atom _       => true
  | .add12 _ rest => additive rest
  | .sub12 _ _    => false

theorem additive_encode (n : Nat) : additive (encode n) = true := by
  induction n using encode.induct with
  | case1 n h => rw [encode, if_pos h]; rfl
  | case2 n h ih => rw [encode, if_neg h, additive]; exact ih

theorem additive_nonneg : ∀ {t : TNum}, additive t = true → 0 ≤ eval t
  | .atom d, _ => Digit.value_nonneg d
  | .add12 d rest, h => by
      have := additive_nonneg (t := rest) h
      have := Digit.value_nonneg d
      simp only [eval]
      omega
  | .sub12 _ _, h => by simp [additive] at h

/-- The additive fragment denotes exactly the non-negative integers: no more,
by `additive_nonneg`, and no less, by `encode`. -/
theorem additive_range (v : Int) :
    (∃ t, additive t = true ∧ eval t = v) ↔ 0 ≤ v := by
  constructor
  · rintro ⟨t, ha, rfl⟩; exact additive_nonneg ha
  · intro h
    exact ⟨encode v.toNat, additive_encode _, by
      rw [eval_encode]; omega⟩

/-! ## What `sa` is for

It reaches below zero, and nothing else does. The grammar as reconstructed
generates every integer, and the negative ones are exactly the ones that need
the subtractive linker.

`encodeInt` bottoms out twice: at the roots for `0`–`11`, and at `d-sa-o` for
`-11`–`-1`, which is `12·0 − d`. Above and below that the same long division
applies, with `Int` flooring division, which rounds towards negative infinity
and therefore keeps the remainder in `0`–`11` on both sides of zero. -/

def encodeInt (n : Int) : TNum :=
  if 0 ≤ n ∧ n < 12 then .atom (Digit.ofResidue n.toNat)
  else if -12 < n ∧ n < 0 then .sub12 (Digit.ofResidue (-n).toNat) (.atom .o)
  else .add12 (Digit.ofResidue (n % 12).toNat) (encodeInt (n / 12))
termination_by n.natAbs
decreasing_by omega

/-- **Every integer has a Talemi word**, not just every natural number. -/
theorem eval_encodeInt (n : Int) : eval (encodeInt n) = n := by
  induction n using encodeInt.induct with
  | case1 n h =>
    rw [encodeInt, if_pos h, eval, Digit.value_ofResidue (by omega)]
    omega
  | case2 n h₁ h₂ =>
    rw [encodeInt, if_neg h₁, if_pos h₂, eval, eval,
      Digit.value_ofResidue (by omega)]
    show 12 * (0 : Int) - _ = n
    omega
  | case3 n h₁ h₂ ih =>
    rw [encodeInt, if_neg h₁, if_neg h₂, eval, ih,
      Digit.value_ofResidue (by omega)]
    omega

/-- Below zero the subtractive linker is not optional. -/
theorem neg_needs_sub {t : TNum} (h : eval t < 0) : additive t = false := by
  cases hadd : additive t with
  | false => rfl
  | true => exact absurd (additive_nonneg hadd) (by omega)

end TNum

end Talemi
