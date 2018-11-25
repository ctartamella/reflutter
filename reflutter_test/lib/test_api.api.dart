// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_api.dart';

// **************************************************************************
// ReflutterHttpGenerator
// **************************************************************************

class TestApi extends ReflutterApiDefinition implements TestApiDefinition {
  TestApi(Client client, String baseUrl, {Map<String, String> headers})
      : super(client, baseUrl, headers);

  @override
  Future<ReflutterResponse<HealthResponse>> healthcheck() async {
    final url = '$baseUrl/';
    var request = ReflutterRequest(method: 'GET', url: url, headers: headers);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    ReflutterResponse response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = ReflutterResponse(
          HealthResponse.fromJson(
              json.decode(rawResponse.body) as Map<String, String>),
          rawResponse);
    } else {
      response = ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return (await interceptResponse(response)
        as Future<ReflutterResponse<HealthResponse>>);
  }
}
