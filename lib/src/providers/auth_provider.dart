import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenify_auth/src/entities/user.dart';
import 'package:zenify_auth/src/storage/secure_storage.dart';
import 'package:zenify_auth/zenify_auth.dart';
import '../repositories/auth_repository.dart';

/// Auth status enum
enum AuthStatus { loading, authenticated, unauthenticated }

class Traveller {
  final String? id;
  final User? user;
  final String? code;

  Traveller({this.id, this.user, this.code});

  factory Traveller.fromJson(Map<String, dynamic> json) {
    return Traveller(
      id: json['id']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user': user?.toJson(), 'code': code};
  }
}

/// A single state class to track both user and auth status
class AuthState<T> {
  final T? user;
  final AuthStatus status;
  final String? token;
  final String? cookie;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final List<Traveller>? travellers;

  AuthState({
    this.user,
    this.status = AuthStatus.loading,
    this.token,
    this.cookie,
    this.error,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.travellers,
  });

  AuthState<T> copyWith({
    T? user,
    AuthStatus? status,
    String? token,
    String? cookie,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    List<Traveller>? travellers,
  }) {
    return AuthState<T>(
      user: user ?? this.user,
      status: status ?? this.status,
      token: token ?? this.token,
      cookie: cookie ?? this.cookie,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      travellers: travellers ?? this.travellers,
    );
  }
}

/// Listenable wrapper for GoRouter
// class AuthStateListener extends ChangeNotifier {
//   AuthStateListener(this._read);

//   final Reader _read;

//   @override
//   void addListener(VoidCallback listener) {
//     // Subscribe to auth state changes
//     _read(authProvider.notifier).addListener((state) {
//       listener();
//     });
//     super.addListener(listener);
//   }
// }

/// Notifier for authentication state
class AuthNotifier<T extends User> extends StateNotifier<AuthState<T>> {
  final AuthRepository<T> repository;
  final AuthStorage _storage = AuthStorage();
  bool _isInitialized = false;

  // Stream controller for external listeners
  final _stateController = StreamController<AuthState<T>>.broadcast();
  Stream<AuthState<T>> get stream => _stateController.stream;

  AuthNotifier(this.repository)
    : super(AuthState<T>(status: AuthStatus.loading)) {
    _initializeAuth();
  }

  @override
  set state(AuthState<T> value) {
    super.state = value;
    _stateController.add(value); // Emit state changes to stream
  }

  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }

  // ===== Getters =====
  bool get isLoggedIns => state.status == AuthStatus.authenticated;

  String? get tokens => state.user?.token ?? state.token ?? "";
  String? get cookies => state.user?.cookie ?? state.cookie ?? "";

  /// Initialize auth state - restore session if available
  Future<void> _initializeAuth() async {
    try {
      await _storage.init(); // Ensure storage is initialized

      // Try to restore from storage first
      final token = _storage.getToken();
      final cookie = _storage.getCookie();
      final userJson = _storage.getUserJson();
      // tokens=_storage.getToken();
      // cookies= _storage.getCookie();

      if (token != null && cookie != null) {
        // Set loading state with stored data (optimistic UI)
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          cookie: cookie,
          user: userJson as T?,
        );
        print('ℹ️  sessionnnnn ${userJson} to restore');
        // try {
        //   // Verify session is still valid by fetching user profile
        //   final user = await repository.getUserProfile();

        //   if (user != null) {
        //     state = state.copyWith(
        //       user: user,
        //       status: AuthStatus.authenticated,
        //       isAuthenticated: true,
        //       token: token,
        //       cookie: cookie,
        //       isLoading: false,
        //     );
        //     print('✅ Session restored successfully');
        //     _isInitialized = true;
        //     return;
        //   }
        // } catch (e) {
        //   print(
        //     '⚠️ Failed to restore session (token expired or network error): $e',
        //   );
        //  // await _storage.clear(); // Clear corrupted/expired data
        // }
      }

      // No valid session found
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isAuthenticated: false,
        isLoading: false,
      );
      print('ℹ️ No session to restore');
    } catch (e) {
      print('❌ Error initializing auth: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isAuthenticated: false,
        isLoading: false,
      );
    } finally {
      _isInitialized = true;
    }
  }

  /// Check if user is logged in via repository
  Future<void> _checkLogin() async {
    final loggedIn = await repository.isLoggedIn();
    if (loggedIn) {
      final user = await repository.getUserProfile();
      if (user != null) {
        state = state.copyWith(
          user: user,
          status: AuthStatus.authenticated,
          isAuthenticated: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
        );
      }
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isAuthenticated: false,
      );
    }
  }

  Future<T?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final user = await repository.login(email, password);
    print('✅ loooog user ${user?.firstName}');
    // Save to storage with user data
    // await _storage.saveAuthData(
    //   token: user?.token ?? '',
    //   cookie: user?.cookie ?? '',
    //   userId: user?.id ?? '',
    //   userJson: user, // Save full user object
    // );

    if (user != null) {
      // Save to storage with user data
      await _storage.saveAuthData(
        token: user.token ?? '',
        cookie: user.cookie ?? '',
        userId: user.id ?? '',
        userJson: User(
          firstName: user?.firstName,
          lastName: user?.lastName,
          id: user?.id,
          picture: user?.picture,
          token: user?.token,
          cookie: user?.cookie,
        ), // Save full user object
      );

      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isAuthenticated: true,
        isLoading: false,
        token: user.token,
        cookie: user.cookie,
      );
      return user;
    } else {
      state = state.copyWith(
        user: null,
        status: AuthStatus.unauthenticated,
        isAuthenticated: false,
        isLoading: false,
        error: 'Login failed. Please check your credentials.',
      );
      return user;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    final user = await repository.register(name, email, password);
    if (user != null) {
      // Save to storage
      await _storage.saveAuthData(
        token: user.token ?? '',
        cookie: user.cookie ?? '',
        userId: user.id ?? '',
                userJson: User(
          firstName: user?.firstName,
          lastName: user?.lastName,
          id: user?.id,
          picture: user?.picture,
          token: user?.token,
          cookie: user?.cookie,
        ), // Save full user object
      );

      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isAuthenticated: true,
        isLoading: false,
        token: user.token,
        cookie: user.cookie,
      );
      return true;
    } else {
      state = state.copyWith(
        user: null,
        status: AuthStatus.unauthenticated,
        isAuthenticated: false,
        isLoading: false,
        error: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);

    final user = await repository.verifyCode(code);

    if (user != null) {
      // Save to storage
      await _storage.saveAuthData(
        token: user.token ?? '',
        cookie: user.cookie ?? '',
        userId: user.id ?? '',
                userJson: User(
          firstName: user?.firstName,
          lastName: user?.lastName,
          id: user?.id,
          picture: user?.picture,
          token: user?.token,
          cookie: user?.cookie,
        ), // Save full user object
      );

      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isAuthenticated: true,
        isLoading: false,
        token: user.token,
        cookie: user.cookie,
      );
      return true;
    } else {
      state = state.copyWith(
        user: null,
        status: AuthStatus.unauthenticated,
        isAuthenticated: false,
        isLoading: false,
        error: 'Code verification failed. Please check your code.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    await _storage.clear(); // Clear stored credentials

    state = state.copyWith(
      user: null,
      status: AuthStatus.unauthenticated,
      isAuthenticated: false,
      travellers: null,
      error: null,
      token: null,
      cookie: null,
    );

    SocketIOManager.instance.disconnect();
  }

  Future<void> fetchUserProfile() async {
    final profile = await repository.getUserProfile();
    if (profile != null) {
      state = state.copyWith(
        user: profile,
        status: AuthStatus.authenticated,
        isAuthenticated: true,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isAuthenticated: false,
      );
    }
  }

  // ===== TRAVELLER LOGIN METHODS =====

  /// Fetch travellers by code
  Future<List<Traveller>> fetchTravellersByCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final fetchedTravellers = await repository.fetchTravellersByCode(code);

      if (fetchedTravellers.isNotEmpty) {
        state = state.copyWith(isLoading: false, travellers: fetchedTravellers);
        return fetchedTravellers;
      } else {
        state = state.copyWith(
          isLoading: false,
          error:
              'No travellers found with this code. Please check your code and try again.',
        );
        return [];
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Connection error. Please check your internet connection and try again.',
      );
      return [];
    }
  }

  /// Login with selected traveller
  Future<bool> loginWithTraveller(Traveller traveller) async {
    if (traveller.user?.email == null) {
      state = state.copyWith(isLoading: false, error: 'Invalid traveller data');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await repository.loginWithTraveller(traveller);

      if (user != null) {
        // Save to storage
        await _storage.saveAuthData(
          token: user.token ?? '',
          cookie: user.cookie ?? '',
          userId: user.id ?? '',
          //userJson: user,
        );

        state = state.copyWith(
          user: user,
          status: AuthStatus.authenticated,
          isAuthenticated: true,
          isLoading: false,
          token: user.token,
          cookie: user.cookie,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed with provided credentials',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred. Please try again later.',
      );
      return false;
    }
  }

  /// Manually set auth state (useful for restoring sessions)
  void setAuthState(AuthState<T> newState) {
    print("newStateeeeeeeeeee ${newState.user}");
    state = newState;
  }

  // Getters
  bool get isLoggedIn => state.status == AuthStatus.authenticated;
  bool get isInitialized => _isInitialized;
  String? get token => state.user?.token ?? state.token ?? "";
  String? get cookie => state.user?.cookie ?? state.cookie ?? "";
}

// /// Provider for AuthNotifier
// final authProvider = StateNotifierProvider<AuthNotifier<User>, AuthState<User>>(
//   (ref) => AuthNotifier<User>(ZenifyAuth.authRepo),
// );
final authProvider = StateNotifierProvider<AuthNotifier<User>, AuthState<User>>(
  (ref) {
    final notifier = AuthNotifier<User>(ZenifyAuth.authRepo);
    // notifier._initializeAuth() already restores session
    return notifier;
  },
);
