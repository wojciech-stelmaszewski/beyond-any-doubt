/*
 * The same measurement for Plotly's scatter3d: rotate the scene camera every
 * frame and count how many frames land in four seconds.
 */
import Plotly from "plotly.js-gl3d-dist-min";

const count = Number(new URLSearchParams(location.search).get("n") ?? 100000);

const xs = new Float32Array(count);
const ys = new Float32Array(count);
const zs = new Float32Array(count);

let x = 1;
let y = 1;
let z = 1;
const h = 0.004;
for (let i = 0; i < count; i += 1) {
  const dx = 10 * (y - x);
  const dy = x * (28 - z) - y;
  const dz = x * y - (8 / 3) * z;
  x += dx * h;
  y += dy * h;
  z += dz * h;
  xs[i] = x;
  ys[i] = y;
  zs[i] = z;
}

const node = document.getElementById("plot");
const startedBuild = performance.now();

await Plotly.newPlot(
  node,
  [
    {
      type: "scatter3d",
      mode: "markers",
      x: Array.from(xs),
      y: Array.from(ys),
      z: Array.from(zs),
      marker: { size: 1.4, color: Array.from(zs), colorscale: "Cividis" },
    },
  ],
  {
    width: 960,
    height: 540,
    margin: { l: 0, r: 0, t: 0, b: 0 },
    scene: { camera: { eye: { x: 1.6, y: 1.6, z: 0.6 } } },
  },
  { displayModeBar: false }
);

window.__benchBuildMs = Math.round(performance.now() - startedBuild);

let frames = 0;
let started = 0;

function frame(now) {
  if (started === 0) started = now;
  const angle = (now - started) / 1000;
  Plotly.relayout(node, {
    "scene.camera.eye": { x: Math.cos(angle) * 2, y: Math.sin(angle) * 2, z: 0.6 },
  });
  frames += 1;

  const elapsed = now - started;
  if (elapsed >= 4000) {
    window.__benchResult = {
      library: "plotly gl3d",
      points: count,
      fps: Math.round((frames / elapsed) * 1000),
      frames,
      elapsedMs: Math.round(elapsed),
    };
    return;
  }
  requestAnimationFrame(frame);
}

requestAnimationFrame(frame);
