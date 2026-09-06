/* Sanity checks for the numbers behind the figures. */
import { eulerStep, heunStep, integrate, lorenz, rk4Step } from "../src/lib/ode.mjs";

console.log("--- Lorenz separation, delta0 = 1e-9 on x ---");
const field = lorenz();
const a = integrate(field, [1, 1, 1], { t1: 34, h: 0.004 });
const b = integrate(field, [1 + 1e-9, 1, 1], { t1: 34, h: 0.004 });

for (const t of [0, 1, 2, 4, 8, 12, 16, 20, 24, 28, 32]) {
  const i = Math.round(t / 0.004);
  const d = Math.hypot(a[i][1] - b[i][1], a[i][2] - b[i][2], a[i][3] - b[i][3]);
  console.log(`  t=${String(t).padStart(2)}  sep = ${d.toExponential(2)}`);
}

console.log("--- integrator error at t = 1 for x' = -x ---");
const decay = (_t, [x]) => [-x];
const exact = Math.exp(-1);

for (const n of [2, 4, 8, 16, 32, 64, 128]) {
  const h = 1 / n;
  const errors = [eulerStep, heunStep, rk4Step].map((step) => {
    const path = integrate(decay, [1], { t1: 1, h, step });
    return Math.abs(path[path.length - 1][1] - exact).toExponential(2);
  });
  console.log(`  h=1/${String(n).padStart(3)}  euler ${errors[0]}  heun ${errors[1]}  rk4 ${errors[2]}`);
}

console.log("--- same, with h that does not divide the interval ---");
for (const h of [0.4, 0.27, 0.183]) {
  const path = integrate(decay, [1], { t1: 1, h, step: rk4Step });
  const last = path[path.length - 1];
  console.log(`  h=${h}  final t = ${last[0].toFixed(4)}  error = ${Math.abs(last[1] - exact).toExponential(2)}`);
}
