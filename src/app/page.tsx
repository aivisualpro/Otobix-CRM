'use client';

import { useEffect, useState, useMemo } from 'react';
import { useSession } from 'next-auth/react';
import { useHeader } from '@/context/HeaderContext';
import {
  BarChart as BarChartIcon,
  Users,
  CreditCard,
  Activity,
  DollarSign,
  ArrowUpRight,
  Download,
  Calendar as CalendarIcon,
  Loader2,
  Trophy,
} from 'lucide-react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

// Types
interface TelecallingRecord {
  _id: string;
  inspectionStatus?: string;
  inspectionDateTime?: string;
  createdAt?: string;
  allocatedTo?: string;
}

interface EngineerStat {
  name: string;
  count: number;
  email?: string; // If available or derived
}

export default function Home() {
  const { data: session } = useSession();
  const { setTitle, setSearchContent, setActionsContent } = useHeader();
  const [mounted, setMounted] = useState(false);

  const [chartData, setChartData] = useState<{ name: string; total: number }[]>([]);
  const [engineerData, setEngineerData] = useState<EngineerStat[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Initial Header Setup
  useEffect(() => {
    setTitle('Dashboard');
    setSearchContent(null);
    setActionsContent(
      <div className="flex items-center gap-2">
        <Button size="sm" variant="outline" className="hidden sm:flex h-8 gap-1">
          <CalendarIcon className="h-3.5 w-3.5 text-muted-foreground/70" />
          <span className="text-xs">Current Fiscal Year</span>
        </Button>
        <Button size="sm" className="h-8 gap-1 bg-slate-900 text-white hover:bg-slate-800">
          <Download className="h-3.5 w-3.5" />
          <span className="text-xs">Download Report</span>
        </Button>
      </div>
    );
    setMounted(true);
  }, [setTitle, setSearchContent, setActionsContent]);

  // Fetch Data
  useEffect(() => {
    const fetchData = async () => {
      if (!session?.user) return;

      setIsLoading(true);
      try {
        const baseUrl =
          process.env.NEXT_PUBLIC_BACKENDBASEURL ||
          'https://otobix-app-backend-development.onrender.com/api/';
        const listEndpoint =
          process.env.NEXT_PUBLIC_TELECALLINGLIST ||
          'inspection/telecallings/get-list-by-telecaller';
        const url = `${baseUrl}${listEndpoint}?limit=10000`;
        const token = (session.user as any)?.backendToken;

        const res = await fetch(url, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (res.ok) {
          const data = await res.json();
          const records: TelecallingRecord[] = Array.isArray(data) ? data : data.data || [];
          processDashboardData(records);
        }
      } catch (error) {
        console.error('Dashboard data fetch error:', error);
      } finally {
        setIsLoading(false);
      }
    };

    if (mounted) {
      fetchData();
    }
  }, [mounted, session]);

  const processDashboardData = (records: TelecallingRecord[]) => {
    // 1. Process Chart Data (Inspected/Completed per month)
    const monthCounts = new Array(12).fill(0);
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    records.forEach((record) => {
      const status = record.inspectionStatus?.toLowerCase() || '';
      if (status === 'inspected' || status === 'completed') {
        const dateStr = record.inspectionDateTime || record.createdAt;
        if (dateStr) {
          const date = new Date(dateStr);
          if (!isNaN(date.getTime())) {
            const monthIndex = date.getMonth(); // 0-11
            monthCounts[monthIndex]++;
          }
        }
      }
    });

    const processedChartData = monthNames.map((name, index) => ({
      name,
      total: monthCounts[index],
    }));
    setChartData(processedChartData);

    // 2. Process Top Engineers (Allocated To)
    const engineerCounts: Record<string, number> = {};

    records.forEach((record) => {
      const engineer = record.allocatedTo;
      if (engineer) {
        engineerCounts[engineer] = (engineerCounts[engineer] || 0) + 1;
      }
    });

    const processedEngineers = Object.entries(engineerCounts)
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);

    setEngineerData(processedEngineers);
  };

  if (!mounted) return null;

  return (
    <div className="flex-1 space-y-4 p-4 md:p-8 pt-6 overflow-hidden flex flex-col h-full bg-slate-50/50">
      <div className="flex items-center justify-between space-y-2">
        <h2 className="text-3xl font-black tracking-tight text-slate-900">Overview</h2>
      </div>

      <Tabs defaultValue="overview" className="space-y-4 flex-1 overflow-hidden flex flex-col">
        <TabsList className="bg-white p-1 rounded-xl w-fit border border-slate-200 shadow-sm">
          <TabsTrigger
            value="overview"
            className="rounded-lg data-[state=active]:bg-slate-100 data-[state=active]:text-slate-900 font-bold text-xs uppercase tracking-wide"
          >
            Overview
          </TabsTrigger>
          <TabsTrigger
            value="analytics"
            disabled
            className="rounded-lg font-bold text-xs uppercase tracking-wide"
          >
            Analytics
          </TabsTrigger>
          <TabsTrigger
            value="reports"
            disabled
            className="rounded-lg font-bold text-xs uppercase tracking-wide"
          >
            Reports
          </TabsTrigger>
          <TabsTrigger
            value="notifications"
            disabled
            className="rounded-lg font-bold text-xs uppercase tracking-wide"
          >
            Notifications
          </TabsTrigger>
        </TabsList>

        <TabsContent
          value="overview"
          className="space-y-4 overflow-auto custom-scrollbar pr-2 pb-2"
        >
          {/* Key Metrics Cards */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card className="bg-white hover:shadow-md transition-shadow duration-200 border-slate-200 shadow-sm">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-xs font-bold uppercase tracking-wider text-slate-500">
                  Total Inspections
                </CardTitle>
                <Activity className="h-4 w-4 text-emerald-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-black text-slate-900">
                  {chartData.reduce((acc, curr) => acc + curr.total, 0).toLocaleString()}
                </div>
                <p className="text-[10px] text-emerald-600 flex items-center mt-1 font-bold uppercase tracking-wide">
                  <ArrowUpRight className="h-3 w-3 mr-1" />
                  Approved / Completed
                </p>
              </CardContent>
            </Card>
            {/* ... other metrics can be hooked up real data later ... */}
          </div>

          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
            {/* Overview Chart */}
            <Card className="col-span-4 border-slate-200 shadow-sm bg-white">
              <CardHeader>
                <CardTitle className="text-slate-900 font-bold">Monthly Inspections</CardTitle>
                <CardDescription>
                  Inspected vehicles count for the current fiscal year.
                </CardDescription>
              </CardHeader>
              <CardContent className="pl-2">
                {isLoading ? (
                  <div className="h-[350px] flex items-center justify-center">
                    <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
                  </div>
                ) : (
                  <ResponsiveContainer width="100%" height={350}>
                    <BarChart data={chartData}>
                      <XAxis
                        dataKey="name"
                        stroke="#888888"
                        fontSize={12}
                        tickLine={false}
                        axisLine={false}
                      />
                      <YAxis
                        stroke="#888888"
                        fontSize={12}
                        tickLine={false}
                        axisLine={false}
                        allowDecimals={false}
                      />
                      <Tooltip
                        cursor={{ fill: '#f8fafc' }}
                        contentStyle={{
                          backgroundColor: '#fff',
                          border: '1px solid #e2e8f0',
                          borderRadius: '12px',
                          boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                          fontSize: '12px',
                          fontWeight: 'bold',
                        }}
                      />
                      <Bar
                        dataKey="total"
                        fill="#0f172a"
                        radius={[4, 4, 0, 0]}
                        name="Inspections"
                      />
                    </BarChart>
                  </ResponsiveContainer>
                )}
              </CardContent>
            </Card>

            {/* Top Engineers List */}
            <Card className="col-span-3 border-slate-200 shadow-sm bg-white">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="text-slate-900 font-bold">
                      Top Inspection Engineers
                    </CardTitle>
                    <CardDescription>Highest allocations this month.</CardDescription>
                  </div>
                  <Trophy className="w-5 h-5 text-amber-500" />
                </div>
              </CardHeader>
              <CardContent>
                {isLoading ? (
                  <div className="h-[300px] flex items-center justify-center">
                    <Loader2 className="w-6 h-6 animate-spin text-blue-600" />
                  </div>
                ) : engineerData.length > 0 ? (
                  <div className="space-y-6">
                    {engineerData.map((eng, i) => (
                      <div key={i} className="flex items-center group">
                        <Avatar className="h-9 w-9 border border-slate-100 group-hover:scale-105 transition-transform">
                          <AvatarFallback
                            className={`text-xs font-black ${i < 3 ? 'bg-amber-50 text-amber-600' : 'bg-slate-100 text-slate-600'}`}
                          >
                            {eng.name.substring(0, 2).toUpperCase()}
                          </AvatarFallback>
                        </Avatar>
                        <div className="ml-4 space-y-1">
                          <p className="text-xs font-bold leading-none text-slate-800">
                            {eng.name}
                          </p>
                          <p className="text-[10px] text-slate-500 font-medium">Engineer</p>
                        </div>
                        <div className="ml-auto font-black text-slate-900 bg-slate-50 px-2 py-1 rounded text-xs border border-slate-100">
                          {eng.count}
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="h-20 flex items-center justify-center text-slate-400 text-xs font-medium">
                    No data available.
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>
        <TabsContent
          value="analytics"
          className="h-full flex items-center justify-center text-slate-400"
        >
          Analytics view coming soon.
        </TabsContent>
      </Tabs>
    </div>
  );
}
