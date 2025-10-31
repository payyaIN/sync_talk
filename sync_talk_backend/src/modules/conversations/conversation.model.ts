
// import mongoose, { Schema, Document, Types } from 'mongoose';
// export interface IConversation extends Document {
//   participants: Types.ObjectId[]; title?: string; isGroup: boolean; lastMessageAt?: Date; createdAt: Date; updatedAt: Date;
// }
// const ConversationSchema = new Schema<IConversation>({
//   participants: [{ type: Schema.Types.ObjectId, ref: 'User', required: true }],
//   title: { type: String }, isGroup: { type: Boolean, default: false }, lastMessageAt: { type: Date }
// }, { timestamps: true });
// export const Conversation = mongoose.model<IConversation>('Conversation', ConversationSchema);


import mongoose, { Schema, Document } from "mongoose";

export interface IConversation extends Document {
  participants: mongoose.Types.ObjectId[];
  isGroup: boolean;
  groupName?: string;
  groupImage?: string;
  admins?: mongoose.Types.ObjectId[];
  lastMessage?: string;
}

const ConversationSchema = new Schema<IConversation>(
  {
    participants: [{ type: Schema.Types.ObjectId, ref: "User" }],
    isGroup: { type: Boolean, default: false },
    groupName: { type: String },
    groupImage: { type: String, default: "" },
    admins: [{ type: Schema.Types.ObjectId, ref: "User" }],
    lastMessage: { type: String, default: "" }
  },
  { timestamps: true }
);

export const Conversation = mongoose.model<IConversation>(
  "Conversation",
  ConversationSchema
);
