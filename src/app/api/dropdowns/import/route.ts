import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Dropdown from '@/models/Dropdown';

export const dynamic = 'force-dynamic';

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
      
      // Basic validation
      if (!item.description || !item.type) {
        failedCount++;
        errors.push(`Row ${i + 1}: Missing Description or Type`);
        continue;
      }

      try {
        const filter = {
          type: item.type.toString().trim(),
          description: { 
            $regex: new RegExp(`^${item.description.toString().trim()}$`, 'i') 
          }
        };

        const update = {
          description: item.description.toString().trim(),
          type: item.type.toString().trim(),
          icon: item.icon || undefined,
          color: item.color || undefined,
          isActive: true,
          // Only set created/updated defaults if needed, mostly handled by timestamps: true
        };

        // Upsert: Update if exists, Insert if new
        await Dropdown.findOneAndUpdate(filter, update, {
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
