// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_api.dart';

// **************************************************************************
// ReflutterHttpGenerator
// **************************************************************************

class TestApi extends ReflutterApiDefinition implements TestApiDefinition {
  TestApi(Client client, String baseUrl, {Map<String, String> headers})
      : super(client, baseUrl, headers);

  @override
  Future<HealthResponse> healthcheck() async {
    final url = '$baseUrl/';
    var request = ReflutterRequest(method: 'GET', url: url, headers: headers);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return null;
    }
    final response = HealthResponse.fromJson(
        json.decode(rawResponse.body) as Map<String, dynamic>);
    return await interceptResponse(response);
  }

  @override
  Future<UserResponse> listUsers({dynamic sortOrder, dynamic sortField}) async {
    final queryStr = paramsToQueryUri({
      'sort_order': '$sortOrder',
      'sort_field': '$sortField',
    });
    final url = '$baseUrl/users?$queryStr';
    var request = ReflutterRequest(
        method: 'GET',
        url: url,
        headers: headers,
        body: json.encode(sortField));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return null;
    }
    final response = UserResponse.fromJson(
        json.decode(rawResponse.body) as Map<String, dynamic>);
    return await interceptResponse(response);
  }
}
