import { defineMdastPlugin } from "satteri";

const escapeHtml = (value) =>
  String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

const parse = (source) => {
  const trimmed = source.trim();
  if (!trimmed.startsWith("{")) return { chart: trimmed };
  return JSON.parse(trimmed);
};

/**
 * Turns a ```figure block into a figure. Two kinds are understood:
 *
 *     ```figure
 *     { "chart": "slope-field", "caption": "..." }      // SVG, zoom and pan
 *     ```
 *     ```figure
 *     { "scene": "lorenz-attractor", "caption": "..." } // WebGL, rotatable
 *     ```
 *
 * Both emit an empty container that the client script fills once the figure
 * approaches the viewport. Nothing is drawn at build time: a figure that cannot
 * be turned, zoomed or interrogated is not what we want on the page.
 *
 * The plugin is a factory so the figure counter restarts for each document.
 */
export const figureBlock = () => {
  let count = 0;

  return defineMdastPlugin({
    name: "figure-block",
    code: (node) => {
      if (node.lang !== "figure") return node;

      const { chart, scene, caption = "" } = parse(node.value);
      const id = scene ?? chart;
      if (!id) throw new Error("A figure block needs either a chart or a scene.");

      count += 1;
      const number = count;
      const title = `Figure ${number}. ${caption.replace(/\s+/g, " ").trim()}`;
      const attribute = scene ? "data-scene" : "data-chart";
      const className = scene ? "scene3d" : "chart2d";
      const hint = scene
        ? "Drag to rotate · scroll to zoom"
        : "Scroll to zoom · drag to pan · double-click to reset";

      return {
        type: "html",
        value:
          `<figure class="plot" id="fig-${escapeHtml(id)}">` +
          `<div class="${className}" ${attribute}="${escapeHtml(id)}" role="img"` +
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
