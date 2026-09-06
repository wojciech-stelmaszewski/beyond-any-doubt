import * as echarts from "echarts/core";
import { Scatter3DChart, SurfaceChart, Line3DChart } from "echarts-gl/charts";
import { Grid3DComponent } from "echarts-gl/components";
import { CanvasRenderer } from "echarts/renderers";
echarts.use([Scatter3DChart, SurfaceChart, Line3DChart, Grid3DComponent, CanvasRenderer]);
export { echarts };
