import { integrate, logisticExact, lorenz } from "../ode.mjs";

/*
 * Each scene ships as a recipe, not as data: a few hundred bytes of parameters
 * that the browser turns into geometry. Integrating a Lorenz trajectory takes a
 * few milliseconds, where the same points as JSON would be megabytes.
 */

const lorenzTrajectory = ({ t1 = 44, h = 0.004 } = {}) => {
  const path = integrate(lorenz(), [1, 1, 1], { t1, h, keep: 2 });
  const zs = path.map((p) => p[3]);
  const zMin = Math.min(...zs);
  const zMax = Math.max(...zs);
  return path.map(([, x, y, z]) => [x, y, z, (z - zMin) / (zMax - zMin)]);
};

const lorenzCloud = ({ count = 400000, h = 0.002 } = {}) => {
  const field = lorenz();
  const data = new Array(count);

  // The approach from (1, 1, 1) is not part of the attractor, and leaving it in
  // draws a thread across the middle that belongs to no wing.
  const warmup = integrate(field, [1, 1, 1], { t1: 40, h: 0.004 });
  let state = warmup[warmup.length - 1].slice(1);
  let t = 0;

  // A long orbit sampled densely traces out the attractor as a cloud; colour
  // encodes speed, which is what makes the slow outer edges of the wings read.
  for (let i = 0; i < count; i += 1) {
    const [dx, dy, dz] = field(t, state);
    state = [state[0] + dx * h, state[1] + dy * h, state[2] + dz * h];
    t += h;
    const speed = Math.hypot(dx, dy, dz);
    data[i] = [state[0], state[1], state[2], Math.min(1, speed / 260)];
  }
  return data;
};

/** A parametric surface as a triangle mesh, with vertex order for the index. */
const surfaceMesh = (fn, nu, nv, shadeFrom) => {
  const data = [];
  for (let i = 0; i <= nu; i += 1) {
    for (let j = 0; j <= nv; j += 1) {
      const point = fn(i / nu, j / nv);
      data.push([point[0], point[1], point[2], shadeFrom(point)]);
    }
  }

  const index = [];
  const at = (i, j) => i * (nv + 1) + j;
  for (let i = 0; i < nu; i += 1) {
    for (let j = 0; j < nv; j += 1) {
      index.push(at(i, j), at(i + 1, j), at(i + 1, j + 1));
      index.push(at(i, j), at(i + 1, j + 1), at(i, j + 1));
    }
  }
  return { data, index };
};

export const SPECS = {
  "lorenz-attractor": () => ({
    aspect: 0.66,
    x: { domain: [-20, 20], label: "x" },
    y: { domain: [-25, 30], label: "y" },
    z: { domain: [0, 48], label: "z" },
    layers: [{ kind: "line", data: lorenzTrajectory() }],
  }),

  "lorenz-cloud": () => ({
    aspect: 0.66,
    x: { domain: [-20, 20], label: "x" },
    y: { domain: [-25, 30], label: "y" },
    z: { domain: [0, 48], label: "z" },
    layers: [{ kind: "points", data: lorenzCloud(), size: 0.0022 }],
  }),

  "solution-surface": () => {
    const exact = logisticExact({ r: 1.2, K: 1 });
    const mesh = surfaceMesh(
      (u, v) => {
        const t = u * 6;
        const x0 = 0.02 + v * (1.9 - 0.02);
        return [t, x0, exact(t, x0)];
      },
      60,
      52,
      (point) => point[2] / 1.9
    );
    return {
      aspect: 0.62,
      x: { domain: [0, 6], label: "t" },
      y: { domain: [0, 1.9], label: "x₀" },
      z: { domain: [0, 1.9], label: "x" },
      layers: [{ kind: "surface", data: mesh.data, index: mesh.index }],
    };
  },
};

export const sceneIds = Object.keys(SPECS);
