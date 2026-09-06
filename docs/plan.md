# Beyond Any Doubt — Living Plan

This is the canonical, continuously updated plan. The timestamped snapshot
`docs/plan-2026-09-04_11-49.md` holds the full reasoning, the research citations and the verified
contrast figures; it is a historical record and should not be edited. This file records what we
decided, what is still open, and what we intend to improve next.

**Project:** an advanced mathematics blog at `beyond-any-doubt.org`, hosted on GitHub Pages.

---

## 1. Current State

The repository contains a `LICENSE` and this documentation. No application code exists yet.
Implementation is blocked on the approval gate (Phase 0 in `docs/tasks-2026-09-04_11-49.md`).

## 2. Direction

**Design — "Ink & Proof".** A warm off-white paper (`#FAF8F4`) with near-black ink (`#16181D`), a
single disciplined indigo accent (`#2740B0`) for anything actionable, and four semantic hues that
mark the structure of a mathematical argument (definition, theorem, conjecture, counterexample).
Every token's contrast ratio has been computed and every chart colour has been run through a
colour-vision-deficiency simulation. Nothing is decorative.

**Technology.** Astro 7 producing fully static output, Markdown/MDX content, KaTeX rendered at build
time, and Observable Plot charts server-side rendered to SVG at build time. The default reading
experience ships no JavaScript at all; interactivity is opt-in per figure.

## 3. Decision Log

Decisions are appended here as they are made. Each entry records the choice, the reason, and what
would cause us to revisit it.

| # | Decision | Status | Rationale | Revisit if |
| --- | --- | --- | --- | --- |
| D1 | Light theme is the default; dark theme is fully specified, not derived | **Proposed** | Positive display polarity measurably improves proofreading (Buchner & Baumgartner 2007; Piepenbrock et al. 2013, 2014); some low-vision readers need the reverse (Legge et al. 1985) | — |
| D2 | Text is `#16181D` on `#FAF8F4`, not black on white | **Proposed** | Reading speed saturates well below maximum contrast (Legge et al. 1987); maximum contrast only adds glare and halation | — |
| D3 | Default chart series capped at five | **Proposed** | Above five, CVD simulation shows indistinguishable pairs (min ΔE 2.9 at eight series); also matches Cowan's (2001) working-memory limit | — |
| D4 | Chart series keep varied luminance rather than uniform contrast | **Proposed** | Forcing every series above 4.5:1 makes them isoluminant (L 0.14–0.19), destroying greyscale/print separation | — |
| D5 | Astro 7, static output | **Proposed** | Zero JS by default, islands for interactivity, Node 22.21.1 already satisfies the requirement | Workflow turns out to be notebook-driven → reconsider Quarto |
| D6 | ~~KaTeX at build time~~ → **MathJax 4 + STIX Two, SVG at build time** | **Decided** (spike, 2026-09-05) | KaTeX fails outright on `\label`/`\eqref`; MathJax renders everything, ships no client JS and no runtime CSS or fonts, and matches STIX Two body text | Never, unless HTML size on real posts proves unacceptable |
| D7 | Native Sätteri markdown pipeline | **Decided** (spike, 2026-09-05) | Works; own MathJax plugin on `mdastPlugins` avoids the community `satteri-katex` and its Sätteri downgrade | Astro changes the plugin API |
| D8 | Body text uses STIX Two Text; maths uses STIX Two Math | **Decided** | User preference for harmonised text/maths; only reachable via MathJax, which D6 now selects | — |
| D9 | `singleDollarTextMath: true`; prices written as `\$50` | **Decided** (spike) | Inline `$…$` maths and bare currency are mutually exclusive in Sätteri; inline maths is far more common here | — |
| D10 | `\eqref` via **document-scope rendering**: Sätteri emits `\(…\)` placeholders, an Astro integration typesets each finished page once | **Decided & implemented** (2026-09-05) | The only option that gives LaTeX-like behaviour; forward references work too | Astro removes `astro:build:done` |

## 4. Open Questions

1. Whether comments (Giscus) are wanted at all, given the audience.
2. Whether `\label` should be allowed only inside numbered environments (current behaviour, matches
   LaTeX) or whether every display equation should be numbered via `tags: "all"`.

## 4a. Built and Verified (2026-09-05)

The skeleton exists and builds. Measured on `dist/posts/euler-product/`:

| Check | Result |
| --- | --- |
| `\eqref` cross-references | resolve, including forward references |
| Client-side JavaScript | 0 bytes, 0 files |
| Runtime CSS / font files for maths | none |
| Screen-reader text for maths | present (assistive MathML) |
| Sätteri version conflict (§3.1 of the spike) | gone — resolves to 0.10.5 |
| `CNAME` for the apex domain | emitted |
| Build time, 2 pages | ~730 ms |

## 4b. Typography (2026-09-05)

STIX Two Text is self-hosted as a **variable** font, so weights 400–700 cost one file per style:
27.9 KB roman + 30.3 KB italic, latin subset, 58 KB in total for the entire range. The roman file
is preloaded. STIX Two *Math* ships nothing — MathJax inlines its glyphs as SVG paths.

To avoid the reflow that `font-display: swap` normally causes, the stack includes a metric-matched
`STIX Fallback` face: Georgia with `size-adjust` and ascent/descent overrides derived from
measuring both faces in the browser. Measured on a block of body prose at a fixed width:

| Fallback | Rendered height | Error vs the real font |
| --- | --- | --- |
| `STIX Fallback` (adjusted Georgia) | 416 px | **0.00 %** |
| Plain Georgia | 445 px | 6.97 % |

The UI and monospace roles use system stacks rather than Inter and JetBrains Mono. Two extra
families would be two extra downloads for text that amounts to dates and the odd code span; this
is the YAGNI call, and it is easy to revisit.

Known gaps, deliberately left for later phases: there is no theme toggle, no charts, and no deploy
workflow.

## 5. Improvement Backlog

Ordered by expected value, to be pulled from once the site is live.

### Correctness and trust

- Automated contrast checking in CI, so no token can silently regress below its documented ratio.
- Brettel-based CVD verification (covers tritanopia, which the Viénot simulation models poorly).
- Build-time internal link checking, failing the build on breakage.
- Greyscale-print verification for every chart.

### Reading experience

- Print stylesheet that forces the light theme, expands links to URLs and keeps figures unbroken.
- Stable permalink anchors on every heading, figure and numbered equation.
- Table of contents with reading-position indication for long proofs.
- Reduced-motion support honouring `prefers-reduced-motion`.

### Authoring experience

- A maths torture-test post kept in the repository as a permanent regression check.
- A `/styleguide` page rendering every token, callout and chart series.
- Post templates for the common shapes: exposition, proof walkthrough, computational experiment.

### Performance

- Font subsetting driven by actual glyph usage.
- Lighthouse CI budget with performance and accessibility both at 95 or above.
- Measure whether GitHub Pages' short `Cache-Control` lifetime on hashed assets matters in practice
  before attempting to work around it.

## 6. Explicitly Out of Scope (YAGNI)

Multi-language content, a tag taxonomy beyond flat tags, a multi-author system, a runtime CMS, a
newsletter, and any client-side state management library. Each of these gets reconsidered only when
a concrete need appears — not in anticipation of one.
