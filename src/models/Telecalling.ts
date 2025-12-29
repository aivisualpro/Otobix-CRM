import mongoose, { Schema, Document, Model, Types } from 'mongoose';

export interface ITelecalling extends Document {
  _id: Types.ObjectId;
  appointmentId?: string;
  timeStamp: Date;
  emailAddress?: string;
  appointmentSource?: string;
  vehicleStatus?: string;
  addressForInspection?: string;
  zipCode?: string;
  customerName: string;
  customerContactNumber?: string;
  city?: string;
  yearOfManufacture?: number;
  make?: string;
  vehicleModel?: string;
  variant?: string;
  odometerReading?: string;
  serialNum?: string;
  requestedInspectionDate?: string;
  requestedInspectionTime?: string;
  allocatedTo?: string;
  inspectionStatus?: string;
  priority?: string;
  ncdUcdName?: string;
  repName?: string;
  repContact?: string;
  bankSource?: string;
  referenceName?: string;
  remarks?: string;
  createdBy?: string;
  createdAt: Date;
  updatedAt: Date;
}

const TelecallingSchema = new Schema<ITelecalling>(
  {
    appointmentId: { type: String, trim: true, index: true, sparse: true },
    timeStamp: { type: Date, default: Date.now },
    emailAddress: { type: String, trim: true, lowercase: true },
    appointmentSource: { type: String, trim: true },
    vehicleStatus: { type: String, trim: true },
    addressForInspection: { type: String, trim: true },
    zipCode: { type: String, trim: true },
    customerName: { type: String, trim: true },
    customerContactNumber: { type: String, trim: true },
    city: { type: String, trim: true },
    yearOfManufacture: { type: Number },
    make: { type: String, trim: true },
    vehicleModel: { type: String, trim: true },
    variant: { type: String, trim: true },
    odometerReading: { type: String, trim: true },
    serialNum: { type: String, trim: true },
    requestedInspectionDate: { type: String, trim: true },
    requestedInspectionTime: { type: String, trim: true },
    allocatedTo: { type: String, trim: true },
    inspectionStatus: { type: String, trim: true, default: 'Pending' },
    priority: { type: String, trim: true, default: 'Medium' },
    ncdUcdName: { type: String, trim: true },
    repName: { type: String, trim: true },
    repContact: { type: String, trim: true },
    bankSource: { type: String, trim: true },
    referenceName: { type: String, trim: true },
    remarks: { type: String, trim: true },
    createdBy: { type: String, trim: true },
  },
  {
    timestamps: true,
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
