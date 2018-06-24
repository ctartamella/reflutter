
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';

import 'test_api.dart';

void main() async {
  final mockclient = new MockClient((req) {
    var body = HealthResponse()..value = "OK";
    var jsonBody = json.encoder.convert(body);
    var resp = new Response(jsonBody, 200);

    return new Future<Response>.sync(() => resp);
  });

  final api = new TestApi(mockclient, "/", { }, serializers);
  var resp = await api.healthcheck();

  expect(resp.isSuccessful(), true);
  expect(resp.Body, "OK");
}
