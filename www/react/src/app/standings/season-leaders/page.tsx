"use client";
import { useEffect, useState } from "react";
import StandingsTable from "../../../components/StandingsTable";
import TeamStrengthPlot from "../../../components/TeamStrengthPlot";
import type { TeamStrength } from "../../../types/TeamStrength";
export default function SeasonLeadersPage() {
  const [data, setData] = useState<TeamStrength[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("http://localhost:8000/api/season-overall-strengths") // Adjust if your FastAPI runs elsewhere
      .then((res) => res.json())
      .then((json) => {
        setData(json);
        setLoading(false);
      });
  }, []);

  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] w-full px-4">
      <h1 className="text-3xl font-bold text-gray-900 mb-4">Season Leaders</h1>
      <p className="text-md text-gray-600 max-w-xl text-center mb-8">
        View the top NFL teams by strength for the selected season.
      </p>
      {loading ? (
        <div>Loading...</div>
      ) : (
        <>
          <div className="w-full max-w-4xl mb-8">
            <StandingsTable data={data} />
          </div>
          <div className="w-full max-w-5xl">
            <TeamStrengthPlot data={data} />
          </div>
        </>
      )}
    </div>
  );
} 