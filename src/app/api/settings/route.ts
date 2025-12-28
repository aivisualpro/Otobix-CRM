import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Settings from '@/models/Settings';

export const dynamic = 'force-dynamic';

// GET all settings
export async function GET() {
  try {
    await dbConnect();
    const settings = await Settings.find({}).sort({ category: 1, key: 1 }).lean();
    return NextResponse.json(settings);
  } catch (error) {
    console.error('Failed to fetch settings:', error);
    return NextResponse.json({ error: 'Failed to fetch settings' }, { status: 500 });
  }
}

// POST - Create new setting
export async function POST(request: NextRequest) {
  try {
    await dbConnect();
    const body = await request.json();

    // Check if key already exists
    const existing = await Settings.findOne({ key: body.key });
    if (existing) {
      return NextResponse.json({ error: 'Setting with this key already exists' }, { status: 400 });
    }

    const newSetting = await Settings.create(body);
    return NextResponse.json(newSetting, { status: 201 });
  } catch (error) {
    console.error('Failed to create setting:', error);
    return NextResponse.json({ error: 'Failed to create setting' }, { status: 500 });
  }
}

// PUT - Update setting by key
export async function PUT(request: NextRequest) {
  try {
    await dbConnect();
    const body = await request.json();
    const { key, value } = body;

    if (!key) {
      return NextResponse.json({ error: 'Key is required' }, { status: 400 });
    }

    const updated = await Settings.findOneAndUpdate(
      { key },
      { value },
      { new: true }
    );

    if (!updated) {
      return NextResponse.json({ error: 'Setting not found' }, { status: 404 });
    }

    return NextResponse.json(updated);
  } catch (error) {
    console.error('Failed to update setting:', error);
    return NextResponse.json({ error: 'Failed to update setting' }, { status: 500 });
  }
}
