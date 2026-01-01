import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import CarVariance from '@/models/CarVariance';

export const dynamic = 'force-dynamic';

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    await dbConnect();
    const { id } = await params;

    if (!id) {
      return NextResponse.json({ error: 'ID is required' }, { status: 400 });
    }

    const deleted = await CarVariance.findByIdAndDelete(id);

    if (!deleted) {
      return NextResponse.json({ error: 'Car variance not found' }, { status: 404 });
    }

    return NextResponse.json({ message: 'Car variance deleted successfully' });
  } catch (error) {
    console.error('Failed to delete car variance:', error);
    return NextResponse.json({ error: 'Failed to delete car variance' }, { status: 500 });
  }
}
