import mongoose, { Schema, Document, Types } from 'mongoose';

export interface ICall extends Document {
  caller: Types.ObjectId;
  receiver: Types.ObjectId;
  isVideo: boolean;
  isMissed: boolean;
  duration?: number; // seconds
  createdAt: Date;
}

const CallSchema: Schema = new Schema({
  caller: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  receiver: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  isVideo: { type: Boolean, default: false },
  isMissed: { type: Boolean, default: false },
  duration: { type: Number },
  createdAt: { type: Date, default: Date.now }
});

export const Call = mongoose.model<ICall>('Call', CallSchema);
