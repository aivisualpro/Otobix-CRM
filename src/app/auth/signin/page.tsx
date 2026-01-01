'use client';

import { useState } from 'react';
import { signIn, useSession } from 'next-auth/react';
import { useRouter, useSearchParams } from 'next/navigation';
import { User, Phone, Lock, Loader2, AlertCircle, BadgeCheck, ChevronRight } from 'lucide-react';
import Image from 'next/image';
import { useEffect, Suspense } from 'react';

function SignInContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { data: session, status } = useSession();
  
  const [userName, setUserName] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [debugLogs, setDebugLogs] = useState<string[]>([]);
  const [redirecting, setRedirecting] = useState(false);

  const addLog = (msg: string) => {
    console.log(`[SignIn Debug] ${msg}`);
    setDebugLogs(prev => [...prev.slice(-4), msg]);
  };

  // Log status changes
  useEffect(() => {
    addLog(`Status: ${status}`);
    if (session) {
      addLog(`User: ${session.user?.name || 'Unknown'}`);
    }
  }, [status, session]);

  // Auto-redirect handling
  useEffect(() => {
    if (status === 'authenticated' && !redirecting) {
      setRedirecting(true);
      
      let callbackUrl = searchParams.get('callbackUrl') || '/';
      if (callbackUrl.includes('/auth/signin')) callbackUrl = '/';

      addLog(`Logic: Logged in, will jump to ${callbackUrl} in 1s...`);
      
      const timer = setTimeout(() => {
        addLog('Executing jump...');
        // Force full reload to ensure middleware sees the new cookie
        window.location.href = callbackUrl;
      }, 1500);

      return () => clearTimeout(timer);
    }
  }, [status, searchParams, redirecting]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    addLog('Starting sign in process...');

    try {
      const result = await signIn('credentials', {
        userName,
        phoneNumber,
        password,
        redirect: false,
      });

      if (result?.error) {
        setError(result.error);
        setLoading(false);
        addLog(`Error: ${result.error}`);
      } else if (result?.ok) {
        addLog('Login successful! Updating session...');
        // The useEffect above will handle redirection when status changes
      }
    } catch (err: any) {
      addLog(`Unexpected error: ${err.message}`);
      setError(`An unexpected error occurred: ${err.message}`);
      setLoading(false);
    }
  };

  if (status === 'loading') {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100 p-8 flex flex-col items-center text-center">
          <Loader2 className="w-10 h-10 text-blue-600 animate-spin mb-4" />
          <h2 className="text-xl font-bold text-slate-800 mb-2">Verifying Session</h2>
          <p className="text-slate-500">Checking your login status...</p>
        </div>
      </div>
    );
  }

  if (status === 'authenticated') {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100 p-8 flex flex-col items-center text-center">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mb-4">
            <BadgeCheck className="w-10 h-10 text-green-600" />
          </div>
          <h2 className="text-xl font-bold text-slate-800 mb-2">Login Successful</h2>
          <p className="text-slate-500 mb-6">Redirecting you to the dashboard...</p>
          
          <div className="w-full space-y-3">
            <button 
              onClick={() => window.location.href = '/'}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold h-11 rounded-xl transition-all flex items-center justify-center gap-2"
            >
              Go to Dashboard <ChevronRight className="w-4 h-4" />
            </button>
            <button 
              onClick={() => {
                const url = new URL(window.location.href);
                url.searchParams.delete('callbackUrl');
                window.location.href = url.pathname;
              }}
              className="w-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-medium h-11 rounded-xl transition-all flex items-center justify-center gap-2"
            >
              Clear Redirect & Stay Here
            </button>
          </div>

          <div className="mt-8 p-3 bg-slate-50 rounded-lg w-full text-left">
            <p className="text-[10px] font-bold text-slate-400 mb-1 uppercase tracking-wider">Debug Info</p>
            <div className="text-[10px] font-mono text-slate-400 space-y-1">
              {debugLogs.map((log, i) => (
                <div key={i} className="border-l-2 border-slate-200 pl-2">&gt; {log}</div>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100">
        <div className="px-8 py-6 bg-white border-b border-gray-100 text-center">
          <div className="relative w-24 h-24 mx-auto mb-6 flex items-center justify-center">
            <img
              src="/logo-v2.png"
              alt="Otobix CRM"
              className="object-contain w-full h-full"
            />
          </div>
          <h1 className="text-2xl font-bold text-slate-800">Welcome Back</h1>
          <p className="text-slate-500 text-sm mt-1">Sign in to your account</p>
        </div>

        <form onSubmit={handleSubmit} className="p-8 space-y-6">
          {error && (
            <div className="bg-red-50 text-red-600 p-3 rounded-lg text-sm flex items-center gap-2 border border-red-100 animate-in fade-in slide-in-from-top-2">
              <AlertCircle className="w-4 h-4 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          <div className="space-y-4">
            <div>
              <label htmlFor="userName" className="block text-sm font-medium text-slate-700 mb-1.5">User Name</label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                <input
                  id="userName"
                  name="userName"
                  type="text"
                  required
                  value={userName}
                  onChange={(e) => setUserName(e.target.value)}
                  className="!pl-12 w-full h-10 transition-all focus:ring-2 focus:ring-blue-100 placeholder:text-slate-300 rounded-xl border border-slate-200"
                  placeholder="Enter your user name"
                  autoComplete="username"
                />
              </div>
            </div>

            <div>
              <label htmlFor="phoneNumber" className="block text-sm font-medium text-slate-700 mb-1.5">Contact Number</label>
              <div className="relative">
                <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                <input
                  id="phoneNumber"
                  name="phoneNumber"
                  type="tel"
                  required
                  value={phoneNumber}
                  onChange={(e) => setPhoneNumber(e.target.value)}
                  className="!pl-12 w-full h-10 transition-all focus:ring-2 focus:ring-blue-100 placeholder:text-slate-300 rounded-xl border border-slate-200"
                  placeholder="Enter your contact number"
                  autoComplete="tel"
                />
              </div>
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-slate-700 mb-1.5">Password</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                <input
                  id="password"
                  name="password"
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="!pl-12 w-full h-10 transition-all focus:ring-2 focus:ring-blue-100 placeholder:text-slate-300 rounded-xl border border-slate-200"
                  placeholder="••••••••"
                  autoComplete="current-password"
                />
              </div>
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold h-11 rounded-xl transition-all shadow-lg shadow-blue-600/20 flex items-center justify-center gap-2 hover:shadow-blue-600/30 disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {loading ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" /> Signing in...
              </>
            ) : (
              'Sign In'
            )}
          </button>
        </form>

        <div className="px-8 py-4 bg-slate-50 border-t border-gray-100 text-center">
          <p className="text-xs text-slate-500 mb-2">
            Don&apos;t have an account? Contact your administrator.
          </p>
          {debugLogs.length > 0 && (
            <div className="mt-4 p-2 bg-slate-100 rounded text-[10px] text-left font-mono text-slate-400 overflow-hidden">
              {debugLogs.map((log, i) => <div key={i}>&gt; {log}</div>)}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function SignInPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100 p-8 flex flex-col items-center">
          <Loader2 className="w-8 h-8 animate-spin text-blue-600 mb-4" />
          <p className="text-slate-500 animate-pulse">Initializing login module...</p>
        </div>
      </div>
    }>
      <SignInContent />
    </Suspense>
  );
}
