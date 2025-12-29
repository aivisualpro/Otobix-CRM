import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IDropdown extends Document {
  description: string;
  type: string;
  icon?: string; // URL to uploaded image
  color?: string; // Hex color code
  isActive: boolean;
  sortOrder: number;
  createdAt: Date;
  updatedAt: Date;
}

const DropdownSchema = new Schema<IDropdown>(
  {
    description: { type: String, required: true, trim: true },
    type: { type: String, required: true, trim: true },
    icon: { type: String },
    color: { type: String },
    isActive: { type: Boolean, default: true },
    sortOrder: { type: Number, default: 0 },
  },
  {
    timestamps: true,
  }
);

// Index for faster queries by type
DropdownSchema.index({ type: 1, sortOrder: 1 });

// Clear cached models
if (mongoose.models.Dropdown) {
  delete mongoose.models.Dropdown;
}

const Dropdown: Model<IDropdown> = mongoose.model<IDropdown>('Dropdown', DropdownSchema);

export default Dropdown;
