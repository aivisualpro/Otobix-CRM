'use client';

import SettingsSidebar from '@/components/SettingsSidebar';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { useHeader } from '@/context/HeaderContext';

export default function ModuleSettingsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();

  const { setTitle, setSearchContent } = useHeader();

  useEffect(() => {
    setTitle('Module Settings');
    setSearchContent(
      <div className="flex items-center gap-1 bg-gray-100/50 p-1 rounded-lg border border-gray-200/50">
        <button
          onClick={() => router.push('/admin/settings/module-settings/users')}
          className={`px-4 py-1.5 text-xs font-semibold rounded-md transition-all ${
            pathname.includes('/users')
              ? 'bg-white text-blue-600 shadow-sm'
              : 'text-slate-500 hover:text-slate-700 hover:bg-white/50'
          }`}
        >
          Users
        </button>
        <button
          onClick={() => router.push('/admin/settings/module-settings/telecalling')}
          className={`px-4 py-1.5 text-xs font-semibold rounded-md transition-all ${
            pathname.includes('/telecalling')
              ? 'bg-white text-blue-600 shadow-sm'
              : 'text-slate-500 hover:text-slate-700 hover:bg-white/50'
          }`}
        >
          Telecalling
        </button>
      </div>
    );
  }, [setTitle, setSearchContent, router, pathname]);

  return (
    <div className="h-full flex bg-slate-50 overflow-hidden">
      <SettingsSidebar activeSection="module-settings" />
      
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Content */}
        <div className="flex-1 overflow-y-auto">
          {children}
        </div>
      </div>
    </div>
  );
}
