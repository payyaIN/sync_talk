import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'session.dart';
import 'dart:async';

class Sockets {
  IO.Socket? presence;
  final _online = <String>{};
  final _onlineCtrl = StreamController<Set<String>>.broadcast();
  Stream<Set<String>> get onlineStream => _onlineCtrl.stream;
  IO.Socket? chat;

  void connect({
    required String userId,
    String base = 'http://192.168.1.8:4000',
  }) {
    presence = IO.io(
      '$base/presence',
      IO.OptionBuilder().setTransports(['websocket']).setAuth({
        'userId': userId,
      }).build(),
    );
    presence!.on('online', (d) {
      final id = d['userId']?.toString();
      if (id != null) {
        _online.add(id);
        _onlineCtrl.add(Set.of(_online));
      }
    });
    presence!.on('offline', (d) {
      final id = d['userId']?.toString();
      if (id != null) {
        _online.remove(id);
        _onlineCtrl.add(Set.of(_online));
      }
    });
    chat = IO.io(
      '$base/chat',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
  }

  void joinConversation(String conversationId) {
    chat?.emit('room:join', conversationId);
  }
}

final sockets = Sockets();
