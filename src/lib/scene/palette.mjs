import { Color } from "three";

/*
 * The scene takes its colours from the page's design tokens rather than from a
 * table of its own, so the palette stays defined in one place and a change of
 * theme reaches WebGL as well as the CSS.
 */

const SEQ_STOPS = 9;
const SERIES_COUNT = 5;

const readToken = (styles, name, fallback) => {
  const value = styles.getPropertyValue(name).trim();
  return value === "" ? fallback : value;
};

export function readPalette(element = document.documentElement) {
  const styles = getComputedStyle(element);
  const color = (name, fallback) => new Color(readToken(styles, name, fallback));

  return {
    // Cividis, for continuous quantities.
    sequential: Array.from({ length: SEQ_STOPS }, (_, i) => color(`--seq-${i}`, "#808080")),
    // Okabe-Ito, for anything categorical.
    series: Array.from({ length: SERIES_COUNT }, (_, i) => color(`--series-${i + 1}`, "#0072b2")),
    paper: color("--paper-raised", "#ffffff"),
    sunken: color("--paper-sunken", "#f0ece4"),
    rule: color("--rule", "#dcd6ca"),
    ruleStrong: color("--rule-strong", "#beb6a6"),
    ink: color("--ink", "#16181d"),
    ink2: color("--ink-2", "#444a54"),
    accent: color("--counterexample", "#a32319"),
  };
}

/** Samples the cividis ramp, interpolating between its nine stops. */
export function sampleSequential(palette, t, target = new Color()) {
  const position = Math.max(0, Math.min(1, t)) * (SEQ_STOPS - 1);
  const stop = Math.min(SEQ_STOPS - 2, Math.floor(position));
  return target
    .copy(palette.sequential[stop])
    .lerp(palette.sequential[stop + 1], position - stop);
}

/**
 * Calls back whenever the theme changes, so a live scene can re-read its
 * colours instead of being rebuilt.
 */
export function watchTheme(onChange) {
  const observer = new MutationObserver(() => onChange(readPalette()));
  observer.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme", "class"],
  });
  return () => observer.disconnect();
}
