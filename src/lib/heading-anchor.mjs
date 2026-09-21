import Slugger from "github-slugger";
import { defineHastPlugin } from "satteri";

/*
 * Permalinks on section headings. The id is set here so the built-in
 * heading-ids pass can reuse it; the visible "#" is CSS, so it never leaks
 * into the slug or the table of contents.
 *
 * The factory is per document: a shared slugger would number collisions
 * across posts.
 */
export const headingAnchor = () => () => {
  const slugger = new Slugger();

  return defineHastPlugin({
    name: "heading-anchor",
    element: {
      filter: ["h2", "h3", "h4"],
      visit(node, ctx) {
        const text = ctx.textContent(node).trim();
        const existing = node.properties?.id;
        const slug = typeof existing === "string" ? existing : slugger.slug(text);
        if (typeof existing !== "string") ctx.setProperty(node, "id", slug);

        ctx.appendChild(node, {
          type: "element",
          tagName: "a",
          properties: {
            className: ["heading-anchor"],
            href: `#${slug}`,
            ariaLabel: `Permalink to “${text}”`,
          },
          children: [],
        });
      },
    },
  });
};

export default headingAnchor;
