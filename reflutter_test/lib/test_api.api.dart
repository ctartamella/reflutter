// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_api.dart';

// **************************************************************************
// ReflutterHttpGenerator
// **************************************************************************

class TestApi extends ReflutterApiDefinition implements TestApiDefinition {
  TestApi(Client client, String baseUrl, {Map headers})
      : super(client, baseUrl, headers);

  @override
  Future<ReflutterResponse<HealthResponse>> healthcheck() async {
    final url = '$baseUrl/';
    var request =
        new ReflutterRequest(method: 'GET', url: url, headers: headers);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          new HealthResponse.fromJson(json.decode(rawResponse.body)),
          rawResponse);
    } else {
      response =
          new ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return await interceptResponse(response);
  }
}
