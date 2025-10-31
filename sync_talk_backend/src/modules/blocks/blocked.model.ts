import mongoose, { Schema, Document } from "mongoose";

export interface IBlocked extends Document {
  blocker: string;
  blocked: string;
}

const BlockSchema = new Schema<IBlocked>(
  {
    blocker: { type: Schema.Types.ObjectId, ref: "User", required: true },
    blocked: { type: Schema.Types.ObjectId, ref: "User", required: true }
  },
  { timestamps: true }
);

export const Block = mongoose.model<IBlocked>("Block", BlockSchema);
