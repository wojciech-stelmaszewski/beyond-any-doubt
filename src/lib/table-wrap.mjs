import { defineHastPlugin } from "satteri";

/*
 * Overflow on a <table> itself is ignored by several browsers, iOS Safari
 * among them: a wide row then widens the page. Wrapping the table in a block
 * is what actually keeps the scroll inside the column.
 */
export const tableWrap = () =>
  defineHastPlugin({
    name: "table-wrap",
    element: {
      filter: ["table"],
      visit(node, ctx) {
        ctx.wrapNode(node, {
          type: "element",
          tagName: "div",
          properties: { className: ["table-scroll"] },
          children: [],
        });
      },
    },
  });

export default tableWrap;
