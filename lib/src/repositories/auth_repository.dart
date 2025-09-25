// abstract class AuthRepository<T> {
//   Future<T?> login(String email, String password);
//   Future<T?> register(String name, String email, String password);
//   Future<T?> verifyCode(String code);
//   Future<void> logout();
//   Future<bool> isLoggedIn();
//   Future<T?> getUserProfile();
// }
import 'package:zenify_auth/zenify_auth.dart';

abstract class AuthRepository<T> {
  Future<T?> login(String email, String password);
  Future<T?> register(String name, String email, String password);
  Future<T?> verifyCode(String code);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<T?> getUserProfile();

  // New traveller login methods
  Future<List<Traveller>> fetchTravellersByCode(String code);
  Future<T?> loginWithTraveller(Traveller traveller);
}
