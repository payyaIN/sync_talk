import http from 'http';
import { Server } from 'socket.io';
import { createApp } from './app';
import { config } from './config/env';
import { connectDB } from './config/db';
// We will implement these socket gateways next
import { registerChat } from './sockets/chat.socket';
import { registerCall } from './sockets/call.socket';
import { registerPresence } from './sockets/presence.gateway';

async function main() {
  try {
    const app = createApp();

    const server = http.createServer(app);

    // Improved Socket.IO setup with CORS and Transports
    const io = new Server(server, {
      cors: {
        origin: process.env.CLIENT_URL || '*', // Allow all for now, restrict in prod
        methods: ['GET', 'POST'],
        credentials: true
      },
      transports: ['websocket', 'polling'],
      pingTimeout: 60000,
    });

    // Attach io to app for use in controllers if needed
    (app as any).set('io', io);

    console.log('📡 Registering Socket.IO gateways...');
    registerChat(io);
    registerCall(io);
    registerPresence(io);
    console.log('✅ Socket.IO gateways registered');

    // Connect to database
    console.log('🔌 Connecting to MongoDB...');
    await connectDB();
    console.log('✅ MongoDB connected');

    // Start server
    const PORT = Number(process.env.PORT || 8000);
    const HOST = '0.0.0.0';

    // Gracefully handle port-in-use errors instead of crashing with an unhandled event
    server.on('error', (err: NodeJS.ErrnoException) => {
      if (err.code === 'EADDRINUSE') {
        console.error(`\n❌ Port ${PORT} is already in use.`);
        console.error(`   Run this to free it:`);
        console.error(`   (Get-NetTCPConnection -LocalPort ${PORT}).OwningProcess | ForEach-Object { Stop-Process -Id $_ -Force }`);
        process.exit(1);
      } else {
        throw err;
      }
    });

    server.listen(PORT, HOST, () => {
      console.log(`\n🚀 Server is running!`);
      console.log(`📍 HTTP: http://${HOST}:${PORT}`);
      console.log(`🔌 Socket.IO: Enabled`);
    });

    const shutdown = async (signal: string) => {
      console.log(`\n${signal} received. Shutting down gracefully...`);
      server.close(() => {
        console.log('🛑 HTTP server closed');
        io.close(() => console.log('🛑 Socket.IO closed'));
        process.exit(0);
      });
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

main();
