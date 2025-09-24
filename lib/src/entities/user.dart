import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? role;

  @HiveField(2)
  String? username;

  @HiveField(3)
  String? password;

  @HiveField(4)
  String? salt;

  @HiveField(5)
  String? logo;

  @HiveField(6)
  String? phone;

  @HiveField(7)
  String? email;

  @HiveField(8)
  String? gender;

  @HiveField(9)
  String? firstName;

  @HiveField(10)
  String? lastName;

  @HiveField(11)
  DateTime? birthDate;

  @HiveField(12)
  String? picture;

  @HiveField(13)
  String? address;

  @HiveField(14)
  String? zipCode;

  @HiveField(15)
  String? countryId;

  @HiveField(16)
  String? stateId;

  @HiveField(17)
  String? cityId;

  @HiveField(18)
  String? languageId;

  @HiveField(19)
  String? secondLanguageId;

  @HiveField(20)
  String? facebookKey;

  @HiveField(21)
  String? profile;

  @HiveField(22)
  bool? enableOauth;

  @HiveField(23)
  int? sessionTimeout;

  @HiveField(24)
  bool? multipleSession;

  @HiveField(25)
  bool? phoneValidated;

  @HiveField(26)
  String? phoneValidationCode;

  @HiveField(27)
  bool? emailValidated;

  @HiveField(28)
  String? emailValidationCode;

  @HiveField(29)
  String? authenticationMode;

  @HiveField(30)
  bool? enabled;

  @HiveField(31)
  String? confirmationToken;

  @HiveField(32)
  DateTime? passwordRequestedAt;

  @HiveField(33)
  bool? locked;

  @HiveField(34)
  bool? expired;

  @HiveField(35)
  DateTime? expiresAt;

  @HiveField(36)
  bool? credentialsExpired;

  @HiveField(37)
  DateTime? credentialsExpireAt;

  @HiveField(38)
  DateTime? lastLogin;

  @HiveField(39)
  DateTime? lastFailedLogin;

  @HiveField(40)
  int? loginCount;

  @HiveField(41)
  int? failedLoginCount;

  @HiveField(42)
  int? lastFailedLoginCount;

  @HiveField(43)
  DateTime? createdAt;

  @HiveField(44)
  String? creatorUserId;

  @HiveField(45)
  DateTime? updatedAt;

  @HiveField(46)
  String? updaterUserId;
  @HiveField(47)
  final String? token;
  @HiveField(48)
  final String? cookie;
  User({
    this.id,
    this.role,
    this.username,
    this.password,
    this.salt,
    this.logo,
    this.phone,
    this.email,
    this.gender,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.picture,
    this.address,
    this.zipCode,
    this.countryId,
    this.stateId,
    this.cityId,
    this.languageId,
    this.secondLanguageId,
    this.facebookKey,
    this.profile,
    this.enableOauth,
    this.sessionTimeout,
    this.multipleSession,
    this.phoneValidated,
    this.phoneValidationCode,
    this.emailValidated,
    this.emailValidationCode,
    this.authenticationMode,
    this.enabled,
    this.confirmationToken,
    this.passwordRequestedAt,
    this.locked,
    this.expired,
    this.expiresAt,
    this.credentialsExpired,
    this.credentialsExpireAt,
    this.lastLogin,
    this.lastFailedLogin,
    this.loginCount,
    this.failedLoginCount,
    this.lastFailedLoginCount,
    this.createdAt,
    this.creatorUserId,
    this.updatedAt,
    this.updaterUserId,
    this.token,
    this.cookie,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      role: json['role'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      salt: json['salt'] as String?,
      logo: json['logo'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'])
          : null,
      picture: json['picture'] as String?,
      address: json['address'] as String?,
      zipCode: json['zipCode'] as String?,
      countryId: json['countryId'] as String?,
      stateId: json['stateId'] as String?,
      cityId: json['cityId'] as String?,
      languageId: json['languageId'] as String?,
      secondLanguageId: json['secondLanguageId'] as String?,
      facebookKey: json['facebookKey'] as String?,
      profile: json['profile'] as String?,
      enableOauth: json['enableOauth'] as bool?,
      sessionTimeout: json['sessionTimeout'] as int?,
      multipleSession: json['multipleSession'] as bool?,
      phoneValidated: json['phoneValidated'] as bool?,
      phoneValidationCode: json['phoneValidationCode'] as String?,
      emailValidated: json['emailValidated'] as bool?,
      emailValidationCode: json['emailValidationCode'] as String?,
      authenticationMode: json['authenticationMode'] as String?,
      enabled: json['enabled'] as bool?,
      confirmationToken: json['confirmationToken'] as String?,
      passwordRequestedAt: json['passwordRequestedAt'] != null
          ? DateTime.tryParse(json['passwordRequestedAt'])
          : null,
      locked: json['locked'] as bool?,
      expired: json['expired'] as bool?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
      credentialsExpired: json['credentialsExpired'] as bool?,
      credentialsExpireAt: json['credentialsExpireAt'] != null
          ? DateTime.tryParse(json['credentialsExpireAt'])
          : null,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'])
          : null,
      lastFailedLogin: json['lastFailedLogin'] != null
          ? DateTime.tryParse(json['lastFailedLogin'])
          : null,
      loginCount: json['loginCount'] as int?,
      failedLoginCount: json['failedLoginCount'] as int?,
      lastFailedLoginCount: json['lastFailedLoginCount'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      creatorUserId: json['creatorUserId'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      updaterUserId: json['updaterUserId'] as String?,
      token: json['token'] as String?,
      cookie: json['cookie'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'username': username,
    'password': password,
    'salt': salt,
    'logo': logo,
    'phone': phone,
    'email': email,
    'gender': gender,
    'firstName': firstName,
    'lastName': lastName,
    'birthDate': birthDate?.toIso8601String(),
    'picture': picture,
    'address': address,
    'zipCode': zipCode,
    'countryId': countryId,
    'stateId': stateId,
    'cityId': cityId,
    'languageId': languageId,
    'secondLanguageId': secondLanguageId,
    'facebookKey': facebookKey,
    'profile': profile,
    'enableOauth': enableOauth,
    'sessionTimeout': sessionTimeout,
    'multipleSession': multipleSession,
    'phoneValidated': phoneValidated,
    'phoneValidationCode': phoneValidationCode,
    'emailValidated': emailValidated,
    'emailValidationCode': emailValidationCode,
    'authenticationMode': authenticationMode,
    'enabled': enabled,
    'confirmationToken': confirmationToken,
    'passwordRequestedAt': passwordRequestedAt?.toIso8601String(),
    'locked': locked,
    'expired': expired,
    'expiresAt': expiresAt?.toIso8601String(),
    'credentialsExpired': credentialsExpired,
    'credentialsExpireAt': credentialsExpireAt?.toIso8601String(),
    'lastLogin': lastLogin?.toIso8601String(),
    'lastFailedLogin': lastFailedLogin?.toIso8601String(),
    'loginCount': loginCount,
    'failedLoginCount': failedLoginCount,
    'lastFailedLoginCount': lastFailedLoginCount,
    'createdAt': createdAt?.toIso8601String(),
    'creatorUserId': creatorUserId,
    'updatedAt': updatedAt?.toIso8601String(),
    'updaterUserId': updaterUserId,
    'token': token,
    'cookie': cookie,
  };
}
