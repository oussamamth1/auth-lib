import 'package:hive_flutter/hive_flutter.dart';
import 'package:zenify_auth/zenify_auth.dart';

class AuthStorage {
  static const _boxName = 'auth_storage';
  static const _tokenKey = 'auth_token';
  static const _cookieKey = 'auth_cookie';
  static const _userIdKey = 'auth_user_id';
  static const _userJsonKey =
      'auth_user_json'; // Store full user as JSON string

  Box? _box;
  Box? _boxuser;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _boxuser = await Hive.openBox<User>('users');
  }

  Future<void> saveAuthData({
    required String token,
    required String cookie,
    required String userId,
    User? userJson, // Optional user JSON data
  }) async {
    await _box?.put(_tokenKey, token);
    await _box?.put(_cookieKey, cookie);
    await _box?.put(_userIdKey, userId);
   if (userJson != null) {
      await _box?.put(_userJsonKey, userJson.toJson()); // ✅ store JSON
    }
  }

  String? getToken() => _box?.get(_tokenKey);
  String? getCookie() => _box?.get(_cookieKey);
  String? getUserId() => _box?.get(_userIdKey);
 User? getUserJson() {
    final data = _box?.get(_userJsonKey);
    if (data != null) {
      return User.fromJson(Map<String, dynamic>.from(data)); // ✅ convert back
    }
    return null;
  }

  bool isLoggedIn() {
    return getToken() != null && getCookie() != null;
  }

  Future<void> clear() async {
    await _box?.clear();
  }
}
