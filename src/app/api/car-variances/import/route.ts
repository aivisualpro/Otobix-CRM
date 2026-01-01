import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import CarVariance from '@/models/CarVariance';

export async function POST(request: NextRequest) {
  try {
    await dbConnect();
    const body = await request.json();
    const { records } = body;

    // Validate input
    if (!records || !Array.isArray(records)) {
      return NextResponse.json(
        { error: 'Invalid data format. Expected "records" array.' },
        { status: 400 }
      );
    }

    let createdCount = 0;
    let failedCount = 0;
    const errors: string[] = [];

    for (let i = 0; i < records.length; i++) {
      const item = records[i];
      
      const make = item.make?.toString().trim();
      const carModel = (item.carModel || item.model)?.toString().trim();
      const variant = item.variant?.toString().trim();

      // Basic validation
      if (!make || !carModel || !variant) {
        failedCount++;
        errors.push(`Row ${i + 1}: Missing Make, Model, or Variant`);
        continue;
      }

      try {
        const filter = {
          make: { $regex: new RegExp(`^${make}$`, 'i') },
          carModel: { $regex: new RegExp(`^${carModel}$`, 'i') },
          variant: { $regex: new RegExp(`^${variant}$`, 'i') }
        };

        const update = {
          make,
          carModel,
          variant,
          price: Number(item.price) || 0,
        };

        // Upsert: Update if exists, Insert if new
        await CarVariance.findOneAndUpdate(filter, update, {
          upsert: true,
          new: true,
          setDefaultsOnInsert: true,
        });

        createdCount++;
      } catch (err: any) {
        failedCount++;
        errors.push(`Row ${i + 1}: ${err.message}`);
      }
    }

    return NextResponse.json({
      success: true,
      count: createdCount, // Total processed/upserted successfully
      inserted: createdCount,
      failed: failedCount,
      errors: errors.length > 0 ? errors : undefined,
    });
  } catch (error) {
    console.error('Import error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
