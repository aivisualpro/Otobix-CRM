import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Dropdown from '@/models/Dropdown';

// GET single dropdown
export async function GET(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    await dbConnect();
    const { id } = await params;

    const dropdown = await Dropdown.findById(id).lean();
    if (!dropdown) {
      return NextResponse.json({ error: 'Dropdown not found' }, { status: 404 });
    }

    return NextResponse.json(dropdown);
  } catch (error) {
    console.error('Failed to fetch dropdown:', error);
    return NextResponse.json({ error: 'Failed to fetch dropdown' }, { status: 500 });
  }
}

// PUT - Update dropdown
export async function PUT(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    await dbConnect();
    const { id } = await params;
    const body = await request.json();

    const updated = await Dropdown.findByIdAndUpdate(id, body, { new: true });
    if (!updated) {
      return NextResponse.json({ error: 'Dropdown not found' }, { status: 404 });
    }

    return NextResponse.json(updated);
  } catch (error) {
    console.error('Failed to update dropdown:', error);
    return NextResponse.json({ error: 'Failed to update dropdown' }, { status: 500 });
  }
}

// DELETE dropdown
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    await dbConnect();
    const { id } = await params;

    const deleted = await Dropdown.findByIdAndDelete(id);
    if (!deleted) {
      return NextResponse.json({ error: 'Dropdown not found' }, { status: 404 });
    }

    return NextResponse.json({ message: 'Dropdown deleted successfully' });
  } catch (error) {
    console.error('Failed to delete dropdown:', error);
    return NextResponse.json({ error: 'Failed to delete dropdown' }, { status: 500 });
  }
}
