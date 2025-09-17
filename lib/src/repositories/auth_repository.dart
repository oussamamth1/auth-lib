abstract class AuthRepository<T> {
  Future<T?> login(String email, String password);
  Future<T?> register(String name, String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<T?> getUserProfile();
}
