import { defineMdastPlugin } from "satteri";

const ESCAPES = { "&": "&amp;", "<": "&lt;", ">": "&gt;" };
const escapeHtml = (value) => value.replace(/[&<>]/g, (c) => ESCAPES[c]);

// Emits TeX back into the page wrapped in \( \) / \[ \] delimiters instead of
// rendering it. The actual typesetting happens once per finished page, which is
// what lets \label and \eqref see each other.
export const mathPlaceholder = () =>
  defineMdastPlugin({
    name: "math-placeholder",
    // Display and inline maths are told apart by class: the first is a block of
    // its own that a wide equation can scroll inside, the second has to stay in
    // the run of text.
    math: (node) => ({
      type: "html",
      value: `<span class="math-tex math-display">\\[${escapeHtml(node.value)}\\]</span>`,
    }),
    inlineMath: (node) => ({
      type: "html",
      value: `<span class="math-tex math-inline">\\(${escapeHtml(node.value)}\\)</span>`,
    }),
  });

export default mathPlaceholder;
