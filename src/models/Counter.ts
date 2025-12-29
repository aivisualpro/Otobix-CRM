import mongoose, { Schema, Document, Model } from 'mongoose';

export interface ICounter extends Omit<Document, '_id'> {
  _id: string;
  seq: number;
}

const CounterSchema = new Schema<ICounter>({
  _id: { type: String, required: true },
  seq: { type: Number, default: 10000001 },
});

// Delete cached model to handle schema changes in development
if (mongoose.models.Counter) {
  delete mongoose.models.Counter;
}

const Counter: Model<ICounter> = mongoose.model<ICounter>('Counter', CounterSchema);

export default Counter;
