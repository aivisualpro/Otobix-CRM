import { NextRequest, NextResponse } from 'next/server';

interface ImportRecord {
  [key: string]: unknown;
}

interface ImportRequestBody {
  records: ImportRecord[];
}

// Helper to normalize field names from CSV headers
const normalizeFieldName = (key: string): string => {
  // Convert various formats to camelCase
  const normalized = key
    .trim()
    .replace(/[\s_-]+(.)?/g, (_, c) => (c ? c.toUpperCase() : ''))
    .replace(/^./, (c) => c.toLowerCase());

  // Map common variations
  const fieldMappings: Record<string, string> = {
    // Required Fields
    carregistrationnumber: 'carRegistrationNumber',
    car_registration_number: 'carRegistrationNumber',
    registrationnumber: 'carRegistrationNumber',
    regnumber: 'carRegistrationNumber',
    regno: 'carRegistrationNumber',
    car_reg_no: 'carRegistrationNumber',
    
    yearofregistration: 'yearOfRegistration',
    year_of_registration: 'yearOfRegistration',
    reg_year: 'yearOfRegistration',
    regyear: 'yearOfRegistration',
    
    ownername: 'ownerName',
    owner_name: 'ownerName',
    customername: 'ownerName',
    customer_name: 'ownerName',
    name: 'ownerName',
    
    ownershipserialnumber: 'ownershipSerialNumber',
    ownership_serial_number: 'ownershipSerialNumber',
    ownershipserial: 'ownershipSerialNumber',
    ownership_serial: 'ownershipSerialNumber',
    serialnumber: 'ownershipSerialNumber',
    serial_no: 'ownershipSerialNumber',
    
    make: 'make',
    vehiclemake: 'make',
    
    model: 'model',
    vehiclemodel: 'model',
    vehicle_model: 'model',
    
    variant: 'variant',
    vehiclevariant: 'variant',
    
    // Optional Fields
    appointmentid: 'appointmentId',
    appointment_id: 'appointmentId',
    
    timestamp: 'timeStamp',
    date: 'timeStamp',
    
    emailaddress: 'emailAddress',
    email_address: 'emailAddress',
    email: 'emailAddress',
    
    contactnumber: 'customerContactNumber',
    contact_number: 'customerContactNumber',
    customercontactnumber: 'customerContactNumber',
    customer_contact_number: 'customerContactNumber',
    phonenumber: 'customerContactNumber',
    phone: 'customerContactNumber',
    contact: 'customerContactNumber',
    
    city: 'city',
    location: 'city',
    
    zipcode: 'zipCode',
    zip_code: 'zipCode',
    zip: 'zipCode',
    pincode: 'zipCode',
    
    yearofmanufacture: 'yearOfManufacture',
    year_of_manufacture: 'yearOfManufacture',
    mfg_year: 'yearOfManufacture',
    year: 'yearOfManufacture',
    
    odometerreadinginkms: 'odometerReadingInKms',
    odometer_reading_in_kms: 'odometerReadingInKms',
    odometerreading: 'odometerReadingInKms',
    odometer: 'odometerReadingInKms',
    kms: 'odometerReadingInKms',
    
    allocatedto: 'allocatedTo',
    allocated_to: 'allocatedTo',
    assignedto: 'allocatedTo',
    
    inspectionstatus: 'inspectionStatus',
    inspection_status: 'inspectionStatus',
    status: 'inspectionStatus',
    
    approvalstatus: 'approvalStatus',
    approval_status: 'approvalStatus',
    
    priority: 'priority',
    
    ncducdname: 'ncdUcdName',
    ncd_ucd_name: 'ncdUcdName',
    ncd_ucd: 'ncdUcdName',
    
    repname: 'repName',
    rep_name: 'repName',
    representative: 'repName',
    
    repcontact: 'repContact',
    rep_contact: 'repContact',
    representative_contact: 'repContact',
    
    banksource: 'bankSource',
    bank_source: 'bankSource',
    bank: 'bankSource',
    
    referencename: 'referenceName',
    reference_name: 'referenceName',
    reference: 'referenceName',
    
    remarks: 'remarks',
    comments: 'remarks',
    
    additionalnotes: 'additionalNotes',
    additional_notes: 'additionalNotes',
    notes: 'additionalNotes',
    
    carimages: 'carImages',
    car_images: 'carImages',
    images: 'carImages',
    
    inspectiondatetime: 'inspectionDateTime',
    inspection_date_time: 'inspectionDateTime',
    inspectiondate: 'inspectionDateTime',
    
    inspectionaddress: 'inspectionAddress',
    inspection_address: 'inspectionAddress',
    addressforinspection: 'inspectionAddress',
    address: 'inspectionAddress',
    
    inspectionengineernumber: 'inspectionEngineerNumber',
    inspection_engineer_number: 'inspectionEngineerNumber',
    engineernumber: 'inspectionEngineerNumber',
    engineer_contact: 'inspectionEngineerNumber',
    
    addedby: 'addedBy',
    added_by: 'addedBy',
    
    appointmentsource: 'appointmentSource',
    appointment_source: 'appointmentSource',
    source: 'appointmentSource',
    
    vehiclestatus: 'vehicleStatus',
    vehicle_status: 'vehicleStatus',
  };

  return fieldMappings[normalized.toLowerCase()] || normalized;
};

// Helper to sanitize values (remove placeholders like _1, _6, etc.)
const sanitizeValue = (value: unknown): unknown => {
  if (typeof value === 'string') {
    // Remove values that are just underscores followed by numbers (e.g. "_6", "_1")
    if (/^_\d+$/.test(value.trim())) {
      return undefined;
    }
    // Remove "nan" or "null" string values
    if (['nan', 'null', 'undefined'].includes(value.trim().toLowerCase())) {
      return undefined;
    }
    return value.trim();
  }
  return value;
};

// Backend API configuration
const getBaseUrl = () => process.env.NEXT_PUBLIC_BACKENDBASEURL || 'https://otobix-app-backend-development.onrender.com/api/';
const getAddUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGADD || 'inspection/telecallings/add'}`;
const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MDBhYzc2NTA4OGQxYTA2ODc3MDU0NCIsInVzZXJOYW1lIjoiY3VzdG9tZXIiLCJ1c2VyVHlwZSI6IkN1c3RvbWVyIiwiaWF0IjoxNzY0MzMxNjMxLCJleHAiOjIwNzk2OTE2MzF9.oXw1J4ca1XoIAg-vCO2y0QqZIq0VWHdYBrl2y9iIv4Q';

// POST bulk import telecalling records via external API
export async function POST(request: NextRequest): Promise<NextResponse> {
  try {
    const { records }: ImportRequestBody = await request.json();

    if (!records || !Array.isArray(records) || records.length === 0) {
      return NextResponse.json({ error: 'No records to process' }, { status: 400 });
    }

    console.log(`[Import] Processing ${records.length} records via external API...`);

    // Prepare documents for insert
    const docsToInsert = records.map((record, index) => {
      const doc: Record<string, unknown> = {};

      // Normalize all field names from CSV and sanitize values
      for (const [key, value] of Object.entries(record)) {
        if (value !== undefined && value !== null && value !== '') {
          const normalizedKey = normalizeFieldName(key);
          const sanitizedVal = sanitizeValue(value);

          if (sanitizedVal !== undefined && sanitizedVal !== '') {
            doc[normalizedKey] = sanitizedVal;
          }
        }
      }

      // Remove _id and id to let backend generate new IDs
      delete doc._id;
      delete doc.id;

      // Ensure all required fields have defaults if missing
      if (!doc.carRegistrationNumber) doc.carRegistrationNumber = `UNKNOWN-${index + 1}`;
      if (!doc.yearOfRegistration) doc.yearOfRegistration = new Date().getFullYear().toString();
      if (!doc.ownerName) {
        doc.ownerName = doc.name || doc.customerName || `Unknown Owner`;
      }
      if (!doc.make) doc.make = 'Unknown';
      if (!doc.model) doc.model = 'Unknown';
      if (!doc.variant) doc.variant = 'Unknown';

      // Ensure required numeric fields are numbers with proper defaults
      if (doc.ownershipSerialNumber === undefined || doc.ownershipSerialNumber === null || doc.ownershipSerialNumber === '') {
        doc.ownershipSerialNumber = 1;
      } else {
        const num = parseInt(String(doc.ownershipSerialNumber));
        doc.ownershipSerialNumber = isNaN(num) ? 1 : num;
      }

      if (doc.odometerReadingInKms) {
        const num = parseFloat(String(doc.odometerReadingInKms));
        doc.odometerReadingInKms = isNaN(num) ? 0 : num;
      }

      // Set defaults for optional fields
      if (!doc.addedBy) doc.addedBy = 'Telecaller';
      if (!doc.inspectionStatus) doc.inspectionStatus = 'Pending';
      if (!doc.priority) doc.priority = 'Medium';

      // Clean up helper fields
      delete doc.__v;
      delete doc.customerName;
      delete doc.name;

      return doc;
    });

    console.log(`[Import] Prepared ${docsToInsert.length} documents for external API`);
    if (docsToInsert.length > 0) {
      console.log('[Import] Sample document:', JSON.stringify(docsToInsert[0], null, 2));
    }

    // Send records to external API one by one (or in small batches)
    let insertedCount = 0;
    let failedCount = 0;
    const errors: string[] = [];

    // Process in batches of 10 to avoid overwhelming the API
    const BATCH_SIZE = 10;
    for (let i = 0; i < docsToInsert.length; i += BATCH_SIZE) {
      const batch = docsToInsert.slice(i, i + BATCH_SIZE);
      
      // Process batch items in parallel
      const results = await Promise.allSettled(
        batch.map(async (doc) => {
          const formData = new FormData();
          
          // Append all fields to FormData
          for (const [key, value] of Object.entries(doc)) {
            if (value !== undefined && value !== null) {
              formData.append(key, String(value));
            }
          }

          const response = await fetch(getAddUrl(), {
            method: 'POST',
            headers: {
              'Authorization': AUTH_TOKEN,
            },
            body: formData,
          });

          if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.message || `API returned ${response.status}`);
          }

          return response.json();
        })
      );

      // Count successes and failures
      results.forEach((result, idx) => {
        if (result.status === 'fulfilled') {
          insertedCount++;
        } else {
          failedCount++;
          if (errors.length < 5) {
            errors.push(`Row ${i + idx + 1}: ${result.reason?.message || 'Unknown error'}`);
          }
        }
      });

      console.log(`[Import] Batch ${Math.floor(i / BATCH_SIZE) + 1}: ${results.filter(r => r.status === 'fulfilled').length} success, ${results.filter(r => r.status === 'rejected').length} failed`);
    }

    console.log(`[Import] Complete: ${insertedCount} inserted, ${failedCount} failed`);

    return NextResponse.json({
      message: insertedCount > 0 ? 'Import completed' : 'Import failed',
      inserted: insertedCount,
      failed: failedCount,
      total: records.length,
      errors: errors.length > 0 ? errors : undefined,
    });
  } catch (error: unknown) {
    console.error('POST /api/telecalling/import error:', error);

    const errorMessage = error instanceof Error ? error.message : 'Import failed';
    return NextResponse.json(
      {
        error: 'Import failed',
        details: errorMessage,
      },
      { status: 500 }
    );
  }
}
