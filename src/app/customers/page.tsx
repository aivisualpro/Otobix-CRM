'use client';

import { useEffect } from 'react';
import { useHeader } from '@/context/HeaderContext';

export default function CustomersPage() {
  const { setTitle, setSearchContent, setActionsContent } = useHeader();

  useEffect(() => {
    setTitle('Customers');
    setSearchContent(null);
    setActionsContent(null);
  }, [setTitle, setSearchContent, setActionsContent]);

  return (
    <div className="h-full overflow-auto custom-scrollbar p-6">
      <div className="bg-white rounded-xl p-8 shadow-sm border border-gray-100 text-center">
        <h2 className="text-2xl font-bold text-slate-800 mb-2">Customers</h2>
        <p className="text-slate-500">Customers panel coming soon.</p>
      </div>
    </div>
  );
}
