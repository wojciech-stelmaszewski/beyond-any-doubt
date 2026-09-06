import {
  AmbientLight,
  BufferAttribute,
  BufferGeometry,
  Color,
  DirectionalLight,
  DoubleSide,
  Float32BufferAttribute,
  Line,
  LineBasicMaterial,
  LineSegments,
  Mesh,
  MeshLambertMaterial,
  MeshBasicMaterial,
  PerspectiveCamera,
  Points,
  PointsMaterial,
  Scene,
  Vector3,
  WebGLRenderer,
} from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import { CSS2DObject, CSS2DRenderer } from "three/examples/jsm/renderers/CSS2DRenderer.js";
import { readPalette, sampleSequential, watchTheme } from "./palette.mjs";

const AXES = ["x", "y", "z"];
const OTHER = { x: ["y", "z"], y: ["x", "z"], z: ["x", "y"] };

const niceTicks = (min, max, count = 4) => {
  const raw = (max - min) / Math.max(count, 2);
  const magnitude = 10 ** Math.floor(Math.log10(raw));
  const n = raw / magnitude;
  const step = (n >= 5 ? 10 : n >= 2 ? 5 : n >= 1 ? 2 : 1) * magnitude;
  const ticks = [];
  for (let v = Math.ceil(min / step) * step; v <= max + step * 1e-6; v += step) {
    ticks.push(Math.abs(v) < step * 1e-6 ? 0 : v);
  }
  return ticks;
};

const formatTick = (v) => (v === 0 ? "0" : String(Math.round(v * 1000) / 1000));

/**
 * Draws a spec into a container as a rotatable WebGL scene.
 *
 * Data is expressed in the units of the problem; this maps it into a unit cube
 * so that one camera setup frames every figure, whatever its axes mean.
 */
export function createScene(container, spec) {
  const { x, y, z, layers, autoRotate = true } = spec;
  const domains = { x: x.domain, y: y.domain, z: z.domain };
  const labels = { x: x.label ?? "x", y: y.label ?? "y", z: z.label ?? "z" };

  const centre = (axis) => (domains[axis][0] + domains[axis][1]) / 2;
  const extent = (axis) => domains[axis][1] - domains[axis][0] || 1;
  const norm = (axis, value) => (value - centre(axis)) / extent(axis);
  const place = (px, py, pz) => new Vector3(norm("x", px), norm("y", py), norm("z", pz));

  let palette = readPalette();

  const scene = new Scene();
  const camera = new PerspectiveCamera(38, 16 / 9, 0.01, 100);
  camera.position.set(1.5, -1.9, 1.15);
  camera.up.set(0, 0, 1);

  const renderer = new WebGLRenderer({ antialias: true, alpha: true });
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  container.appendChild(renderer.domElement);

  const overlay = new CSS2DRenderer();
  overlay.domElement.className = "scene3d-labels";
  container.appendChild(overlay.domElement);

  const controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.08;
  controls.enablePan = false;
  controls.minDistance = 1.1;
  controls.maxDistance = 6;
  controls.autoRotateSpeed = 0.7;

  scene.add(new AmbientLight(0xffffff, 1.9));
  const keyLight = new DirectionalLight(0xffffff, 1.5);
  keyLight.position.set(2, -3, 4);
  scene.add(keyLight);

  // --- bounding box: six walls, of which only the three behind the data show ---

  const wallMaterial = new MeshBasicMaterial({ side: DoubleSide, transparent: true, opacity: 0.55 });
  const gridMaterial = new LineBasicMaterial({ transparent: true, opacity: 0.55 });
  const walls = [];

  for (const axis of AXES) {
    for (const side of [0, 1]) {
      const [a, b] = OTHER[axis];
      const fixed = side === 0 ? -0.5 : 0.5;
      const corner = (u, v) => {
        const p = { [axis]: fixed, [a]: u, [b]: v };
        return new Vector3(p.x, p.y, p.z);
      };

      const quad = [corner(-0.5, -0.5), corner(0.5, -0.5), corner(0.5, 0.5), corner(-0.5, 0.5)];
      const mesh = new Mesh(
        new BufferGeometry().setFromPoints([quad[0], quad[1], quad[2], quad[0], quad[2], quad[3]]),
        wallMaterial
      );

      const gridPoints = [];
      for (let i = 1; i < 5; i += 1) {
        const t = -0.5 + i / 5;
        gridPoints.push(corner(t, -0.5), corner(t, 0.5), corner(-0.5, t), corner(0.5, t));
      }
      const grid = new LineSegments(
        new BufferGeometry().setFromPoints(gridPoints),
        gridMaterial
      );

      const normal = new Vector3();
      normal[axis] = side === 0 ? -1 : 1;
      const centrePoint = corner(0, 0);

      scene.add(mesh, grid);
      walls.push({ mesh, grid, normal, centre: centrePoint, axis, side });
    }
  }

  // --- axis labels, as real DOM so they use the page's typeface ---

  const makeLabel = (text, className) => {
    const node = document.createElement("span");
    node.className = className;
    node.textContent = text;
    const object = new CSS2DObject(node);
    scene.add(object);
    return object;
  };

  const tickLabels = AXES.flatMap((axis) =>
    niceTicks(...domains[axis], 4).map((value) => ({
      axis,
      value: norm(axis, value),
      object: makeLabel(formatTick(value), "scene3d-tick"),
    }))
  );
  const axisLabels = AXES.map((axis) => ({
    axis,
    object: makeLabel(labels[axis], "scene3d-axis"),
  }));

  // --- data layers ---

  const built = layers.map((layer) => buildLayer(layer, place, palette));
  for (const item of built) scene.add(item.object);

  // --- per-frame work ---

  const toCamera = new Vector3();
  const corner = new Vector3();
  const probe = new Vector3();

  // How far outside the box the tick text and the axis names sit.
  const OUTSET = 1.1;
  const NAME_OUTSET = 1.3;

  const CORNERS = [
    { x: -0.5, y: -0.5 },
    { x: 0.5, y: -0.5 },
    { x: 0.5, y: 0.5 },
    { x: -0.5, y: 0.5 },
  ];

  /**
   * Chooses which edge of the box carries each axis's labels: the leftmost
   * vertical edge for z, and the lowest horizontal edge for x and y.
   */
  function pickEdges() {
    let zEdge = CORNERS[0];
    let leftmost = Infinity;
    for (const c of CORNERS) {
      const screenX = probe.set(c.x, c.y, 0).project(camera).x;
      if (screenX < leftmost) {
        leftmost = screenX;
        zEdge = c;
      }
    }

    let xEdge = { y: -0.5 };
    let lowest = Infinity;
    for (const y of [-0.5, 0.5]) {
      const screenY = probe.set(0, y, -0.5).project(camera).y;
      if (screenY < lowest) {
        lowest = screenY;
        xEdge = { y };
      }
    }

    let yEdge = { x: -0.5 };
    lowest = Infinity;
    for (const x of [-0.5, 0.5]) {
      const screenY = probe.set(x, 0, -0.5).project(camera).y;
      if (screenY < lowest) {
        lowest = screenY;
        yEdge = { x };
      }
    }

    return { x: xEdge, y: yEdge, z: zEdge };
  }

  /*
   * Two axes meet at every corner of the box, so at some camera angles their
   * end ticks land on top of each other. Rather than nudge them — which makes
   * them drift as the box turns — the later one is dropped, since the axis it
   * belongs to is labelled anyway.
   */
  const placedLabels = [];
  const MIN_LABEL_GAP = 26;

  function hideCollidingTicks() {
    const width = container.clientWidth;
    const height = container.clientHeight;
    placedLabels.length = 0;

    for (const label of axisLabels) {
      probe.copy(label.object.position).project(camera);
      placedLabels.push([(probe.x * 0.5 + 0.5) * width, (-probe.y * 0.5 + 0.5) * height]);
    }

    for (const tick of tickLabels) {
      probe.copy(tick.object.position).project(camera);
      const sx = (probe.x * 0.5 + 0.5) * width;
      const sy = (-probe.y * 0.5 + 0.5) * height;
      const clear = placedLabels.every(([ox, oy]) => Math.hypot(sx - ox, sy - oy) >= MIN_LABEL_GAP);
      tick.object.visible = clear;
      if (clear) placedLabels.push([sx, sy]);
    }
  }

  function updateBox() {
    for (const wall of walls) {
      toCamera.copy(camera.position).sub(wall.centre);
      const behind = wall.normal.dot(toCamera) < 0;
      wall.mesh.visible = behind;
      wall.grid.visible = behind;
    }

    /*
     * Labels belong on the silhouette of the box, and which edge that is
     * depends on where the camera has been dragged to. Picking the edge in
     * screen space rather than from the camera's coordinates keeps them on the
     * outside through a full turn: the vertical edge furthest to the left
     * carries z, and the lowest horizontal edge carries x and y.
     */
    const edge = pickEdges();

    for (const tick of tickLabels) {
      if (tick.axis === "z") {
        corner.set(edge.z.x * OUTSET, edge.z.y * OUTSET, tick.value);
      } else if (tick.axis === "x") {
        corner.set(tick.value, edge.x.y * OUTSET, -0.5 * OUTSET);
      } else {
        corner.set(edge.y.x * OUTSET, tick.value, -0.5 * OUTSET);
      }
      tick.object.position.copy(corner);
    }

    for (const label of axisLabels) {
      if (label.axis === "z") corner.set(edge.z.x * NAME_OUTSET, edge.z.y * NAME_OUTSET, 0);
      else if (label.axis === "x") corner.set(0, edge.x.y * NAME_OUTSET, -0.5 * NAME_OUTSET);
      else corner.set(edge.y.x * NAME_OUTSET, 0, -0.5 * NAME_OUTSET);
      label.object.position.copy(corner);
    }

    hideCollidingTicks();
  }

  function applyPalette(next) {
    palette = next;
    wallMaterial.color.copy(palette.sunken);
    gridMaterial.color.copy(palette.ruleStrong);
    for (const item of built) item.recolor(palette);
  }

  applyPalette(palette);
  const stopWatchingTheme = watchTheme(applyPalette);

  function resize() {
    const width = container.clientWidth;
    if (width === 0) return;
    const height = Math.round(width * (spec.aspect ?? 0.62));
    renderer.setSize(width, height);
    overlay.setSize(width, height);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
  }

  const resizeObserver = new ResizeObserver(resize);
  resizeObserver.observe(container);
  resize();

  const reduceMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;
  controls.autoRotate = autoRotate && !reduceMotion;
  controls.addEventListener("start", () => {
    controls.autoRotate = false;
  });

  let running = true;
  function frame() {
    if (!running) return;
    controls.update();
    updateBox();
    renderer.render(scene, camera);
    overlay.render(scene, camera);
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);

  return {
    dispose() {
      running = false;
      stopWatchingTheme();
      resizeObserver.disconnect();
      controls.dispose();
      renderer.dispose();
      container.replaceChildren();
    },
    /** Pauses the loop when the figure is off screen; WebGL is not free. */
    setActive(active) {
      if (active && !running) {
        running = true;
        requestAnimationFrame(frame);
      } else {
        running = active;
      }
    },
  };
}

/**
 * Turns one layer of a spec into a three.js object, plus a way to re-colour it
 * without rebuilding its geometry.
 */
function buildLayer(layer, place, palette) {
  const positions = [];
  const shades = [];

  for (const [px, py, pz, shade] of layer.data) {
    const v = place(px, py, pz);
    positions.push(v.x, v.y, v.z);
    shades.push(shade ?? 0.5);
  }

  const geometry = new BufferGeometry();
  geometry.setAttribute("position", new Float32BufferAttribute(positions, 3));
  geometry.setAttribute("color", new BufferAttribute(new Float32Array(shades.length * 3), 3));

  if (layer.kind === "surface" && layer.index) {
    geometry.setIndex(layer.index);
    geometry.computeVertexNormals();
  }

  const tint = new Color();
  const recolor = (next) => {
    const colors = geometry.getAttribute("color");
    for (let i = 0; i < shades.length; i += 1) {
      if (layer.series !== undefined) tint.copy(next.series[layer.series % next.series.length]);
      else sampleSequential(next, shades[i], tint);
      colors.setXYZ(i, tint.r, tint.g, tint.b);
    }
    colors.needsUpdate = true;
  };
  recolor(palette);

  if (layer.kind === "points") {
    /*
     * A cloud this dense would otherwise read as one solid shape. Letting the
     * points blend, and leaving the depth buffer alone so that near points do
     * not erase the ones behind them, turns overlap back into shading: the
     * denser a region, the more opaque it appears.
     */
    return {
      object: new Points(
        geometry,
        new PointsMaterial({
          size: layer.size ?? 0.004,
          vertexColors: true,
          sizeAttenuation: true,
          transparent: true,
          opacity: layer.opacity ?? 0.5,
          depthWrite: false,
        })
      ),
      recolor,
    };
  }

  if (layer.kind === "surface") {
    return {
      object: new Mesh(
        geometry,
        new MeshLambertMaterial({ vertexColors: true, side: DoubleSide, flatShading: false })
      ),
      recolor,
    };
  }

  return {
    object: new Line(geometry, new LineBasicMaterial({ vertexColors: true })),
    recolor,
  };
}
