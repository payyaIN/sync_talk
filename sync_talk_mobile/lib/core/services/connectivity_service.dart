
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  bool _online = true;
  Stream<bool> get onChanged => _controller.stream;
  bool get online => _online;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      if (isOnline != _online) {
        _online = isOnline;
        _controller.add(_online);
      }
    });
    Connectivity().checkConnectivity().then((r){
      final isOnline = r != ConnectivityResult.none;
      if (isOnline != _online) {
        _online = isOnline;
        _controller.add(_online);
      }
    });
  }
}
final connectivityService = ConnectivityService();
