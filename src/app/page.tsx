'use client';

import { useEffect, useState } from 'react';
import { useHeader } from '@/context/HeaderContext';
import { 
  BarChart as BarChartIcon, 
  Users, 
  CreditCard, 
  Activity, 
  DollarSign, 
  ArrowUpRight,
  Download,
  Calendar as CalendarIcon
} from 'lucide-react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer 
} from 'recharts';

// Mock Data for the chart
const data = [
  { name: "Jan", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Feb", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Mar", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Apr", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "May", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Jun", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Jul", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Aug", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Sep", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Oct", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Nov", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Dec", total: Math.floor(Math.random() * 5000) + 1000 },
];

export default function Home() {
  const { setTitle, setSearchContent, setActionsContent } = useHeader();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setTitle('Dashboard');
    setSearchContent(null);
    setActionsContent(
      <div className="flex items-center gap-2">
        <Button size="sm" variant="outline" className="hidden sm:flex h-8 gap-1">
           <CalendarIcon className="h-3.5 w-3.5 text-muted-foreground/70" />
           <span className="text-xs">Jan 20, 2024 - Feb 09, 2024</span>
        </Button>
        <Button size="sm" className="h-8 gap-1 bg-slate-900 text-white hover:bg-slate-800">
           <Download className="h-3.5 w-3.5" />
           <span className="text-xs">Download</span>
        </Button>
      </div>
    );
    setMounted(true);
  }, [setTitle, setSearchContent, setActionsContent]);

  if (!mounted) return null;

  return (
    <div className="flex-1 space-y-4 p-4 md:p-8 pt-6 overflow-hidden flex flex-col h-full">
      <div className="flex items-center justify-between space-y-2">
        <h2 className="text-3xl font-bold tracking-tight text-slate-900">Overview</h2>
      </div>
      
      <Tabs defaultValue="overview" className="space-y-4 flex-1 overflow-hidden flex flex-col">
        <TabsList className="bg-slate-100/50 p-1 rounded-xl w-fit">
          <TabsTrigger value="overview" className="rounded-lg data-[state=active]:bg-white data-[state=active]:text-slate-900 data-[state=active]:shadow-sm">Overview</TabsTrigger>
          <TabsTrigger value="analytics" disabled className="rounded-lg">Analytics</TabsTrigger>
          <TabsTrigger value="reports" disabled className="rounded-lg">Reports</TabsTrigger>
          <TabsTrigger value="notifications" disabled className="rounded-lg">Notifications</TabsTrigger>
        </TabsList>
        
        <TabsContent value="overview" className="space-y-4 overflow-auto custom-scrollbar pr-2 pb-2">
          {/* Key Metrics Cards */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card className="bg-white hover:shadow-md transition-shadow duration-200 border-slate-100 shadow-sm">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-slate-500">
                  Total Revenue
                </CardTitle>
                <DollarSign className="h-4 w-4 text-emerald-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-slate-900">$45,231.89</div>
                <p className="text-xs text-emerald-600 flex items-center mt-1 font-medium">
                   <ArrowUpRight className="h-3 w-3 mr-1" />
                   +20.1% from last month
                </p>
              </CardContent>
            </Card>
            <Card className="bg-white hover:shadow-md transition-shadow duration-200 border-slate-100 shadow-sm">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-slate-500">
                  Subscriptions
                </CardTitle>
                <Users className="h-4 w-4 text-blue-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-slate-900">+2350</div>
                <p className="text-xs text-emerald-600 flex items-center mt-1 font-medium">
                   <ArrowUpRight className="h-3 w-3 mr-1" />
                   +180.1% from last month
                </p>
              </CardContent>
            </Card>
            <Card className="bg-white hover:shadow-md transition-shadow duration-200 border-slate-100 shadow-sm">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-slate-500">
                  Sales
                </CardTitle>
                <CreditCard className="h-4 w-4 text-indigo-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-slate-900">+12,234</div>
                <p className="text-xs text-emerald-600 flex items-center mt-1 font-medium">
                   <ArrowUpRight className="h-3 w-3 mr-1" />
                   +19% from last month
                </p>
              </CardContent>
            </Card>
            <Card className="bg-white hover:shadow-md transition-shadow duration-200 border-slate-100 shadow-sm">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-slate-500">
                  Active Now
                </CardTitle>
                <Activity className="h-4 w-4 text-rose-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-slate-900">+573</div>
                <p className="text-xs text-emerald-600 flex items-center mt-1 font-medium">
                   <ArrowUpRight className="h-3 w-3 mr-1" />
                   +201 since last hour
                </p>
              </CardContent>
            </Card>
          </div>

          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
            {/* Overview Chart */}
            <Card className="col-span-4 border-slate-100 shadow-sm">
              <CardHeader>
                <CardTitle className="text-slate-900">Overview</CardTitle>
                <CardDescription>
                  Monthly revenue breakdown for the current fiscal year.
                </CardDescription>
              </CardHeader>
              <CardContent className="pl-2">
                <ResponsiveContainer width="100%" height={350}>
                  <BarChart data={data}>
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
                      tickFormatter={(value) => `$${value}`}
                    />
                    <Tooltip 
                        cursor={{fill: '#f1f5f9'}}
                        contentStyle={{
                            backgroundColor: '#fff',
                            border: '1px solid #e2e8f0',
                            borderRadius: '8px',
                            boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'
                        }}
                    />
                    <Bar
                      dataKey="total"
                      fill="#0f172a"
                      radius={[4, 4, 0, 0]}
                    />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            {/* Recent Sales List */}
            <Card className="col-span-3 border-slate-100 shadow-sm">
              <CardHeader>
                <CardTitle className="text-slate-900">Recent Sales</CardTitle>
                <CardDescription>
                  You made 265 sales this month.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-8">
                  {[
                    { name: 'Olivia Martin', email: 'olivia.martin@email.com', amount: '+$1,999.00', src: '/avatars/01.png', fallback: 'OM' },
                    { name: 'Jackson Lee', email: 'jackson.lee@email.com', amount: '+$39.00', src: '/avatars/02.png', fallback: 'JL' },
                    { name: 'Isabella Nguyen', email: 'isabella.nguyen@email.com', amount: '+$299.00', src: '/avatars/03.png', fallback: 'IN' },
                    { name: 'William Kim', email: 'will@email.com', amount: '+$99.00', src: '/avatars/04.png', fallback: 'WK' },
                    { name: 'Sofia Davis', email: 'sofia.davis@email.com', amount: '+$39.00', src: '/avatars/05.png', fallback: 'SD' },
                  ].map((sale, i) => (
                    <div key={i} className="flex items-center">
                      <Avatar className="h-9 w-9">
                        <AvatarImage src={sale.src} alt="Avatar" />
                        <AvatarFallback className="bg-blue-50 text-blue-600 text-xs font-bold">{sale.fallback}</AvatarFallback>
                      </Avatar>
                      <div className="ml-4 space-y-1">
                        <p className="text-sm font-medium leading-none text-slate-900">{sale.name}</p>
                        <p className="text-sm text-slate-500">{sale.email}</p>
                      </div>
                      <div className="ml-auto font-medium text-slate-900">{sale.amount}</div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
        <TabsContent value="analytics" className="h-full flex items-center justify-center text-slate-400">
             Analytics view coming soon.
        </TabsContent>
      </Tabs>
    </div>
  );
}
