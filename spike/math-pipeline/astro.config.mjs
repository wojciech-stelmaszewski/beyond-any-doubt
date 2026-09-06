import { defineConfig } from "astro/config";
import { satteri } from "@astrojs/markdown-satteri";
import { satteriKatex } from "satteri-katex";
import { satteriMathJax4 } from "./src/lib/satteri-mathjax4.mjs";
import { mathPlaceholder } from "./src/lib/math-placeholder.mjs";
import { mathjaxIntegration } from "./src/integrations/mathjax.mjs";

// katex   — per-node KaTeX
// mathjax — per-node MathJax 4
// docscope — placeholders + one MathJax pass per finished page (supports \eqref)
const engine = process.env.MATH_ENGINE ?? "docscope";

const plugin =
  engine === "mathjax" ? satteriMathJax4() : engine === "katex" ? satteriKatex() : mathPlaceholder();

export default defineConfig({
  output: "static",
  integrations: engine === "docscope" ? [mathjaxIntegration()] : [],
  vite: { define: { "import.meta.env.MATH_ENGINE": JSON.stringify(engine) } },
  markdown: {
    processor: satteri({
      features: { math: { singleDollarTextMath: true } },
      mdastPlugins: [plugin],
    }),
  },
});
