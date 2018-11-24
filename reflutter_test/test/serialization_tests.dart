import 'package:test/test.dart';
import 'package:reflutter_test/test_api.dart';

void main() {
  test('Simple serialization', () async {
    var resp = HealthResponse(value: 'OK');
    var jBody = resp.toJson();
    expect(true, true);

    var sBody = HealthResponse.fromJson(jBody);
    expect(sBody.value, 'OK');
  });

  test('List serialization', () async {
    //var list = new List<HealthResponse>.filled(5, new HealthResponse("OK"));
    //var jBody = json.encode(list);
    //var obj = json.decode(jBody);
  });
}
