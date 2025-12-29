'use client';

import { useEffect } from 'react';
import { useHeader } from '@/context/HeaderContext';
import { BarChart2, Users, Phone, Car, LucideIcon } from 'lucide-react';

interface StatItem {
  label: string;
  value: string;
  icon: LucideIcon;
  color: string;
}

export default function Home() {
  const { setTitle, setSearchContent, setActionsContent } = useHeader();

  useEffect(() => {
    setTitle('Dashboard');
    setSearchContent(null);
    setActionsContent(null);
  }, [setTitle, setSearchContent, setActionsContent]);

  const stats: StatItem[] = [
    { label: 'Total Leads', value: '0', icon: Phone, color: 'bg-blue-500' },
    { label: 'Active Customers', value: '0', icon: Users, color: 'bg-green-500' },
    { label: 'Vehicles', value: '0', icon: Car, color: 'bg-purple-500' },
    { label: 'Revenue', value: '$0', icon: BarChart2, color: 'bg-orange-500' },
  ];

  return (
    <div className="h-full overflow-auto custom-scrollbar p-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, index) => (
          <div key={index} className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500 font-medium">{stat.label}</p>
                <p className="text-3xl font-bold text-slate-800 mt-1">{stat.value}</p>
              </div>
              <div className={`${stat.color} p-3 rounded-xl`}>
                <stat.icon className="w-6 h-6 text-white" />
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-xl p-8 shadow-sm border border-gray-100 text-center">
        <h2 className="text-2xl font-bold text-slate-800 mb-2">Welcome to Otobix CRM</h2>
        <p className="text-slate-500">
          Your Next.js powered CRM is ready. Navigate using the menu above.
        </p>
      </div>
    </div>
  );
}
