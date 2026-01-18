'use client';

import { useRouter, usePathname } from 'next/navigation';

interface SettingsSidebarProps {
  activeSection: string;
  onNavigate?: (section: string) => void;
  children?: React.ReactNode;
}

export default function SettingsSidebar({
  activeSection,
  onNavigate,
  children,
}: SettingsSidebarProps) {
  const router = useRouter();
  const pathname = usePathname();

  const sections = [
    { id: 'settings', label: 'Settings' },
    { id: 'dropdowns', label: 'Dropdowns' },
    { id: 'car-variances', label: 'Car Variances' },
    { id: 'module-settings', label: 'Module Settings' },
  ];

  const handleClick = (id: string) => {
    if (id === 'module-settings') {
      router.push('/admin/settings/module-settings');
    } else if (id === 'car-variances') {
      router.push('/admin/settings/car-variances');
    } else {
      if (pathname.includes('/module-settings') || pathname.includes('/car-variances')) {
        router.push(`/admin/settings?section=${id}`);
      } else {
        onNavigate?.(id);
      }
    }
  };

  return (
    <div className="w-64 bg-white border-r border-gray-200 flex flex-col shrink-0 h-full">


      <div className="p-3">
        {sections.map((section) => (
          <button
            key={section.id}
            onClick={() => handleClick(section.id)}
            className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors mb-1 ${
              activeSection === section.id
                ? 'bg-blue-50 text-blue-600'
                : 'text-slate-600 hover:bg-gray-50'
            }`}
          >
            {section.label}
          </button>
        ))}
      </div>

      {children && (
        <div className="flex-1 overflow-y-auto p-3 border-t border-gray-100">{children}</div>
      )}
    </div>
  );
}
