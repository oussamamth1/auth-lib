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
  }) {
    // Initialize Hive (if not already)
    Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HiveCookieAdapter());
    // Hive.registerAdapter(HiveUserAdapter());

    // Open the authBox
    Hive.openBox('authBox');
    Hive.openBox('cookieBox');
    _authRepo = AuthRepositoryImpl<User>(fromJson: fromJson, baseUrl: baseUrl);
  }

  /// Get the initialized repository
  static AuthRepositoryImpl<User> get authRepo => _authRepo;
}
