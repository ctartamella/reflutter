library flutter_refit.serializer_cli;

import 'package:build/build.dart';
import 'src/serializer_cli/generator.dart';

Builder refitSerializer(BuilderOptions options) =>
      refitSerializerPartBuilder(header: options.config['header'] as String);