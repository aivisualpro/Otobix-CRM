'use client';

import { usePathname } from 'next/navigation';
import GlobalHeader from '@/components/GlobalHeader';
import Header from '@/components/Header';
import { ReactNode } from 'react';
import { SessionProvider } from 'next-auth/react';

export default function ClientLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const isAuthPage = pathname?.startsWith('/auth');

  const content = isAuthPage ? (
    <main className="min-h-screen bg-slate-50">{children}</main>
  ) : (
    <div className="grid grid-rows-[var(--global-header-height)_var(--route-header-height)_1fr] h-screen overflow-hidden">
      <GlobalHeader />
      <Header />
      <main className="overflow-hidden bg-gray-50">{children}</main>
    </div>
  );

  return <SessionProvider>{content}</SessionProvider>;
}
