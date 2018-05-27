/// Support for doing something awesome.
///
/// More dartdocs go here.
library flutter_refit;

export 'refit/refit.dart';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'build_runner/generator.dart';

Builder refitHttpPartBuilder(BuilderOptions options) => new PartBuilder([new JaguarHttpGenerator()], generatedExtension: ".api.dart");