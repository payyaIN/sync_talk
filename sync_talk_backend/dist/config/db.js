"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.connectDB = connectDB;
const mongoose_1 = __importDefault(require("mongoose"));
const env_js_1 = require("./env.js");
async function connectDB() {
    try {
        await mongoose_1.default.connect(env_js_1.config.mongoUri, { family: 4 });
        console.log('Mongo connected');
    }
    catch (e) {
        console.error('Mongo Connection Error:', e);
        process.exit(1);
    }
}
