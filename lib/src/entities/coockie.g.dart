// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coockie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveCookieAdapter extends TypeAdapter<HiveCookie> {
  @override
  final int typeId = 1;

  @override
  HiveCookie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCookie(
      name: fields[0] as String,
      value: fields[1] as String,
      domain: fields[2] as String?,
      path: fields[3] as String?,
      httpOnly: fields[4] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCookie obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.domain)
      ..writeByte(3)
      ..write(obj.path)
      ..writeByte(4)
      ..write(obj.httpOnly);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveCookieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
