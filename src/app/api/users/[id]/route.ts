import { NextRequest, NextResponse } from 'next/server';

interface RouteParams {
  params: Promise<{ id: string }>;
}

const getBaseUrl = () => process.env.NEXT_PUBLIC_BACKENDBASEURL || 'https://otobix-app-backend-development.onrender.com/api/';
const getUpdateUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSUPDATE || 'user/update-profile'}`;
const getDeleteUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSDELETE || 'user/delete'}`;
const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MDBhYzc2NTA4OGQxYTA2ODc3MDU0NCIsInVzZXJOYW1lIjoiY3VzdG9tZXIiLCJ1c2VyVHlwZSI6IkN1c3RvbWVyIiwiaWF0IjoxNzY0MzMxNjMxLCJleHAiOjIwNzk2OTE2MzF9.oXw1J4ca1XoIAg-vCO2y0QqZIq0VWHdYBrl2y9iIv4Q';

export async function PUT(request: NextRequest, { params }: RouteParams): Promise<NextResponse> {
  try {
    const { id } = await params;
    const body = await request.json();

    // Backend typically expects userId for updates
    body.userId = id;

    const res = await fetch(getUpdateUrl(), {
        method: 'POST', // Backend often uses POST for update-profile
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

    const updatedUser = await res.json();
    return NextResponse.json(updatedUser);
  } catch (error) {
    console.error('Failed to proxy update user:', error);
    return NextResponse.json({ error: 'Failed to update user' }, { status: 500 });
  }
}

export async function DELETE(request: NextRequest, { params }: RouteParams): Promise<NextResponse> {
  try {
    const { id } = await params;

    const res = await fetch(getDeleteUrl(), { 
        method: 'POST', // Backend often uses POST for delete
        headers: {
            'Content-Type': 'application/json',
            'Authorization': AUTH_TOKEN
        },
        body: JSON.stringify({ userId: id })
    });

    if (!res.ok) {
        const err = await res.json();
        return NextResponse.json(err, { status: res.status });
    }

    return NextResponse.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Failed to proxy delete user:', error);
    return NextResponse.json({ error: 'Failed to delete user' }, { status: 500 });
  }
}
