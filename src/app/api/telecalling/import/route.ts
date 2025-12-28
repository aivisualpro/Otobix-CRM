import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Telecalling from '@/models/Telecalling';

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
    .replace(/[\s_-]+(.)?/g, (_, c) => c ? c.toUpperCase() : '')
    .replace(/^./, c => c.toLowerCase());
  
  // Map common variations
  const fieldMappings: Record<string, string> = {
    'appointmentid': 'appointmentId',
    'customername': 'customerName',
    'customer_name': 'customerName',
    'customercontactnumber': 'customerContactNumber',
    'customer_contact_number': 'customerContactNumber',
    'phonenumber': 'customerContactNumber',
    'phone': 'customerContactNumber',
    'contact': 'customerContactNumber',
    'emailaddress': 'emailAddress',
    'email_address': 'emailAddress',
    'email': 'emailAddress',
    'model': 'vehicleModel',
    'vehiclemodel': 'vehicleModel',
    'vehicle_model': 'vehicleModel',
    'yearofmanufacture': 'yearOfManufacture',
    'year_of_manufacture': 'yearOfManufacture',
    'year': 'yearOfManufacture',
    'odometerreading': 'odometerReading',
    'odometer_reading': 'odometerReading',
    'odometer': 'odometerReading',
    'serialnum': 'serialNum',
    'serial_num': 'serialNum',
    'serialnumber': 'serialNum',
    'vin': 'serialNum',
    'addressforinspection': 'addressForInspection',
    'address_for_inspection': 'addressForInspection',
    'address': 'addressForInspection',
    'zipcode': 'zipCode',
    'zip_code': 'zipCode',
    'zip': 'zipCode',
    'requestedinspectiondate': 'requestedInspectionDate',
    'requested_inspection_date': 'requestedInspectionDate',
    'inspectiondate': 'requestedInspectionDate',
    'requestedinspectiontime': 'requestedInspectionTime',
    'requested_inspection_time': 'requestedInspectionTime',
    'inspectiontime': 'requestedInspectionTime',
    'allocatedto': 'allocatedTo',
    'allocated_to': 'allocatedTo',
    'assignedto': 'allocatedTo',
    'inspectionstatus': 'inspectionStatus',
    'inspection_status': 'inspectionStatus',
    'status': 'inspectionStatus',
    'vehiclestatus': 'vehicleStatus',
    'vehicle_status': 'vehicleStatus',
    'appointmentsource': 'appointmentSource',
    'appointment_source': 'appointmentSource',
    'source': 'appointmentSource',
    'ncducdname': 'ncdUcdName',
    'ncd_ucd_name': 'ncdUcdName',
    'repname': 'repName',
    'rep_name': 'repName',
    'repcontact': 'repContact',
    'rep_contact': 'repContact',
    'banksource': 'bankSource',
    'bank_source': 'bankSource',
    'referencename': 'referenceName',
    'reference_name': 'referenceName',
    'createdat': 'createdAt',
    'created_at': 'createdAt',
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

// POST bulk import telecalling records
export async function POST(request: NextRequest): Promise<NextResponse> {
  try {
    await dbConnect();
    const { records }: ImportRequestBody = await request.json();
    
    if (!records || !Array.isArray(records) || records.length === 0) {
      return NextResponse.json({ error: 'No records to process' }, { status: 400 });
    }

    console.log(`[Import] Processing ${records.length} records...`);

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
      
      // Store original appointmentId/id as appointmentId field
      if (record.appointmentId || record._id || record.id) {
        doc.appointmentId = String(record.appointmentId || record._id || record.id);
      }
      
      // Remove _id and id to let MongoDB generate ObjectId
      delete doc._id;
      delete doc.id;
      
      // Handle createdAt date parsing
      if (doc.createdAt && typeof doc.createdAt === 'string') {
        const parsedDate = new Date(doc.createdAt as string);
        if (!isNaN(parsedDate.getTime())) {
          doc.createdAt = parsedDate;
        } else {
          delete doc.createdAt;
        }
      }
      
      // Ensure customerName has a value
      if (!doc.customerName) {
        doc.customerName = doc.name || doc.customer || `Record ${index + 1}`;
      }
      
      // Clean up helper fields
      delete doc.name;
      delete doc.customer;
      delete doc.__v;
      
      // Parse yearOfManufacture as number
      if (doc.yearOfManufacture) {
        const year = parseInt(String(doc.yearOfManufacture));
        doc.yearOfManufacture = isNaN(year) ? undefined : year;
      }

      return doc;
    });

    console.log(`[Import] Prepared ${docsToInsert.length} documents for insert`);
    console.log('[Import] Sample document:', JSON.stringify(docsToInsert[0], null, 2));

    // Use insertMany with ordered: false to continue even if some fail
    const result = await Telecalling.insertMany(docsToInsert, { 
      ordered: false,
      rawResult: true 
    });

    console.log(`[Import] Result:`, result);

    return NextResponse.json({ 
      message: 'Import completed successfully',
      inserted: result.insertedCount || docsToInsert.length,
      total: records.length
    });

  } catch (error: unknown) {
    console.error('POST /api/telecalling/import error:', error);
    
    // Handle bulk write errors (some documents may have been inserted)
    if (error && typeof error === 'object' && 'insertedDocs' in error) {
      const bulkError = error as { insertedDocs: unknown[]; message: string };
      return NextResponse.json({ 
        message: 'Import partially completed',
        inserted: bulkError.insertedDocs?.length || 0,
        error: bulkError.message
      });
    }
    
    const errorMessage = error instanceof Error ? error.message : 'Import failed';
    return NextResponse.json({ 
      error: 'Import failed', 
      details: errorMessage 
    }, { status: 500 });
  }
}


