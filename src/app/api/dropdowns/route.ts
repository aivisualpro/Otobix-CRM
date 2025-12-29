import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Dropdown from '@/models/Dropdown';

export const dynamic = 'force-dynamic';

// GET all dropdowns (optionally filter by type)
export async function GET(request: NextRequest) {
  try {
    await dbConnect();

    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type');

    const query = type ? { type } : {};
    const dropdowns = await Dropdown.find(query).sort({ type: 1, sortOrder: 1 }).lean();

    return NextResponse.json(dropdowns);
  } catch (error) {
    console.error('Failed to fetch dropdowns:', error);
    return NextResponse.json({ error: 'Failed to fetch dropdowns' }, { status: 500 });
  }
}

// POST - Create new dropdown
export async function POST(request: NextRequest) {
  try {
    await dbConnect();
    const body = await request.json();

    const newDropdown = await Dropdown.create(body);
    return NextResponse.json(newDropdown, { status: 201 });
  } catch (error) {
    console.error('Failed to create dropdown:', error);
    return NextResponse.json({ error: 'Failed to create dropdown' }, { status: 500 });
  }
}
