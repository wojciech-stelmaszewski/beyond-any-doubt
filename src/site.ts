/*
 * Facts about the site that more than one place needs to agree on: the page
 * head, the feed, the sitemap and the structured data all quote them. Keeping
 * one copy is what stops the feed from claiming a different author than the
 * page it links to.
 */
export const site = {
  name: "Beyond Any Doubt",
  description: "Advanced mathematics, worked through in full.",
  author: "Wojciech Stelmaszewski",
  /** Matches `site` in astro.config.mjs. */
  url: "https://beyond-any-doubt.org",
  language: "en",
} as const;
