'use client';

import { useHeader } from '@/context/HeaderContext';

export default function Header() {
  const { title, searchContent, actionsContent } = useHeader();

  return (
    <header className="bg-white border-b border-gray-100 px-4 py-2 flex items-center justify-between gap-4 h-full z-40 shrink-0">
      <div className="flex items-center gap-4 shrink-0">
        {title && <h1 className="text-lg font-bold text-slate-800 tracking-tight">{title}</h1>}
      </div>
      <div className="flex-1 flex justify-center">
        {searchContent}
      </div>
      <div className="flex items-center gap-2 shrink-0">
        {actionsContent}
      </div>
    </header>
  );
}
