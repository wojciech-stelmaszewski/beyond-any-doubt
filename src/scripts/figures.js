/*
 * Boots the figures on a page.
 *
 * Both renderers are behind dynamic imports and an IntersectionObserver, so a
 * post pays only for the kinds of figure it actually contains, and only once
 * the reader has scrolled far enough to be about to see one. three.js is much
 * the larger of the two, which is why a post of ordinary 2D charts never
 * touches it.
 */

const mounted = new WeakMap();

async function mountScene(container) {
  const [{ createScene }, { SPECS }] = await Promise.all([
    import("../lib/scene/create-scene.mjs"),
    import("../lib/scene/specs.mjs"),
  ]);

  const build = SPECS[container.dataset.scene];
  if (!build) throw new Error(`unknown scene "${container.dataset.scene}"`);

  container.classList.add("is-live");
  return createScene(container, build());
}

async function mountChart(container) {
  const [{ createChart, legend }, { CHARTS }] = await Promise.all([
    import("../lib/plot2d/create-chart.mjs"),
    import("../lib/plot2d/specs.mjs"),
  ]);

  const build = CHARTS[container.dataset.chart];
  if (!build) throw new Error(`unknown chart "${container.dataset.chart}"`);

  const spec = build();
  container.classList.add("is-live");
  const chart = createChart(container, spec);

  if (spec.legend) container.after(legend(spec.legend));
  return chart;
}

async function mount(container) {
  if (mounted.has(container)) return;
  mounted.set(container, null);

  try {
    const figure = container.dataset.scene
      ? await mountScene(container)
      : await mountChart(container);
    mounted.set(container, figure);
  } catch (error) {
    console.warn("[figures]", error);
    container.classList.add("has-failed");
  }
}

const nearViewport = new IntersectionObserver(
  (entries) => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      nearViewport.unobserve(entry.target);
      mount(entry.target);
    }
  },
  { rootMargin: "300px" }
);

// Once a scene exists, stop its render loop while it is off screen.
const onScreen = new IntersectionObserver((entries) => {
  for (const entry of entries) {
    mounted.get(entry.target)?.setActive?.(entry.isIntersecting);
  }
});

for (const container of document.querySelectorAll("[data-scene], [data-chart]")) {
  nearViewport.observe(container);
  onScreen.observe(container);
}
