import 'package:socket_io_client/socket_io_client.dart' as IO;

class AdminSocketService {
  static IO.Socket? _socket;

  static void connect(String adminToken) {
    _socket = IO.io(
      'http://192.168.1.8:4000',
      IO.OptionBuilder().setTransports(['websocket']).setAuth({
        'token': adminToken,
      }).build(),
    );

    _socket?.connect();

    // Listen to admin events
    _socket?.on('admin:new-user', (data) {
      print('New user registered: ${data['email']}');
      // Update UI
    });

    _socket?.on('admin:message-flagged', (data) {
      print('Message flagged: ${data['id']}');
      // Show notification
    });

    _socket?.on('admin:user-reported', (data) {
      print('User reported: ${data['userId']}');
      // Show alert
    });
  }
}
