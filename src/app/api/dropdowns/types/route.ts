import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Dropdown from '@/models/Dropdown';

export const dynamic = 'force-dynamic';

// GET all unique dropdown types
export async function GET() {
  try {
    await dbConnect();
    
    const types = await Dropdown.distinct('type');
    return NextResponse.json(types.sort());
  } catch (error) {
    console.error('Failed to fetch dropdown types:', error);
    return NextResponse.json({ error: 'Failed to fetch types' }, { status: 500 });
  }
}
