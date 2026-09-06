/*
 * Rotates a point cloud and reports the frame rate. The point count comes from
 * ?n= so the same build can be driven across sizes.
 */
import {
  BufferGeometry,
  Color,
  Float32BufferAttribute,
  PerspectiveCamera,
  Points,
  PointsMaterial,
  Scene,
  WebGLRenderer,
} from "three";

const count = Number(new URLSearchParams(location.search).get("n") ?? 100000);

const scene = new Scene();
const camera = new PerspectiveCamera(50, 16 / 9, 0.1, 1000);
const renderer = new WebGLRenderer({ antialias: true, alpha: true });
renderer.setSize(960, 540, false);
renderer.setPixelRatio(1);
document.body.appendChild(renderer.domElement);

// A Lorenz-like cloud, so the benchmark shapes the data the way a post would.
const positions = new Float32Array(count * 3);
const colors = new Float32Array(count * 3);
const tint = new Color();

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

  positions[i * 3] = x;
  positions[i * 3 + 1] = y;
  positions[i * 3 + 2] = z - 25;

  tint.setHSL(0.12 + 0.5 * (z / 50), 0.6, 0.55);
  colors[i * 3] = tint.r;
  colors[i * 3 + 1] = tint.g;
  colors[i * 3 + 2] = tint.b;
}

const geometry = new BufferGeometry();
geometry.setAttribute("position", new Float32BufferAttribute(positions, 3));
geometry.setAttribute("color", new Float32BufferAttribute(colors, 3));

const cloud = new Points(geometry, new PointsMaterial({ size: 0.25, vertexColors: true }));
scene.add(cloud);

const radius = 90;
let frames = 0;
let started = 0;

function frame(now) {
  if (started === 0) started = now;
  const angle = (now - started) / 1000;
  camera.position.set(Math.cos(angle) * radius, Math.sin(angle) * radius, 40);
  camera.lookAt(0, 0, 0);
  renderer.render(scene, camera);
  frames += 1;

  const elapsed = now - started;
  if (elapsed >= 4000) {
    window.__benchResult = {
      library: "three.js",
      points: count,
      fps: Math.round((frames / elapsed) * 1000),
      frames,
      elapsedMs: Math.round(elapsed),
    };
    return;
  }
  requestAnimationFrame(frame);
}

window.__benchBuildMs = 0;
requestAnimationFrame(frame);
