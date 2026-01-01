import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import CarVariance from '@/models/CarVariance';

export const dynamic = 'force-dynamic';

// GET all car variances
export async function GET(request: NextRequest) {
  try {
    await dbConnect();
    const variances = await CarVariance.find({}).sort({ make: 1, carModel: 1, variant: 1 }).lean();
    return NextResponse.json(variances);
  } catch (error) {
    console.error('Failed to fetch car variances:', error);
    return NextResponse.json({ error: 'Failed to fetch car variances' }, { status: 500 });
  }
}

// POST - Create new car variance
export async function POST(request: NextRequest) {
  try {
    await dbConnect();
    const body = await request.json();
    
    // Basic validation
    if (!body.make || !body.carModel || !body.variant) {
        return NextResponse.json({ error: 'Make, Model, and Variant are required' }, { status: 400 });
    }

    const newVariance = await CarVariance.create(body);
    return NextResponse.json(newVariance, { status: 201 });
  } catch (error) {
    console.error('Failed to create car variance:', error);
    return NextResponse.json({ error: 'Failed to create car variance' }, { status: 500 });
  }
}

// PUT - Update car variance
export async function PUT(request: NextRequest) {
  try {
    await dbConnect();
    const body = await request.json();
    const { _id, ...updateData } = body;

    if (!_id) {
       return NextResponse.json({ error: 'ID is required' }, { status: 400 });
    }

    const updatedVariance = await CarVariance.findByIdAndUpdate(_id, updateData, { new: true });
    
    if (!updatedVariance) {
        return NextResponse.json({ error: 'Car variance not found' }, { status: 404 });
    }

    return NextResponse.json(updatedVariance);
  } catch (error) {
    console.error('Failed to update car variance:', error);
    return NextResponse.json({ error: 'Failed to update car variance' }, { status: 500 });
  }
}
