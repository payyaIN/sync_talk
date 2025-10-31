import mongoose, { Schema, Document } from "mongoose";

export interface IUser extends Document {
  name: string;
  email: string;
  password: string;
  avatar?: string;
}

const userSchema: Schema<IUser> = new Schema(
  {
    name: { type: String, required: true },
    email: { type: String, unique: true, required: true },
    password: { type: String, required: true },
    avatar: { type: String, default: "" }
  },
  { timestamps: true }
);

export const User = mongoose.model<IUser>("User", userSchema);


// {
//   _id: string,
//   name: string,
//   email: string,
//   password: string,
//   avatar: string,
//   lastSeen: Date,
//   createdAt: Date,
//   updatedAt: Date
// }
