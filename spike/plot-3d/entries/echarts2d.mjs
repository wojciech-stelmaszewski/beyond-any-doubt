// 2D only: line + scatter for standard charts, custom for vector fields,
// plus the interaction we actually want (zoom, hover readout).
import * as echarts from "echarts/core";
import { LineChart, ScatterChart, CustomChart } from "echarts/charts";
import { GridComponent, TooltipComponent, DataZoomComponent, LegendComponent, MarkLineComponent } from "echarts/components";
import { SVGRenderer } from "echarts/renderers";
echarts.use([LineChart, ScatterChart, CustomChart, GridComponent, TooltipComponent,
  DataZoomComponent, LegendComponent, MarkLineComponent, SVGRenderer]);
export { echarts };
