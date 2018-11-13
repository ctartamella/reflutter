import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';

import 'package:reflutter_test/test_api.dart';

void main() async {
  final mockclient = new MockClient((req) {
    final body = new HealthResponse(value: "OK");
    final jsonBody = json.encode(body);
    final resp = new Response(jsonBody, 200);
    return new Future<Response>.sync(() => resp);
  });

  test("Test GET call", () async {
    final api = new TestApi(mockclient, "/");
    var resp = await api.healthcheck();

    expect(resp.isSuccessful(), true);
    expect(resp.Body.value, "OK");
  });
}
