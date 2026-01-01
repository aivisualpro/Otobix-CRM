import { NextAuthOptions } from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        userName: { label: 'User Name', type: 'text' },
        phoneNumber: { label: 'Contact Number', type: 'text' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        console.log('--- Auth Debug Start ---');
        if (!credentials?.userName || !credentials?.phoneNumber || !credentials?.password) {
          throw new Error('User Name, Contact Number, and Password are required');
        }

        const baseUrl =
          process.env.NEXT_PUBLIC_BACKENDBASEURL ||
          'https://otobix-app-backend-development.onrender.com/api/';
        const loginUrl = `${baseUrl}${process.env.NEXT_PUBLIC_USERLOGIN || 'user/login'}`;

        console.log(`[Auth] loginUrl: ${loginUrl}`);

        try {
          const controller = new AbortController();
          const timeoutId = setTimeout(() => controller.abort(), 10000); // 10s fetch timeout

          const res = await fetch(loginUrl, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Accept: 'application/json',
            },
            body: JSON.stringify({
              userName: credentials.userName,
              phoneNumber: credentials.phoneNumber,
              password: credentials.password,
            }),
            signal: controller.signal,
          });

          clearTimeout(timeoutId);
          console.log(`[Auth] Response status: ${res.status}`);

          if (!res.ok) {
            const errorText = await res.text();
            console.error(`[Auth] Login failed with status ${res.status}: ${errorText}`);
            throw new Error(`Server error: ${res.status}`);
          }

          const result = await res.json();
          console.log('[Auth] Response body structure:', Object.keys(result));

          if (result.status === false || result.success === false) {
            console.warn(`[Auth] Backend returned failure: ${result.message}`);
            throw new Error(result.message || 'Invalid login credentials');
          }

          // The user object is nested under 'user' key per your provided example
          const userData = result.user || result.data;

          if (!userData) {
            console.error('[Auth] No user data found in result');
            throw new Error('User data not found in server response');
          }

          // Map role from userType or userRole
          const role = userData.userType || userData.userRole || userData.role || 'user';

          console.log('[Auth] Mapped user:', userData.userName || userData.name, 'Role:', role);
          console.log('--- Auth Debug End ---');

          return {
            id: (userData.id || userData._id || '').toString(),
            name: userData.userName || userData.name,
            email: userData.email,
            image: userData.imageUrl || userData.image,
            role: role,
            backendToken: result.token, // Store the token if needed
          };
        } catch (error: any) {
          console.error('Authorize error:', error.message);
          throw new Error(error.message || 'Failed to sign in');
        }
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.role = (user as any).role;
        token.id = user.id;
        token.backendToken = (user as any).backendToken;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        (session.user as any).role = token.role;
        (session.user as any).id = token.id;
        (session.user as any).backendToken = token.backendToken;
      }
      return session;
    },
  },
  pages: {
    signIn: '/auth/signin',
  },
  session: {
    strategy: 'jwt',
  },
  // Force a consistent cookie name to prevent Middleware/Client mismatches
  cookies: {
    sessionToken: {
      name: 'next-auth.session-token',
      options: {
        httpOnly: true,
        sameSite: 'lax',
        path: '/',
        secure: process.env.NODE_ENV === 'production',
      },
    },
  },
  secret: process.env.NEXTAUTH_SECRET || 'a-very-secret-value-for-development-only',
};
