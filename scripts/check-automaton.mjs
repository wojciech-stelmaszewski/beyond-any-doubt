/*
 * Checks the state diagram against the theorems it illustrates.
 *
 * The figure in the Talemi post draws a three-state reader. That reader is a
 * transcription of `parse` in the Lean library, and a transcription is a place
 * where a drawing can quietly stop matching the thing it claims to depict —
 * the post would then be illustrating a grammar it does not prove anything
 * about.
 *
 * So: enumerate every syllable string up to length five over a small alphabet
 * carrying one representative of each behaviour, ask both implementations
 * whether it reads, and require the answers to agree everywhere. The expected
 * verdicts are produced by Lean, from `lean/scripts/parse-verdicts.lean`, and
 * committed beside this script so the check needs no Lean toolchain to run.
 *
 *     node scripts/check-automaton.mjs
 */

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { run } from "../src/lib/diagram/specs.mjs";

const here = dirname(fileURLToPath(import.meta.url));

// Must match `alpha` in the Lean generator: two plain roots, the root that is
// also the additive linker, the linker that is only a linker, and the fusion.
const ALPHABET = ["o", "ka", "na", "sa", "tu"];
const LENGTH = 5;

/** Every word of the given length, first syllable varying slowest. */
function words(n) {
  if (n === 0) return [[]];
  return ALPHABET.flatMap((syllable) => words(n - 1).map((rest) => [syllable, ...rest]));
}

const all = Array.from({ length: LENGTH }, (_, i) => words(i + 1)).flat();
const ours = all.map((word) => (run(word).accepted ? "1" : "0")).join("");
const lean = readFileSync(join(here, "parse-verdicts.txt"), "utf8").trim();

if (lean.length !== ours.length) {
  console.error(`FAIL: Lean lists ${lean.length} verdicts, the diagram has ${ours.length}`);
  process.exit(1);
}

const disagreements = [];
for (let i = 0; i < ours.length; i += 1) {
  if (ours[i] !== lean[i]) disagreements.push({ word: all[i].join(" "), lean: lean[i] });
}

if (disagreements.length > 0) {
  console.error(`FAIL: the diagram disagrees with parse on ${disagreements.length} word(s):`);
  for (const { word, lean: verdict } of disagreements.slice(0, 10)) {
    console.error(`  "${word}" — Lean says ${verdict === "1" ? "reads" : "does not read"}`);
  }
  process.exit(1);
}

const accepted = [...ours].filter((bit) => bit === "1").length;
console.log(`OK: ${ours.length} words up to length ${LENGTH}, ${accepted} of them read,`);
console.log("and the diagram's verdict matches Lean's on every one.");
