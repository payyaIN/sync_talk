
import mongoose, { Schema, Document } from 'mongoose';
export interface IUser extends Document {
  email: string; passwordHash?: string; displayName: string; avatarUrl?: string; role: 'user'|'admin'|'moderator'; banned: boolean; createdAt: Date; updatedAt: Date;
}
const UserSchema = new Schema<IUser>({
  email: { type: String, unique: true, required: true },
  passwordHash: { type: String },
  displayName: { type: String, required: true },
  avatarUrl: { type: String },
  role: { type: String, default: 'user' },
  banned: { type: Boolean, default: false }
}, { timestamps: true });
export const User = mongoose.model<IUser>('User', UserSchema);
