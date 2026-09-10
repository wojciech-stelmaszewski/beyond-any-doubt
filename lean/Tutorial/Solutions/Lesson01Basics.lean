/-
Solutions to Lesson 1.

This file exists to be green: if it compiles, every exercise in the lesson is
actually solvable as stated. Reading it before being stuck for a while wastes the
lesson.
-/
import Mathlib.Tactic

namespace Tutorial.Solutions.Lesson01

example : 7 * 6 = 42 := by norm_num

-- `rfl` suffices: applying a lambda is computation, and so is `3 + 1`.
example : (fun n : Nat => n + 1) 3 = 4 := rfl

example : 2 ^ 10 = 1024 := by norm_num

end Tutorial.Solutions.Lesson01
