import 'package:hive/hive.dart';

part 'coockie.g.dart'; // ✅ Make sure this matches your generated file name

@HiveType(typeId: 1)
class HiveCookie extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String value;

  @HiveField(2)
  String? domain;

  @HiveField(3)
  String? path;

  @HiveField(4)
  bool? httpOnly;

  HiveCookie({
    required this.name,
    required this.value,
    this.domain,
    this.path,
    this.httpOnly,
  });
}
