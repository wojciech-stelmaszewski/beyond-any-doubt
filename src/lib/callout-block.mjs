import { defineHastPlugin } from "satteri";

/*
 * Structural callouts, written as an annotated blockquote:
 *
 *     > [!theorem] Theorem 2.4
 *     > Every Cauchy sequence in $\mathbb{R}$ converges.
 *
 * The blockquote is chosen over a fenced block so that the body stays ordinary
 * Markdown — emphasis, links and `$...$` all keep working inside a callout,
 * because by the time this plugin runs they have already been processed.
 *
 * Each kind carries a bracketed sigil as well as a colour. A reader who cannot
 * separate the teal of a definition from the purple of a theorem still has the
 * letter, and so does anyone reading a printed page.
 */
const KINDS = {
  definition: { sigil: "D", colour: "definition" },
  theorem: { sigil: "T", colour: "theorem", qed: true },
  lemma: { sigil: "L", colour: "theorem", qed: true },
  corollary: { sigil: "C", colour: "theorem", qed: true },
  proposition: { sigil: "P", colour: "theorem", qed: true },
  conjecture: { sigil: "?", colour: "conjecture" },
  counterexample: { sigil: "!", colour: "counterexample" },
  proof: { sigil: "∎", colour: "ink", qed: true },
  remark: { sigil: "¶", colour: "ink" },
};

const MARKER = /^\[!([a-z]+)\][ \t]*([^\n]*)\n?/i;

const element = (tagName, className, children) => ({
  type: "element",
  tagName,
  properties: className ? { className } : {},
  children,
});

const text = (value) => ({ type: "text", value });

/** Strips the `[!kind] Title` marker off the first paragraph of a blockquote. */
function takeMarker(blockquote) {
  const paragraph = blockquote.children.find((child) => child.type === "element");
  const first = paragraph?.children?.[0];
  if (first?.type !== "text") return null;

  const match = MARKER.exec(first.value);
  if (match === null) return null;

  const kind = match[1].toLowerCase();
  if (!Object.hasOwn(KINDS, kind)) return null;

  const remainder = first.value.slice(match[0].length);
  const body = blockquote.children.map((child) =>
    child === paragraph
      ? {
          ...paragraph,
          children:
            remainder === ""
              ? paragraph.children.slice(1)
              : [text(remainder), ...paragraph.children.slice(1)],
        }
      : child
  );

  return { kind, title: match[2].trim(), body };
}

export const calloutBlock = () =>
  defineHastPlugin({
    name: "callout-block",
    element: {
      filter: ["blockquote"],
      visit(node) {
        const found = takeMarker(node);
        if (found === null) return;

        const { kind, title, body } = found;
        const { sigil, colour, qed } = KINDS[kind];
        const heading = title === "" ? kind.toUpperCase() : title.toUpperCase();

        const label = element("p", ["callout-label"], [
          element("span", ["callout-sigil"], [text(sigil)]),
          text(heading),
        ]);

        // The tombstone closes a statement the way it does in print, and is
        // hidden from assistive technology because "black square" is noise.
        const tail = qed
          ? [element("span", ["callout-qed"], [{ type: "element", tagName: "span", properties: { ariaHidden: "true" }, children: [text("∎")] }])]
          : [];

        return element("aside", ["callout", `callout-${kind}`, `is-${colour}`], [
          label,
          ...body,
          ...tail,
        ]);
      },
    },
  });

export default calloutBlock;
