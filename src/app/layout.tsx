import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import GlobalHeader from "@/components/GlobalHeader";
import Header from "@/components/Header";
import { HeaderProvider } from "@/context/HeaderContext";
import { ReactNode } from "react";
import { Metadata } from "next";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Otobix CRM",
  description: "Customer Relationship Management for Otobix",
};

interface RootLayoutProps {
  children: ReactNode;
}

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased`} suppressHydrationWarning>
        <HeaderProvider>
          <div className="grid grid-rows-[var(--global-header-height)_var(--route-header-height)_1fr] h-screen overflow-hidden">
            <GlobalHeader />
            <Header />
            <main className="overflow-hidden bg-gray-50">
              {children}
            </main>
          </div>
        </HeaderProvider>
      </body>
    </html>
  );
}
