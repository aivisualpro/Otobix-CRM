import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import User from '@/models/User';

// Helper to normalize keys (remove spaces, lowercase)
const normalizeFieldName = (key: string): string => {
  const normalized = key.trim().replace(/[^a-zA-Z0-9]/g, '').toLowerCase();
  
  const fieldMappings: Record<string, string> = {
    'firstname': 'firstName', // Temp, will combine
    'lastname': 'lastName',   // Temp, will combine
    'name': 'userName',
    'username': 'userName',
    'fullname': 'userName',
    'emailaddress': 'email',
    'email': 'email',
    'role': 'userRole',
    'userrole': 'userRole',
    'password': 'password',
    'phone': 'phoneNumber',
    'phonenumber': 'phoneNumber',
    'mobile': 'phoneNumber',
    'contact': 'phoneNumber',
    'city': 'location',
    'location': 'location',
    'allowedcities': 'allowedCities',
    'address': 'addressList',
    'addresslist': 'addressList',
    'status': 'approvalStatus',
    'approvalstatus': 'approvalStatus',
    'isstaff': 'isStaff'
  };
  
  return fieldMappings[normalized] || key;
};

export async function POST(request: NextRequest) {
  try {
    await dbConnect();
    const { records } = await request.json();

    if (!records || !Array.isArray(records) || records.length === 0) {
      return NextResponse.json({ error: 'No records to process' }, { status: 400 });
    }

    const docsToInsert = records.map((record) => {
      const doc: Record<string, unknown> = {};
      let tempFirstName = '';
      let tempLastName = '';

      for (const [key, value] of Object.entries(record)) {
        if (value !== undefined && value !== null && value !== '') {
          const normalizedKey = normalizeFieldName(key);
          
          if (normalizedKey === 'firstName') {
            tempFirstName = String(value);
          } else if (normalizedKey === 'lastName') {
            tempLastName = String(value);
          } else if (normalizedKey === 'addressList' || normalizedKey === 'allowedCities') {
            // Ensure it's an array (split by comma if string)
            if (typeof value === 'string') {
               doc[normalizedKey] = value.split(',').map(s => s.trim()).filter(Boolean);
            } else if (Array.isArray(value)) {
               doc[normalizedKey] = value;
            }
          } else if (normalizedKey === 'isStaff') {
            // Convert string to boolean
            const strVal = String(value).toLowerCase().trim();
            doc[normalizedKey] = strVal === 'true' || strVal === '1' || strVal === 'yes';
          } else {
            doc[normalizedKey] = value;
          }
        }
      }

      // Handle UserName if not explicit
      if (!doc.userName) {
        if (tempFirstName || tempLastName) {
          doc.userName = `${tempFirstName} ${tempLastName}`.trim();
        } else {
             // Fallback from email
             doc.userName = String(doc.email || 'User').split('@')[0];
        }
      }
      
      // Default password if missing
      if (!doc.password) {
        doc.password = 'password123';
      }
      
      // Default role
      if (!doc.userRole) {
        doc.userRole = 'User';
      }

      return doc;
    });

    console.log('Docs to insert preview:', docsToInsert.slice(0, 3));

    // Use insertMany with ordered: false to skip duplicates (by email)
    // Use insertMany with ordered: false to skip duplicates (by email)
    // When ordered: false, operation continues even if some fail.
    // However, Mongoose throws an error if ANY fail, but the error object contains info about successes.
    
    let insertedCount = 0;
    let errorCount = 0;
    let errors: string[] = [];

    try {
      const result = await User.insertMany(docsToInsert, { ordered: false, rawResult: true });
      insertedCount = result.insertedCount || docsToInsert.length;
    } catch (error: any) {
      console.log('--- Import Error Log Start ---');
      // detailed logging to debug
      if (error.writeErrors) {
         console.log('Write Errors Sample:', JSON.stringify(error.writeErrors.slice(0, 1), null, 2));
      } else {
         console.log('Full Error:', JSON.stringify(error, null, 2));
      }
      console.log('--- Import Error Log End ---');

      if (error.writeErrors) {
        // Partial success
        insertedCount = error.insertedCount || 0; // Mongoose usually provides this in the error object for unordered
        // If insertedCount is missing in error, we might have to calculate from result if accessible, but error usually has it for bulkWrite
        // For insertMany with Mongoose, it wraps bulkWrite.
        // Let's rely on error.insertedDocs which might be present or result property.
        // Actually, easiest is:
        insertedCount = error.result?.nInserted || error.insertedCount || 0;
        errorCount = error.writeErrors.length;
        errors = error.writeErrors.map((e: any) => {
          if (e.code === 11000) {
            return `Duplicate key error: ${e.errmsg || 'Record already exists'}`;
          }
          return e.message || e.errmsg || (e.err && e.err.message) || 'Validation Error';
        });
      } else {
        throw error; // Unknown fatal error
      }
    }

    return NextResponse.json({
      message: `Import processed. Added: ${insertedCount}, Skipped: ${errorCount}`,
      inserted: insertedCount,
      failed: errorCount,
      errors: errors.slice(0, 5) // Return first 5 errors as sample
    });

  } catch (error: any) {
    console.error('Import fatal error:', error);
    return NextResponse.json({ 
      error: 'Import failed completely', 
      details: error.message 
    }, { status: 500 });
  }
}
