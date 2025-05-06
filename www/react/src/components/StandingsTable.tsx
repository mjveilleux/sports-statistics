import { TeamStrength } from "../types/TeamStrength";

interface Props {
  data: TeamStrength[];
}

export default function StandingsTable({ data }: Props) {
  return (
    <div className="overflow-x-auto w-full">
      <table className="min-w-full bg-white border rounded shadow">
        <thead>
          <tr>
            <th className="px-4 py-2">Team</th>
            <th className="px-4 py-2">Division</th>
            <th className="px-4 py-2">Conference</th>
            <th className="px-4 py-2">Median</th>
            <th className="px-4 py-2">Q5</th>
            <th className="px-4 py-2">Q95</th>
          </tr>
        </thead>
        <tbody>
          {data.map((team) => (
            <tr key={team.team_nm}>
              <td className="px-4 py-2">{team.team_nm}</td>
              <td className="px-4 py-2">{team.division_nm}</td>
              <td className="px-4 py-2">{team.conference_nm}</td>
              <td className="px-4 py-2">{team.median.toFixed(3)}</td>
              <td className="px-4 py-2">{team.q5?.toFixed(3) ?? "-"}</td>
              <td className="px-4 py-2">{team.q95?.toFixed(3) ?? "-"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
} 