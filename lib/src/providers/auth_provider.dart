import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenify_auth/src/entities/user.dart';
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

/// Notifier for authentication state
class AuthNotifier<T extends User> extends StateNotifier<AuthState<T>> {
  final AuthRepository<T> repository;

  AuthNotifier(this.repository)
    : super(AuthState<T>(status: AuthStatus.loading)) {
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await repository.isLoggedIn();
    if (loggedIn) {
      final user = await repository.getUserProfile();
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
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final user = await repository.login(email, password);
    if (user != null) {
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
        error: 'Login failed. Please check your credentials.',
      );
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    final user = await repository.register(name, email, password);
    if (user != null) {
      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isAuthenticated: true,
        isLoading: false,
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
      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isAuthenticated: true,
        isLoading: false,
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
    state = state.copyWith(
      user: null,
      status: AuthStatus.unauthenticated,
      isAuthenticated: false,
      travellers: null,
      error: null,
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

  // Getters
  bool get isLoggedIn => state.status == AuthStatus.authenticated;
  String? get token => state.user?.token ?? "";
  String? get cookie => state.user?.cookie ?? "";
}

/// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier<User>, AuthState<User>>(
  (ref) => AuthNotifier<User>(ZenifyAuth.authRepo),
);
