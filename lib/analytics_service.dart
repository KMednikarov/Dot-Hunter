import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static bool _enabled = true;

  static bool get enabled => _enabled;

  static Future<void> init() async {
    await Firebase.initializeApp();
    _analytics = FirebaseAnalytics.instance;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('analytics_enabled') ?? true;
    await _analytics?.setAnalyticsCollectionEnabled(_enabled);
    if (_enabled) {
      await _analytics?.logAppOpen();
    }
  }

  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_enabled', enabled);
    await _analytics?.setAnalyticsCollectionEnabled(enabled);
  }

  static Future<void> logGameStart() async {
    if (_enabled) {
      await _analytics?.logEvent(name: 'game_start');
    }
  }

  static Future<void> logGameOver(int score) async {
    if (_enabled) {
      await _analytics?.logEvent(name: 'game_over', parameters: {'score': score});
    }
  }

  static Future<void> logPurchase(String item) async {
    if (_enabled) {
      await _analytics?.logEvent(name: 'purchase', parameters: {'item': item});
    }
  }

  static Future<void> logPowerupUse(String powerup) async {
    if (_enabled) {
      await _analytics?.logEvent(name: 'powerup_use', parameters: {'type': powerup});
    }
  }
}
