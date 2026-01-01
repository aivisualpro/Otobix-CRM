import { NextRequest, NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

const getBaseUrl = () => process.env.NEXT_PUBLIC_BACKENDBASEURL || 'https://otobix-app-backend-development.onrender.com/api/';
const getListUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSLIST || 'user/all-users-list'}`;
const getAddUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSADD || 'user/register'}`;
const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MDBhYzc2NTA4OGQxYTA2ODc3MDU0NCIsInVzZXJOYW1lIjoiY3VzdG9tZXIiLCJ1c2VyVHlwZSI6IkN1c3RvbWVyIiwiaWF0IjoxNzY0MzMxNjMxLCJleHAiOjIwNzk2OTE2MzF9.oXw1J4ca1XoIAg-vCO2y0QqZIq0VWHdYBrl2y9iIv4Q';

export async function GET() {
  try {
    const res = await fetch(getListUrl(), {
      headers: {
        'Authorization': AUTH_TOKEN
      },
      cache: 'no-store'
    });
    
    if (!res.ok) {
        return NextResponse.json({ error: 'Failed to fetch users from external API' }, { status: res.status });
    }

    const data = await res.json();
    const actualData = data.data || data;
    return NextResponse.json(actualData);
  } catch (error) {
    console.error('Failed to proxy fetch users:', error);
    return NextResponse.json({ error: 'Failed to fetch users' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    const res = await fetch(getAddUrl(), {
      method: 'POST',
      headers: { 
        'Content-Type': 'application/json',
        'Authorization': AUTH_TOKEN
      },
      body: JSON.stringify(body),
    });

    if (!res.ok) {
        const err = await res.json();
        return NextResponse.json(err, { status: res.status });
    }

    const newUser = await res.json();
    return NextResponse.json(newUser, { status: 201 });
  } catch (error) {
    console.error('Failed to proxy create user:', error);
    return NextResponse.json({ error: 'Failed to create user' }, { status: 500 });
  }
}
