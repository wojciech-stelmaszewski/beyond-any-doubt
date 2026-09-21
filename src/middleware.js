import { defineMiddleware } from "astro:middleware";

/**
 * Production typesets in `astro:build:done`. Dev never reaches that hook, so
 * the same per-page pass runs here — otherwise the placeholders stay as raw
 * TeX and a local preview looks broken.
 */
export const onRequest = defineMiddleware(async (_context, next) => {
  const response = await next();
  if (!import.meta.env.DEV) return response;

  const type = response.headers.get("content-type") ?? "";
  if (!type.includes("text/html")) return response;

  const html = await response.text();
  if (!html.includes("math-tex") || html.includes("<mjx-container")) {
    return htmlResponse(response, html);
  }

  const { typesetPage } = await import("./lib/typeset-page.mjs");
  return htmlResponse(response, await typesetPage(html));
});

function htmlResponse(response, html) {
  const headers = new Headers(response.headers);
  headers.delete("content-length");
  headers.delete("content-encoding");
  return new Response(html, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
