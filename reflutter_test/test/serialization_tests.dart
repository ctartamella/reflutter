library serialization;

import 'dart:convert';

import 'package:reflutter_test/test_api.dart';
import 'package:test/test.dart';

void main() {
  test("Simple serialization", () async {
    var jBody = json.encode(new HealthResponse(value: "OK"));
    expect(true, true);

    var sBody = new HealthResponse.fromJson(json.decode(jBody));
    expect(sBody.value, "OK");
  });

  test("List serialization", () async {
    //var list = new List<HealthResponse>.filled(5, new HealthResponse("OK"));
    //var jBody = json.encode(list);
    //var obj = json.decode(jBody);
  });
}
