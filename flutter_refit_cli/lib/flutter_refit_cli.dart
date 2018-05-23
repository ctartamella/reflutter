library flutter_refit_cli;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'refit_cli/generator.dart';

Builder refitHttpPartBuilder(BuilderOptions options) => new PartBuilder([new JaguarHttpGenerator()], generatedExtension: ".api.dart");