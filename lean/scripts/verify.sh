#!/usr/bin/env bash
# Checks the proofs in this directory.
#
# A successful `lake build` already is the verification: Lean will not produce an
# olean for a theorem it cannot check. What a green build does not rule out is an
# *admitted* goal — `sorry` compiles perfectly well — so the two checks after the
# build close that gap, both by reading Lean's own output rather than the source.
#
# Grepping the source for the word `sorry` would be the obvious approach and is
# the wrong one: it also finds the word in comments, including comments explaining
# what `sorry` is.
set -euo pipefail

cd "$(dirname "$0")/.."

log=$(mktemp)
trap 'rm -f "$log"' EXIT

echo "==> Fetching prebuilt Mathlib (no-op once the cache is warm)"
lake exe cache get

echo "==> Building: every theorem is rechecked from its axioms"
lake build 2>&1 | tee "$log"

# Lean warns on any declaration that reaches `sorry`, whether or not anything
# depends on it.
# The dot before `sorry` is deliberate: Lean quotes it with backticks, and the
# pattern should not break the day that changes to apostrophes.
echo "==> Checking that no declaration was admitted"
if grep -qE 'declaration uses .sorry.' "$log"; then
  echo "FAIL: a declaration is admitted rather than proved" >&2
  grep -nE 'declaration uses .sorry.' "$log" >&2
  exit 1
fi

# The `#print axioms` lines in Banach/Examples.lean list everything each theorem
# rests on. Anything outside Mathlib's three classical axioms is a finding:
# `sorryAx` means an admitted goal somewhere below, and `Lean.ofReduceBool` means
# a step was delegated to compiled code instead of being checked by the kernel.
echo "==> Checking which axioms the proofs rest on"
listings=$(grep -c 'depends on axioms' "$log" || true)
if [ "$listings" -eq 0 ]; then
  echo "FAIL: no axiom listings in the build output, so nothing was checked" >&2
  echo "Expected '#print axioms' output from Banach/Examples.lean. Try:" >&2
  echo "  rm -rf .lake/build/lib/lean/Banach && lake build" >&2
  exit 1
fi

unexpected=$(
  grep 'depends on axioms' "$log" \
    | sed -e 's/.*\[//' -e 's/\]//' \
    | tr -s ', ' '\n' \
    | sort -u \
    | grep -vxE 'propext|Classical\.choice|Quot\.sound' || true
)
if [ -n "$unexpected" ]; then
  echo "FAIL: the proofs rest on axioms they should not:" >&2
  echo "$unexpected" >&2
  exit 1
fi

echo
echo "OK: $listings theorems check, resting only on propext, Classical.choice"
echo "and Quot.sound. No goal is admitted anywhere beneath them."
