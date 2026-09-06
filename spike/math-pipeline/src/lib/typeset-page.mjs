import { createRequire } from "node:module";
import { mathjax } from "@mathjax/src/js/mathjax.js";
import { TeX } from "@mathjax/src/js/input/tex.js";
import { SVG } from "@mathjax/src/js/output/svg.js";
import { liteAdaptor } from "@mathjax/src/js/adaptors/liteAdaptor.js";
import { RegisterHTMLHandler } from "@mathjax/src/js/handlers/html.js";
import { AssistiveMmlHandler } from "@mathjax/src/js/a11y/assistive-mml.js";
import { MathJaxStix2Font } from "@mathjax/mathjax-stix2-font/js/svg.js";

import "@mathjax/src/js/input/tex/base/BaseConfiguration.js";
import "@mathjax/src/js/input/tex/ams/AmsConfiguration.js";
import "@mathjax/src/js/input/tex/tagformat/TagFormatConfiguration.js";
import "@mathjax/src/js/input/tex/boldsymbol/BoldsymbolConfiguration.js";
import "@mathjax/src/js/input/tex/mathtools/MathtoolsConfiguration.js";
import "@mathjax/src/js/input/tex/braket/BraketConfiguration.js";
import "@mathjax/src/js/input/tex/newcommand/NewcommandConfiguration.js";

const require = createRequire(import.meta.url);

mathjax.asyncLoad = (name) => import(name);

const FONT_CHUNK_DIR = require
  .resolve("@mathjax/mathjax-stix2-font/js/svg.js")
  .replace(/svg\.js$/, "svg/dynamic");

await Promise.all(
  require("node:fs")
    .readdirSync(FONT_CHUNK_DIR)
    .filter((file) => file.endsWith(".js"))
    .map((file) => import(`@mathjax/mathjax-stix2-font/js/svg/dynamic/${file}`))
);

const adaptor = liteAdaptor();
AssistiveMmlHandler(RegisterHTMLHandler(adaptor));

const PACKAGES = ["base", "ams", "tagformat", "boldsymbol", "mathtools", "braket", "newcommand"];

/**
 * Typesets every expression in one page as a single MathJax document, so that
 * equation numbering and \label / \eqref resolve across the whole page.
 */
export async function typesetPage(html) {
  if (!html.includes("math-tex")) return html;

  const doc = mathjax.document(html, {
    InputJax: new TeX({ packages: PACKAGES, tags: "ams" }),
    OutputJax: new SVG({ fontCache: "local", fontData: MathJaxStix2Font }),
    // Never look for maths inside code samples.
    skipHtmlTags: ["script", "noscript", "style", "textarea", "pre", "code", "annotation", "annotation-xml"],
  });

  await doc.renderPromise();
  return adaptor.doctype(doc.document) + adaptor.outerHTML(adaptor.root(doc.document));
}
