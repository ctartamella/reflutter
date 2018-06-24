// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_api.dart';

// **************************************************************************
// ReflutterHttpGenerator
// **************************************************************************

class TestApi extends ReflutterApiDefinition implements TestApiDefinition {
  TestApi(Client client, String baseUrl, Map headers, Serializers serializers)
      : super(client, baseUrl, headers, serializers);

  @override
  Future<ReflutterResponse<String>> healthcheck() async {
    final url = '$baseUrl/';
    var request =
        new ReflutterRequest(method: 'GET', url: url, headers: headers);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new ReflutterResponse<String>(
          serializers.deserialize(json.decode(rawResponse.body)), rawResponse);
    } else {
      response = new ReflutterResponse.error(rawResponse);
    }
    ;
    return await interceptResponse(response);
  }
}
