/*
 * Draws the picture that appears when a post is pasted into Slack, Bluesky or
 * a group chat. One per post, composed at build time.
 *
 * Satori lays the card out with flexbox and converts every glyph to a path, so
 * the result carries no font dependency: sharp can rasterise it without STIX
 * being installed anywhere. That is the whole reason for the indirection —
 * handing an SVG with a <text> element to sharp would render in whatever the
 * build machine happened to have.
 */

import { readFile } from "node:fs/promises";
import { createRequire } from "node:module";
import { join } from "node:path";
import satori from "satori";
import sharp from "sharp";

const WIDTH = 1200;
const HEIGHT = 630;

/*
 * Tokens, from tokens.css. The background is --ink rather than the dark theme's
 * --paper because --ink is what the mark was drawn on: matching it exactly is
 * what lets the fractal sit on the card with no visible edge to its tile.
 */
const INK = "#16181d";
const INK_RGB = "22,24,29";
const PAPER = "#faf8f4";
const MUTED = "#a9b0ba";
const AMBER = "#e3a84c";

/*
 * Anchored to the project root rather than to import.meta.url, because the
 * build bundles this module into dist/.prerender/chunks and every path relative
 * to the module would then point into the output directory.
 */
const root = process.cwd();
const require = createRequire(join(root, "package.json"));

/*
 * The page itself is set in the variable cut of STIX Two Text, but Satori's
 * font parser rejects a variable font's fvar table outright. This is the static
 * 400 weight of the same typeface, which is the only weight the card uses, so
 * the two are indistinguishable here.
 */
const FONT = require.resolve(
  "@fontsource/stix-two-text/files/stix-two-text-latin-400-normal.woff"
);

let assets;
async function load() {
  if (assets) return assets;

  const [font, mark] = await Promise.all([
    readFile(FONT),
    readFile(join(root, "src/assets/og-mark.png")),
  ]);

  assets = { font, mark: `data:image/png;base64,${mark.toString("base64")}` };
  return assets;
}

/** Minimal element factory: Satori wants React-shaped objects, not JSX. */
const h = (type, props, ...children) => ({
  type,
  props: { ...props, children: children.length > 1 ? children : children[0] },
});

const box = (style, ...children) => h("div", { style }, ...children);
const text = (content, style) => h("div", { style }, content);

/*
 * A longer title is set smaller rather than cut. Truncating is the worse
 * trade: "the analytic continuation of the zeta…" has lost the noun it was
 * about, and the card is the only thing most readers see before deciding.
 */
function titleSize(title) {
  if (title.length <= 38) return 78;
  if (title.length <= 58) return 68;
  if (title.length <= 84) return 56;
  return 48;
}

/**
 * @param {object}  card
 * @param {string}  card.title     the post's title
 * @param {string}  card.subtitle  a short line under it, usually the description
 * @param {?string} card.eyebrow   the site name, omitted where it would repeat
 *                                 the title
 * @returns {Promise<Buffer>} a PNG, 1200x630
 */
export async function renderCard({ title, subtitle, eyebrow }) {
  const { font, mark } = await load();

  /*
   * The mark's own background is the same near-black as the card, so it can sit
   * flush against the right edge with no seam and no cutout: the fractal simply
   * dissolves into the card.
   */
  const svg = await satori(
    box(
      {
        display: "flex",
        width: WIDTH,
        height: HEIGHT,
        background: INK,
        fontFamily: "STIX Two Text",
      },
      h("img", {
        src: mark,
        width: HEIGHT,
        height: HEIGHT,
        style: { position: "absolute", top: 0, right: 0 },
      }),
      /*
       * A wash of the background across the left. Without it the fractal's
       * bright core runs under the end of a long title and the text loses its
       * footing. The stops are spread wide on purpose: a short ramp between two
       * near-opaque values shows up as a seam rather than as a gradient.
       */
      box({
        position: "absolute",
        top: 0,
        left: 0,
        width: WIDTH,
        height: HEIGHT,
        backgroundImage: `linear-gradient(95deg, ${INK} 30%, rgba(${INK_RGB},0.92) 48%, rgba(${INK_RGB},0.55) 68%, rgba(${INK_RGB},0) 92%)`,
      }),
      box(
        {
          display: "flex",
          flexDirection: "column",
          // With no eyebrow there is nothing to space apart, so the block simply
          // settles on the baseline instead of drifting to the top.
          justifyContent: eyebrow ? "space-between" : "flex-end",
          width: 780,
          height: "100%",
          padding: "62px 0 66px 72px",
        },
        ...(eyebrow
          ? [text(eyebrow, { fontSize: 25, letterSpacing: 4.5, color: AMBER })]
          : []),
        // Title and standfirst travel together; only the eyebrow floats away.
        box(
          { display: "flex", flexDirection: "column" },
          text(title, {
            fontSize: titleSize(title),
            lineHeight: 1.14,
            color: PAPER,
            marginBottom: 20,
          }),
          text(subtitle, { fontSize: 29, lineHeight: 1.4, color: MUTED })
        )
      )
    ),
    {
      width: WIDTH,
      height: HEIGHT,
      fonts: [{ name: "STIX Two Text", data: font, weight: 400, style: "normal" }],
    }
  );

  /*
   * Quantised to 256 colours, which costs two thirds of the bytes and shows
   * nowhere: the card is a smooth ramp and some white text, and neither has the
   * variety that makes quantisation visible.
   */
  return sharp(Buffer.from(svg))
    .png({ compressionLevel: 9, palette: true, quality: 90, effort: 10 })
    .toBuffer();
}

/**
 * Trims to a word boundary. A safety net for text long enough to overrun the
 * card whatever size it is set at, not something the usual title should meet.
 */
export function clamp(value, limit) {
  if (value.length <= limit) return value;
  const cut = value.slice(0, limit);
  return `${cut.slice(0, cut.lastIndexOf(" "))}…`;
}
