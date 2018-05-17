import 'package:flutter_refit/refit_cli.dart';

main(List<String> args) async {
  _start(args);
}

String get _usage => '''
Available commands:
  - build
  - watch
''';

_start(List<String> args) {
  if (args.length > 0) {
    if (args[0] == 'watch') {
      return watch();
    } else if (args[0] == 'build') {
      return build();
    }
  }
  print(_usage);
}