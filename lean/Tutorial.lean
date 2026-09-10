/-
Root of the tutorial library. `lake build Tutorial` builds every lesson and every
solution; warnings about `sorry` are the unfinished exercises, and are expected.

Not part of `defaultTargets`, so `lake build` and `scripts/verify.sh` ignore it.
-/
import Tutorial.Lesson01Basics
import Tutorial.Lesson02Functions
import Tutorial.Lesson03Structures
import Tutorial.Lesson04Rewriting
import Tutorial.Lesson05Induction
import Tutorial.Lesson06Automation
import Tutorial.Lesson07MetricSpaces
import Tutorial.Lesson08Limits

import Tutorial.Solutions.Lesson01Basics
import Tutorial.Solutions.Lesson02Functions
import Tutorial.Solutions.Lesson03Structures
import Tutorial.Solutions.Lesson04Rewriting
import Tutorial.Solutions.Lesson05Induction
import Tutorial.Solutions.Lesson06Automation
import Tutorial.Solutions.Lesson07MetricSpaces
import Tutorial.Solutions.Lesson08Limits
