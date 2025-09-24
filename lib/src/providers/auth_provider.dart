import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenify_auth/src/entities/user.dart';
import 'package:zenify_auth/zenify_auth.dart';
import '../repositories/auth_repository.dart';

/// Auth status enum
enum AuthStatus { loading, authenticated, unauthenticated }

/// A single state class to track both user and auth status
class AuthState<T> {
  final T? user;
  final AuthStatus status;
  final String? token;
  final String? cookie;

  AuthState({
    this.user,
    this.status = AuthStatus.loading,
    this.token,
    this.cookie,
  });

  AuthState<T> copyWith({
    T? user,
    AuthStatus? status,
    String? token,
    String? cookie,
  }) {
    return AuthState<T>(
      user: user ?? this.user,
      status: status ?? this.status,
      token: token ?? this.token,
      cookie: cookie ?? this.cookie,
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
        token: token,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, token: token);
    }
  }

  Future<bool> login(String email, String password) async {
    final user = await repository.login(email, password);
    if (user != null) {
      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        token: user.token,
        cookie: user.cookie,
      );
      return true;
    } else {
      state = state.copyWith(user: null, status: AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    final user = await repository.register(email, password, name);
    if (user != null) {
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
      return true;
    } else {
      state = state.copyWith(user: null, status: AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    final user = await repository.verifyCode(code);
    if (user != null) {
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
      return true;
    } else {
      state = state.copyWith(user: null, status: AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = state.copyWith(user: null, status: AuthStatus.unauthenticated);
    SocketIOManager.instance.disconnect();
  }

  Future<void> fetchUserProfile() async {
    final profile = await repository.getUserProfile();
    if (profile != null) {
      // state = state.copyWith(
      //   user: profile,
      //   status: AuthStatus.authenticated,
      //   token: profile.token,
      //   cookie: profile.cookie,
      // );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  bool get isLoggedIn => state.status == AuthStatus.authenticated;
  String? get token => state.user?.token ?? "";
  String? get cookie => state.user?.cookie ?? "";
}

/// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier<User>, AuthState<User>>(
  (ref) => AuthNotifier<User>(ZenifyAuth.authRepo),
);
