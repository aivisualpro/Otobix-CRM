import { NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Counter from '@/models/Counter';
import ReusableId from '@/models/ReusableId';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    await dbConnect();

    // Reset or create the counter for 2025 (or current year)
    const date = new Date();
    const counterId = `appointmentId_${date.getFullYear()}`;

    // We want the next one to be 10000001
    // So we set it to 10000000
    await Counter.findOneAndUpdate(
      { _id: counterId },
      { $set: { seq: 10000000 } },
      { upsert: true }
    );

    // Clear reusable IDs
    await ReusableId.deleteMany({});

    return NextResponse.json({ message: 'Counter reset to 10000000. Next ID will be ...10000001' });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to reset counter' }, { status: 500 });
  }
}
