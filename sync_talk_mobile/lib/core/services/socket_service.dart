// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../config/app_env.dart';
// import '../utils/token_store.dart';

// class SocketService {
//   static IO.Socket? socket;

//   static Future<void> connect() async {
//     final token = await TokenStore.read();
//     socket = IO.io(AppEnv.socketUrl,
//         IO.OptionBuilder()
//             .setTransports(['websocket'])
//             .setAuth({'token': token})
//             .disableAutoConnect()
//             .build(),
//     );
//     socket!.connect();
//   }

//   static void joinRoom(String roomId) {
//     socket?.emit("join_room", roomId);
//   }

//   static void sendMessage(String roomId, String message) {
//     socket?.emit("send_message", {"roomId": roomId, "message": message});
//   }

//   static void onMessage(Function(dynamic) handler) {
//     socket?.on("receive_message", handler);
//   }
// }

// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../config/app_env.dart';

// class SocketService {
//   static IO.Socket? _socket;

//   static IO.Socket connect(String userId) {
//     _socket ??= IO.io(AppEnv.socketUrl, {
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     _socket!.onConnect((_) {
//       _socket!.emit("hello", userId);
//     });

//     return _socket!;
//   }

//   static void join(String roomId) {
//     _socket?.emit('join_room', roomId);
//   }

//   static void send(String roomId, String text, {String? forwardOf}) {
//     _socket?.emit('send_message', {
//       'roomId': roomId,
//       'message': text,
//       'forwardOf': forwardOf,
//     });
//   }

//   static void seen(String roomId) {
//     _socket?.emit('seen_messages', roomId);
//   }

//   static void typing(String roomId) {
//     _socket?.emit('typing', roomId);
//   }

//   static void stopTyping(String roomId) {
//     _socket?.emit('stop_typing', roomId);
//   }

//   static void onMessage(void Function(dynamic) cb) {
//     _socket?.on('receive_message', cb);
//   }

//   static void onStatus(void Function(dynamic) cb) {
//     _socket?.on('message_status_update', cb);
//   }

//   static void onSeen(void Function(dynamic) cb) {
//     _socket?.on('messages_seen', cb);
//   }

//   static void onTyping(void Function(dynamic) cb) {
//     _socket?.on('typing', cb);
//   }

//   static void onStopTyping(void Function(dynamic) cb) {
//     _socket?.on('stop_typing', cb);
//   }
// }

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sync_talk_mobile/core/config/app_env.dart';

class SocketService {
  static IO.Socket? _socket;

  static IO.Socket connect(String userId) {
    _socket ??= IO.io(AppEnv.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      _socket!.emit('user_online', userId);
    });

    return _socket!;
  }

  static void disconnect(String userId) {
    _socket?.emit('user_offline', userId);
    _socket?.disconnect();
  }

  static void join(String roomId) {
    _socket?.emit('join_room', roomId);
  }

  static void send(String roomId, String text, {String? forwardOf}) {
    _socket?.emit('send_message', {
      'roomId': roomId,
      'message': text,
      'forwardOf': forwardOf,
    });
  }

  static void seen(String roomId) {
    _socket?.emit('seen_messages', roomId);
  }

  static void typing(String roomId) {
    _socket?.emit('typing', roomId);
  }

  static void stopTyping(String roomId) {
    _socket?.emit('stop_typing', roomId);
  }

  static void onMessage(void Function(dynamic) cb) {
    _socket?.on('receive_message', cb);
  }

  static void onStatus(void Function(dynamic) cb) {
    _socket?.on('message_status_update', cb);
  }

  static void onSeen(void Function(dynamic) cb) {
    _socket?.on('messages_seen', cb);
  }

  static void onTyping(void Function(dynamic) cb) {
    _socket?.on('typing', cb);
  }

  static void onStopTyping(void Function(dynamic) cb) {
    _socket?.on('stop_typing', cb);
  }

  static void onPresence(void Function(dynamic) cb) {
    _socket?.on('presence_update', cb);
  }
}
