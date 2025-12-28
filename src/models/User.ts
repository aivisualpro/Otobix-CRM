import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IUser extends Document {
  userRole: string;
  phoneNumber?: string;
  location?: string;
  userName: string;
  email: string;
  image?: string;
  secondaryContactPerson?: string;
  secondaryContactNumber?: string;
  password?: string;
  addressList?: string[];
  approvalStatus?: string;
  rejectionComment?: string;
  wishlist?: any[];
  myBids?: any[];
  assignedKam?: string;
  permissions?: string[];
  allowedCities?: string[];
  isStaff?: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>({
  userRole: { type: String, default: 'User' },
  phoneNumber: { type: String, trim: true },
  location: { type: String, trim: true },
  userName: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, trim: true, lowercase: true },
  image: { type: String },
  secondaryContactPerson: { type: String },
  secondaryContactNumber: { type: String },
  password: { type: String },
  addressList: { type: [String], default: [] },
  allowedCities: { type: [String], default: [] },
  approvalStatus: { type: String, default: 'Pending' },
  rejectionComment: { type: String },
  wishlist: { type: [], default: [] },
  myBids: { type: [], default: [] },
  assignedKam: { type: String },
  permissions: { type: [String], default: [] },
  isStaff: { type: Boolean, default: false }
}, {
  timestamps: true
});

// Delete cached model
if (mongoose.models.Users) {
  // Try to delete specific 'Users' model if it exists, though usually it's singular
  delete mongoose.models.Users;
}
if (mongoose.models.User) {
  delete mongoose.models.User;
}

// Important: Mongoose often pluralizes 'User' to 'users'. 
// Since you have an existing collection 'users', explicit collection name is safer 
// or relying on mongoose default pluralization. 
// Assuming default 'users' is correct.

const User: Model<IUser> = mongoose.model<IUser>('User', UserSchema);

export default User;
