// Direct ESM API probe: MathJax 4 + SVG output + STIX Two math font.
import { mathjax } from "@mathjax/src/js/mathjax.js";
import { TeX } from "@mathjax/src/js/input/tex.js";
import { SVG } from "@mathjax/src/js/output/svg.js";
import { liteAdaptor } from "@mathjax/src/js/adaptors/liteAdaptor.js";
import { RegisterHTMLHandler } from "@mathjax/src/js/handlers/html.js";
import { MathJaxStix2Font } from "@mathjax/mathjax-stix2-font/js/svg.js";

// Registering a configuration module is what enables the corresponding
// TeX package in MathJax 4; there is no AllPackages barrel any more.
import "@mathjax/src/js/input/tex/base/BaseConfiguration.js";
import "@mathjax/src/js/input/tex/ams/AmsConfiguration.js";
import "@mathjax/src/js/input/tex/tagformat/TagFormatConfiguration.js";
import "@mathjax/src/js/input/tex/boldsymbol/BoldsymbolConfiguration.js";
import "@mathjax/src/js/input/tex/mathtools/MathtoolsConfiguration.js";
import "@mathjax/src/js/input/tex/braket/BraketConfiguration.js";
import "@mathjax/src/js/input/tex/newcommand/NewcommandConfiguration.js";

const adaptor = liteAdaptor();
RegisterHTMLHandler(adaptor);

// MathJax 4 splits font data into dynamic chunks; Node needs an explicit loader.
mathjax.asyncLoad = (name) => import(name);

const tex = new TeX({
  packages: ["base", "ams", "tagformat", "boldsymbol", "mathtools", "braket", "newcommand"],
  tags: "ams",
});
const svg = new SVG({ fontCache: "local", fontData: MathJaxStix2Font });
const doc = mathjax.document("", { InputJax: tex, OutputJax: svg });

const cases = [
  ["inline", "f:\\mathbb{R}\\to\\mathbb{R}", false],
  ["align", "\\begin{align} \\zeta(s) &= \\sum_{n=1}^{\\infty} n^{-s} \\\\ &= \\prod_p (1-p^{-s})^{-1} \\end{align}", true],
  ["cases", "\\operatorname{sgn}(x)=\\begin{cases} 1 & x>0 \\\\ -1 & x<0 \\end{cases}", true],
  ["label", "\\label{eq:euler} e^{i\\pi} + 1 = 0", true],
  ["eqref", "\\text{see } \\eqref{eq:euler}", false],
  ["substack", "\\sum_{\\substack{1 \\le i \\le n \\\\ i \\ne j}} a_i", true],
  ["cfrac", "\\cfrac{1}{1+\\cfrac{1}{1+\\ddots}}", true],
  ["mathtools", "\\begin{dcases} a & b \\\\ c & d \\end{dcases}", true],
  ["braket", "\\braket{\\psi | \\phi}", false],
];

let totalBytes = 0;
for (const [name, src, display] of cases) {
  try {
    const node = await doc.convertPromise(src, { display });
    const html = adaptor.outerHTML(node);
    totalBytes += html.length;
    const err = html.match(/data-mjx-error="([^"]*)"/);
    console.log(
      `${name.padEnd(10)} ${err ? "ERROR " : "ok    "} ${String(html.length).padStart(6)} B` +
        (err ? `  -> ${err[1]}` : "")
    );
  } catch (e) {
    console.log(`${name.padEnd(10)} THREW  ${e.message.split("\n")[0]}`);
  }
}
console.log("\nfont in use:", svg.font.constructor.name);
console.log("total SVG bytes:", totalBytes);
