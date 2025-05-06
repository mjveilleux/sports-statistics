import "~/styles/globals.css";

import { type Metadata } from "next";
import { Geist } from "next/font/google";
import Link from 'next/link';

export const metadata: Metadata = {
  title: "NFL Team Strength",
  description: "NFL team strength statistics and analytics",
  icons: [{ rel: "icon", url: "/favicon.ico" }],
};

const geist = Geist({
  subsets: ["latin"],
  variable: "--font-geist-sans",
});

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${geist.variable}`}>
      <body>
        <nav className="bg-white border-b border-gray-200 px-4 py-2 flex items-center justify-between">
          <div className="flex items-center space-x-6">
            <Link href="/" className="text-lg font-semibold text-gray-800 hover:text-blue-600">Home</Link>
            <div className="relative group">
              <button className="text-lg font-semibold text-gray-800 hover:text-blue-600 focus:outline-none">Standings</button>
              <div className="absolute left-0 mt-2 w-48 bg-white border border-gray-200 rounded shadow-lg opacity-0 group-hover:opacity-100 transition-opacity z-10">
                <Link href="/standings/weekly-leaders" className="block px-4 py-2 text-gray-700 hover:bg-gray-100">Weekly Leaders</Link>
                <Link href="/standings/season-leaders" className="block px-4 py-2 text-gray-700 hover:bg-gray-100">Season Leaders</Link>
              </div>
            </div>
          </div>
        </nav>
        <main className="min-h-screen bg-gray-50">{children}</main>
      </body>
    </html>
  );
}
