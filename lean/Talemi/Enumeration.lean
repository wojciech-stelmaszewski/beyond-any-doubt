/-
Counting the shortest spellings.

`Shortest.lean` proves that the additive spelling is never beaten. It does not
prove that it is the only one that ties, and it is not. This file counts the
ties.

Counting means enumerating, and an enumeration is worth nothing until it is
known to be exactly right: `mem_spellings` says it misses no numeral,
`eval_of_mem_spellings` says it invents none. Everything after those two is
arithmetic the kernel can do by itself.

The enumeration is smaller than it looks. At each step the value fixes the
digit: if `v = d + 12·w` with `0 ≤ d < 12` then `d` is `v % 12` and `w` is
`v / 12`, with no freedom left, and the subtractive step is pinned the same
way. So a numeral is not a free choice of digits — it is a sequence of choices
between `na` and `sa`, one at each rung, and `spellings` walks that binary
tree.
-/
import Talemi.Shortest

namespace Talemi

namespace TNum

/-! ## How deep a short word can be

Every rung costs two syllables, except the bottom one when it fuses. So a word
of `L` syllables has at most `(L+1)/2` rungs, and searching to depth three
finds every spelling of seven syllables or fewer. -/

def depth : TNum → Nat
  | .atom _       => 0
  | .add12 _ rest => depth rest + 1
  | .sub12 _ rest => depth rest + 1

theorem two_mul_depth_le (t : TNum) : 2 * depth t ≤ len t + 1 := by
  induction t with
  | atom => simp only [depth, len]; omega
  | add12 d rest ih =>
    by_cases h : rest = .atom .ka
    · subst h; simp only [depth, len]; split <;> omega
    · rw [len_add12 h]; simp only [depth]; omega
  | sub12 _ _ ih => simp only [depth, len]; omega

/-! ## The enumeration -/

/-- Every numeral of value `v` with fewer than `fuel` rungs, and nothing that
is not a numeral of value `v`. -/
def spellings : Nat → Int → List TNum
  | 0,        _ => []
  | fuel + 1, v =>
      (if 0 ≤ v ∧ v < 12 then [TNum.atom (Digit.ofResidue v.toNat)] else []) ++
      (spellings fuel (v / 12)).map
        (TNum.add12 (Digit.ofResidue (v % 12).toNat)) ++
      (spellings fuel ((v + (-v) % 12) / 12)).map
        (TNum.sub12 (Digit.ofResidue ((-v) % 12).toNat))

theorem ofResidue_value (d : Digit) : Digit.ofResidue d.value.toNat = d := by
  cases d <;> rfl

/-- **The enumeration is complete.** -/
theorem mem_spellings : ∀ (fuel : Nat) (t : TNum), depth t < fuel →
    t ∈ spellings fuel (eval t)
  | 0,        _, h => absurd h (by omega)
  | _ + 1, .atom d, _ => by
      have h0 := Digit.value_nonneg d
      have h1 := Digit.value_lt_twelve d
      simp only [spellings, eval, if_pos (And.intro h0 h1), ofResidue_value]
      simp
  | fuel + 1, .add12 d rest, h => by
      have h0 := Digit.value_nonneg d
      have h1 := Digit.value_lt_twelve d
      have hrest := mem_spellings fuel rest (by simp only [depth] at h; omega)
      have hdiv : (eval (.add12 d rest)) / 12 = eval rest := by
        simp only [eval]; omega
      have hmod : (eval (.add12 d rest)) % 12 = d.value := by
        simp only [eval]; omega
      simp only [spellings, hdiv, hmod, ofResidue_value, List.mem_append,
        List.mem_map]
      exact Or.inl (Or.inr ⟨rest, hrest, rfl⟩)
  | fuel + 1, .sub12 d rest, h => by
      have h0 := Digit.value_nonneg d
      have h1 := Digit.value_lt_twelve d
      have hrest := mem_spellings fuel rest (by simp only [depth] at h; omega)
      have hmod : (-eval (.sub12 d rest)) % 12 = d.value := by
        simp only [eval]; omega
      have hdiv : (eval (.sub12 d rest) + d.value) / 12 = eval rest := by
        simp only [eval]; omega
      simp only [spellings, hmod, hdiv, ofResidue_value, List.mem_append,
        List.mem_map]
      exact Or.inr ⟨rest, hrest, rfl⟩

/-- **The enumeration is sound.** -/
theorem eval_of_mem_spellings : ∀ (fuel : Nat) (v : Int) (t : TNum),
    t ∈ spellings fuel v → eval t = v
  | 0,        _, _, h => absurd h (by simp [spellings])
  | fuel + 1, v, t, h => by
      simp only [spellings, List.mem_append, List.mem_map] at h
      rcases h with (h | ⟨r, hr, rfl⟩) | ⟨r, hr, rfl⟩
      · split at h
        · next hv =>
          simp only [List.mem_singleton] at h
          subst h
          rw [eval, Digit.value_ofResidue (by omega)]
          omega
        · simp at h
      · have := eval_of_mem_spellings fuel (v / 12) r hr
        rw [eval, this, Digit.value_ofResidue (by omega)]
        omega
      · have := eval_of_mem_spellings fuel ((v + (-v) % 12) / 12) r hr
        rw [eval, this, Digit.value_ofResidue (by omega)]
        omega

/-! ## Searching to depth three

Fuel of four covers every word of five syllables or fewer, and by
`len_encode_le` that covers every shortest word for every value below
cap 5 = 1871. -/

theorem mem_spellings_four {t : TNum} (h : len t ≤ 5) :
    t ∈ spellings 4 (eval t) :=
  mem_spellings 4 t (by have := two_mul_depth_le t; omega)

def minLen (v : Int) : Nat := ((spellings 4 v).map len).foldl Nat.min 99

theorem foldl_min_le_init : ∀ (l : List Nat) (a : Nat), l.foldl Nat.min a ≤ a
  | [],      a => Nat.le_refl a
  | y :: ys, a =>
      Nat.le_trans (foldl_min_le_init ys (Nat.min a y)) (Nat.min_le_left a y)

theorem foldl_min_le : ∀ (l : List Nat) (a x : Nat), x ∈ l →
    l.foldl Nat.min a ≤ x
  | [],      _, _, h => absurd h (by simp)
  | y :: ys, a, x, h => by
      rcases List.mem_cons.mp h with rfl | h
      · exact Nat.le_trans (foldl_min_le_init ys (Nat.min a x))
          (Nat.min_le_right a x)
      · exact foldl_min_le ys (Nat.min a y) x h

theorem minLen_le_of_mem {v : Int} {t : TNum} (h : t ∈ spellings 4 v) :
    minLen v ≤ len t :=
  foldl_min_le _ 99 (len t) (List.mem_map_of_mem h)

theorem le_foldl_min : ∀ (l : List Nat) (a b : Nat), b ≤ a →
    (∀ x ∈ l, b ≤ x) → b ≤ l.foldl Nat.min a
  | [],      _, _, ha, _  => ha
  | y :: ys, a, b, ha, hl =>
      le_foldl_min ys (Nat.min a y) b
        (Nat.le_min.mpr ⟨ha, hl y List.mem_cons_self⟩)
        (fun x hx => hl x (List.mem_cons_of_mem _ hx))

theorem le_minLen {v : Int} {b : Nat} (hb : b ≤ 99)
    (h : ∀ u ∈ spellings 4 v, b ≤ len u) : b ≤ minLen v :=
  le_foldl_min _ 99 b hb (by
    intro x hx
    obtain ⟨u, hu, rfl⟩ := List.mem_map.mp hx
    exact h u hu)

/-! ## What "the shortest spelling" means

Stated over all numerals, not merely the enumerated ones — the enumeration is
a means of deciding the question, not part of its statement. -/

def IsShortest (v : Int) (t : TNum) : Prop :=
  eval t = v ∧ ∀ u : TNum, eval u = v → len t ≤ len u

def shortestSpellings (v : Int) : List TNum :=
  (spellings 4 v).filter (fun t => len t == minLen v)

/-- Below 12⁴ a shortest spelling is short enough to have been enumerated. -/
theorem mem_shortestSpellings {v : Int} {t : TNum} (ht : IsShortest v t)
    {w : TNum} (hw : eval w = v) (hw5 : len w ≤ 5) :
    t ∈ shortestSpellings v := by
  have h5 : len t ≤ 5 := Nat.le_trans (ht.2 w hw) hw5
  have hmem : t ∈ spellings 4 v := ht.1 ▸ mem_spellings_four h5
  have hge : minLen v ≤ len t := minLen_le_of_mem hmem
  have hle : len t ≤ minLen v :=
    le_minLen (by omega) fun u hu =>
      ht.2 u (eval_of_mem_spellings 4 v u hu)
  simp only [shortestSpellings, List.mem_filter, hmem, true_and]
  simp [Nat.le_antisymm hle hge]

/-- Conversely, everything enumerated as shortest really is. -/
theorem isShortest_of_mem {v : Int} {t : TNum} (h : t ∈ shortestSpellings v)
    {w : TNum} (hw : eval w = v) (hw5 : len w ≤ 5) : IsShortest v t := by
  simp only [shortestSpellings, List.mem_filter, beq_iff_eq] at h
  obtain ⟨hmem, hlen⟩ := h
  refine ⟨eval_of_mem_spellings 4 v t hmem, fun u hu => ?_⟩
  by_cases h5 : len u ≤ 5
  · exact hlen ▸ minLen_le_of_mem (hu ▸ mem_spellings_four h5)
  · have : minLen v ≤ len w := minLen_le_of_mem (hw ▸ mem_spellings_four hw5)
    omega

/-! ## Deciding uniqueness -/

def allEqual : List TNum → Bool
  | []      => true
  | t :: ts => ts.all (fun u => u == t) && allEqual ts

theorem eq_of_allEqual : ∀ {l : List TNum}, allEqual l = true →
    ∀ {t u : TNum}, t ∈ l → u ∈ l → t = u
  | [],      _, _, _, ht, _ => absurd ht (by simp)
  | s :: ts, h, t, u, ht, hu => by
      simp only [allEqual, Bool.and_eq_true, List.all_eq_true] at h
      have key : ∀ x ∈ s :: ts, x = s := by
        intro x hx
        rcases List.mem_cons.mp hx with rfl | hx
        · rfl
        · exact beq_iff_eq.mp (h.1 x hx)
      rw [key t ht, key u hu]

theorem exists_false_of_all_eq_false : ∀ {l : List TNum} {p : TNum → Bool},
    l.all p = false → ∃ x, x ∈ l ∧ p x = false
  | [],      _, h => absurd h (by simp)
  | y :: ys, p, h => by
      simp only [List.all_cons, Bool.and_eq_false_iff] at h
      rcases h with h | h
      · exact ⟨y, by simp, h⟩
      · obtain ⟨x, hx, hp⟩ := exists_false_of_all_eq_false h
        exact ⟨x, by simp [hx], hp⟩

theorem exists_ne_of_not_allEqual : ∀ {l : List TNum}, allEqual l = false →
    ∃ t u : TNum, t ∈ l ∧ u ∈ l ∧ t ≠ u
  | [],      h => absurd h (by simp [allEqual])
  | s :: ts, h => by
      simp only [allEqual, Bool.and_eq_false_iff] at h
      rcases h with h | h
      · obtain ⟨u, hu, hne⟩ := exists_false_of_all_eq_false h
        exact ⟨u, s, by simp [hu], by simp, fun he => by simp [he] at hne⟩
      · obtain ⟨t, u, ht, hu, hne⟩ := exists_ne_of_not_allEqual h
        exact ⟨t, u, by simp [ht], by simp [hu], hne⟩

/-- Does `v` have exactly one shortest spelling? -/
def uniqueShortest (v : Int) : Bool := allEqual (shortestSpellings v)

theorem unique_of_uniqueShortest {v : Int} (h : uniqueShortest v = true)
    {w : TNum} (hw : eval w = v) (hw5 : len w ≤ 5)
    {t u : TNum} (ht : IsShortest v t) (hu : IsShortest v u) : t = u :=
  eq_of_allEqual h (mem_shortestSpellings ht hw hw5)
    (mem_shortestSpellings hu hw hw5)

theorem two_of_not_uniqueShortest {v : Int} (h : uniqueShortest v = false)
    {w : TNum} (hw : eval w = v) (hw5 : len w ≤ 5) :
    ∃ t u : TNum, t ≠ u ∧ IsShortest v t ∧ IsShortest v u := by
  obtain ⟨t, u, ht, hu, hne⟩ := exists_ne_of_not_allEqual h
  exact ⟨t, u, hne, isShortest_of_mem ht hw hw5, isShortest_of_mem hu hw hw5⟩

/-! ## The count

`encode n` is the witness that fuel of four suffices: below 1872 it is at most
five syllables long, so nothing shorter was left unsearched. -/

theorem len_encode_le_five {n : Nat} (h : n < 1872) : len (encode n) ≤ 5 :=
  len_encode_le n 5 (by simp only [cap]; omega)

/-- **The shortest spelling is almost never unique.** Of the first four
hundred numbers only forty-six have one, and they fall in three blocks ending
at 23, 155 and 287 — which are `cap 2`, `cap 3` and `cap 4`. That is
`sub_le_cap_sub_eleven` showing through: a subtractive word lands eleven short
of the ceiling for its length, so the eleven values just under each ceiling
have no subtractive rival and nothing to tie with. 0 and 1 are the two
stragglers, bare roots that nothing three syllables long can match. -/
theorem unique_shortest_below_400 :
    (List.range 400).filter (fun n : Nat => uniqueShortest (n : Int))
      = List.range 24 ++ List.range' 145 11 ++ List.range' 277 11 := by
  decide

/-- The pattern the number of shortest spellings follows below 300: constant
between ceilings, and 1 over the last eleven values before each of them. -/
def tieCount (n : Nat) : Nat :=
  if n ≤ 23 then 1
  else if n ≤ 144 then 2
  else if n ≤ 155 then 1
  else if n ≤ 276 then 2
  else if n ≤ 287 then 1
  else 4

set_option maxRecDepth 4000 in
/-- **How many shortest spellings, exactly.** Uniqueness is the `1` in a
coarser pattern. The enumeration lists each numeral once — the three branches
of `spellings` are told apart by their head constructor — so its length is the
number of spellings and not merely a bound on it. -/
theorem tie_counts_below_300 :
    (List.range 300).all
      (fun n : Nat => (shortestSpellings (n : Int)).length == tieCount n) := by
  decide

end TNum

end Talemi
