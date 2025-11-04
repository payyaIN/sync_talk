// import mongoose, { Schema, Document } from "mongoose";
import mongoose, { Schema, Document, Types } from "mongoose";

export interface IBlocked extends Document {
  blocker: Types.ObjectId;
  blocked: Types.ObjectId;
}

const BlockSchema = new Schema<IBlocked>(
  {
    blocker: { type: Schema.Types.ObjectId, ref: "User", required: true },
    blocked: { type: Schema.Types.ObjectId, ref: "User", required: true }
  },
  { timestamps: true }
);

export const Block = mongoose.model<IBlocked>("Block", BlockSchema);
