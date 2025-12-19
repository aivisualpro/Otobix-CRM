import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String tokenKey = 'token';
  static const String userNameKey = 'userName';
  static const String userImageUrlKey = 'userImageUrl';
  static const String userEmailKey = 'userEmail';
  static const String userPhoneKey = 'userPhone';
  static const String userRoleKey = 'userRole';
  static const String userKey = 'user';
  static const String userIdKey = 'userId';
  static const String entityTypeKey = 'entityType';
  static const String approvalStatusKey = 'approvalStatus'; // ✅ Add this

  // New key for permissions
  static const String permissionsKey = 'permissions';

  static SharedPreferences? _prefs;

  /// Call this once at app start (like in main())
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save string
  static Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Get string
  static Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  /// Save boolean
  static Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Get boolean
  static bool getBool(String key) {
    return _prefs?.getBool(key) ?? false;
  }

  /// Save list of strings (for permissions)
  static Future<void> saveStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  /// Get list of strings (for permissions)
  static List<String> getStringList(String key) {
    return _prefs?.getStringList(key) ?? [];
  }

  /// Remove value
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// Clear all
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
