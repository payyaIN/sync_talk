/// Backend server URL configuration.
///
/// For a RELEASE/PORTFOLIO APK:
///   - Deploy the backend to a cloud service (Render, Railway, etc.)
///   - Set _productionUrl to your deployed backend URL
///   - Set _useProduction = true
///
/// For LOCAL DEVELOPMENT (USB cable + adb reverse tcp:8000 tcp:8000):
///   - Set _useProduction = false
///   - Keep _localUrl as 'http://localhost:8000'
class AppEnv {
  // ─── ENVIRONMENT SWITCH ──────────────────────────────────────────────────────

  /// true  → use deployed cloud backend (for APK / portfolio builds)
  /// false → use local backend (for dev with USB + adb reverse)
  static const bool _useProduction = true;

  // ─── PRODUCTION (Cloud-deployed backend) ─────────────────────────────────────
  /// Your deployed backend URL — e.g. https://synctalk-api.onrender.com
  /// Leave empty until you deploy; the app will fall back to LAN IP.
  static const String _productionUrl =
      'https://sync-talk-backend-4ubc.onrender.com'; // ← set after deploying

  // ─── LOCAL DEVELOPMENT ───────────────────────────────────────────────────────
  /// For dev: ADB reverse (USB) uses localhost.
  /// For same-WiFi testing: change to your PC's LAN IP (e.g. 192.168.0.157)
  static const String _localUrl = 'http://192.168.0.157:8000';

  // ────────────────────────────────────────────────────────────────────────────

  static String get baseUrl {
    if (_useProduction && _productionUrl.isNotEmpty) {
      return _productionUrl;
    }
    return _localUrl;
  }

  static String get apiBaseUrl => '$baseUrl/api';
  static String get socketUrl => baseUrl;
}
