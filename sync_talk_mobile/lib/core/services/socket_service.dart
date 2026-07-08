import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'session.dart';
import '../config/app_env.dart';

class SocketService extends ChangeNotifier {
  static IO.Socket? _socket;

  static String get _socketUrl => '${AppEnv.socketUrl}/chat';

  static IO.Socket connect(String userId) {
    if (_socket != null && _socket!.connected) return _socket!;

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket Connected: ${_socket!.id}');
      // _socket!.emit('user_online', userId); // Backend might need to listen to this on /chat or remove if using connection event
    });

    _socket!.onConnectError((data) => print('❌ Socket Error: $data'));

    _socket!.connect();
    return _socket!;
  }

  static void disconnect(String userId) {
    _socket?.disconnect();
  }

  static void join(String roomId) {
    _socket?.emit('join_room', roomId);
  }

  static void send(
    String roomId,
    String text,
    String senderId, {
    String? forwardOf,
    List<String> attachments = const [],
  }) {
    // Backend expects: { roomId, content, senderId, attachments }
    _socket?.emit('send_message', {
      'roomId': roomId,
      'content': text, // Changed from 'message' to 'content' to match backend
      'senderId': senderId,
      'forwardOf': forwardOf,
      'attachments': attachments,
    });
  }

  static void onMessage(void Function(dynamic) cb) {
    _socket?.on('receive_message', cb);
  }

  static void typing(String roomId) {
    _socket?.emit('typing', roomId);
  }

  static void stopTyping(String roomId) {
    _socket?.emit('stop_typing', roomId);
  }

  static void onPresence(void Function(dynamic) cb) {
    _socket?.on('presence_update', cb);
  }
}
