# Beyond Any Doubt

Advanced mathematics, worked through in full — [beyond-any-doubt.org](https://beyond-any-doubt.org).

A static site built around two things that are usually afterthoughts: equations
that are typeset properly, and figures you can actually turn and zoom. Both are
load-bearing here, so most of the decisions below exist to serve them.

## Running it

Node 22 or later, which is also what CI uses.

```sh
npm install
npm run dev      # http://localhost:4321
npm run build    # writes dist/
npm run preview  # serves what was built
```

Vite caches the modules that `astro.config.mjs` imports, so edits to the figure
or maths code sometimes do not take effect. When output stops matching the
source, clear the caches:

```sh
./scripts/rebuild.sh
```

## Writing a post

Posts are Markdown in `src/content/posts/`, with frontmatter checked against the
schema in `src/content.config.ts`:

```yaml
---
title: The Euler product, and why it is not a coincidence
description: >-
  One or two sentences. Keep it under about 160 characters: that is where a
  search result is cut, and it is also what fits on the social card.
published: 2026-09-05
tags: ["analytic number theory"]
draft: false
---
```

### Maths

`$inline$` and `$$display$$`, with the full LaTeX surface MathJax supports.
Equations can be labelled and referred to from anywhere on the page:

```markdown
$$
\dot{x} = \sigma(y - x) \label{eq:lorenz}
$$

The nonlinearity in $\eqref{eq:lorenz}$ is only two quadratic terms.
```

Cross-references work because the page is typeset **once, as a whole document**,
after Astro has assembled it — not fragment by fragment during Markdown
processing. That is the entire reason for the integration in
`src/integrations/mathjax.mjs`: `\label` and `\eqref` cannot resolve if each
equation is rendered in isolation, unaware of the others.

### Callouts

A blockquote with a marker becomes a semantically styled aside. Nine kinds:
`definition`, `theorem`, `lemma`, `corollary`, `proposition`, `conjecture`,
`counterexample`, `proof`, `remark`.

```markdown
> [!theorem] Theorem 1.2 (Picard–Lindelöf)
> If $f$ is continuous in $t$ and Lipschitz in $x$, then the initial value
> problem has a unique solution on some interval around $t = 0$.
```

The text after the marker is the whole label, so numbering is yours to write and
yours to keep consistent — nothing counts for you.

Each kind has a colour, and also its own sigil — `D`, `T`, `∎`, `¶` and so on —
because colour alone must never be the thing that carries the meaning. The
results and the proof close with a tombstone; the rest do not.

### Figures

A `figure` block naming a chart or a scene, plus a caption:

````markdown
```figure
{ "chart": "slope-field", "caption": "Four solutions over the direction field." }
```

```figure
{ "scene": "lorenz-attractor", "caption": "Drag it: the wings meet at an angle." }
```
````

Available now — add to `src/lib/plot2d/specs.mjs` or `src/lib/scene/specs.mjs`
for more:

| Kind | Identifiers |
| --- | --- |
| `chart` (2D, Observable Plot) | `slope-field`, `phase-portrait`, `sensitive-dependence`, `convergence` |
| `scene` (3D, three.js) | `lorenz-attractor`, `lorenz-cloud`, `solution-surface` |

Captions accept inline HTML and `\eqref`.

## How it is put together

**Figures ship as recipes, not as data.** A post carries roughly three kilobytes
describing what to draw; the trajectories are integrated in the browser by
`src/lib/ode.mjs`. The alternative — precomputing points and shipping them —
would have meant hundreds of kilobytes for the four-hundred-thousand-point
cloud alone, to say nothing of what it does to a diff.

**Figures load only when scrolled to.** three.js and the scene data are fetched
on intersection, so a reader who never reaches the bottom of a post never pays
for the WebGL that lives there.

**Figures read their colours from CSS.** `src/lib/scene/palette.mjs` resolves
the design tokens at runtime and watches for theme changes, so a plot recoloured
by the theme toggle needs no second copy of the palette in JavaScript.

**Maths is SVG with MathML attached.** The visible output is SVG for typographic
control; a visually hidden MathML twin travels with it so screen readers get the
structure rather than a picture.

**The theme follows the system, until it is told otherwise.** The choice is
persisted, and applied by a synchronous inline script in `<head>` — deferred
code would show a flash of the wrong theme before it ran.

**The palette is chosen for legibility, not taste.** Categorical series use
Okabe–Ito, continuous quantities use cividis, and every pair meets WCAG
contrast. Series are distinguished by dash pattern as well as hue.

**Social cards are composed at build time.** Satori converts glyphs to paths, so
a card carries no font dependency and cannot come out in whatever typeface the
build machine happens to have installed.

### Layout

```
src/
  content/posts/     the posts
  lib/               build-time and browser modules
    ode.mjs            Euler, Heun, RK4, and the systems the posts use
    plot2d/            2D chart specs and rendering
    scene/             three.js scenes, point clouds, palette bridge
    og-card.mjs        social card composition
    *-block.mjs        Markdown plugins: figures, callouts, maths markers
    typeset-page.mjs   whole-document MathJax pass
  integrations/      the Astro hook that runs that pass
  styles/            tokens, then base styles built on them
  site.ts            facts the head, feed and sitemap must agree on
scripts/
  make-icons.mjs     draws the site mark; run by hand, output committed
  check-ode.mjs      sanity-checks the numbers behind the figures
  rebuild.sh         clean rebuild when Vite's cache goes stale
```

### The site mark

The icon is the filled Julia set of $z \mapsto z^2 + c$ at $c = -0.4 + 0.6i$,
shaded by escape time along the same design tokens the figures use. It is drawn
by `scripts/make-icons.mjs` and committed rather than generated during the
build: it never changes, so CI has no reason to spend a second of CPU on it.

```sh
node scripts/make-icons.mjs
```

## Deployment

Pushing to `main` builds the site and publishes it to GitHub Pages via
`.github/workflows/deploy.yml`. The custom domain lives in the repository's Pages
settings, not in a `CNAME` file — when publishing from a workflow, GitHub ignores
that file.

## Notes

`docs/` holds the reasoning behind the larger choices: the palette, the
[MathJax against KaTeX comparison](docs/spike-math-2026-09-05.md), and the
[3D plotting library benchmarks](docs/spike-plot-3d-2026-09-05.md) that settled
on three.js.

`lean/` is separate from the site and does not ship with it: a machine-checked
proof of [Banach's fixed point theorem](lean/README.md), taking the title of this
place a little more literally than the posts do.
