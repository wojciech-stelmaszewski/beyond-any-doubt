# Spike report — math rendering pipeline

- **Date:** 2026-09-05
- **Task:** 2.1–2.9 in `docs/tasks-2026-09-04_11-49.md`
- **Question:** does Astro 7's Sätteri pipeline carry an advanced maths blog, and should we
  render with KaTeX or MathJax 4?
- **Code:** `spike/math-pipeline/` (runnable; `MATH_ENGINE=katex|mathjax npx astro build`)

Everything below was measured on a real build, not inferred from documentation.

---

## 1. Verdict

**Use MathJax 4 with the STIX Two font, rendered to SVG at build time.** It renders every
construct the torture test throws at it, ships no client JavaScript and no runtime CSS or font
files, and matches the STIX Two body text. KaTeX fails outright on `\label` and `\eqref`.

**One requirement is not met and needs a decision:** `\eqref` cross-references do not resolve
under Sätteri's plugin model. See §5.

---

## 2. Versions in play

| Package | Version | Note |
| --- | --- | --- |
| `astro` | 7.3.1 | pulls `@astrojs/markdown-satteri@0.4.0` → `satteri ^0.10.3` |
| `satteri` | 0.10.5 → **downgraded to 0.9.5** | see §3.1 |
| `satteri-katex` | 0.1.1 | peer-depends on `satteri ^0.9.5` |
| `satteri-mathjax` | 0.1.0 | **not used** — depends on `mathjax-full@3`, i.e. MathJax 3 |
| `@mathjax/src` | 4.1.3 | MathJax 4 lives here, not in `mathjax-full` |
| `@mathjax/mathjax-stix2-font` | 4.1.3 | STIX Two maths font for MathJax 4 |
| `katex` | 0.16.x via `satteri-katex` | npm's latest `katex` is 0.18.5 |

## 3. What broke, and why

### 3.1 Installing `satteri-katex` silently downgrades Sätteri

`satteri-katex@0.1.1` declares `peerDependencies: { satteri: "^0.9.5" }`. Under 0.x semver that
range excludes 0.10.x, so npm resolved the conflict by installing `satteri@0.9.5` — below the
`^0.10.3` that Astro's own `@astrojs/markdown-satteri@0.4.0` asks for. No error, no warning in the
build output. The build worked, but the dependency graph is inconsistent, and any future Astro
patch could break it.

This is the concrete form of the "young plugin ecosystem" risk flagged in the plan.

### 3.2 Without a renderer plugin, display maths becomes a code block

With `features: { math: true }` and no rendering plugin, Sätteri emits:

```html
<pre class="astro-code github-dark" data-language="plaintext"><code><span class="line">
  <span>\begin{align}</span></span>
```

Display maths is syntax-highlighted as **plaintext**. There is no error and no warning — the page
builds cleanly and the maths is simply gone. Inline maths fares slightly better, becoming
`<code class="language-math math-inline">`.

This is why the renderer must be registered in `mdastPlugins`, not `hastPlugins`: the highlighter
runs first on HAST, by which point display maths is already a code node.

### 3.3 Single-dollar maths versus currency

With `singleDollarTextMath: true`, the prose `this costs $50 to $100` is parsed as maths and
renders as `costs 50to100 in prose`. With it set to `false`, currency is safe but **inline `$…$`
maths stops working entirely** — `$f:\mathbb{R}\to\mathbb{R}$` reaches the page as literal text.

It is genuinely one or the other. Recommendation: keep `singleDollarTextMath: true` (inline maths
is far more common than currency on this blog) and write prices as `\$50`.

### 3.4 MathJax 4 in Node: three non-obvious traps

1. **`AllPackages` no longer exists.** MathJax 4 has no barrel module; each TeX package is enabled
   by importing its configuration module (`ams/AmsConfiguration.js`, `tagformat/…`, and so on).
2. **Font data loads asynchronously, but Sätteri's handlers are synchronous.** The first `\mathbb`
   throws `MathJax retry -- an asynchronous action is required`. Using `require` for the chunks
   does *not* fix it: the CommonJS chunks register against the CommonJS copy of the font class,
   which the ESM instance never reads — a textbook dual-package hazard. The fix is a top-level
   `await` that dynamic-imports every chunk in `…/js/svg/dynamic/` before any handler runs.
3. **`fontCache: "global"` silently produces blank maths.** Glyphs become `<use>` references into a
   shared `<defs>` block that only exists once per document; rendering each expression in isolation
   leaves 176 dangling `<use>` elements and 114 orphaned paths. The page showed fraction rules and
   nothing else. `fontCache: "local"` makes each expression self-contained.

Trap 3 is worth dwelling on: the byte-size comparison *favoured* the broken build, because missing
glyphs are smaller than present ones. Only the screenshot caught it.

### 3.5 SVG output is invisible to screen readers by default

With plain SVG output the accessibility tree for the first paragraph read:

> "Inline: the map with and ."

The maths contributes nothing. Wrapping the handler in `AssistiveMmlHandler` emits a
visually-hidden MathML copy and restores it to:

> "Inline: the map f : R → R with ε > 0 and ‖ x ‖ 2 ."

This inverts the usual "MathJax is better for accessibility" claim: MathJax with SVG output and no
assistive MathML is **worse** than KaTeX, which ships MathML by default. It is only better once
explicitly configured. Cost: HTML grows from 68 KB to 81 KB on the torture page.

## 4. Measured comparison

Same source document, same layout, same machine.

| | KaTeX | MathJax 4 + STIX Two |
| --- | --- | --- |
| Build time | 665 ms | 714 ms |
| HTML (torture page) | 40.7 KB | 81.2 KB |
| Client JavaScript | 0 B | 0 B |
| Runtime CSS | 24 KB (required) | 0 |
| Runtime font files | ~1.1 MB unsubset | 0 |
| Rendering errors | **2** | 0 |
| `align`, `cases`, `pmatrix`, `substack`, `cfrac` | ok | ok |
| AMS auto-numbering | ok — (1), (2) | ok — (1), (2), (3.7) |
| `\label` | **ParseError** | ok |
| `\eqref` | **ParseError** | renders, but `(???)` — see §5 |
| `mathtools`, `braket` | not available | ok |
| Screen-reader text | ok (MathML by default) | ok (only with `AssistiveMmlHandler`) |
| Breaks if CSS fails to load | **yes** — duplicated MathML, wrong fonts | no — self-contained |
| Font harmony with STIX Two body | mismatched (Computer Modern) | matched |

The HTML size difference is real but less alarming than it looks: MathJax needs no stylesheet and
no font download, so the *first-page* byte count favours MathJax, while a reader who visits many
pages eventually amortises KaTeX's cached font files. For a blog where most visits are one or two
deep, MathJax is the better trade.

## 5. The unresolved requirement: `\eqref`

`\eqref{eq:euler}` renders as `(???)` even though the `\label` is defined earlier on the page.

The cause is structural, not a configuration mistake. Sätteri's plugin API converts one MDAST node
at a time:

```js
defineMdastPlugin({ math: (node) => render(node.value, true), inlineMath: … })
```

Each expression is therefore an independent MathJax conversion. Equation *numbering* survives this
(the counter lives on the shared document), but MathJax's label registry is populated per equation
and consumed by a second pass that never runs, so a reference never finds its label.

Three ways out, in increasing order of effort:

1. **Drop `\eqref`.** Use `\tag{3.7}` plus a hand-written anchor and an ordinary Markdown link.
   Works in both engines, zero machinery, but numbering becomes manual and drift-prone.
2. **Resolve references in a post-processing pass.** Let MathJax emit `(???)`, then rewrite those
   placeholders against a label→number map collected during the build. Moderate effort, keeps the
   plugin model.
3. **Render maths at document scope.** Skip the per-node plugin and run MathJax once over each
   assembled page. This is how MathJax expects to be used and makes `\eqref` work natively, but it
   means stepping outside Sätteri's plugin model.

Option 3 is the only one that makes `\eqref` behave the way it does in LaTeX.

### Resolution (same day)

Option 3 was chosen and implemented. Sätteri now emits `\(…\)` / `\[…\]` placeholders
(`src/lib/math-placeholder.mjs`) and an Astro integration typesets each finished page in one
MathJax pass (`src/integrations/mathjax.mjs`, `src/lib/typeset-page.mjs`). Both backward and
**forward** references resolve, because MathJax's own two-pass recompile finally has a whole
document to work with. Cost: ~40 ms per page.

One clarification the fix exposed: `\label` in a bare `$$…$$` block is *meant* to fail. Under
`tags: "ams"` only AMS environments are numbered, so a label needs `\begin{equation}`. The
original torture test was wrong, not MathJax.

## 6. Recommended configuration

```js
// astro.config.mjs
markdown: {
  processor: satteri({
    features: { math: { singleDollarTextMath: true } },
    mdastPlugins: [satteriMathJax4()],   // MDAST, never HAST
  }),
}
```

with the plugin in `spike/math-pipeline/src/lib/satteri-mathjax4.mjs`:

- `@mathjax/src` 4.1.3, packages `base, ams, tagformat, boldsymbol, mathtools, braket, newcommand`
- `tags: "ams"` for automatic numbering
- SVG output, `fontCache: "local"`, `fontData: MathJaxStix2Font`
- `AssistiveMmlHandler` wrapping the HTML handler
- top-level `await` preloading every font chunk

## 7. Follow-ups

- [ ] Decide between the three `\eqref` options in §5.
- [ ] Pin `satteri` explicitly and re-check §3.1 whenever Astro or `satteri-katex` updates.
- [ ] Subset the STIX Two *text* font (the maths font ships no files, but body text still does).
- [ ] Measure HTML size on a realistic post; the torture page is deliberately maths-dense.
- [ ] Decide whether `displayAlign: "center"` or left alignment suits the design.
