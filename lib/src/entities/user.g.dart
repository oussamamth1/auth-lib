// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 9;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String?,
      role: fields[1] as String?,
      username: fields[2] as String?,
      password: fields[3] as String?,
      salt: fields[4] as String?,
      logo: fields[5] as String?,
      phone: fields[6] as String?,
      email: fields[7] as String?,
      gender: fields[8] as String?,
      firstName: fields[9] as String?,
      lastName: fields[10] as String?,
      birthDate: fields[11] as DateTime?,
      picture: fields[12] as String?,
      address: fields[13] as String?,
      zipCode: fields[14] as String?,
      countryId: fields[15] as String?,
      stateId: fields[16] as String?,
      cityId: fields[17] as String?,
      languageId: fields[18] as String?,
      secondLanguageId: fields[19] as String?,
      facebookKey: fields[20] as String?,
      profile: fields[21] as String?,
      enableOauth: fields[22] as bool?,
      sessionTimeout: fields[23] as int?,
      multipleSession: fields[24] as bool?,
      phoneValidated: fields[25] as bool?,
      phoneValidationCode: fields[26] as String?,
      emailValidated: fields[27] as bool?,
      emailValidationCode: fields[28] as String?,
      authenticationMode: fields[29] as String?,
      enabled: fields[30] as bool?,
      confirmationToken: fields[31] as String?,
      passwordRequestedAt: fields[32] as DateTime?,
      locked: fields[33] as bool?,
      expired: fields[34] as bool?,
      expiresAt: fields[35] as DateTime?,
      credentialsExpired: fields[36] as bool?,
      credentialsExpireAt: fields[37] as DateTime?,
      lastLogin: fields[38] as DateTime?,
      lastFailedLogin: fields[39] as DateTime?,
      loginCount: fields[40] as int?,
      failedLoginCount: fields[41] as int?,
      lastFailedLoginCount: fields[42] as int?,
      createdAt: fields[43] as DateTime?,
      creatorUserId: fields[44] as String?,
      updatedAt: fields[45] as DateTime?,
      updaterUserId: fields[46] as String?,
      token: fields[47] as String?,
      cookie: fields[48] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(49)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.salt)
      ..writeByte(5)
      ..write(obj.logo)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(8)
      ..write(obj.gender)
      ..writeByte(9)
      ..write(obj.firstName)
      ..writeByte(10)
      ..write(obj.lastName)
      ..writeByte(11)
      ..write(obj.birthDate)
      ..writeByte(12)
      ..write(obj.picture)
      ..writeByte(13)
      ..write(obj.address)
      ..writeByte(14)
      ..write(obj.zipCode)
      ..writeByte(15)
      ..write(obj.countryId)
      ..writeByte(16)
      ..write(obj.stateId)
      ..writeByte(17)
      ..write(obj.cityId)
      ..writeByte(18)
      ..write(obj.languageId)
      ..writeByte(19)
      ..write(obj.secondLanguageId)
      ..writeByte(20)
      ..write(obj.facebookKey)
      ..writeByte(21)
      ..write(obj.profile)
      ..writeByte(22)
      ..write(obj.enableOauth)
      ..writeByte(23)
      ..write(obj.sessionTimeout)
      ..writeByte(24)
      ..write(obj.multipleSession)
      ..writeByte(25)
      ..write(obj.phoneValidated)
      ..writeByte(26)
      ..write(obj.phoneValidationCode)
      ..writeByte(27)
      ..write(obj.emailValidated)
      ..writeByte(28)
      ..write(obj.emailValidationCode)
      ..writeByte(29)
      ..write(obj.authenticationMode)
      ..writeByte(30)
      ..write(obj.enabled)
      ..writeByte(31)
      ..write(obj.confirmationToken)
      ..writeByte(32)
      ..write(obj.passwordRequestedAt)
      ..writeByte(33)
      ..write(obj.locked)
      ..writeByte(34)
      ..write(obj.expired)
      ..writeByte(35)
      ..write(obj.expiresAt)
      ..writeByte(36)
      ..write(obj.credentialsExpired)
      ..writeByte(37)
      ..write(obj.credentialsExpireAt)
      ..writeByte(38)
      ..write(obj.lastLogin)
      ..writeByte(39)
      ..write(obj.lastFailedLogin)
      ..writeByte(40)
      ..write(obj.loginCount)
      ..writeByte(41)
      ..write(obj.failedLoginCount)
      ..writeByte(42)
      ..write(obj.lastFailedLoginCount)
      ..writeByte(43)
      ..write(obj.createdAt)
      ..writeByte(44)
      ..write(obj.creatorUserId)
      ..writeByte(45)
      ..write(obj.updatedAt)
      ..writeByte(46)
      ..write(obj.updaterUserId)
      ..writeByte(47)
      ..write(obj.token)
      ..writeByte(48)
      ..write(obj.cookie);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
