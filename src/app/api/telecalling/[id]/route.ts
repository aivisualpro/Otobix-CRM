import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Telecalling from '@/models/Telecalling';
import ReusableId from '@/models/ReusableId';

interface RouteParams {
  params: Promise<{ id: string }>;
}

export const dynamic = 'force-dynamic';

// GET single telecalling record
export async function GET(request: NextRequest, { params }: RouteParams): Promise<NextResponse> {
  try {
    await dbConnect();
    const { id } = await params;

    const record = await Telecalling.findById(id).lean();

    if (!record) {
      return NextResponse.json({ error: 'Record not found' }, { status: 404 });
    }

    return NextResponse.json(record);
  } catch (error) {
    console.error('GET /api/telecalling/[id] error:', error);
    return NextResponse.json({ error: 'Failed to fetch record' }, { status: 500 });
  }
}

// PUT update telecalling record
export async function PUT(request: NextRequest, { params }: RouteParams): Promise<NextResponse> {
  try {
    await dbConnect();
    const { id } = await params;
    const body = await request.json();

    // Remove immutable fields
    delete body._id;
    delete body.appointmentId;
    delete body.id;
    delete body.telecallingId;

    const record = await Telecalling.findByIdAndUpdate(
      id,
      { $set: body },
      { new: true, runValidators: true }
    ).lean();

    if (!record) {
      return NextResponse.json({ error: 'Record not found' }, { status: 404 });
    }

    return NextResponse.json(record);
  } catch (error) {
    console.error('PUT /api/telecalling/[id] error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Failed to update record';
    return NextResponse.json({ error: errorMessage }, { status: 500 });
  }
}

// DELETE telecalling record
export async function DELETE(request: NextRequest, { params }: RouteParams): Promise<NextResponse> {
  try {
    await dbConnect();
    const { id } = await params;

    const record = await Telecalling.findByIdAndDelete(id).lean();

    if (!record) {
      return NextResponse.json({ error: 'Record not found' }, { status: 404 });
    }

    // Recycle appointmentId
    if (record.appointmentId) {
      try {
        const parts = record.appointmentId.split('-');
        let year = new Date().getFullYear();
        if (parts.length > 0 && !isNaN(parseInt(parts[0]))) {
          year = 2000 + parseInt(parts[0]);
        }

        // Save to reusable pool
        await ReusableId.create({
          _id: record.appointmentId,
          year: year,
        });
      } catch (e) {
        // Ignore duplicates
        console.warn('Could not recycle ID:', e);
      }
    }

    return NextResponse.json({ message: 'Record deleted successfully', id });
  } catch (error) {
    console.error('DELETE /api/telecalling/[id] error:', error);
    return NextResponse.json({ error: 'Failed to delete record' }, { status: 500 });
  }
}
