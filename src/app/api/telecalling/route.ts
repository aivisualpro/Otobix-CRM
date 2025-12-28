import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Telecalling from '@/models/Telecalling';
import Counter from '@/models/Counter';
import ReusableId from '@/models/ReusableId';

// GET all telecalling records
export async function GET(): Promise<NextResponse> {
  try {
    await dbConnect();
    const records = await Telecalling.find({})
      .select('appointmentId customerName customerContactNumber city vehicleModel vehicleStatus requestedInspectionDate requestedInspectionTime appointmentSource remarks createdBy createdAt priority inspectionStatus allocatedTo')
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
    
    // Map 'model' to 'vehicleModel' to avoid Document conflicts
    if (body.model) {
      body.vehicleModel = body.model;
      delete body.model;
    }
    
    // Let MongoDB generate the _id automatically
    // Generate unique Appointment ID
    const date = new Date();
    const yearShort = date.getFullYear().toString().slice(-2);
    const counterId = `appointmentId_${date.getFullYear()}`;

    // 1. Check for reusable ID first
    const recycled = await ReusableId.findOneAndDelete({}, { sort: { _id: 1 } });
    
    if (recycled) {
      body.appointmentId = recycled._id;
    } else {
      // 2. Generate new ID
      
      // Ensure counter exists and minimum value logic
      let counter = await Counter.findById(counterId);
      if (!counter) {
        counter = await Counter.create({ _id: counterId, seq: 10000000 });
      } else if (counter.seq < 10000000) {
        counter.seq = 10000000;
        await counter.save();
      }

      const updatedCounter = await Counter.findByIdAndUpdate(
        counterId,
        { $inc: { seq: 1 } },
        { new: true }
      );

      if (updatedCounter) {
        body.appointmentId = `${yearShort}-${updatedCounter.seq}`;
      }
    }
    
    const record = await Telecalling.create(body);
    return NextResponse.json(record, { status: 201 });
  } catch (error) {
    console.error('POST /api/telecalling error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Failed to create record';
    return NextResponse.json({ error: errorMessage }, { status: 500 });
  }
}


