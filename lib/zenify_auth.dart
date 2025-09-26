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
    _doInitialize();
    return _doInitialize();
  }

  static Future<void> _doInitialize() async {
    // if (_authRepo != null) return; // Already initialized

    // Initialize Hive (if not already)
    await Hive.initFlutter();

    // Register adapters
    //Hive.registerAdapter(HiveCookieAdapter());
    // Hive.registerAdapter(UserAdapter());

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
    try {
      final box = Hive.box('authBox');
      final raw = box.get('user'); // key you used when saving user
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      return null;
    } catch (e) {
      print('Error getting saved user: $e');
      return null;
    }
  }

  /// 🔹 Return saved token
  static String? getSavedToken() {
    try {
      final box = Hive.box('authBox');
      return box.get('authToken'); // assumes you saved token under "token"
    } catch (e) {
      print('Error getting saved token: $e');
      return null;
    }
  }

  /// 🔹 Return saved cookies
  static String? getSavedCookies() {
    try {
      final box = Hive.box('cookieBox');
      if (box.values.isNotEmpty) {
        return box.values.first.toString();
      }
      return null;
    } catch (e) {
      print('Error getting saved cookies: $e');
      return null;
    }
  }

  /// 🔹 Clear all saved authentication data (for logout)
  static Future<void> clearSavedData() async {
    try {
      final authBox = Hive.box('authBox');
      final cookieBox = Hive.box('cookieBox');

      // Clear all auth data
      await authBox.clear();
      await cookieBox.clear();

      print('✅ All authentication data cleared');
    } catch (e) {
      print('Error clearing saved data: $e');
      rethrow;
    }
  }

  /// 🔹 Clear specific auth data
  static Future<void> clearAuthToken() async {
    try {
      final box = Hive.box('authBox');
      await box.delete('authToken');
      print('✅ Auth token cleared');
    } catch (e) {
      print('Error clearing auth token: $e');
      rethrow;
    }
  }

  /// 🔹 Clear user data
  static Future<void> clearUserData() async {
    try {
      final box = Hive.box('authBox');
      await box.delete('user');
      print('✅ User data cleared');
    } catch (e) {
      print('Error clearing user data: $e');
      rethrow;
    }
  }

  /// 🔹 Clear cookies
  static Future<void> clearCookies() async {
    try {
      final box = Hive.box('cookieBox');
      await box.clear();
      print('✅ Cookies cleared');
    } catch (e) {
      print('Error clearing cookies: $e');
      rethrow;
    }
  }

  /// 🔹 Save user data (helper method)
  static Future<void> saveUser(User? userData) async {
    try {
      final box = Hive.box('authBox');
      await box.put('user', userData);
      print('✅ User data saved');
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  /// 🔹 Save auth token (helper method)
  static Future<void> saveAuthToken(String? token) async {
    try {
      final box = Hive.box('authBox');
      await box.put('authToken', token);
      print('✅ Auth token saved');
    } catch (e) {
      print('Error saving auth token: $e');
      rethrow;
    }
  }

  /// 🔹 Check if user is logged in
  static bool get isLoggedIn {
    final token = getSavedToken();
    final user = getSavedUser();
    return token != null && user != null;
  }

  /// 🔹 Get current user as User object (if exists)
  static User? getCurrentUser() {
    try {
      final userData = getSavedUser();
      if (userData != null && _fromJson != null) {
        return _fromJson!(userData);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// 🔹 Fetch fresh user data from server
  static Future<User?> fetchFreshUser() async {
    try {
      final authRepo = await authRepoAsync;
      final token = getSavedToken();

      if (token == null) {
        print('❌ No auth token found');
        return null;
      }

      // Fetch user from server using the profile endpoint
      final userData = await authRepo.getUserProfile();

      if (userData != null) {
        // Save the fresh user data
        await saveUser(userData);
        print('✅ Fresh user data fetched and saved');
        return _fromJson!(userData as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error fetching fresh user: $e');
      return null;
    }
  }

  /// 🔹 Login with fresh user data
  static Future<User?> loginWithFreshUser({
    required String email,
    required String password,
  }) async {
    try {
      final authRepo = await authRepoAsync;

      // Clear any existing user data before login
      await clearUserData();

      // Perform login
      final loginResult = await authRepo.login(email, password);

      if (loginResult != null) {
        // Fetch fresh user data after successful login
        final freshUser = await fetchFreshUser();
        return freshUser;
      }

      return null;
    } catch (e) {
      print('Error during login with fresh user: $e');
      return null;
    }
  }

  /// 🔹 Refresh current user data from server
  static Future<User?> refreshCurrentUser() async {
    try {
      if (!isLoggedIn) {
        print('❌ User not logged in, cannot refresh');
        return null;
      }

      // Clear current user data and fetch fresh
      await clearUserData();
      return await fetchFreshUser();
    } catch (e) {
      print('Error refreshing current user: $e');
      return null;
    }
  }

  /// 🔹 Complete logout - clears all data and resets repository state
  static Future<void> logout() async {
    try {
      // Clear all saved data
      await clearSavedData();

      // Optionally reset the repository
      // _authRepo = null;

      print('✅ Logout completed');
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  /// 🔹 Reset ZenifyAuth (for testing or complete reset)
  static Future<void> reset() async {
    try {
      await clearSavedData();
      _authRepo = null;
      _initializationFuture = null;
      print('✅ ZenifyAuth reset completed');
    } catch (e) {
      print('Error during reset: $e');
      rethrow;
    }
  }
}
