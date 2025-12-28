import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IReusableId extends Omit<Document, '_id'> {
  _id: string; // The appointmentId, e.g., "25-10000005"
  year: number; // 2025
}

const ReusableIdSchema = new Schema<IReusableId>({
  _id: { type: String, required: true },
  year: { type: Number, required: true, index: true }
});

// Delete cached model
if (mongoose.models.ReusableId) {
  delete mongoose.models.ReusableId;
}

const ReusableId: Model<IReusableId> = mongoose.model<IReusableId>('ReusableId', ReusableIdSchema);

export default ReusableId;
