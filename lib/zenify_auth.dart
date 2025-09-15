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
export 'src/service/socketmanagement.dart';

// optional: default User entity
export 'src/entities/user.dart';
export 'src/entities/coockie.dart';


import 'src/config/api_base_url.dart';

class ZenifyAuth {
  static late AuthRepositoryImpl<User> _authRepo;

  static void initialize({
    required String baseUrl,
    required User Function(Map<String, dynamic>) fromJson,
    String profilePath = "/api/user",
  }) {
    // Initialize API Base URL globally
    ApiBaseUrl.initialize(baseUrl);

    // Initialize Hive
    Hive.initFlutter();
    Hive.registerAdapter(HiveCookieAdapter());
    Hive.openBox('authBox');
    Hive.openBox('cookieBox');

    _authRepo = AuthRepositoryImpl<User>(fromJson: fromJson, baseUrl: baseUrl);
  }

  static AuthRepositoryImpl<User> get authRepo => _authRepo;
}

