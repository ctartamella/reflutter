import 'package:http/http.dart';

/// Test whether the given [Response] body indicates success.
bool responseSuccessful(Response response) =>
    response.statusCode >= 200 && response.statusCode < 300;

/// Convert a [Map<String, String>] to a formatted query
/// string for use in a URL.
String paramsToQueryUri(Map<String, String> params) {
  final pairs = <List<String>>[];
  params.forEach((key, value) =>
      pairs.add([Uri.encodeQueryComponent(key), Uri.encodeQueryComponent(value)]));

  return pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
}

