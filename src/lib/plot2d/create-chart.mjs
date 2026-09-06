import * as Plot from "@observablehq/plot";

/*
 * A 2D figure that can be zoomed and interrogated.
 *
 * Colours are handed to Plot as `var(--token)` strings rather than resolved
 * values. Plot writes them straight into SVG attributes, where they resolve
 * against the page, so a chart follows the light/dark theme without anyone
 * having to tell it that the theme changed.
 */

const DEFAULT_MARGIN = { top: 20, right: 26, bottom: 48, left: 70 };

const isLog = (axis) => axis.type === "log";

const SUPERSCRIPTS = { "-": "⁻", 0: "⁰", 1: "¹", 2: "²", 3: "³", 4: "⁴", 5: "⁵", 6: "⁶", 7: "⁷", 8: "⁸", 9: "⁹" };

/**
 * Labels a decade as a power of ten and leaves everything between it blank.
 *
 * Plot's default would render 10⁻⁶ as "1µ", which is right for a voltage and
 * wrong for an error term. Blanking the intermediate ticks keeps the minor
 * grid lines without crowding the axis with them.
 */
const powerOfTen = (value) => {
  const exponent = Math.log10(value);
  const rounded = Math.round(exponent);
  if (Math.abs(exponent - rounded) > 1e-9) return "";
  return `10${String(rounded).replace(/[-\d]/g, (char) => SUPERSCRIPTS[char])}`;
};
/** Zooming has to happen in the space the axis is drawn in, not in its units. */
const toScreen = (axis, value) => (isLog(axis) ? Math.log10(value) : value);
const toValue = (axis, screen) => (isLog(axis) ? 10 ** screen : screen);

export function createChart(container, spec) {
  const margin = { ...DEFAULT_MARGIN, ...(spec.margin ?? {}) };
  const home = { x: [...spec.x.domain], y: [...spec.y.domain] };
  let domain = { x: [...home.x], y: [...home.y] };
  let width = 0;
  let height = 0;

  const plotBox = () => ({
    left: margin.left,
    right: width - margin.right,
    top: margin.top,
    bottom: height - margin.bottom,
  });

  /** Turns a pixel position into a data value on the given axis. */
  function dataAt(axis, pixel) {
    const box = plotBox();
    const spec_ = spec[axis];
    const [lo, hi] = domain[axis].map((v) => toScreen(spec_, v));
    const t =
      axis === "x"
        ? (pixel - box.left) / (box.right - box.left)
        : (box.bottom - pixel) / (box.bottom - box.top);
    return toValue(spec_, lo + t * (hi - lo));
  }

  function render() {
    const marks = spec.marks({ domain, margin, width, height });

    const axis = (name) => ({
      domain: domain[name],
      label: spec[name].label,
      type: spec[name].type,
      tickFormat: spec[name].tickFormat ?? (isLog(spec[name]) ? powerOfTen : undefined),
      ticks: spec[name].ticks,
      labelAnchor: "center",
      labelArrow: "none",
      labelOffset: name === "x" ? 38 : 56,
      nice: false,
    });

    const figure = Plot.plot({
      width,
      height,
      marginTop: margin.top,
      marginRight: margin.right,
      marginBottom: margin.bottom,
      marginLeft: margin.left,
      style: {
        background: "transparent",
        fontFamily: "var(--font-ui)",
        fontSize: "12px",
        color: "var(--ink-3)",
        overflow: "visible",
      },
      /*
       * Data is clipped to the frame. Without this, zooming in leaves the parts
       * of a curve that fall outside the axes drawn across the margins and over
       * the tick labels, which reads as the chart having come apart. The axes
       * set their own clip, so this only reaches the marks.
       */
      clip: "frame",
      x: axis("x"),
      y: axis("y"),
      marks: [
        Plot.gridX({ stroke: "var(--rule)", strokeOpacity: 1 }),
        Plot.gridY({ stroke: "var(--rule)", strokeOpacity: 1 }),
        Plot.frame({ stroke: "var(--rule-strong)" }),
        ...marks,
      ],
    });

    figure.setAttribute("role", "img");
    if (spec.title) figure.setAttribute("aria-label", spec.title);
    container.replaceChildren(figure);
  }

  function resize() {
    const next = container.clientWidth;
    if (next === 0 || next === width) return;
    width = next;
    height = Math.round(width * (spec.aspect ?? 0.56));
    render();
  }

  // --- interaction: wheel to zoom about the cursor, drag to pan ---

  const clampToHome = () => {
    for (const name of ["x", "y"]) {
      const axisSpec = spec[name];
      const [homeLo, homeHi] = home[name].map((v) => toScreen(axisSpec, v));
      let [lo, hi] = domain[name].map((v) => toScreen(axisSpec, v));
      const span = Math.min(hi - lo, homeHi - homeLo);

      if (lo < homeLo) [lo, hi] = [homeLo, homeLo + span];
      if (hi > homeHi) [lo, hi] = [homeHi - span, homeHi];
      domain[name] = [toValue(axisSpec, lo), toValue(axisSpec, hi)];
    }
  };

  function zoomAt(px, py, factor) {
    for (const [name, pixel] of [
      ["x", px],
      ["y", py],
    ]) {
      const axisSpec = spec[name];
      const anchor = toScreen(axisSpec, dataAt(name, pixel));
      const [lo, hi] = domain[name].map((v) => toScreen(axisSpec, v));
      domain[name] = [
        toValue(axisSpec, anchor + (lo - anchor) * factor),
        toValue(axisSpec, anchor + (hi - anchor) * factor),
      ];
    }
    clampToHome();
    render();
  }

  const onWheel = (event) => {
    event.preventDefault();
    const box = container.getBoundingClientRect();
    zoomAt(event.clientX - box.left, event.clientY - box.top, Math.exp(event.deltaY * 0.0018));
  };

  let dragFrom = null;

  const onPointerDown = (event) => {
    if (event.button !== 0) return;
    const box = container.getBoundingClientRect();
    dragFrom = {
      px: event.clientX - box.left,
      py: event.clientY - box.top,
      domain: { x: [...domain.x], y: [...domain.y] },
    };
    container.setPointerCapture(event.pointerId);
    container.classList.add("is-panning");
  };

  const onPointerMove = (event) => {
    if (dragFrom === null) return;
    const box = container.getBoundingClientRect();

    for (const [name, moved] of [
      ["x", event.clientX - box.left - dragFrom.px],
      ["y", event.clientY - box.top - dragFrom.py],
    ]) {
      const axisSpec = spec[name];
      const [lo, hi] = dragFrom.domain[name].map((v) => toScreen(axisSpec, v));
      const pixels = name === "x" ? plotBox().right - plotBox().left : plotBox().bottom - plotBox().top;
      const shift = ((name === "x" ? -moved : moved) / pixels) * (hi - lo);
      domain[name] = [toValue(axisSpec, lo + shift), toValue(axisSpec, hi + shift)];
    }
    clampToHome();
    render();
  };

  const onPointerUp = (event) => {
    if (dragFrom === null) return;
    dragFrom = null;
    container.releasePointerCapture(event.pointerId);
    container.classList.remove("is-panning");
  };

  const onDoubleClick = () => {
    domain = { x: [...home.x], y: [...home.y] };
    render();
  };

  container.addEventListener("wheel", onWheel, { passive: false });
  container.addEventListener("pointerdown", onPointerDown);
  container.addEventListener("pointermove", onPointerMove);
  container.addEventListener("pointerup", onPointerUp);
  container.addEventListener("dblclick", onDoubleClick);

  const resizeObserver = new ResizeObserver(resize);
  resizeObserver.observe(container);
  resize();

  return {
    dispose() {
      resizeObserver.disconnect();
      container.removeEventListener("wheel", onWheel);
      container.removeEventListener("pointerdown", onPointerDown);
      container.removeEventListener("pointermove", onPointerMove);
      container.removeEventListener("pointerup", onPointerUp);
      container.removeEventListener("dblclick", onDoubleClick);
      container.replaceChildren();
    },
  };
}

/**
 * A direction field as arrows of constant length on screen.
 *
 * The length has to be fixed in pixels rather than in data units: the two axes
 * rarely share a scale, so an arrow of "one unit" would stretch along whichever
 * axis happens to be shorter and the field would read as skewed.
 */
export function directionField({ fn, domain, margin, width, height, nx = 24, ny = 14, length = 15 }) {
  const [x0, x1] = domain.x;
  const [y0, y1] = domain.y;
  const pxPerX = (width - margin.left - margin.right) / (x1 - x0);
  const pxPerY = (height - margin.top - margin.bottom) / (y1 - y0);

  const arrows = [];
  for (let i = 0; i < nx; i += 1) {
    for (let j = 0; j < ny; j += 1) {
      const x = x0 + ((i + 0.5) / nx) * (x1 - x0);
      const y = y0 + ((j + 0.5) / ny) * (y1 - y0);
      const [u, v] = fn(x, y);

      const screenX = u * pxPerX;
      const screenY = v * pxPerY;
      const norm = Math.hypot(screenX, screenY) || 1;
      const dx = ((length * screenX) / norm / pxPerX) / 2;
      const dy = ((length * screenY) / norm / pxPerY) / 2;

      arrows.push({ x1: x - dx, y1: y - dy, x2: x + dx, y2: y + dy });
    }
  }
  return arrows;
}

/**
 * A legend that shows each series' dash pattern as well as its colour, so the
 * two cues that separate the lines are both present in the key.
 */
export function legend(items) {
  const list = document.createElement("ul");
  list.className = "chart-legend";

  for (const item of items) {
    const entry = document.createElement("li");
    entry.innerHTML =
      `<svg viewBox="0 0 34 12" aria-hidden="true">` +
      `<line x1="1" y1="6" x2="33" y2="6" stroke="${item.color}" stroke-width="2.4"` +
      (item.dash ? ` stroke-dasharray="${item.dash}"` : "") +
      ` stroke-linecap="round" /></svg>`;
    entry.appendChild(document.createTextNode(item.label));
    list.appendChild(entry);
  }
  return list;
}
