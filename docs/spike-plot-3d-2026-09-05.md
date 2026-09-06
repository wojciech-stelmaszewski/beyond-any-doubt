# Spike: interactive 3D charts and point clouds

**Date:** 2026-09-05
**Question:** which JavaScript library should draw rotatable 3D figures and point
clouds, while taking its colours from our design tokens?

This revises the earlier decision that all figures are static SVG generated at
build time. Rotation and point clouds cannot be done without client-side code,
so the question is no longer *whether* to ship JavaScript but *how little*.

## Candidates considered

| Library | Licence | Status | Verdict |
| --- | --- | --- | --- |
| three.js 0.185.1 | MIT | active | **recommended** |
| plotly.js (gl3d bundle) 4.0.0 | MIT | active | too heavy, too slow |
| echarts + echarts-gl 2.1.0 | Apache-2 / BSD | stale | does not build |
| MathBox 2.3.2 | MIT | abandoned | unusable |
| LightningChart JS, SciChart.js | commercial | active | licence cost |

Two candidates were eliminated before measurement:

- **echarts-gl** does not bundle under Vite, Rollup or esbuild. It imports
  paths without file extensions (`echarts/lib/data/OrdinalMeta`), which only
  webpack resolves; esbuild reports 19 such errors. This reproduces against both
  echarts 5.6.0 and 6.1.0. Astro builds on Vite, so this is disqualifying.
- **MathBox** is thematically the closest fit — it exists to draw mathematics —
  but its last release was 2023, it pins three.js 0.137 (48 versions behind),
  and it draws roughly 240 downloads a week. Adopting it means owning it.

The commercial libraries publish the strongest benchmarks, but those benchmarks
appear in their own marketing comparisons, and both require a paid licence. Out
of scope for a personal blog.

## Measurements

All numbers measured locally on this machine, not quoted from vendors.

### Bundle size

Realistic entry points — for three.js, the modules a scene actually needs
(renderer, camera, `OrbitControls`, lines, points, and for the surface variant a
mesh with lighting); for Plotly, the `gl3d` partial bundle. Bundled with
esbuild, minified, gzip -9.

| Bundle | Minified | Minified + gzip |
| --- | ---: | ---: |
| three.js (points and lines) | 533.8 KB | **133.0 KB** |
| three.js (adds shaded surfaces) | 538.4 KB | **133.9 KB** |
| plotly.js gl3d | 1708.6 KB | **543.3 KB** |

Adding surface support to the three.js scene costs 0.9 KB gzipped, so there is
no reason to split the two cases.

### Frame rate while rotating

A Lorenz point cloud, rotated a full turn while counting frames over four
seconds, 960×540, `devicePixelRatio` forced to 1. The display caps at 60 Hz, so
60 FPS means "as fast as the screen allows", not "the ceiling".

| Points | three.js | plotly.js gl3d |
| ---: | ---: | ---: |
| 100 000 | **60 FPS** | 21 FPS (1.08 s to first draw) |
| 1 000 000 | **58 FPS** | did not finish first draw in 135 s |
| 5 000 000 | 14 FPS | not attempted |

One caveat, stated so the comparison is not read as harsher than it is: the
Plotly loop drives rotation through `Plotly.relayout` on every frame, which is
heavier than its own drag handler, so 21 FPS understates interactive dragging.
The 1M result is not affected by that caveat — Plotly never got as far as
drawing anything, because the cost is in ingesting the data.

## Recommendation

**three.js for interactive 3D, keeping the build-time SVG for everything 2D.**

- 133 KB gzipped, loaded only on pages that actually contain a 3D figure, and
  only when that figure scrolls into view.
- A million points at 58 FPS covers attractors, Monte Carlo samples and spectra
  with room to spare. Beyond a few million points the answer is an octree with
  level-of-detail (Potree, or voxelkloud on WebGPU); that is a different problem
  and we do not have it yet.
- Colours come from `getComputedStyle` on the document element, so the cividis
  ramp and the Okabe-Ito series stay the single source of truth and the scene
  re-colours itself when the theme changes. A packaged charting library would
  instead want its own colour config.

## Decision

Interactive everywhere, at both dimensions:

- **3D is always a canvas.** No static poster frame; a figure that cannot be
  turned is not what we want on the page. Without JavaScript the reader gets the
  caption and a note, which is the accepted cost.
- **2D is interactive too**, via **Observable Plot**, which came in at 83.5 KB
  gzipped as built — well under the 133.3 KB the spike measured, because
  `d3-zoom` turned out to be unnecessary. Zoom and pan are about forty lines
  against the axis domains, and re-rendering the plot is cheap at our data
  sizes. It was chosen over the alternatives because it is the
  only one that draws all four of our 2D figures with stock marks: `vector` is
  precisely a slope field, `line` carries solution curves, and its scales go
  logarithmic for the error plots. ECharts costs 208.1 KB and would need a
  `custom` series to draw arrows — the same work we already do, in a foreign
  API. uPlot is far lighter at 22.5 KB but is built for time series and has no
  answer for a vector field. JSXGraph is the most mathematical of them and also
  the heaviest at 250.0 KB.
- **Point clouds up to about a million points**, held in memory. Beyond that the
  answer is an octree with level-of-detail; we do not have that problem.

### How the scenes are fed

Scenes ship as recipes rather than data. The markdown block names a scene, and
the browser integrates the system itself — a Lorenz trajectory is a few
milliseconds of arithmetic, where the same points as JSON would be megabytes.

Colours come from `getComputedStyle` on the document element, so the cividis
ramp and the Okabe-Ito series stay the single source of truth. A `MutationObserver`
on the theme attribute re-reads them, which re-colours a live scene without
rebuilding its geometry.

### Measured cost on the page

Measured on the built output, gzip -9:

| Chunk | gzip | Loaded |
| --- | ---: | --- |
| page entry | 1 350 B | always |
| ODE integrators | 460 B | with the first figure of either kind |
| chart recipes | 7 264 B | with the first 2D figure |
| Observable Plot | 83 474 B | with the first 2D figure |
| scene recipes | 750 B | with the first 3D figure |
| three.js scene | 136 229 B | with the first 3D figure |

Both renderers sit behind dynamic imports driven by an `IntersectionObserver`
with a 300 px margin, and they are separate chunks: a post of ordinary 2D charts
never requests three.js, and a reader who stops halfway down never pays for a
figure further on. Scenes also stop their render loop while off screen.

The 2D charts need no theme handling at all. Their colours are written into the
SVG as `var(--series-1)` and friends rather than resolved values, so a change of
theme recolours them through the cascade, with no listener and no redraw. Only
the WebGL scenes, which cannot read a CSS variable, need the `MutationObserver`.

A 400 000-point cloud holds 60 FPS on the built page.

## Open questions

- Point clouds beyond ~2M points need a streaming format (Potree, or voxelkloud
  on WebGPU). Deferred until a post needs one.
