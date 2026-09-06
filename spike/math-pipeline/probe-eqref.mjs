import { satteriMathJax4 } from "./src/lib/satteri-mathjax4.mjs";
const p = satteriMathJax4();
const a = p.math({ value: "\\label{eq:e} e^{i\\pi}+1=0" });
const b = p.inlineMath({ value: "\\eqref{eq:e}" });
const text = (h) => (h.value.match(/aria-label="([^"]*)"/) || h.value.match(/>([^<]{1,40})</) || [,"?"])[1];
console.log("label eq contains tag id:", /mjx-eqn/.test(a.value) ? "yes" : "no");
console.log("eqref renders as       :", /\(\?\?\?\)/.test(b.value) ? "(???)  UNRESOLVED" : "resolved");
console.log("eqref mathml text      :", (b.value.match(/<mtext>([^<]*)<\/mtext>|<mn>([^<]*)<\/mn>/g)||[]).join(" "));
