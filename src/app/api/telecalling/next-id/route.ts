import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Counter from '@/models/Counter';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    await dbConnect();

    const date = new Date();
    const yearShort = date.getFullYear().toString().slice(-2); // e.g., "25" for 2025
    const counterId = `appointmentId_${date.getFullYear()}`;

    // Ensure counter starts at 10000001 (8 digits)
    // If it exists and is less than 10000000, update it.
    // We use two atomic operations to be safe or one if possible.
    
    // First, ensure it's at least the baseline
    await Counter.findOneAndUpdate(
      { _id: counterId, seq: { $lt: 10000000 } },
      { $set: { seq: 10000000 } }, // Set one less so the next inc makes it 10000001
      { upsert: true, setDefaultsOnInsert: true }
    );

    // Then increment
    const counter = await Counter.findByIdAndUpdate(
      counterId,
      { $inc: { seq: 1 } },
      { new: true, upsert: true }
    );

    // Format: YY-Seq (e.g., 25-1000001)
    const newId = `${yearShort}-${counter.seq}`;

    return NextResponse.json({ id: newId });
  } catch (error) {
    console.error('Error generating appointment ID:', error);
    return NextResponse.json(
      { error: 'Failed to generate appointment ID' },
      { status: 500 }
    );
  }
}
