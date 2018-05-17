import 'dart:async';
import 'package:build/build.dart';
import 'package:flutter_refit/generator_config.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build_runner/build_runner.dart' as build_runner;

import '../../refit_cli.dart';

const _defaultPath = const [
  "lib/**/**.dart",
  "bin/**/**.dart",
  "test/**/**.dart",
  "example/**/**.dart",
  "lib/*.dart",
  "bin/*.dart",
  "test/*.dart",
  "example/*.dart"
];

const jaguarHttpConfigFile = "pubspec.yaml";

class JaguarHttpConfig extends GeneratorConfig {
  static const String httpKey = 'refit_http';

  JaguarHttpConfig({String configFileName: jaguarHttpConfigFile})
      : super(configFileName: configFileName);

  List<String> get httpFiles => config[httpKey];
}

/// Watch files and trigger build function
Future<build_runner.ServeHandler> watch() =>
    build_runner.watch(buildActions(), deleteFilesByDefault: true);

/// Build all Http Class
Future<build_runner.BuildResult> build() =>
    build_runner.build(buildActions(), deleteFilesByDefault: true);

List<build_runner.BuildAction> buildActions(
    {String configFileName: jaguarHttpConfigFile, String copyrightContent}) {
  final config = new JaguarHttpConfig();

  if (config.pubspec.projectName == null) {
    throw "Could not find the project name";
  }

  var httpFiles = config.httpFiles;

  if (httpFiles == null || httpFiles.isEmpty) {
    print(
        "[WARNING] Refit did not find any files to watch in 'pubspec.yaml', '$_defaultPath' used by default");
    httpFiles = _defaultPath;
  }

  return [
    new build_runner.BuildAction(
        refitHttpPartBuilder(header: copyrightContent),
        config.pubspec.projectName,
        inputs: config.httpFiles),
  ];
}

Builder refitHttpPartBuilder({String header}) =>
new PartBuilder([const JaguarHttpGenerator()], header: header);