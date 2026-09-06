import { defineMdastPlugin } from "satteri";

const ESCAPES = { "&": "&amp;", "<": "&lt;", ">": "&gt;" };
const escapeHtml = (value) => value.replace(/[&<>]/g, (c) => ESCAPES[c]);

// Emits TeX back into the page wrapped in \( \) / \[ \] delimiters instead of
// rendering it. The actual typesetting happens once per finished page, which is
// what lets \label and \eqref see each other.
export const mathPlaceholder = () =>
  defineMdastPlugin({
    name: "math-placeholder",
    math: (node) => ({
      type: "html",
      value: `<span class="math-tex">\\[${escapeHtml(node.value)}\\]</span>`,
    }),
    inlineMath: (node) => ({
      type: "html",
      value: `<span class="math-tex">\\(${escapeHtml(node.value)}\\)</span>`,
    }),
  });

export default mathPlaceholder;
