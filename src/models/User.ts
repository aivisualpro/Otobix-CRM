import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IUser extends Document {
  userRole: string;
  phoneNumber?: string;
  location?: string;
  userName: string;
  email: string;
  dealershipName?: string;
  image?: string;
  entityType?: string;
  primaryContactPerson?: string;
  primaryContactNumber?: string;
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

const UserSchema = new Schema<IUser>(
  {
    userRole: { type: String, default: 'User' },
    phoneNumber: { type: String, trim: true },
    location: { type: String, trim: true },
    userName: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, trim: true, lowercase: true },
    dealershipName: { type: String, trim: true },
    image: { type: String },
    entityType: { type: String, trim: true },
    primaryContactPerson: { type: String, trim: true },
    primaryContactNumber: { type: String, trim: true },
    secondaryContactPerson: { type: String, trim: true },
    secondaryContactNumber: { type: String, trim: true },
    password: { type: String },
    addressList: { type: [String], default: [] },
    allowedCities: { type: [String], default: [] },
    approvalStatus: { type: String, default: 'Pending' },
    rejectionComment: { type: String },
    wishlist: { type: [], default: [] },
    myBids: { type: [], default: [] },
    assignedKam: { type: String },
    permissions: { type: [String], default: [] },
    isStaff: { type: Boolean, default: false },
  },
  {
    timestamps: true,
  }
);

// Delete cached model
if (mongoose.models.Users) {
  delete mongoose.models.Users;
}
if (mongoose.models.User) {
  delete mongoose.models.User;
}

const User: Model<IUser> = mongoose.model<IUser>('User', UserSchema);

export default User;
