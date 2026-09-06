import * as echarts from "echarts/core";
import { LineChart, ScatterChart, CustomChart } from "echarts/charts";
import { GridComponent, TooltipComponent, DataZoomComponent, LegendComponent, MarkLineComponent } from "echarts/components";
import { CanvasRenderer } from "echarts/renderers";
echarts.use([LineChart, ScatterChart, CustomChart, GridComponent, TooltipComponent,
  DataZoomComponent, LegendComponent, MarkLineComponent, CanvasRenderer]);
export { echarts };
