import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api.dart';
import 'session.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {}

class PushService {
  String? lastOpenConversationId;
  bool _inited = false;
  Future<void> init() async {
    if (_inited) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      final fcm = FirebaseMessaging.instance;
      if (Platform.isIOS) {
        await fcm.requestPermission(alert: true, badge: true, sound: true);
      }
      final token = await fcm.getToken();
      if (token != null && session.accessToken != null) {
        await dio.post('/api/users/device', data: {'token': token});
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (session.accessToken != null)
          await dio.post('/api/users/device', data: {'token': newToken});
      });

      // fcm.onTokenRefresh.listen((t) async {
      //   if (session.accessToken != null) {
      //     await dio.post('/api/users/device', data: {'token': t});
      //   }
      // });
      _inited = true;
    } catch (_) {}
  }
}

final pushService = PushService();
