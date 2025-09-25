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
export 'src/ui/authFlowScreen.dart';
export 'src/ui/travellerList.dart';
export 'src/ui/codeLoginScreen.dart';
export 'src/service/socketmanagement.dart';

// optional: default User entity
export 'src/entities/user.dart';
export 'src/entities/coockie.dart';

class ZenifyAuth {
  static AuthRepositoryImpl<User>? _authRepo;
  static Future<void>? _initializationFuture;
  static String? _baseUrl;
  static User Function(Map<String, dynamic>)? _fromJson;
  static String? _profilePath;

  /// Initialize the auth package
  static Future<void> initialize({
    required String baseUrl,
    required User Function(Map<String, dynamic>) fromJson,
    String profilePath = "/api/user",
  }) async {
    // Store initialization parameters
    _baseUrl = baseUrl;
    _fromJson = fromJson;
    _profilePath = profilePath;

    // Only initialize once
    _initializationFuture ??= _doInitialize();
    return _initializationFuture!;
  }

  static Future<void> _doInitialize() async {
    if (_authRepo != null) return; // Already initialized

    // Initialize Hive (if not already)
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HiveCookieAdapter());
    // Hive.registerAdapter(HiveUserAdapter());

    // Open the authBox
    await Hive.openBox('authBox');
    await Hive.openBox('cookieBox');

    _authRepo = AuthRepositoryImpl<User>(
      fromJson: _fromJson!,
      baseUrl: _baseUrl!,
    );
  }

  /// Get the initialized repository (with automatic lazy initialization)
  static Future<AuthRepositoryImpl<User>> get authRepoAsync async {
    if (_authRepo != null) return _authRepo!;

    if (_baseUrl == null || _fromJson == null) {
      throw Exception(
        'ZenifyAuth not configured. Call ZenifyAuth.initialize() first.',
      );
    }

    await _doInitialize();
    return _authRepo!;
  }

  /// Get the initialized repository (synchronous - throws if not initialized)
  static AuthRepositoryImpl<User> get authRepo {
    if (_authRepo == null) {
      throw Exception(
        'ZenifyAuth not initialized. Call ZenifyAuth.initialize() and await it first.',
      );
    }
    return _authRepo!;
  }

  /// Check if ZenifyAuth has been initialized
  static bool get isInitialized => _authRepo != null;

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
