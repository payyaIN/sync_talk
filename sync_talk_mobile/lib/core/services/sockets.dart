import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../config/app_env.dart';

class Sockets {
  IO.Socket? presence;
  final _online = <String>{};
  final _onlineCtrl = StreamController<Set<String>>.broadcast();
  Stream<Set<String>> get onlineStream => _onlineCtrl.stream;
  Set<String> get onlineUsers => _online;

  void connect({
    required String userId,
    String? base,
  }) {
    if (presence != null && presence!.connected) return;

    final baseUrl = base ?? AppEnv.baseUrl;
    presence = IO.io(
      '$baseUrl/presence',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'userId': userId})
          .build(),
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

    presence!.connect();
  }

  void disconnect() {
    presence?.disconnect();
    presence = null;
  }
}

final sockets = Sockets();
