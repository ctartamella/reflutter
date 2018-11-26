import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';

import 'package:reflutter_test/test_api.dart';

void main() async {
  final mockclient = MockClient((req) {
    final body = HealthResponse(value: 'OK');
    final jsonBody = json.encode(body);
    final resp = Response(jsonBody, 200);
    return Future<Response>.sync(() => resp);
  });

  test('Test GET call', () async {
    final api = TestApi(mockclient, '/');
    final resp = await api.healthcheck();

    expect(resp.isSuccessful(), true);
    expect(resp.body.value, 'OK');
  });
}
