import mongoose, { Schema, Document } from 'mongoose';

export interface IAiMessage extends Document {
  userId: mongoose.Types.ObjectId;
  sender: 'me' | 'ai';
  message: string;
  createdAt: Date;
  updatedAt: Date;
}

const AiMessageSchema = new Schema<IAiMessage>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  sender: { type: String, enum: ['me', 'ai'], required: true },
  message: { type: String, required: true },
}, { timestamps: true });

export const AiMessage = mongoose.model<IAiMessage>('AiMessage', AiMessageSchema);
