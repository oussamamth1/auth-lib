import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String? email;

  @HiveField(1)
  final String? firstName;

  @HiveField(2)
  final String? lastName;

  @HiveField(3)
  final String? token;

  @HiveField(4)
  final String? id;

  User({this.id, this.email, this.firstName, this.lastName, this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return User(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      token: json['access_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'token': token,
  };
}
