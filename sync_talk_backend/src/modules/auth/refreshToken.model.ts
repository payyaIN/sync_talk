
import mongoose, { Schema, Document, Types } from 'mongoose';
export interface IRefreshToken extends Document { user: Types.ObjectId; token: string; expiresAt: Date; }
const RefreshTokenSchema = new Schema<IRefreshToken>({
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  token: { type: String, required: true, unique: true },
  expiresAt: { type: Date, required: true }
}, { timestamps: true });
export const RefreshToken = mongoose.model<IRefreshToken>('RefreshToken', RefreshTokenSchema);
