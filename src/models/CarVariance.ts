import mongoose, { Schema, Document, Model } from 'mongoose';

export interface ICarVariance extends Document {
  make: string;
  carModel: string;
  variant: string;
  price: number;
  createdAt: Date;
  updatedAt: Date;
}

const CarVarianceSchema = new Schema<ICarVariance>(
  {
    make: { type: String, required: true, trim: true },
    carModel: { type: String, required: true, trim: true },
    variant: { type: String, required: true, trim: true },
    price: { type: Number, required: true, default: 0 },
  },
  {
    timestamps: true,
  }
);

// Index for faster lookups
CarVarianceSchema.index({ make: 1, carModel: 1, variant: 1 });

// Clear cached models
if (mongoose.models.CarVariance) {
  delete mongoose.models.CarVariance;
}

const CarVariance: Model<ICarVariance> = mongoose.model<ICarVariance>('CarVariance', CarVarianceSchema, 'carMakeModelVariant');

export default CarVariance;
