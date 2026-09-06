/*
 * The theme switch.
 *
 * Which theme is showing has already been decided by the inline script in the
 * document head; this only handles changing it. A stored choice is the reader's
 * and always wins. With no stored choice the page follows the operating system,
 * and keeps following it — someone whose machine switches to dark at sunset
 * should see the page switch too, without having to reload.
 */

const STORAGE_KEY = "theme";
const systemDark = matchMedia("(prefers-color-scheme: dark)");

const read = () => {
  try {
    return localStorage.getItem(STORAGE_KEY);
  } catch {
    return null;
  }
};

const isDark = () => document.documentElement.dataset.theme === "dark";

function apply(dark) {
  if (dark) document.documentElement.dataset.theme = "dark";
  else delete document.documentElement.dataset.theme;
  describe();
}

/** Keeps the button's label and pressed state honest about what it will do. */
function describe() {
  const dark = isDark();
  for (const button of document.querySelectorAll(".theme-toggle")) {
    button.setAttribute("aria-pressed", String(dark));
    button.querySelector(".theme-toggle-label").textContent = dark
      ? "Light theme"
      : "Dark theme";
  }
}

for (const button of document.querySelectorAll(".theme-toggle")) {
  button.addEventListener("click", () => {
    const dark = !isDark();
    apply(dark);
    try {
      localStorage.setItem(STORAGE_KEY, dark ? "dark" : "light");
    } catch {
      /* The choice will not survive the session, but it holds for this page. */
    }
  });
}

systemDark.addEventListener("change", (event) => {
  if (read() === null) apply(event.matches);
});

describe();
