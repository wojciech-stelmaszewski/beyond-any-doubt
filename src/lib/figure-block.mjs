import { defineMdastPlugin } from "satteri";

const escapeHtml = (value) =>
  String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

/*
 * A malformed block here used to take the whole article down without saying
 * so — the exception is swallowed upstream and the page renders with an empty
 * body, which looks like a styling bug and is not one. The commonest cause is
 * a caption wrapped across lines, since JSON forbids a literal newline inside
 * a string, so the failure is reported with that named.
 */
const parse = (source) => {
  const trimmed = source.trim();
  if (!trimmed.startsWith("{")) return { chart: trimmed };

  try {
    return JSON.parse(trimmed);
  } catch (error) {
    const hint = /\n/.test(trimmed)
      ? " A caption must sit on one line: JSON strings cannot contain a newline."
      : "";
    console.error(`[figure-block] cannot read this figure block.${hint}\n${trimmed}`);
    throw new Error(`figure block is not valid JSON: ${error.message}.${hint}`);
  }
};

const KINDS = {
  chart: {
    attribute: "data-chart",
    className: "chart2d",
    hint: "Scroll to zoom · drag to pan · double-click to reset",
    role: "img",
  },
  scene: {
    attribute: "data-scene",
    className: "scene3d",
    hint: "Drag to rotate · scroll to zoom",
    role: "img",
  },
  /*
   * A diagram holds real controls, so it is a group rather than an image: an
   * `img` role would hide the buttons inside it from a screen reader, which is
   * the opposite of what announcing the figure is for.
   */
  diagram: {
    attribute: "data-diagram",
    className: "diagram",
    hint: "Pick a word · click a syllable to stop there",
    role: "group",
  },
};

/**
 * Turns a ```figure block into a figure. Three kinds are understood:
 *
 *     ```figure
 *     { "chart": "slope-field", "caption": "..." }      // SVG, zoom and pan
 *     ```
 *     ```figure
 *     { "scene": "lorenz-attractor", "caption": "..." } // WebGL, rotatable
 *     ```
 *     ```figure
 *     { "diagram": "talemi-reader", "caption": "..." }  // SVG, walkable
 *     ```
 *
 * All three emit an empty container that the client script fills once the
 * figure approaches the viewport. Nothing is drawn at build time: a figure that
 * cannot be turned, zoomed or interrogated is not what we want on the page.
 *
 * The plugin is a factory, but one call produces one definition that the
 * pipeline reuses for every document, so the counter has to be reset per
 * document rather than per factory call. Left to itself it went on counting:
 * in a dev session the same figure gained a number on every reload, and in a
 * build it inherited whatever the previously rendered post had reached.
 */
export const figureBlock = () => {
  let count = 0;

  return defineMdastPlugin({
    name: "figure-block",
    before: () => {
      count = 0;
    },
    code: (node) => {
      if (node.lang !== "figure") return node;

      const spec = parse(node.value);
      const caption = spec.caption ?? "";
      const kind = Object.keys(KINDS).find((name) => spec[name]);
      if (!kind) throw new Error("A figure block needs a chart, a scene or a diagram.");

      const id = spec[kind];
      const { attribute, className, hint, role } = KINDS[kind];

      count += 1;
      const number = count;
      const title = `Figure ${number}. ${caption.replace(/\s+/g, " ").trim()}`;

      return {
        type: "html",
        value:
          `<figure class="plot" id="fig-${escapeHtml(id)}">` +
          `<div class="${className}" ${attribute}="${escapeHtml(id)}" role="${role}"` +
          ` aria-label="${escapeHtml(title)}">` +
          `<p class="figure-fallback">This figure is drawn in the browser and needs JavaScript.</p>` +
          `</div>` +
          `<p class="figure-hint">${hint}</p>` +
          `<figcaption><b>Figure ${number}.</b> ${caption}</figcaption>` +
          `</figure>`,
      };
    },
  });
};

export default figureBlock;
