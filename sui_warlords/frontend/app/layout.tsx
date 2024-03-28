import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import SuiProviders from "../components/SuiProviders"



const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "SUI Warlords",
  description: "Built by pure stubborness",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>        
          <SuiProviders>
            <main className={inter.className}>{children}</main>
          </SuiProviders>        
      </body>      
    </html>
  );
}
