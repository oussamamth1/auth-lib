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

  const AuthState({this.user, this.status = AuthStatus.loading});

  AuthState<T> copyWith({T? user, AuthStatus? status}) {
    return AuthState<T>(user: user ?? this.user, status: status ?? this.status);
  }
}

/// Notifier for authentication state
class AuthNotifier<T> extends StateNotifier<AuthState<T>> {
  final AuthRepository<T> repository;

  AuthNotifier(this.repository)
    : super(AuthState<T>(status: AuthStatus.loading)) {
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await repository.isLoggedIn();
    if (loggedIn) {
      final user = await repository.getUserProfile();
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    final user = await repository.login(email, password);
    if (user != null) {
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
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
  Future<void> logout() async {
    await repository.logout();
    state = state.copyWith(user: null, status: AuthStatus.unauthenticated);
    SocketIOManager.instance.disconnect();
  }

  Future<void> fetchUserProfile() async {
    final profile = await repository.getUserProfile();
    if (profile != null) {
      state = state.copyWith(user: profile, status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  bool get isLoggedIn => state.status == AuthStatus.authenticated;
}

/// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier<User>, AuthState<User>>(
  (ref) => AuthNotifier<User>(ZenifyAuth.authRepo),
);
