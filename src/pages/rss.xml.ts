import rss from "@astrojs/rss";
import type { APIRoute } from "astro";
import { getCollection } from "astro:content";
import { site } from "../site";

/*
 * Summaries only, not full posts. The typeset maths on this site is SVG with a
 * MathML twin attached, and no feed reader renders that as anything better than
 * a wall of markup — a reader is served far better by a description and a link
 * to the page where the equations actually work.
 */
export const GET: APIRoute = async (context) => {
  const posts = (await getCollection("posts", ({ data }) => !data.draft)).sort(
    (a, b) => b.data.published.valueOf() - a.data.published.valueOf()
  );

  return rss({
    title: site.name,
    description: site.description,
    site: context.site ?? site.url,
    items: posts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.published,
      link: `/posts/${post.id}/`,
      categories: [...post.data.tags],
    })),
    customData: `<language>${site.language}</language>`,
  });
};
