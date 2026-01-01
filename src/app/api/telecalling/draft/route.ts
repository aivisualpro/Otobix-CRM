import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Counter from '@/models/Counter';
import Telecalling from '@/models/Telecalling';
import ReusableId from '@/models/ReusableId';

export async function POST(request: NextRequest) {
  try {
    await dbConnect();

    const date = new Date();
    const yearShort = date.getFullYear().toString().slice(-2);
    const counterId = `appointmentId_${date.getFullYear()}`;

    // 1. Check for recycled ID first
    const recycled = await ReusableId.findOneAndDelete({}, { sort: { _id: 1 } });

    let newAppointmentId: string;

    if (recycled) {
      newAppointmentId = recycled._id;
    } else {
      // 2. No recycled ID, generate new one

      // Ensure counter exists and starts at least at 10000000
      let counter = await Counter.findById(counterId);

      if (!counter) {
        // Create new counter
        counter = await Counter.create({ _id: counterId, seq: 10000000 });
      } else if (counter.seq < 10000000) {
        // Fix existing low counter
        counter.seq = 10000000;
        await counter.save();
      }

      // Atomically increment to get the new ID
      const updatedCounter = await Counter.findByIdAndUpdate(
        counterId,
        { $inc: { seq: 1 } },
        { new: true }
      );

      if (!updatedCounter) {
        throw new Error('Failed to increment counter');
      }

      newAppointmentId = `${yearShort}-${updatedCounter.seq}`;
    }

    // 3. Create the Draft Record immediately
    const newRecord = await Telecalling.create({
      appointmentId: newAppointmentId,
      ownerName: 'New Applicant', // Placeholder to be visible
      carRegistrationNumber: 'PENDING',
      yearOfRegistration: new Date().getFullYear().toString(),
      ownershipSerialNumber: 1,
      make: 'PENDING',
      model: 'PENDING',
      variant: 'PENDING',
      inspectionStatus: 'Pending', // Default status
      addedBy: 'Telecaller',
    });

    return NextResponse.json(newRecord);
  } catch (error) {
    console.error('Error creating draft record:', error);
    return NextResponse.json({ error: 'Failed to create draft record' }, { status: 500 });
  }
}
