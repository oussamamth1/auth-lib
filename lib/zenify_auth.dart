library zenify_auth;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zenify_auth/src/entities/coockie.dart';
import 'package:zenify_auth/zenify_auth.dart';

// repositories
export 'src/repositories/auth_repository.dart';
export 'src/repositories/auth_repository_impl.dart';

// providers
export 'src/providers/auth_provider.dart';
export 'src/ui/login.dart';
export 'src/ui/registerScreen.dart';
export 'src/service/socketmanagement.dart';

// optional: default User entity
export 'src/entities/user.dart';
export 'src/entities/coockie.dart';

class ZenifyAuth {
  static late AuthRepositoryImpl<User> _authRepo;

  /// Initialize the auth package
  static void initialize({
    required String baseUrl,
    required User Function(Map<String, dynamic>) fromJson,
    String profilePath = "/api/user",
  }) async {
    // Initialize Hive (if not already)
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HiveCookieAdapter());
    // Hive.registerAdapter(HiveUserAdapter());

    // Open the authBox
    await Hive.openBox('authBox');
    await Hive.openBox('cookieBox');
    _authRepo = AuthRepositoryImpl<User>(fromJson: fromJson, baseUrl: baseUrl);
  }

  /// Get the initialized repository
  static AuthRepositoryImpl<User> get authRepo => _authRepo;

  /// 🔹 Return saved user JSON (if exists)
  static Map<String, dynamic>? getSavedUser() {
    final box = Hive.box('authBox');
    final raw = box.get('user'); // key you used when saving user
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  /// 🔹 Return saved token
  static String? getSavedToken() {
    final box = Hive.box('authBox');
    return box.get('authToken'); // assumes you saved token under "token"
  }

  /// 🔹 Return saved cookies
  static String? getSavedCookies() {
    final box = Hive.box('cookieBox');
    return box.values.first.toString();
  }
}
