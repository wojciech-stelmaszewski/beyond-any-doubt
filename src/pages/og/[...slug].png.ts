import type { APIRoute, GetStaticPaths } from "astro";
import { getCollection } from "astro:content";
import { clamp, renderCard } from "../../lib/og-card.mjs";
import { site } from "../../site";

/*
 * One social card per post, plus one for the site itself, written out as real
 * files during the build. Nothing renders these on demand: the site is static,
 * and a card that has to be generated when it is requested is a card that is
 * missing the first time anyone pastes the link.
 */
export const getStaticPaths = (async () => {
  const posts = await getCollection("posts", ({ data }) => !data.draft);

  return [
    // The site's own card carries no eyebrow: it would repeat the title.
    {
      params: { slug: "site" },
      props: { title: site.name, subtitle: site.description, eyebrow: null },
    },
    ...posts.map((post) => ({
      params: { slug: post.id },
      props: {
        title: post.data.title,
        subtitle: post.data.description,
        eyebrow: site.name.toUpperCase(),
      },
    })),
  ];
}) satisfies GetStaticPaths;

/*
 * The limits sit just above what a description should be anyway — a search
 * result is cut at about 160 characters — so a well-written one is never
 * trimmed here, and the clamp only catches the pathological case.
 */
export const GET: APIRoute = async ({ props }) => {
  const png = await renderCard({
    title: clamp(props.title as string, 120),
    subtitle: clamp(props.subtitle as string, 165),
    eyebrow: props.eyebrow as string | null,
  });

  return new Response(png, { headers: { "Content-Type": "image/png" } });
};
