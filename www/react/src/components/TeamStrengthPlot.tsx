import * as Plot from "plotly.js";
import type { TeamStrength } from "../types/TeamStrength";

interface Props {
  data: TeamStrength[];
}

export default function TeamStrengthPlot({ data }: Props) {
  return (
    <Plot
      data={[
        {
          x: data.map((team) => team.team_nm),
          y: data.map((team) => team.median),
          error_y: {
            type: "data",
            symmetric: false,
            array: data.map((team) => (team.q95 ?? team.median) - team.median),
            arrayminus: data.map((team) => team.median - (team.q5 ?? team.median)),
            visible: true,
          },
          type: "bar",
          name: "Median Strength",
        },
      ]}
      layout={{
        title: "Team Strength Distribution (Median, Q5, Q95)",
        xaxis: { title: "Team", tickangle: -45 },
        yaxis: { title: "Strength" },
        margin: { t: 40, b: 120 },
        height: 500,
      }}
      style={{ width: "100%" }}
      config={{ responsive: true }}
    />
  );
} 