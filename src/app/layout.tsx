import { Inter, Quicksand } from 'next/font/google';
import './globals.css';
import { HeaderProvider } from '@/context/HeaderContext';
import { ReactNode } from 'react';
import { Metadata } from 'next';
import ClientLayout from '@/components/ClientLayout';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
});

const quicksand = Quicksand({
  subsets: ['latin'],
  variable: '--font-quicksand',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'Otobix CRM',
  description: 'Customer Relationship Management for Otobix',
  icons: {
    icon: '/logo-v2.png',
  },
};

interface RootLayoutProps {
  children: ReactNode;
}

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en">
      <body
        className={`${inter.variable} ${quicksand.variable} antialiased font-sans`}
        suppressHydrationWarning
      >
        <HeaderProvider>
          <ClientLayout>{children}</ClientLayout>
        </HeaderProvider>
      </body>
    </html>
  );
}
