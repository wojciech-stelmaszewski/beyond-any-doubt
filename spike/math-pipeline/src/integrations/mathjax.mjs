import { readFile, writeFile } from "node:fs/promises";
import { glob } from "node:fs/promises";
import { fileURLToPath } from "node:url";

/**
 * Typesets maths after the static HTML has been generated. Running per finished
 * page (rather than per expression) is what makes \eqref work.
 */
export function mathjaxIntegration() {
  return {
    name: "beyond-any-doubt:mathjax",
    hooks: {
      "astro:build:done": async ({ dir, logger }) => {
        const { typesetPage } = await import("../lib/typeset-page.mjs");
        const root = fileURLToPath(dir);
        const started = Date.now();
        let pages = 0;

        for await (const entry of glob("**/*.html", { cwd: root })) {
          const path = `${root}${entry}`;
          const html = await readFile(path, "utf8");
          const typeset = await typesetPage(html);
          if (typeset !== html) {
            await writeFile(path, typeset);
            pages += 1;
          }
        }

        logger.info(`typeset maths on ${pages} page(s) in ${Date.now() - started}ms`);
      },
    },
  };
}

export default mathjaxIntegration;
