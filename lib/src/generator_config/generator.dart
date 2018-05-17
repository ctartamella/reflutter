import 'dart:io';

import 'package:yaml/yaml.dart';
import 'pubspec.dart';

const String defaultConfigFile = "jaguar.yaml";

class GeneratorConfig {
  final String configFileName;
  final Pubspec pubspec;

  final Map _config;
  Map get config => _config;

  GeneratorConfig({this.configFileName: defaultConfigFile})
      : pubspec = new Pubspec(),
        _config = loadYaml(new File(configFileName).readAsStringSync());
}