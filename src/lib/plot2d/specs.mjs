import * as Plot from "@observablehq/plot";
import { directionField } from "./create-chart.mjs";
import {
  dampedOscillator,
  eulerStep,
  heunStep,
  integrate,
  logisticExact,
  lorenz,
  rk4Step,
} from "../ode.mjs";

/*
 * Every series carries a dash pattern as well as a hue. Colour alone fails for
 * readers with colour vision deficiency, in greyscale print, and on a bad
 * projector; the dash survives all three.
 */
export const SERIES = [
  { color: "var(--series-1)", dash: null },
  { color: "var(--series-2)", dash: "8 4" },
  { color: "var(--series-3)", dash: "2 3" },
  { color: "var(--series-4)", dash: "11 3 2 3" },
  { color: "var(--series-5)", dash: "1 4" },
];

const ARROW = {
  stroke: "var(--ink-3)",
  strokeOpacity: 0.55,
  strokeWidth: 1.1,
  headLength: 4.5,
};

const line = (data, series, extra = {}) =>
  Plot.line(data, {
    x: "x",
    y: "y",
    stroke: series.color,
    strokeDasharray: series.dash ?? undefined,
    strokeWidth: 2.4,
    strokeLinecap: "round",
    ...extra,
  });

const readout = (data, format) =>
  Plot.tip(
    data,
    Plot.pointer({
      x: "x",
      y: "y",
      title: format,
      // The tip is chrome, not data: it has to be free to sit over the margin
      // when the point it describes is near an edge.
      clip: false,
      fontFamily: "var(--font-ui)",
      fontSize: 12,
      fill: "var(--paper-raised)",
      stroke: "var(--rule-strong)",
      textPadding: 8,
    })
  );

const asPoints = (pairs, label) => pairs.map(([x, y]) => ({ x, y, series: label }));

// --- the figures ---------------------------------------------------------

const slopeField = () => {
  const r = 1.2;
  const K = 1;
  const exact = logisticExact({ r, K });
  const starts = [0.04, 0.25, 0.75, 1.75];

  const curves = starts.map((x0, i) =>
    asPoints(
      Array.from({ length: 161 }, (_, k) => {
        const t = (k / 160) * 6;
        return [t, exact(t, x0)];
      }),
      `x₀ = ${x0}`
    )
  );

  return {
    title: "Slope field of the logistic equation, with four solutions",
    aspect: 0.54,
    x: { domain: [0, 6], label: "t" },
    y: { domain: [0, 2], label: "x(t)" },
    legend: starts.map((x0, i) => ({ ...SERIES[i], label: `x₀ = ${x0}` })),
    marks: ({ domain, margin, width, height }) => [
      Plot.arrow(
        directionField({
          fn: (_t, x) => [1, r * x * (1 - x / K)],
          domain,
          margin,
          width,
          height,
          nx: 26,
          ny: 15,
        }),
        { x1: "x1", y1: "y1", x2: "x2", y2: "y2", ...ARROW }
      ),
      Plot.ruleY([K], { stroke: "var(--ink-3)", strokeDasharray: "5 4", strokeWidth: 1.4 }),
      Plot.text([{ x: 5.6, y: K + 0.09 }], {
        x: "x",
        y: "y",
        text: () => "x = K",
        fill: "var(--ink-3)",
        fontFamily: "var(--font-ui)",
        fontSize: 12,
      }),
      ...curves.map((data, i) => line(data, SERIES[i])),
      Plot.dot(
        starts.map((x0) => ({ x: 0, y: x0 })),
        { x: "x", y: "y", fill: "var(--ink)", r: 3.5 }
      ),
      readout(curves.flat(), (d) => `${d.series}\nt = ${d.x.toFixed(2)}\nx = ${d.y.toFixed(3)}`),
    ],
  };
};

const phasePortrait = () => {
  const field = dampedOscillator({ omega: 1, zeta: 0.15 });
  const starts = [
    [1.9, 0],
    [0, 1.7],
    [-1.6, -0.7],
    [0.7, -1.9],
  ];

  const curves = starts.map((state, i) =>
    asPoints(
      integrate(field, state, { t1: 24, h: 0.02, keep: 3 }).map(([, x, v]) => [x, v]),
      `x₀ = ${state[0]}, v₀ = ${state[1]}`
    )
  );

  return {
    title: "Phase portrait of a damped oscillator",
    aspect: 0.72,
    x: { domain: [-2.2, 2.2], label: "x   (displacement)" },
    y: { domain: [-2.2, 2.2], label: "v   (velocity)" },
    legend: starts.map((state, i) => ({
      ...SERIES[i],
      label: `x₀ = ${state[0]}, v₀ = ${state[1]}`,
    })),
    marks: ({ domain, margin, width, height }) => [
      Plot.arrow(
        directionField({
          fn: (x, v) => field(0, [x, v]),
          domain,
          margin,
          width,
          height,
          nx: 19,
          ny: 19,
          length: 13,
        }),
        { x1: "x1", y1: "y1", x2: "x2", y2: "y2", ...ARROW, strokeOpacity: 0.45 }
      ),
      ...curves.map((data, i) => line(data, SERIES[i], { strokeWidth: 2.1 })),
      Plot.dot(
        starts.map(([x, v]) => ({ x, y: v })),
        { x: "x", y: "y", fill: "var(--ink)", r: 3.5 }
      ),
      Plot.dot([{ x: 0, y: 0 }], { x: "x", y: "y", fill: "var(--counterexample)", r: 5 }),
      Plot.text([{ x: 0.95, y: 0.42 }], {
        x: "x",
        y: "y",
        text: () => "stable spiral",
        fill: "var(--counterexample)",
        fontFamily: "var(--font-ui)",
        fontSize: 12,
        textAnchor: "start",
      }),
      readout(curves.flat(), (d) => `${d.series}\nx = ${d.x.toFixed(3)}\nv = ${d.y.toFixed(3)}`),
    ],
  };
};

const sensitiveDependence = () => {
  const field = lorenz();
  const delta0 = 1e-9;

  /*
   * The pair has to start on the attractor, not merely near it.
   *
   * Perturbing the usual (1, 1, 1) instead measures the transient approach: the
   * separation sits at its initial value for a dozen time units before it grows
   * at all, because the perturbation begins aligned with a contracting
   * direction and has to rotate into an expanding one first. That plateau is
   * real, but it is a property of the starting point rather than of the system,
   * and it hides the exponent the figure is about. Discarding forty time units
   * first puts the pair on the attractor, where the growth is clean.
   */
  const warmup = integrate(field, [1, 1, 1], { t1: 40, h: 0.004 });
  const start = warmup[warmup.length - 1].slice(1);

  const a = integrate(field, start, { t1: 34, h: 0.004, keep: 6 });
  const b = integrate(field, [start[0] + delta0, start[1], start[2]], {
    t1: 34,
    h: 0.004,
    keep: 6,
  });

  const separation = a.map(([t, ...pa], i) => {
    const pb = b[i].slice(1);
    const distance = Math.hypot(pa[0] - pb[0], pa[1] - pb[1], pa[2] - pb[2]);
    return { x: t, y: Math.max(distance, 1e-12), series: "measured separation" };
  });

  const lambda = 0.906;
  const reference = Array.from({ length: 80 }, (_, i) => {
    const t = (i / 79) * 24;
    return { x: t, y: delta0 * Math.exp(lambda * t), series: "e^{λt}" };
  });

  return {
    title: "Separation of two Lorenz trajectories that start 10⁻⁹ apart",
    aspect: 0.52,
    x: { domain: [0, 34], label: "t" },
    y: { domain: [1e-10, 1e2], type: "log", label: "separation  |Δ(t)|" },
    legend: [
      { ...SERIES[0], label: "measured separation" },
      { color: "var(--ink-3)", dash: "6 4", label: "pure exponential, λ ≈ 0.906" },
      { color: "var(--counterexample)", dash: "3 4", label: "size of the attractor" },
    ],
    marks: () => [
      Plot.ruleY([40], { stroke: "var(--counterexample)", strokeDasharray: "3 4", strokeWidth: 1.4 }),
      line(reference, { color: "var(--ink-3)", dash: "6 4" }, { strokeWidth: 1.7 }),
      line(separation, SERIES[0], { strokeWidth: 2.2 }),
      Plot.text([{ x: 1, y: 78 }], {
        x: "x",
        y: "y",
        text: () => "size of the attractor",
        fill: "var(--counterexample)",
        fontFamily: "var(--font-ui)",
        fontSize: 12,
        textAnchor: "start",
      }),
      Plot.text([{ x: 26, y: 2e-9 }], {
        x: "x",
        y: "y",
        text: () => "prediction is gone",
        fill: "var(--ink-2)",
        fontFamily: "var(--font-ui)",
        fontSize: 12,
        textAnchor: "middle",
      }),
      readout(
        separation,
        (d) => `t = ${d.x.toFixed(2)}\nseparation = ${d.y.toExponential(2)}`
      ),
    ],
  };
};

const convergence = () => {
  const decay = (_t, [x]) => [-x];
  const exact = Math.exp(-1);

  /*
   * Step sizes must divide the interval exactly. With an h that does not, the
   * last step lands beside t = 1 rather than on it, and that mismatch in time
   * swamps the discretisation error being measured.
   */
  const steps = [2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192, 256].map((n) => 1 / n);

  const methods = [
    { label: "Euler, order 1", step: eulerStep, series: SERIES[1] },
    { label: "Heun, order 2", step: heunStep, series: SERIES[2] },
    { label: "RK4, order 4", step: rk4Step, series: SERIES[0] },
  ];

  const curves = methods.map(({ step, label }) =>
    steps.map((h) => {
      const path = integrate(decay, [1], { t1: 1, h, step });
      return {
        x: h,
        y: Math.max(Math.abs(path[path.length - 1][1] - exact), 1e-16),
        series: label,
      };
    })
  );

  return {
    title: "Error at t = 1 against step size, for three integrators",
    aspect: 0.56,
    x: { domain: [3e-3, 6e-1], type: "log", label: "step size  h" },
    y: { domain: [1e-13, 1e0], type: "log", label: "error at t = 1" },
    legend: methods.map(({ label, series }) => ({ ...series, label })),
    marks: () => [
      ...curves.map((data, i) => line(data, methods[i].series, { strokeWidth: 2.2 })),
      ...curves.map((data, i) =>
        Plot.dot(data, { x: "x", y: "y", fill: methods[i].series.color, r: 3.2 })
      ),
      readout(
        curves.flat(),
        (d) => `${d.series}\nh = ${d.x.toExponential(2)}\nerror = ${d.y.toExponential(2)}`
      ),
    ],
  };
};

export const CHARTS = {
  "slope-field": slopeField,
  "phase-portrait": phasePortrait,
  "sensitive-dependence": sensitiveDependence,
  "convergence": convergence,
};

export const chartIds = Object.keys(CHARTS);
