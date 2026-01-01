import { z } from 'zod';

export const telecallingSchema = z.object({
  appointmentId: z.string().optional(),
  carRegistrationNumber: z.string().min(1, 'Car Registration Number is required'),
  yearOfRegistration: z.string().min(1, 'Year of Registration is required'),
  ownerName: z.string().min(1, 'Owner Name is required'),
  ownershipSerialNumber: z.coerce.number().min(1, 'Ownership Serial Number is required'),
  make: z.string().min(1, 'Make is required'),
  model: z.string().min(1, 'Model is required'),
  variant: z.string().min(1, 'Variant is required'),
  
  timeStamp: z.date().optional(),
  emailAddress: z.string().email('Invalid email address').optional().or(z.literal('')),
  appointmentSource: z.string().optional(),
  vehicleStatus: z.string().optional(),
  zipCode: z.string().optional(),
  customerContactNumber: z.string().optional(),
  city: z.string().optional(),
  yearOfManufacture: z.string().optional(),
  allocatedTo: z.string().optional(),
  inspectionStatus: z.string().optional().default('Pending'),
  approvalStatus: z.string().optional().default('Pending'),
  priority: z.string().optional().default('Medium'),
  ncdUcdName: z.string().optional(),
  repName: z.string().optional(),
  repContact: z.string().optional(),
  bankSource: z.string().optional(),
  referenceName: z.string().optional(),
  remarks: z.string().optional(),
  createdBy: z.string().optional(),
  
  odometerReadingInKms: z.coerce.number().optional().nullable(),
  additionalNotes: z.string().optional(),
  carImages: z.array(z.string()).optional().default([]),
  inspectionDateTime: z.string().optional().nullable().or(z.date()),
  inspectionAddress: z.string().optional(),
  inspectionEngineerNumber: z.string().optional(),
  addedBy: z.enum(['Customer', 'Telecaller']).optional().default('Telecaller'),
});

export type TelecallingInput = z.infer<typeof telecallingSchema>;
