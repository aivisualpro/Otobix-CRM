import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Telecalling from '@/models/Telecalling';
import Counter from '@/models/Counter';
import ReusableId from '@/models/ReusableId';
import { telecallingSchema } from '@/lib/validations/telecalling';

export const dynamic = 'force-dynamic';

// GET all telecalling records
export async function GET(): Promise<NextResponse> {
  try {
    await dbConnect();
    const records = await Telecalling.find({})
      .sort({ createdAt: -1 })
      .lean();
    return NextResponse.json(records);
  } catch (error) {
    console.error('GET /api/telecalling error:', error);
    return NextResponse.json({ error: 'Failed to fetch records' }, { status: 500 });
  }
}

// POST create a single telecalling record
export async function POST(request: NextRequest): Promise<NextResponse> {
  try {
    await dbConnect();
    const body = await request.json();

    // Validate request body
    const validationResult = telecallingSchema.safeParse(body);
    if (!validationResult.success) {
      return NextResponse.json(
        { error: 'Validation Failed', details: validationResult.error.format() },
        { status: 400 }
      );
    }

    const finalData = { ...validationResult.data } as any;

    // Handle inspectionDateTime conversion if it's a string
    if (finalData.inspectionDateTime && typeof finalData.inspectionDateTime === 'string') {
        const date = new Date(finalData.inspectionDateTime);
        if (!isNaN(date.getTime())) {
            finalData.inspectionDateTime = date;
        } else {
            finalData.inspectionDateTime = null;
        }
    }

    // Generate unique Appointment ID
    const date = new Date();
    const yearShort = date.getFullYear().toString().slice(-2);
    const counterId = `appointmentId_${date.getFullYear()}`;

    // 1. Check for reusable ID first
    // We sort by _id ascending to use the oldest deleted ID first
    const recycled = await ReusableId.findOneAndDelete({}, { sort: { _id: 1 } });

    if (recycled) {
      finalData.appointmentId = recycled._id;
    } else {
      // 2. Generate new ID
      
      // Atomic increment. If it doesn't exist, we'll initialize it.
      const updatedCounter = await Counter.findByIdAndUpdate(
        counterId,
        { $inc: { seq: 1 } },
        { new: true, upsert: true, setDefaultsOnInsert: true }
      );

      if (updatedCounter) {
        finalData.appointmentId = `${yearShort}-${updatedCounter.seq}`;
      }
    }

    const record = await Telecalling.create(finalData);
    return NextResponse.json(record, { status: 201 });
  } catch (error) {
    console.error('POST /api/telecalling error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Failed to create record';
    return NextResponse.json({ error: errorMessage }, { status: 500 });
  }
}
