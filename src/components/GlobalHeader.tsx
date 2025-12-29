'use client';

import { useMemo, useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Home,
  Settings,
  ClipboardCheck,
  Gavel,
  LogOut,
  User,
  Users,
  Car,
  History,
  ShoppingBag,
  Briefcase,
  PhoneCall,
  CreditCard,
  BarChart2,
  CarFront,
  Menu,
  X,
  Shield,
  ChevronDown,
  LucideIcon,
} from 'lucide-react';

interface SubMenuItem {
  name: string;
  path: string;
  icon: LucideIcon;
}

interface MenuItem {
  name: string;
  path: string;
  icon: LucideIcon;
  comingSoon?: boolean;
  subMenu?: SubMenuItem[];
}

const GlobalHeader = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isProfileMenuOpen, setIsProfileMenuOpen] = useState(false);
  const pathname = usePathname();

  // Mock user for demo (replace with your auth logic)
  const user = { userName: 'Admin User', userType: 'admin', imageUrl: '' };
  const role = 'admin';

  const disabledCommon: MenuItem[] = useMemo(
    () => [
      { name: 'Retail', path: '/retail', icon: ShoppingBag, comingSoon: true },
      { name: 'Operations', path: '/operations', icon: Briefcase, comingSoon: true },
      { name: 'Accounts', path: '/accounts', icon: CreditCard, comingSoon: true },
      { name: 'Reports', path: '/reports', icon: BarChart2, comingSoon: true },
    ],
    []
  );

  const menuItems: MenuItem[] = useMemo(() => {
    if (role === 'admin') {
      return [
        { name: 'Home', path: '/', icon: Home },
        {
          name: 'Admin',
          path: '/admin', // This might just be a trigger, or overview
          icon: Settings,
          subMenu: [
            { name: 'Users', path: '/admin/users', icon: Shield },
            { name: 'Settings', path: '/admin/settings', icon: Settings },
          ],
        },
        { name: 'Telecalling', path: '/telecalling', icon: PhoneCall },
        { name: 'Auctions', path: '/auctions', icon: Gavel },
        { name: 'Customers', path: '/customers', icon: Users },
        { name: 'Sales', path: '/sales', icon: BarChart2 },
        ...disabledCommon,
      ];
    }
    return [{ name: 'Home', path: '/', icon: Home }, ...disabledCommon];
  }, [role, disabledCommon]);

  return (
    <header className="bg-[#f4f9ff] border-b border-gray-200 z-50 h-full flex items-center justify-between px-4 lg:px-6 shadow-sm shrink-0">
      {/* Logo */}
      <div className="flex items-center gap-3">
        <Link href="/" className="text-xl font-bold text-blue-500">
          Otobix CRM
        </Link>
      </div>

      {/* Desktop Navigation */}
      {/* Changed overflow-x-auto to visible on desktop to allow dropdowns */}
      <nav className="hidden md:flex items-center gap-1 flex-1 px-8 overflow-visible">
        {menuItems.map((item) =>
          item.comingSoon ? (
            <div
              key={item.name}
              className="flex items-center gap-2 px-3 py-2 rounded-lg opacity-50 cursor-not-allowed grayscale whitespace-nowrap"
            >
              <item.icon className="w-3.5 h-3.5 text-slate-500" />
              <span className="text-xs font-medium text-slate-500">{item.name}</span>
            </div>
          ) : item.subMenu ? (
            // Dropdown Menu Item
            <div key={item.name} className="relative group">
              <button
                className={`flex items-center gap-2 px-3 py-2 rounded-lg transition-all duration-200 whitespace-nowrap cursor-pointer ${
                  pathname.startsWith(item.path)
                    ? 'bg-blue-500 text-white shadow-md'
                    : 'text-slate-600 hover:bg-white/50 hover:text-blue-500'
                }`}
              >
                <item.icon className="w-3.5 h-3.5" />
                <span className="text-xs font-medium">{item.name}</span>
                <ChevronDown className="w-3 h-3 ml-0.5 opacity-70 group-hover:rotate-180 transition-transform duration-200" />
              </button>

              {/* Dropdown Content */}
              <div className="absolute left-0 top-full pt-2 w-48 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50">
                <div className="bg-white border border-gray-100 rounded-xl shadow-xl py-1 overflow-hidden">
                  {item.subMenu.map((sub) => (
                    <Link
                      key={sub.path}
                      href={sub.path}
                      className={`flex items-center gap-2 px-4 py-2.5 text-xs font-medium transition-colors ${
                        pathname === sub.path
                          ? 'bg-blue-50 text-blue-600'
                          : 'text-slate-600 hover:bg-gray-50 hover:text-blue-600'
                      }`}
                    >
                      <sub.icon className="w-3.5 h-3.5" />
                      {sub.name}
                    </Link>
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <Link
              key={item.name}
              href={item.path}
              className={`flex items-center gap-2 px-3 py-2 rounded-lg transition-all duration-200 whitespace-nowrap ${
                pathname === item.path
                  ? 'bg-blue-500 text-white shadow-md'
                  : 'text-slate-600 hover:bg-white/50 hover:text-blue-500'
              }`}
            >
              <item.icon className="w-3.5 h-3.5" />
              <span className="text-xs font-medium">{item.name}</span>
            </Link>
          )
        )}
      </nav>

      {/* Profile & Mobile Toggle */}
      <div className="flex items-center gap-3">
        {/* Profile Dropdown */}
        <div className="relative">
          <button
            onClick={() => setIsProfileMenuOpen(!isProfileMenuOpen)}
            className="flex items-center justify-center p-1 rounded-full hover:bg-white/50 transition-colors focus:outline-none"
          >
            <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
              <User className="w-4 h-4 text-blue-500" />
            </div>
          </button>

          {isProfileMenuOpen && (
            <>
              <div className="fixed inset-0 z-40" onClick={() => setIsProfileMenuOpen(false)} />
              <div className="absolute right-0 top-full mt-2 w-48 bg-white rounded-xl shadow-lg py-1 z-50 border border-gray-100">
                <Link
                  href="/profile"
                  onClick={() => setIsProfileMenuOpen(false)}
                  className="w-full text-left px-4 py-2.5 text-sm text-slate-700 hover:bg-slate-50 flex items-center gap-2"
                >
                  <div className="w-3.5 h-3.5 flex items-center justify-center">
                    <User className="w-4 h-4" />
                  </div>
                  Profile
                </Link>
                <button
                  className="w-full text-left px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 flex items-center gap-2"
                  onClick={() => {
                    window.location.href = '/login';
                  }}
                >
                  <div className="w-3.5 h-3.5 flex items-center justify-center">
                    <LogOut className="w-4 h-4" />
                  </div>
                  Logout
                </button>
              </div>
            </>
          )}
        </div>

        {/* Mobile Menu Button */}
        <button
          className="md:hidden p-2 text-gray-600 hover:bg-gray-100 rounded-lg"
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        >
          {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile Menu Overlay */}
      {isMobileMenuOpen && (
        <div className="absolute top-12 left-0 right-0 bg-white border-b border-gray-200 shadow-lg md:hidden flex flex-col p-4 space-y-2 z-40 max-h-[80vh] overflow-y-auto">
          {menuItems.map((item) =>
            item.comingSoon ? (
              <div
                key={item.name}
                className="flex items-center gap-3 px-4 py-3 rounded-lg opacity-50 grayscale bg-gray-50"
              >
                <item.icon className="w-5 h-5 text-gray-500" />
                <span className="font-medium text-gray-500">{item.name}</span>
                <span className="text-xs bg-gray-200 px-2 py-0.5 rounded">Soon</span>
              </div>
            ) : item.subMenu ? (
              <div key={item.name} className="space-y-1">
                <div className="flex items-center gap-3 px-4 py-3 text-gray-700 font-medium bg-gray-50 rounded-lg">
                  <item.icon className="w-5 h-5" />
                  {item.name}
                </div>
                <div className="pl-12 space-y-1">
                  {item.subMenu.map((sub) => (
                    <Link
                      key={sub.path}
                      href={sub.path}
                      onClick={() => setIsMobileMenuOpen(false)}
                      className={`flex items-center gap-3 px-4 py-2 rounded-lg transition-colors text-sm ${
                        pathname === sub.path
                          ? 'text-blue-600 bg-blue-50'
                          : 'text-slate-600 hover:bg-gray-50'
                      }`}
                    >
                      <sub.icon className="w-4 h-4" />
                      {sub.name}
                    </Link>
                  ))}
                </div>
              </div>
            ) : (
              <Link
                key={item.name}
                href={item.path}
                onClick={() => setIsMobileMenuOpen(false)}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                  pathname === item.path
                    ? 'bg-blue-500 text-white'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                <item.icon className="w-5 h-5" />
                <span className="font-medium">{item.name}</span>
              </Link>
            )
          )}
        </div>
      )}
    </header>
  );
};

export default GlobalHeader;
