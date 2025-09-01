import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Simple anonymous authentication service.
///
/// Generates a persistent random identifier for the current player so that
/// scores posted to the backend can be attributed to a specific user without
/// requiring a full sign in flow.
class AuthService {
  AuthService._();

  static const _prefsKey = 'player_id';
  static final AuthService instance = AuthService._();
  String? _cachedId;

  /// Returns the unique identifier for the current player. A new identifier is
  /// generated and stored the first time this is called.
  Future<String> getPlayerId() async {
    if (_cachedId != null) return _cachedId!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_prefsKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_prefsKey, id);
    }
    _cachedId = id;
    return id;
  }
}
