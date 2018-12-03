// GENERATED CODE - DO NOT MODIFY BY HAND

part of simple_example;

// **************************************************************************
// ReflutterHttpGenerator
// **************************************************************************

class Api extends ReflutterApiDefinition implements ApiDefinition {
  Api(Client client, String baseUrl, {Map<String, String> headers})
      : super(client, baseUrl, headers);

  @override
  Future<ReflutterResponse<User>> getUserById(String id) async {
    final url = '$baseUrl/users/$id';
    var request = ReflutterRequest(method: 'GET', url: url, headers: headers);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return ReflutterResponse(null, rawResponse);
    }
    final response = ReflutterResponse(
        User.fromJson(json.decode(rawResponse.body) as Map<String, dynamic>),
        rawResponse);
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<User>> postUser(User user) async {
    final url = '$baseUrl/users';
    var request = ReflutterRequest(
        method: 'POST',
        url: url,
        headers: headers,
        body: user != null ? json.encode(user) : null);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return ReflutterResponse(null, rawResponse);
    }
    final response = ReflutterResponse(
        User.fromJson(json.decode(rawResponse.body) as Map<String, dynamic>),
        rawResponse);
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<User>> updateUser(String userId, User user) async {
    final url = '$baseUrl/users/$userId';
    var request = ReflutterRequest(
        method: 'PUT',
        url: url,
        headers: headers,
        body: user != null ? json.encode(user) : null);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return ReflutterResponse(null, rawResponse);
    }
    final response = ReflutterResponse(
        User.fromJson(json.decode(rawResponse.body) as Map<String, dynamic>),
        rawResponse);
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<dynamic>> deleteUser(String id) async {
    final url = '$baseUrl/users/$id';
    var request =
        ReflutterRequest(method: 'DELETE', url: url, headers: headers);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return ReflutterResponse(null, rawResponse);
    }
    final response = ReflutterResponse.empty(rawResponse);
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<List<User>>> search(
      {String name: 'John Doe', String email}) async {
    final queryStr = paramsToQueryUri({
      'n': '$name',
      'e': '$email',
    });
    final url = '$baseUrl/users?$queryStr';
    var request = ReflutterRequest(method: 'GET', url: url, headers: headers);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return ReflutterResponse(null, rawResponse);
    }
    final response = ReflutterResponse(
        List<User>.from(json.decode(rawResponse.body) as Iterable),
        rawResponse);
    return await interceptResponse(response);
  }
}
