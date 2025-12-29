import { z } from 'zod';

export const telecallingSchema = z.object({
  appointmentId: z.string().optional(),
  emailAddress: z.string().email('Invalid email address').optional().or(z.literal('')),
  appointmentSource: z.string().optional(),
  vehicleStatus: z.string().optional(),
  addressForInspection: z.string().optional(),
  zipCode: z.string().optional(),
  customerName: z.string().min(1, 'Customer Name is required'),
  customerContactNumber: z.string().optional(),
  city: z.string().optional(),
  yearOfManufacture: z.coerce
    .number()
    .min(1900)
    .max(new Date().getFullYear() + 1)
    .optional(),
  make: z.string().optional(),
  vehicleModel: z.string().optional(),
  variant: z.string().optional(),
  odometerReading: z.string().optional(),
  serialNum: z.string().optional(),
  requestedInspectionDate: z.string().optional(),
  requestedInspectionTime: z.string().optional(),
  allocatedTo: z.string().optional(),
  inspectionStatus: z
    .enum(['Scheduled', 'Pending', 'Completed', 'Cancelled'])
    .optional()
    .default('Pending'),
  priority: z.enum(['High', 'Medium', 'Low']).optional().default('Medium'),
  ncdUcdName: z.string().optional(),
  repName: z.string().optional(),
  repContact: z.string().optional(),
  bankSource: z.string().optional(),
  referenceName: z.string().optional(),
  remarks: z.string().optional(),
  createdBy: z.string().optional(),
});

export type TelecallingInput = z.infer<typeof telecallingSchema>;
