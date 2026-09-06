import { defineConfig } from "astro/config";
import { satteri } from "@astrojs/markdown-satteri";
import { mathPlaceholder } from "./src/lib/math-placeholder.mjs";
import { figureBlock } from "./src/lib/figure-block.mjs";
import { calloutBlock } from "./src/lib/callout-block.mjs";
import { mathjaxIntegration } from "./src/integrations/mathjax.mjs";

export default defineConfig({
  site: "https://beyond-any-doubt.org",
  output: "static",
  integrations: [mathjaxIntegration()],
  markdown: {
    // Maths is only marked up here; it is typeset once per finished page by the
    // integration above, which is what makes \label and \eqref resolve.
    processor: satteri({
      features: { math: { singleDollarTextMath: true } },
      mdastPlugins: [mathPlaceholder(), figureBlock()],
      hastPlugins: [calloutBlock()],
    }),
  },
});
