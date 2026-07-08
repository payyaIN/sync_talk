
import mongoose from 'mongoose';
import { config } from './env.js';
export async function connectDB() {
    try {
        await mongoose.connect(config.mongoUri, { family: 4 } as mongoose.ConnectOptions);
        console.log('Mongo connected');
    } catch (e) {
        console.error('Mongo Connection Error:', e);
        process.exit(1);
    }
}
