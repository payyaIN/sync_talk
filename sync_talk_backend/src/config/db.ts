// import mongoose from "mongoose";

// const connectDB = async () => {
//   try {
//     const conn = await mongoose.connect(process.env.MONGO_URI!);
//     console.log(`✅ MongoDB connected: ${conn.connection.host}`);
//   } catch (error) {
//     console.error("❌ MongoDB connection failed", error);
//     process.exit(1);
//   }
// };

// export default connectDB;


import mongoose from 'mongoose';
import { config } from './env.js';
export async function connectDB(){ await mongoose.connect(config.mongoUri); console.log('Mongo connected'); }
