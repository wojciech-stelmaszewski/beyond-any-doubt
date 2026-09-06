import { createRequire } from "node:module";
import { mathjax } from "@mathjax/src/js/mathjax.js";
import { TeX } from "@mathjax/src/js/input/tex.js";
import { SVG } from "@mathjax/src/js/output/svg.js";
import { liteAdaptor } from "@mathjax/src/js/adaptors/liteAdaptor.js";
import { RegisterHTMLHandler } from "@mathjax/src/js/handlers/html.js";
import { AssistiveMmlHandler } from "@mathjax/src/js/a11y/assistive-mml.js";
import { MathJaxStix2Font } from "@mathjax/mathjax-stix2-font/js/svg.js";
import { defineMdastPlugin } from "satteri";

import "@mathjax/src/js/input/tex/base/BaseConfiguration.js";
import "@mathjax/src/js/input/tex/ams/AmsConfiguration.js";
import "@mathjax/src/js/input/tex/tagformat/TagFormatConfiguration.js";
import "@mathjax/src/js/input/tex/boldsymbol/BoldsymbolConfiguration.js";
import "@mathjax/src/js/input/tex/mathtools/MathtoolsConfiguration.js";
import "@mathjax/src/js/input/tex/braket/BraketConfiguration.js";
import "@mathjax/src/js/input/tex/newcommand/NewcommandConfiguration.js";

const require = createRequire(import.meta.url);

// Must be a dynamic ESM import, not `require`. The CommonJS copies of the font
// chunks register themselves against the CommonJS copy of the font class, so a
// `require` here loads the data into a registry this ESM instance never reads.
mathjax.asyncLoad = (name) => import(name);

const PACKAGES = ["base", "ams", "tagformat", "boldsymbol", "mathtools", "braket", "newcommand"];

const adaptor = liteAdaptor();
// SVG output draws glyphs as paths, which screen readers cannot read. Wrapping
// the handler emits a visually-hidden MathML copy alongside each expression.
AssistiveMmlHandler(RegisterHTMLHandler(adaptor));

const doc = mathjax.document("", {
  InputJax: new TeX({ packages: PACKAGES, tags: "ams" }),
  OutputJax: new SVG({ fontCache: "local", fontData: MathJaxStix2Font, displayAlign: "center" }),
});

// MathJax 4 loads font data in chunks on first use, and that load is async —
// but Satteri's MDAST handlers are synchronous. Pulling in every chunk here,
// at module load, removes dynamic loading from the render path entirely.
const FONT_CHUNK_DIR = require
  .resolve("@mathjax/mathjax-stix2-font/js/svg.js")
  .replace(/svg\.js$/, "svg/dynamic");

const chunkNames = require("node:fs")
  .readdirSync(FONT_CHUNK_DIR)
  .filter((file) => file.endsWith(".js"))
  .map((file) => file.replace(/\.js$/, ""));

await Promise.all(
  chunkNames.map((name) => import(`@mathjax/mathjax-stix2-font/js/svg/dynamic/${name}.js`))
);

// One render forces the font to bind the freshly loaded chunks.
await doc.convertPromise("\\mathbb{R}\\mathcal{A}\\mathfrak{g}\\sum\\int\\alpha", {
  display: true,
});

const escapeAttr = (value) => String(value).replace(/&/g, "&amp;").replace(/"/g, "&quot;");

const render = (source, display) => {
  try {
    return { type: "html", value: adaptor.outerHTML(doc.convert(source, { display })) };
  } catch (error) {
    return {
      type: "html",
      value: `<span class="math-error" title="${escapeAttr(error)}">${escapeAttr(source)}</span>`,
    };
  }
};

export const satteriMathJax4 = () =>
  defineMdastPlugin({
    name: "satteri-mathjax4",
    math: (node) => render(node.value, true),
    inlineMath: (node) => render(node.value, false),
  });

export default satteriMathJax4;
