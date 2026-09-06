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
    /*
     * `displayOverflow: "scroll"` is what keeps a wide equation inside the
     * column. MathJax's default is "overflow", under which it puts an inline
     * min-width on the container so the box refuses to shrink — no amount of
     * overflow-x in our own CSS helps, because the box really is that wide, and
     * the whole page ends up scrolling sideways on a phone. In "scroll" mode
     * MathJax drops that min-width itself and gives the equation its own
     * scrollbar, leaving the expression intact rather than reflowing it.
     */
    OutputJax: new SVG({
      fontCache: "local",
      fontData: MathJaxStix2Font,
      displayOverflow: "scroll",
    }),
    // Never look for maths inside code samples.
    skipHtmlTags: ["script", "noscript", "style", "textarea", "pre", "code", "annotation", "annotation-xml"],
  });

  await doc.renderPromise();
  return restorePrologue(
    adaptor.doctype(doc.document) + adaptor.outerHTML(adaptor.root(doc.document))
  );
}

const DOCTYPE = /^\s*<!doctype/i;
const HEAD_OPEN = /<head(\s[^>]*)?>/i;
const CHARSET = /[ \t]*<meta\s+charset=[^>]*>\n?/i;

/**
 * Puts back the two things that must come first in a document.
 *
 * MathJax rebuilds the page from its own DOM and prepends a stylesheet of some
 * six kilobytes to <head>. That pushes the charset declaration past the 1024
 * bytes a browser scans for it, so the page is decoded as Latin-1 and every
 * apostrophe and dash in the prose turns to mojibake. The doctype is lost in
 * the same round trip, which drops the page into quirks mode.
 *
 * Both are cheap to reassert here, and doing it in one place means no template
 * has to know that maths post-processing happens at all.
 */
function restorePrologue(html) {
  let output = html;

  const charset = CHARSET.exec(output);
  if (charset !== null) {
    output = output.replace(CHARSET, "").replace(HEAD_OPEN, (head) => `${head}${charset[0].trim()}`);
  }

  return DOCTYPE.test(output) ? output : `<!doctype html>${output}`;
}
