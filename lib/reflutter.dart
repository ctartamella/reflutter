/// Support for doing something awesome.
///
/// More dartdocs go here.
library reflutter;

export 'src/reflutter.dart';
export 'src/utils.dart';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'build_runner/generator.dart';

Builder reflutterBuilder(BuilderOptions options) => new PartBuilder([new ReflutterHttpGenerator()], generatedExtension: ".api.dart");