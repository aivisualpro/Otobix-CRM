import { NextRequest, NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

const getBaseUrl = () => process.env.NEXT_PUBLIC_BACKENDBASEURL || 'https://otobix-app-backend-development.onrender.com/api/';
const getAddUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSADD || 'user/register'}`;
const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MDBhYzc2NTA4OGQxYTA2ODc3MDU0NCIsInVzZXJOYW1lIjoiY3VzdG9tZXIiLCJ1c2VyVHlwZSI6IkN1c3RvbWVyIiwiaWF0IjoxNzY0MzMxNjMxLCJleHAiOjIwNzk2OTE2MzF9.oXw1J4ca1XoIAg-vCO2y0QqZIq0VWHdYBrl2y9iIv4Q';

// Helper to normalize keys (remove spaces, lowercase)
const normalizeFieldName = (key: string): string => {
  const normalized = key
    .trim()
    .replace(/[^a-zA-Z0-9]/g, '')
    .toLowerCase();

  const fieldMappings: Record<string, string> = {
    name: 'userName',
    username: 'userName',
    fullname: 'userName',
    emailaddress: 'email',
    email: 'email',
    role: 'userRole',
    userrole: 'userRole',
    password: 'password',
    phone: 'phoneNumber',
    phonenumber: 'phoneNumber',
    mobile: 'phoneNumber',
    contact: 'phoneNumber',
    city: 'location',
    location: 'location',
    address: 'addressList',
    addresslist: 'addressList',
    status: 'approvalStatus',
    approvalstatus: 'approvalStatus',
    dealership: 'dealershipName',
    dealershipname: 'dealershipName',
    entity: 'entityType',
    entitytype: 'entityType',
    primarycontact: 'primaryContactPerson',
    primarycontactperson: 'primaryContactPerson',
    primaryphone: 'primaryContactNumber',
    primarycontactnumber: 'primaryContactNumber',
  };

  return fieldMappings[normalized] || key;
};

export async function POST(request: NextRequest) {
  try {
    const { records } = await request.json();

    if (!records || !Array.isArray(records) || records.length === 0) {
      return NextResponse.json({ error: 'No records to process' }, { status: 400 });
    }

    let insertedCount = 0;
    let errorCount = 0;
    const errors: string[] = [];

    // Process records in sequence (or chunks if many) to hitting the external API
    for (const record of records) {
      const doc: Record<string, unknown> = {};
      for (const [key, value] of Object.entries(record)) {
        if (value !== undefined && value !== null && value !== '') {
          const normalizedKey = normalizeFieldName(key);
          if (normalizedKey === 'addressList') {
              doc[normalizedKey] = typeof value === 'string' ? value.split(',').map(s => s.trim()).filter(Boolean) : value;
          } else {
              doc[normalizedKey] = value;
          }
        }
      }

      // Default values
      if (!doc.userName) doc.userName = String(doc.email || 'User').split('@')[0];
      if (!doc.password) doc.password = 'password123';
      if (!doc.userRole) doc.userRole = 'User';

      try {
        const res = await fetch(getAddUrl(), {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Authorization': AUTH_TOKEN
          },
          body: JSON.stringify(doc),
        });

        if (res.ok) {
          insertedCount++;
        } else {
          errorCount++;
          const errData = await res.json().catch(() => ({}));
          errors.push(`Error for ${doc.email}: ${errData.message || errData.error || res.statusText}`);
        }
      } catch (err: any) {
        errorCount++;
        errors.push(`Fatal error for ${doc.email}: ${err.message}`);
      }
    }

    return NextResponse.json({
      message: `Import processed via external API. Added: ${insertedCount}, Failed: ${errorCount}`,
      inserted: insertedCount,
      failed: errorCount,
      errors: errors.slice(0, 5),
    });
  } catch (error: any) {
    console.error('Import fatal error:', error);
    return NextResponse.json({ error: 'Import failed completely', details: error.message }, { status: 500 });
  }
}
