'use client';

import { useState } from 'react';
import { signIn } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { User, Phone, Lock, Loader2, AlertCircle } from 'lucide-react';
import Image from 'next/image';

export default function SignInPage() {
  const router = useRouter();
  const [userName, setUserName] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const loadingRef = useState(false); // We can just use a simple ref
  const [debugLogs, setDebugLogs] = useState<string[]>([]);

  const addLog = (msg: string) => {
    console.log(`[SignIn Debug] ${msg}`);
    setDebugLogs(prev => [...prev.slice(-4), msg]);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    addLog('VERSION 2.1 - Starting sign in...');

    const controller = new AbortController();
    const timeoutId = setTimeout(() => {
      addLog('Sign in timed out after 15s');
      setLoading(false);
      setError('Login is taking longer than expected. Please check your connection or refresh.');
    }, 15000);

    try {
      addLog(`Attempting login for: ${userName}`);
      const result = await signIn('credentials', {
        userName,
        phoneNumber,
        password,
        redirect: false,
      });

      clearTimeout(timeoutId);
      addLog(`Result: ${result?.error ? 'Error' : 'Success'}`);

      if (result?.error) {
        setError(result.error);
        setLoading(false);
      } else {
        addLog('Login Success! Jumping to root...');
        // The most absolute way to redirect in a browser:
        window.location.replace(window.location.origin);
      }
    } catch (err: any) {
      clearTimeout(timeoutId);
      addLog(`Unexpected error: ${err.message}`);
      setError(`An unexpected error occurred: ${err.message}`);
      setLoading(false);
    }
  };

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
                  className="!pl-12 w-full form-input h-10 transition-all focus:ring-2 focus:ring-blue-100 placeholder:text-slate-300 rounded-xl border-slate-200"
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
                  className="!pl-12 w-full form-input h-10 transition-all focus:ring-2 focus:ring-blue-100 placeholder:text-slate-300 rounded-xl border-slate-200"
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
                  className="!pl-12 w-full form-input h-10 transition-all focus:ring-2 focus:ring-blue-100 placeholder:text-slate-300 rounded-xl border-slate-200"
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
