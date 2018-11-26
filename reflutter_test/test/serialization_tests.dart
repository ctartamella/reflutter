import 'package:test/test.dart';
import 'package:reflutter_test/test_api.dart';

void main() {
  test('Simple serialization', () async {
    final resp = HealthResponse(value: 'OK');
    final jBody = resp.toJson();
    expect(true, true);

    final sBody = HealthResponse.fromJson(jBody);
    expect(sBody.value, 'OK');
  });

  test('List serialization', () async {
    //var list = new List<HealthResponse>.filled(5, new HealthResponse("OK"));
    //var jBody = json.encode(list);
    //var obj = json.decode(jBody);
  });
}
