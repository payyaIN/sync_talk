import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_env.dart';

class CallSocketService extends ChangeNotifier {
  static IO.Socket? _socket;

  static String get _socketUrl => '${AppEnv.socketUrl}/call';

  static IO.Socket connect() {
    if (_socket != null && _socket!.connected) return _socket!;

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder() //////
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Call Socket Connected: ${_socket!.id}');
    });

    _socket!.onConnectError((data) => print('❌ Call Socket Error: $data'));

    _socket!.connect();
    return _socket!;
  }

  static void disconnect() {
    _socket?.disconnect();
  }

  static void joinCall(String roomId) {
    _socket?.emit('join_call', roomId);
  }

  static void sendOffer(String roomId, dynamic sdp, String senderId) {
    _socket?.emit('offer', {
      'roomId': roomId,
      'sdp': sdp,
      'senderId': senderId,
    });
  }

  static void sendAnswer(String roomId, dynamic sdp, String senderId) {
    _socket?.emit('answer', {
      'roomId': roomId,
      'sdp': sdp,
      'senderId': senderId,
    });
  }

  static void sendIceCandidate(
    String roomId,
    dynamic candidate,
    String senderId,
  ) {
    _socket?.emit('ice_candidate', {
      'roomId': roomId,
      'candidate': candidate,
      'senderId': senderId,
    });
  }

  static void onOffer(void Function(dynamic) cb) {
    _socket?.on('offer', cb);
  }

  static void onAnswer(void Function(dynamic) cb) {
    _socket?.on('answer', cb);
  }

  static void onIceCandidate(void Function(dynamic) cb) {
    _socket?.on('ice_candidate', cb);
  }
}
