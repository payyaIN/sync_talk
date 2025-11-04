// import http from "http";
// import app from "./app";
// import { Server } from "socket.io";
// import connectDB from "./config/db";

// const PORT = process.env.PORT || 8000;

// const server = http.createServer(app);

// export const io = new Server(server, {
//   cors: {
//     origin: process.env.CLIENT_URL || "*",
//     methods: ["GET", "POST"],
//   },
// });

// // Connect MongoDB
// connectDB();

// // Socket Setup (will expand later)
// io.on("connection", (socket) => {
//   console.log("⚡ A user connected:", socket.id);

//   socket.on("disconnect", () => {
//     console.log("❌ User disconnected:", socket.id);
//   });
// });

// server.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));



// import http from 'http';
// import { Server } from 'socket.io';
// import { createApp } from './app.js';
// import { config } from './config/env.js';
// import { connectDB } from './config/db.js';
// import { registerPresence } from './sockets/presence.gateway.js';
// import { registerChat } from './sockets/chat.gateway.js';
// import { registerCall } from './sockets/call.gateway.js';

// async function main() {
//   const app = createApp();
//   const server = http.createServer(app);
//   const io = new Server(server, { cors: { origin: '*' } });
//   (app as any).set('io', io);
//   registerPresence(io); registerChat(io); registerCall(io);
//   await connectDB();
//   server.listen(config.port, () => console.log(`API on http://localhost:${config.port}`));
// }
// main().catch((e)=>{ console.error(e); process.exit(1); });

// import http from 'http';
// import { createApp } from './app.js';
// import { connectDB } from './config/db.js';

// const app = createApp();
// const server = http.createServer(app);
// const PORT = Number(process.env.PORT ?? 4000);

// server.listen(PORT, '0.0.0.0', () => {
//   console.log(`HTTP on http://0.0.0.0:${PORT}`);
// });

// (async () => {
//   try {
//     await connectDB(); // your existing function
//     console.log('Mongo connected ✅');
//   } catch (err) {
//     console.error('Mongo connect failed ❌', err);
//   }
// })();

//claude generated
// import http from 'http';
// import { Server } from 'socket.io'; 
// import { createApp } from './app.js';
// import { config } from './config/env.js';
// import { connectDB } from './config/db.js';
// import { registerPresence } from './sockets/presence.gateway.js';
// import { registerChat } from './sockets/chat.gateway.js';
// import { registerCall } from './sockets/call.gateway.js';

// async function main() {
//   try {
//     const app = createApp();
    
//     const server = http.createServer(app);
    
   
//     const io = new Server(server, {
//       cors: {
//         origin: process.env.CORS_ORIGIN || '*',
//         methods: ['GET', 'POST'],
//         credentials: true
//       },
//       transports: ['websocket', 'polling'], // Support both transports
//       pingTimeout: 60000,  // 60 seconds before considering connection dead
//       pingInterval: 25000  // Ping every 25 seconds
//     });
//     (app as any).set('io', io);
//     console.log('📡 Registering Socket.IO gateways...');
//     registerPresence(io);  // Handles user presence (online/offline)
//     registerChat(io);      // Handles chat messages in real-time
//     registerCall(io);      // Handles video call signaling
//     console.log('✅ Socket.IO gateways registered');
    
//     // Connect to database
//     console.log('🔌 Connecting to MongoDB...');
//     await connectDB();
//     console.log('✅ MongoDB connected');
    
//     // Start server
//     const PORT = Number(process.env.PORT || config.port || 4000);
//     const HOST = process.env.HOST || '0.0.0.0';
    
//     server.listen(PORT, HOST, () => {
//       console.log(`\n🚀 Server is running!`);
//       console.log(`📍 HTTP: http://${HOST}:${PORT}`);
//       console.log(`📍 API Docs: http://${HOST}:${PORT}/api/docs`);
//       console.log(`📍 Health: http://${HOST}:${PORT}/health`);
//       console.log(`🔌 Socket.IO: Enabled`); // ✅ This will now show "Enabled"
//       console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
//       console.log(`\n✨ SyncTalk Backend Ready!\n`);
//     });
// const shutdown = async (signal: string) => {
//       console.log(`\n${signal} received. Shutting down gracefully...`);
      
//       server.close(async () => {
//         console.log('🛑 HTTP server closed');
        
//         try {
//           // Close Socket.IO connections gracefully
//           io.close(() => {
//             console.log('🛑 Socket.IO closed');
//           });
          
//           // Close database connection
//           // await mongoose.connection.close();
//           console.log('🛑 Database connection closed');
          
//           console.log('✅ Graceful shutdown complete');
//           process.exit(0);
//         } catch (error) {
//           console.error('❌ Error during shutdown:', error);
//           process.exit(1);
//         }
//       });

//       // Force shutdown after 10 seconds if graceful shutdown fails
//       setTimeout(() => {
//         console.error('⚠️ Forced shutdown after timeout');
//         process.exit(1);
//       }, 10000);
//     };

//     // Handle shutdown signals
//     process.on('SIGTERM', () => shutdown('SIGTERM'));
//     process.on('SIGINT', () => shutdown('SIGINT'));
//      process.on('uncaughtException', (error) => {
//       console.error('💥 Uncaught Exception:', error);
//       shutdown('UNCAUGHT_EXCEPTION');
//     });
    
//     process.on('unhandledRejection', (reason, promise) => {
//       console.error('💥 Unhandled Rejection at:', promise, 'reason:', reason);
//       shutdown('UNHANDLED_REJECTION');
//     });

//   } catch (error) {
//     console.error('❌ Failed to start server:', error);
//     process.exit(1);
//   }
// }
// main();



import http from "http";
// import app from "./app";
import { Server } from "socket.io";
// import connectDB from "./config/db";
import { User } from "./modules/users/user.model";
import { createApp } from "./app";
import { connectDB } from "./config/db";

const app = createApp();
const PORT = process.env.PORT || 8000;

const server = http.createServer(app);

export const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || "*",
    methods: ["GET", "POST"],
  },
});

// Track online users
const onlineUsers = new Map<string, string>();

connectDB();

// Socket Events
io.on("connection", (socket) => {

  socket.on("user_online", async (userId: string) => {
    onlineUsers.set(userId, socket.id);
    io.emit("presence_update", {
      userId,
      isOnline: true,
      lastSeen: null,
    });
  });

  // Emit events to admin namespace
io.of('/admin').on('connection', (socket) => {
  console.log('Admin connected:', socket.id);
  
  // Send real-time stats every 10 seconds
  const interval = setInterval(() => {
    socket.emit('stats:update', {
      activeUsers: onlineUsers.size,
      timestamp: new Date(),
    });
  }, 10000);
  
  socket.on('disconnect', () => {
    clearInterval(interval);
  });
});

  socket.on("disconnect", async () => {
    const userId = [...onlineUsers.entries()].find(([_, id]) => id === socket.id)?.[0];
    if (userId) {
      onlineUsers.delete(userId);
      await User.findByIdAndUpdate(userId, { lastSeen: new Date() });
      io.emit("presence_update", {
        userId,
        isOnline: false,
        lastSeen: new Date(),
      });
    }
  });

  socket.on("typing", (roomId) => {
    socket.to(roomId).emit("typing", roomId);
  });

  socket.on("stop_typing", (roomId) => {
    socket.to(roomId).emit("stop_typing", roomId);
  });

  socket.on("join_room", (roomId) => {
    socket.join(roomId);
  });

  socket.on("send_message", (data) => {
    io.to(data.roomId).emit("receive_message", {
      ...data,
      createdAt: new Date(),
    });
  });
  
});

server.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));
