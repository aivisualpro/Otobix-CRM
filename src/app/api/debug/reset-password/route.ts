import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import User from '@/models/User';
import bcrypt from 'bcryptjs';

export async function POST(request: NextRequest) {
  try {
    await dbConnect();
    const { email, password } = await request.json();

    if (!email || !password) {
      return NextResponse.json({ error: 'Email and password required' }, { status: 400 });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.findOneAndUpdate(
      { email: email.toLowerCase() },
      {
        password: hashedPassword,
        approvalStatus: 'Approved',
        userRole: 'Admin',
      },
      { new: true }
    );

    if (!user) {
      // Create if doesn't exist
      const newUser = await User.create({
        email: email.toLowerCase(),
        userName: 'Admin User',
        password: hashedPassword,
        approvalStatus: 'Approved',
        userRole: 'Admin',
        permissions: ['all'],
      });
      return NextResponse.json({ message: 'User created successfully', user: newUser });
    }

    return NextResponse.json({ message: 'User updated successfully', user });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
