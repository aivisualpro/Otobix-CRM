import mongoose, { Schema, Document, Model, Types } from 'mongoose';

export interface ITelecalling extends Omit<Document, 'model'> {
  _id: Types.ObjectId;
  appointmentId?: string;
  carRegistrationNumber: string;
  yearOfRegistration: string;
  ownerName: string;
  ownershipSerialNumber: number;
  make: string;
  model: string;
  variant: string;
  timeStamp: Date;
  emailAddress?: string;
  appointmentSource?: string;
  vehicleStatus?: string;
  zipCode?: string;
  customerContactNumber?: string;
  city?: string;
  yearOfManufacture?: string;
  allocatedTo?: string;
  inspectionStatus?: string;
  approvalStatus?: string;
  priority?: string;
  ncdUcdName?: string;
  repName?: string;
  repContact?: string;
  bankSource?: string;
  referenceName?: string;
  remarks?: string;
  createdBy?: string;
  odometerReadingInKms?: number;
  additionalNotes?: string;
  carImages: string[];
  inspectionDateTime?: Date;
  inspectionAddress?: string;
  inspectionEngineerNumber?: string;
  addedBy: 'Customer' | 'Telecaller';
  createdAt: Date;
  updatedAt: Date;
}

const TelecallingSchema = new Schema<ITelecalling>(
  {
    appointmentId: {
      type: String,
      trim: true,
      index: true,
      unique: true,
    },
    carRegistrationNumber: { type: String, required: true, trim: true },
    yearOfRegistration: { type: String, required: true, trim: true },
    ownerName: { type: String, required: true, trim: true },
    ownershipSerialNumber: { type: Number, required: true },
    make: { type: String, required: true, trim: true },
    model: { type: String, required: true, trim: true },
    variant: { type: String, required: true, trim: true },
    timeStamp: { type: Date, default: () => new Date() },
    emailAddress: { type: String, trim: true, lowercase: true, default: "" },
    appointmentSource: { type: String, trim: true, default: "" },
    vehicleStatus: { type: String, trim: true, default: "" },
    zipCode: { type: String, trim: true, default: "" },
    customerContactNumber: { type: String, trim: true, default: "" },
    city: { type: String, trim: true, default: "" },
    yearOfManufacture: { type: String, trim: true, default: "" },
    allocatedTo: { type: String, trim: true, default: "" },
    inspectionStatus: { type: String, trim: true, default: "Pending" },
    approvalStatus: { type: String, trim: true, default: "Pending" },
    priority: { type: String, trim: true, default: "Medium" },
    ncdUcdName: { type: String, trim: true, default: "" },
    repName: { type: String, trim: true, default: "" },
    repContact: { type: String, trim: true, default: "" },
    bankSource: { type: String, trim: true, default: "" },
    referenceName: { type: String, trim: true, default: "" },
    remarks: { type: String, trim: true, default: "" },
    createdBy: { type: String, trim: true, default: "" },
    odometerReadingInKms: { type: Number, default: null },
    additionalNotes: { type: String, trim: true, default: "" },
    carImages: { type: [String], default: [] },
    inspectionDateTime: { type: Date, default: null },
    inspectionAddress: { type: String, trim: true, default: "" },
    inspectionEngineerNumber: { type: String, trim: true, default: "" },
    addedBy: {
      type: String,
      enum: ["Customer", "Telecaller"],
      trim: true,
      default: "Telecaller",
    },
  },
  {
    timestamps: true,
    strict: true,
  }
);

TelecallingSchema.set('toJSON', { virtuals: true });
TelecallingSchema.set('toObject', { virtuals: true });

// Delete cached model to handle schema changes in development
if (mongoose.models.Telecalling) {
  delete mongoose.models.Telecalling;
}

const Telecalling: Model<ITelecalling> = mongoose.model<ITelecalling>(
  'Telecalling',
  TelecallingSchema
);

export default Telecalling;
