
import mongoose, { Schema, Document, Types } from 'mongoose';
export interface IMessage extends Document {
  conversation: Types.ObjectId; sender: Types.ObjectId; content: string; attachments: string[]; readBy: Types.ObjectId[]; parentMessage?: Types.ObjectId; createdAt: Date; updatedAt: Date;
}
const MessageSchema = new Schema<IMessage>({
  conversation: { type: Schema.Types.ObjectId, ref: 'Conversation', required: true },
  sender: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String, default: '' },
  attachments: [{ type: String }],
  readBy: [{ type: Schema.Types.ObjectId, ref: 'User' }],
  parentMessage: { type: Schema.Types.ObjectId, ref: 'Message' }
}, { timestamps: true });
export const Message = mongoose.model<IMessage>('Message', MessageSchema);
