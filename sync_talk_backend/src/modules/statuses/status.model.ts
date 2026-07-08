import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IStatus extends Document {
  user: Types.ObjectId;
  mediaUrl: string;
  caption?: string;
  createdAt: Date;
}

const StatusSchema: Schema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  mediaUrl: { type: String, required: true },
  caption: { type: String },
  createdAt: { type: Date, default: Date.now, expires: 86400 } // 24 hours
});

export const Status = mongoose.model<IStatus>('Status', StatusSchema);
