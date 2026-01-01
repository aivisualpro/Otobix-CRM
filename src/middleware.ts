import { withAuth } from 'next-auth/middleware';
import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';

export default withAuth(
  async function middleware(req) {
    const token = await getToken({ req, secret: process.env.NEXTAUTH_SECRET });
    const { pathname } = req.nextUrl;
    
    console.log(`[Middleware] Path: ${pathname}, HasToken: ${!!token}`);
    
    return NextResponse.next();
  },
  {
    callbacks: {
      authorized: ({ token }) => {
        // Log authorized callback specifically
        // console.log('[Middleware] Authorized check:', !!token);
        return !!token;
      },
    },
    pages: {
      signIn: '/auth/signin',
    },
  }
);

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api/auth (NextAuth API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - auth (auth pages like signin)
     * - public files (images etc)
     */
    '/((?!api/auth|api/debug|_next/static|_next/image|favicon.ico|auth|.*\\.png$|.*\\.jpg$|.*\\.jpeg$|.*\\.svg$).*)',
  ],
};
