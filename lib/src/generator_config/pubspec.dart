import 'dart:io';

import 'package:yaml/yaml.dart';

class Pubspec {
  static const String fileName = "pubspec.yaml";

  static const String projectNameKey = "name";
  static const String projectVersionKey = "version";

  final Map _map;
  Map get map => _map;

  Pubspec() : _map = loadYaml(new File(fileName).readAsStringSync());

  String get projectName => map[projectNameKey];
  String get projectVersion => map[projectVersionKey];
}