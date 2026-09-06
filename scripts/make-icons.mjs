/*
 * Draws the site mark and writes every raster size the page needs.
 *
 * The mark is the filled Julia set of z -> z^2 + c at c = -0.4 + 0.6i, coloured
 * by escape time along a ramp built from the design tokens. Escape time is a
 * continuous quantity, so it is shaded the way the figures shade continuous
 * quantities, and the icon ends up speaking the same language as the plots.
 *
 * Run this by hand when the mark changes; the output is committed. Computing a
 * fractal on every build would put a second of CPU into CI for a picture that
 * never changes, and would make the deployed bytes depend on the runner.
 *
 *   node scripts/make-icons.mjs
 */

import { mkdirSync, writeFileSync } from "node:fs";
import sharp from "sharp";

const PUBLIC = new URL("../public/", import.meta.url);
const ASSETS = new URL("../src/assets/", import.meta.url);

const RENDER = 1024;
const MAX_ITER = 300;
const ESCAPE = 256;

/* The parameter, the window on the plane, and how far the ramp is stretched. */
const C = [-0.4, 0.6];
const SPAN = 1.2;
const SPREAD = 42;

/*
 * --ink -> --conjecture -> --paper, from tokens.css. Warm enough to be found in
 * a crowded tab strip, and every stop is a colour the site already uses.
 */
const STOPS = ["#16181d", "#8f5a08", "#faf8f4"].map((hex) => [
  parseInt(hex.slice(1, 3), 16),
  parseInt(hex.slice(3, 5), 16),
  parseInt(hex.slice(5, 7), 16),
]);

function ramp(t) {
  const x = Math.min(0.9999, Math.max(0, t)) * (STOPS.length - 1);
  const i = Math.floor(x);
  const f = x - i;
  const a = STOPS[i];
  const b = STOPS[i + 1];
  return [a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f];
}

/** Escape-time render of the filled Julia set, as raw RGB. */
function drawMark(size, span) {
  const pixels = Buffer.alloc(size * size * 3);
  const inside = ramp(0);

  for (let py = 0; py < size; py += 1) {
    const y0 = (py / size - 0.5) * 2 * span;
    for (let px = 0; px < size; px += 1) {
      const x0 = (px / size - 0.5) * 2 * span;

      let x = x0;
      let y = y0;
      let x2 = x * x;
      let y2 = y * y;
      let n = 0;

      while (x2 + y2 <= ESCAPE && n < MAX_ITER) {
        y = 2 * x * y + C[1];
        x = x2 - y2 + C[0];
        x2 = x * x;
        y2 = y * y;
        n += 1;
      }

      let colour;
      if (n === MAX_ITER) {
        colour = inside;
      } else {
        /*
         * The fractional part of the iteration count. Without it the picture
         * comes out in concentric bands, one per integer step, which reads as
         * contour lines rather than as a gradient.
         */
        const smooth = n + 1 - Math.log(Math.log(Math.sqrt(x2 + y2))) / Math.LN2;
        colour = ramp(smooth / SPREAD);
      }

      const o = (py * size + px) * 3;
      pixels[o] = colour[0];
      pixels[o + 1] = colour[1];
      pixels[o + 2] = colour[2];
    }
  }

  return sharp(pixels, { raw: { width: size, height: size, channels: 3 } });
}

const rounded = (size) =>
  Buffer.from(
    `<svg width="${size}" height="${size}"><rect width="${size}" height="${size}" rx="${Math.round(
      size * 0.2
    )}" fill="#fff"/></svg>`
  );

const master = drawMark(RENDER, SPAN);

/*
 * Palette PNGs, which cost about a third of the bytes of full colour here.
 * A fractal shaded along a three-stop ramp does not use many distinct hues, so
 * quantising to 256 with dithering is not visible at any of these sizes — and
 * a page that ships its figures as a few kilobytes of recipe has no business
 * spending a quarter of a megabyte on its icons.
 */
async function write(dir, name, size, { round }) {
  let image = master.clone().resize(size, size, { kernel: "lanczos3" });
  if (round) image = image.composite([{ input: rounded(size), blend: "dest-in" }]);
  await image
    .png({ compressionLevel: 9, palette: true, quality: 92, effort: 10 })
    .toFile(new URL(name, dir).pathname);
  console.log(`  ${name}`);
}

console.log("icons:");

// Browser tabs: rounded, because nothing else rounds them for us.
await write(PUBLIC, "favicon-16.png", 16, { round: true });
await write(PUBLIC, "favicon-32.png", 32, { round: true });

/*
 * iOS and Android apply their own mask to a home-screen icon, so these are left
 * square. Rounding them first would show as a dark rim inside the system's
 * own corners.
 */
await write(PUBLIC, "apple-touch-icon.png", 180, { round: false });
await write(PUBLIC, "icon-192.png", 192, { round: false });
await write(PUBLIC, "icon-512.png", 512, { round: false });

/*
 * Only ever read at build time, when the social cards are composed, so it goes
 * outside public/ — there is no reason for a reader to download it.
 */
mkdirSync(ASSETS, { recursive: true });
await write(ASSETS, "og-mark.png", 630, { round: false });

writeFileSync(
  new URL("site.webmanifest", PUBLIC),
  `${JSON.stringify(
    {
      name: "Beyond Any Doubt",
      short_name: "Beyond Any Doubt",
      description: "Advanced mathematics, worked through in full.",
      start_url: "/",
      display: "browser",
      background_color: "#faf8f4",
      theme_color: "#faf8f4",
      icons: [
        { src: "/icon-192.png", sizes: "192x192", type: "image/png" },
        { src: "/icon-512.png", sizes: "512x512", type: "image/png" },
      ],
    },
    null,
    2
  )}\n`
);
console.log("  site.webmanifest");
