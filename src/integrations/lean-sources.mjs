import { mkdir, copyFile, readdir } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve } from "node:path";

/**
 * Publishes the Lean sources alongside the site, so a post can offer the
 * machine-checked version of what it argues in prose without sending the
 * reader to a code host.
 *
 * The files are copied from `lean/` at build time rather than duplicated into
 * `public/`, because a second copy in the repository is a copy that drifts:
 * the post would keep promising a proof the library no longer contains.
 */
export function leanSources({ libraries = [] } = {}) {
  return {
    name: "beyond-any-doubt:lean-sources",
    hooks: {
      "astro:build:done": async ({ dir, logger }) => {
        const out = fileURLToPath(dir);
        const repo = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
        let copied = 0;

        for (const library of libraries) {
          const from = join(repo, "lean");
          const to = join(out, "lean");
          await mkdir(join(to, library), { recursive: true });

          const files = [
            `${library}.lean`,
            ...(await readdir(join(from, library)))
              .filter((name) => name.endsWith(".lean"))
              .map((name) => join(library, name)),
          ];

          for (const file of files) {
            await copyFile(join(from, file), join(to, file));
            copied += 1;
          }
        }

        logger.info(`published ${copied} Lean source file(s) under /lean/`);
      },
    },
  };
}

export default leanSources;
