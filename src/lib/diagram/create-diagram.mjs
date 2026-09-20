/*
 * A state diagram you can walk a word through.
 *
 * Drawn by hand rather than by a graph library, for two reasons. The graph is
 * three nodes and four edges, so there is no layout problem to solve — every
 * automatic layout engine that could place it costs several megabytes to ship
 * for the privilege. And colours here are `var(--token)` strings written
 * straight into SVG attributes, the same trick the charts use, so the figure
 * follows the light and dark themes without being told the theme changed. A
 * library that resolves colours for us would take that away.
 */

const SVG_NS = "http://www.w3.org/2000/svg";
const STEP_MS = 680;

const el = (name, attrs = {}, text) => {
  const node = document.createElementNS(SVG_NS, name);
  for (const [key, value] of Object.entries(attrs)) node.setAttribute(key, value);
  if (text !== undefined) node.textContent = text;
  return node;
};

const html = (name, className, text) => {
  const node = document.createElement(name);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
};

/**
 * Geometry for one edge: a quadratic through a control point offset from the
 * midpoint, trimmed so it starts and ends on the circles rather than at their
 * centres, plus an arrowhead lying along the curve's final direction.
 *
 * `bend` is measured to the right of travel, so the sign of an edge's bend
 * depends on which way it runs — which is why the two `tu` edges, both drawn
 * above the line, do not carry the same sign.
 */
function geometry(from, to, bend, radius, gap = 15) {
  const dx = to.x - from.x;
  const dy = to.y - from.y;
  const length = Math.hypot(dx, dy) || 1;
  const normal = { x: -dy / length, y: dx / length };

  const control = {
    x: (from.x + to.x) / 2 + normal.x * bend,
    y: (from.y + to.y) / 2 + normal.y * bend,
  };

  const trim = (point) => {
    const ux = control.x - point.x;
    const uy = control.y - point.y;
    const norm = Math.hypot(ux, uy) || 1;
    return { x: point.x + (ux / norm) * radius, y: point.y + (uy / norm) * radius };
  };

  const start = trim(from);
  const end = trim(to);

  // The curve arrives along the vector from the control point, which is the
  // tangent at t = 1 for a quadratic.
  const angle = Math.atan2(end.y - control.y, end.x - control.x);
  const head = (spread, back) => ({
    x: end.x - back * Math.cos(angle) + spread * Math.sin(angle),
    y: end.y - back * Math.sin(angle) - spread * Math.cos(angle),
  });
  const left = head(4.6, 11);
  const right = head(-4.6, 11);

  /*
   * The label sits at the quadratic's midpoint, pushed clear of the line on
   * the outside of the bend — which is the direction the control point was
   * displaced, and so flips with the sign of `bend` rather than with the
   * direction of travel.
   */
  const side = bend === 0 ? 1 : Math.sign(bend);

  return {
    path: `M ${start.x} ${start.y} Q ${control.x} ${control.y} ${end.x} ${end.y}`,
    arrow: `M ${end.x} ${end.y} L ${left.x} ${left.y} L ${right.x} ${right.y} Z`,
    label: {
      x: (start.x + 2 * control.x + end.x) / 4 + normal.x * gap * side,
      y: (start.y + 2 * control.y + end.y) / 4 + normal.y * gap * side,
    },
  };
}

export function createDiagram(container, spec) {
  const reduceMotion = window.matchMedia?.("(prefers-reduced-motion: reduce)").matches ?? false;
  const byId = new Map(spec.states.map((state) => [state.id, state]));

  const svg = el("svg", {
    viewBox: `0 0 ${spec.width} ${spec.height}`,
    "aria-hidden": "true",
    class: "diagram-svg",
  });

  /* Edges first, so a circle always covers the line rather than the reverse. */
  const edges = spec.edges.map((edge) => {
    const { path, arrow, label } = geometry(
      byId.get(edge.from),
      byId.get(edge.to),
      edge.bend,
      spec.radius,
      edge.gap
    );

    const group = el("g", { class: "diagram-edge" });
    group.append(
      el("path", { d: path, fill: "none", stroke: "var(--ink-3)", "stroke-width": "1.6" }),
      el("path", { d: arrow, fill: "var(--ink-3)", stroke: "none" }),
      el("text", {
        x: label.x,
        y: label.y,
        "text-anchor": "middle",
        "dominant-baseline": "middle",
        class: "diagram-edge-label",
        stroke: "var(--paper-raised)",
        "stroke-width": "5",
        "paint-order": "stroke",
      }, edge.label)
    );

    svg.append(group);
    return { ...edge, group };
  });

  const nodes = new Map();
  for (const state of spec.states) {
    const group = el("g", { class: "diagram-state" });

    /* An accepting state is ringed twice, as it is on paper. */
    if (spec.accepting.has(state.id)) {
      group.append(el("circle", {
        cx: state.x, cy: state.y, r: spec.radius,
        fill: "none", stroke: "var(--ink-2)", "stroke-width": "1.4",
      }));
    }

    group.append(
      el("circle", {
        cx: state.x, cy: state.y,
        r: spec.accepting.has(state.id) ? spec.radius - 6 : spec.radius,
        fill: "var(--paper-raised)", stroke: "var(--ink-2)", "stroke-width": "1.6",
        class: "diagram-ring",
      }),
      el("text", {
        x: state.x, y: state.y,
        "text-anchor": "middle", "dominant-baseline": "central",
        class: "diagram-state-label",
      }, state.label),
      el("text", {
        x: state.x, y: state.y + spec.radius + 20,
        "text-anchor": "middle", class: "diagram-state-note",
      }, state.note)
    );

    svg.append(group);
    nodes.set(state.id, group);
  }

  /* The stub that marks where reading begins. */
  const first = byId.get(spec.states[0].id);
  svg.append(
    el("path", {
      d: `M ${first.x - spec.radius - 34} ${first.y} L ${first.x - spec.radius - 4} ${first.y}`,
      stroke: "var(--ink-2)", "stroke-width": "1.6", fill: "none",
    }),
    el("path", {
      d: `M ${first.x - spec.radius} ${first.y} l -11 4.6 l 0 -9.2 Z`,
      fill: "var(--ink-2)",
    })
  );

  const stage = html("div", "diagram-stage");
  stage.append(svg);

  const tape = html("div", "diagram-tape");
  const verdict = html("p", "diagram-verdict");
  const readout = html("div", "diagram-readout");
  readout.append(tape, verdict);

  const picker = html("div", "diagram-words");
  container.replaceChildren(stage, readout, picker);

  let current = spec.samples[0];
  let cells = [];
  let timer = null;
  let position = 0;
  let resumeWhenSeen = false;

  /** Paints the machine as it stands after `position` syllables have been read. */
  function show(position) {
    const { visited, accepted, read } = spec.run(current.word);
    const at = Math.min(position, visited.length - 1);

    for (const [id, group] of nodes) {
      group.classList.toggle("is-current", visited[at] === id);
    }

    /* The edge lit is the one just taken, if any. */
    const from = visited[at - 1];
    const to = visited[at];
    for (const edge of edges) {
      const taken = at > 0 && edge.from === from && edge.to === to;
      edge.group.classList.toggle("is-taken", taken);
    }

    cells.forEach((cell, index) => {
      cell.classList.toggle("is-read", index < at);
      cell.classList.toggle("is-next", index === at);
      cell.classList.toggle("is-stuck", !accepted && index === read);
    });

    const done = at === visited.length - 1;
    verdict.classList.toggle("is-rejected", done && !accepted);

    if (!done) {
      verdict.textContent = `${at} of ${current.word.length} syllables read`;
    } else if (accepted) {
      verdict.textContent = `Reads, and denotes ${current.gloss}.`;
    } else if (read < current.word.length) {
      /* A syllable the machine had no edge for. */
      verdict.textContent =
        `Stops at "${current.word[read]}": no edge leaves ` +
        `"${byId.get(visited[read]).label}" on that syllable.`;
    } else {
      /* Every syllable read, but the word ended somewhere it may not end. */
      const last = byId.get(visited[visited.length - 1]);
      verdict.textContent = `Ends in "${last.label}", which ${last.note}.`;
    }
  }

  function stop() {
    if (timer !== null) clearInterval(timer);
    timer = null;
  }

  const lastStep = () => spec.run(current.word).visited.length - 1;

  /** Carries on from wherever the walk currently stands. */
  function advance() {
    stop();
    if (position >= lastStep()) return;

    timer = setInterval(() => {
      position += 1;
      show(position);
      if (position >= lastStep()) stop();
    }, STEP_MS);
  }

  /** Walks the current word from the beginning, a syllable at a time. */
  function play() {
    stop();

    /* Someone who has asked for less motion gets the answer, not the journey. */
    if (reduceMotion) {
      position = lastStep();
      show(position);
      return;
    }

    position = 0;
    show(position);
    advance();
  }

  function load(sample) {
    current = sample;
    cells = sample.word.map((syllable, index) => {
      const cell = html("button", "diagram-syllable", syllable);
      cell.type = "button";
      cell.setAttribute("aria-label", `Stop after ${index + 1} syllables`);
      cell.addEventListener("click", () => {
        stop();
        position = index + 1;
        show(position);
      });
      return cell;
    });
    tape.replaceChildren(...cells);

    for (const button of picker.children) {
      button.setAttribute("aria-pressed", String(button.dataset.word === sample.word.join("")));
    }
    play();
  }

  for (const sample of spec.samples) {
    const button = html("button", "diagram-word", sample.word.join(""));
    button.type = "button";
    button.dataset.word = sample.word.join("");
    button.addEventListener("click", () => load(sample));
    picker.append(button);
  }

  load(current);

  return {
    /*
     * A figure scrolled away from should not go on ticking — but it has to be
     * able to take the walk up again, or a reader who leaves and comes back
     * finds it frozen partway through a word.
     */
    setActive: (active) => {
      if (!active) {
        resumeWhenSeen = timer !== null;
        stop();
        return;
      }

      if (!resumeWhenSeen) return;
      resumeWhenSeen = false;
      advance();
    },
    destroy: () => {
      stop();
      container.replaceChildren();
    },
  };
}

export default createDiagram;
