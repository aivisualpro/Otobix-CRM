import mongoose, { Schema, Document, Model } from 'mongoose';

export interface ISettings extends Document {
  key: string;
  value: any;
  category: string;
  label: string;
  description?: string;
  type: 'text' | 'number' | 'boolean' | 'select' | 'json' | 'date';
  options?: string[]; // For select type
  createdAt: Date;
  updatedAt: Date;
}

const SettingsSchema = new Schema<ISettings>(
  {
    key: { type: String, required: true, unique: true, trim: true },
    value: { type: Schema.Types.Mixed, required: true },
    category: { type: String, required: true, default: 'General' },
    label: { type: String, required: true },
    description: { type: String },
    type: {
      type: String,
      enum: ['text', 'number', 'boolean', 'select', 'json', 'date'],
      default: 'text',
    },
    options: { type: [String], default: [] },
  },
  {
    timestamps: true,
  }
);

// Clear cached models
if (mongoose.models.Settings) {
  delete mongoose.models.Settings;
}

const Settings: Model<ISettings> = mongoose.model<ISettings>('Settings', SettingsSchema);

export default Settings;
