"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const http_1 = __importDefault(require("http"));
const socket_io_1 = require("socket.io");
const app_1 = require("./app");
const db_1 = require("./config/db");
// We will implement these socket gateways next
const chat_socket_1 = require("./sockets/chat.socket");
const call_socket_1 = require("./sockets/call.socket");
const presence_gateway_1 = require("./sockets/presence.gateway");
async function main() {
    try {
        const app = (0, app_1.createApp)();
        const server = http_1.default.createServer(app);
        // Improved Socket.IO setup with CORS and Transports
        const io = new socket_io_1.Server(server, {
            cors: {
                origin: process.env.CLIENT_URL || '*', // Allow all for now, restrict in prod
                methods: ['GET', 'POST'],
                credentials: true
            },
            transports: ['websocket', 'polling'],
            pingTimeout: 60000,
        });
        // Attach io to app for use in controllers if needed
        app.set('io', io);
        console.log('📡 Registering Socket.IO gateways...');
        (0, chat_socket_1.registerChat)(io);
        (0, call_socket_1.registerCall)(io);
        (0, presence_gateway_1.registerPresence)(io);
        console.log('✅ Socket.IO gateways registered');
        // Connect to database
        console.log('🔌 Connecting to MongoDB...');
        await (0, db_1.connectDB)();
        console.log('✅ MongoDB connected');
        // Start server
        const PORT = Number(process.env.PORT || 8000);
        const HOST = '0.0.0.0';
        server.listen(PORT, HOST, () => {
            console.log(`\n🚀 Server is running!`);
            console.log(`📍 HTTP: http://${HOST}:${PORT}`);
            console.log(`🔌 Socket.IO: Enabled`);
        });
        const shutdown = async (signal) => {
            console.log(`\n${signal} received. Shutting down gracefully...`);
            server.close(() => {
                console.log('🛑 HTTP server closed');
                io.close(() => console.log('🛑 Socket.IO closed'));
                process.exit(0);
            });
        };
        process.on('SIGTERM', () => shutdown('SIGTERM'));
        process.on('SIGINT', () => shutdown('SIGINT'));
    }
    catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
}
main();
