import Link from "next/link";

export default function HomePage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh]">
      <h1 className="text-4xl font-bold text-gray-900 mb-4">NFL Team Strength Analytics</h1>
      <p className="text-lg text-gray-600 max-w-xl text-center">
        Welcome to the NFL Team Strength Analytics site. Explore comprehensive statistics, team standings, and advanced analytics powered by modern web technologies.
      </p>
    </div>
  );
}
