import { Geist, Geist_Mono } from 'next/font/google';
import './globals.css';
import { HeaderProvider } from '@/context/HeaderContext';
import { ReactNode } from 'react';
import { Metadata } from 'next';
import ClientLayout from '@/components/ClientLayout';

const geistSans = Geist({
  variable: '--font-geist-sans',
  subsets: ['latin'],
});

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
});

export const metadata: Metadata = {
  title: 'Otobix CRM',
  description: 'Customer Relationship Management for Otobix',
};

interface RootLayoutProps {
  children: ReactNode;
}

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
        suppressHydrationWarning
      >
        <HeaderProvider>
          <ClientLayout>{children}</ClientLayout>
        </HeaderProvider>
      </body>
    </html>
  );
}
