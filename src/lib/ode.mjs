const add = (a, b, scale = 1) => a.map((v, i) => v + b[i] * scale);

/** Classical fourth-order Runge–Kutta, fixed step. */
export function rk4Step(fn, t, state, h) {
  const k1 = fn(t, state);
  const k2 = fn(t + h / 2, add(state, k1, h / 2));
  const k3 = fn(t + h / 2, add(state, k2, h / 2));
  const k4 = fn(t + h, add(state, k3, h));
  return state.map((v, i) => v + (h / 6) * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]));
}

export function eulerStep(fn, t, state, h) {
  return add(state, fn(t, state), h);
}

/** Heun's method — the two-stage, second-order member of the same family. */
export function heunStep(fn, t, state, h) {
  const k1 = fn(t, state);
  const k2 = fn(t + h, add(state, k1, h));
  return state.map((v, i) => v + (h / 2) * (k1[i] + k2[i]));
}

export function integrate(fn, state0, { t0 = 0, t1 = 1, h = 0.01, step = rk4Step, keep = 1 } = {}) {
  const path = [[t0, ...state0]];
  let state = state0;
  let t = t0;
  const steps = Math.round((t1 - t0) / h);

  for (let i = 1; i <= steps; i += 1) {
    state = step(fn, t, state, h);
    t = t0 + i * h;
    if (i % keep === 0) path.push([t, ...state]);
  }
  return path;
}

export const lorenz =
  ({ sigma = 10, rho = 28, beta = 8 / 3 } = {}) =>
  (_t, [x, y, z]) =>
    [sigma * (y - x), x * (rho - z) - y, x * y - beta * z];

export const dampedOscillator =
  ({ omega = 1, zeta = 0.15 } = {}) =>
  (_t, [x, v]) =>
    [v, -2 * zeta * omega * v - omega * omega * x];

export const logistic =
  ({ r = 1.2, K = 1 } = {}) =>
  (_t, [x]) =>
    [r * x * (1 - x / K)];

/** Closed form for the logistic equation, used where an exact surface is wanted. */
export const logisticExact = ({ r = 1.2, K = 1 } = {}) =>
  (t, x0) => (K * x0 * Math.exp(r * t)) / (K + x0 * (Math.exp(r * t) - 1));
