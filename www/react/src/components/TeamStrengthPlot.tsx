import * as Plot from "plotly.js";
import type { TeamStrength } from "../types/TeamStrength";
import { useEffect, useRef } from "react";

interface Props {
  data: TeamStrength[];
}

export default function TeamStrengthPlot({ data }: Props) {
  const plotRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (plotRef.current) {
      const plotData: Partial<Plot.PlotData>[] = [{
        x: data.map((team) => team.team_nm),
        y: data.map((team) => team.median),
        error_y: {
          type: "data",
          symmetric: false,
          array: data.map((team) => (team.q95 ?? team.median) - team.median),
          arrayminus: data.map((team) => team.median - (team.q5 ?? team.median)),
          visible: true,
        },
        type: "bar" as const,
        name: "Median Strength",
      }];

      const layout: Partial<Plot.Layout> = {
        title: { text: "Team Strength Distribution (Median, Q5, Q95)" },
        xaxis: { title: { text: "Team" }, tickangle: -45 },
        yaxis: { title: { text: "Strength" } },
        margin: { t: 40, b: 120 },
        height: 500,
      };

      Plot.newPlot(plotRef.current, plotData, layout, { responsive: true });
    }
  }, [data]);

  return <div ref={plotRef} style={{ width: "100%" }} />;
}