library reflutter_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/generator.dart';


/// The main build generator used by the build_runner package
/// for code generation.  This is searched out automatically
/// and is not intended to be used by end users.
Builder reflutterBuilder(BuilderOptions options) =>
    new PartBuilder([new ReflutterHttpGenerator()],
        generatedExtension: '.api.dart');
