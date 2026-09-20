/*
 * State diagrams.
 *
 * There is one, and it draws the Talemi reader. The grammar in the post is
 * right-linear, which is the same thing as saying a finite automaton can read
 * it, and a figure that lets you walk a word through that automaton says so
 * more convincingly than the sentence claiming it does.
 *
 * The machine below is not a fresh account of the language. It is the `parse`
 * function of the Lean library transcribed into its states, and the
 * transcription is checked rather than asserted: `scripts/check-automaton.mjs`
 * enumerates every syllable string up to length five and compares this
 * verdict against Lean's on each one.
 */

/** Every syllable that can stand in digit position. `na` is among them. */
const ROOTS = ["o", "ka", "mi", "su", "na", "lo", "te", "ri", "vo", "ze", "pe", "yu"];

const LINKERS = ["na", "sa"];

/*
 * Three states, and the third is the fusion's doing. Without `tu` the reader
 * needs only `start` and `root` — the two the post claims — because a numeral
 * is then roots and linkers alternating. `tu` closes a word in one syllable
 * and nothing may follow it, which is a state of its own.
 */
const ACCEPTING = new Set(["root", "fused"]);

/**
 * One transition, or `null` where the reader stops. The asymmetry between the
 * two live states is the whole of the grammar: `start` wants a root and reads
 * `na` as the digit four, `root` wants a linker and reads the same syllable as
 * the additive join.
 */
export function step(state, syllable) {
  if (state === "start") {
    if (syllable === "tu") return "fused";
    return ROOTS.includes(syllable) ? "root" : null;
  }

  if (state === "root") {
    if (syllable === "tu") return "fused";
    return LINKERS.includes(syllable) ? "start" : null;
  }

  return null;
}

/**
 * Walks a word and reports where it got to. `visited[i]` is the state before
 * reading `syllables[i]`, so the trail is one longer than the word and a
 * rejected word simply has a short one.
 */
export function run(syllables) {
  const visited = ["start"];
  let state = "start";

  for (const syllable of syllables) {
    const next = step(state, syllable);
    if (next === null) return { visited, accepted: false, read: visited.length - 1 };
    state = next;
    visited.push(state);
  }

  return { visited, accepted: ACCEPTING.has(state), read: syllables.length };
}

/*
 * Values come from the Lean library rather than from a second evaluator
 * written here. A copy of the semantics in JavaScript is a copy that can
 * disagree with the theorems, and this figure is about shape in any case.
 */
const SAMPLES = [
  { word: ["tu"], gloss: "12" },
  { word: ["ka", "tu"], gloss: "13" },
  { word: ["na", "na", "na"], gloss: "52" },
  { word: ["ka", "sa", "te"], gloss: "71" },
  { word: ["ka", "na", "tu"], gloss: "145" },
  { word: ["ka", "na", "ka", "na", "o"], gloss: "13" },
  /* The two ways a word can fail: ending early, and running into a wall. */
  { word: ["ka", "na"], gloss: null },
  { word: ["ka", "tu", "na"], gloss: null },
];

export const DIAGRAMS = {
  /*
   * The three states sit on a triangle rather than in a row. In a row the
   * `start`–`fused` edge has to arch over `root`, and an edge passing across
   * a node it does not touch is the one thing a state diagram must not do.
   */
  "talemi-reader": () => ({
    width: 640,
    height: 268,
    radius: 34,
    states: [
      { id: "start", x: 150, y: 86, label: "start", note: "wants a root" },
      { id: "root", x: 430, y: 86, label: "root", note: "may stop here" },
      { id: "fused", x: 290, y: 192, label: "end", note: "tu closed it" },
    ],
    accepting: ACCEPTING,
    edges: [
      { from: "start", to: "root", label: "any root", bend: 0 },
      { from: "root", to: "start", label: "na · sa", bend: 64 },
      { from: "start", to: "fused", label: "tu", bend: 0, gap: -16 },
      { from: "root", to: "fused", label: "tu", bend: 0 },
    ],
    samples: SAMPLES,
    step,
    run,
  }),
};

export default DIAGRAMS;
