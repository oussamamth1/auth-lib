// auth_state.dart
enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState<T> {
  final T? user;
  final AuthStatus status;

  const AuthState({this.user, this.status = AuthStatus.loading});

  AuthState<T> copyWith({T? user, AuthStatus? status}) {
    return AuthState<T>(user: user ?? this.user, status: status ?? this.status);
  }
}
