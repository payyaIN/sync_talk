
import 'package:hive_flutter/hive_flutter.dart';

class Session {
  String? accessToken;
  String? refreshToken;
  String? userId;
  Future<void> load() async {
    await Hive.initFlutter();
    final box = await Hive.openBox('session');
    accessToken = box.get('accessToken');
    refreshToken = box.get('refreshToken');
    userId = box.get('userId');
  }
  Future<void> save() async {
    final box = await Hive.openBox('session');
    await box.put('accessToken', accessToken);
    await box.put('refreshToken', refreshToken);
    await box.put('userId', userId);
  }
  void setTokens(String? access, String? refresh) {
    accessToken = access; refreshToken = refresh; save();
  }
}
final session = Session();
Future<void> initSession() async { await session.load(); }
