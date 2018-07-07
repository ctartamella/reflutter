// GENERATED CODE - DO NOT MODIFY BY HAND

part of simple_example;

// **************************************************************************
// ReflutterHttpGenerator
// **************************************************************************

class Api extends ReflutterApiDefinition implements ApiDefinition {
  Api(Client client, String baseUrl, Map headers)
      : super(client, baseUrl, headers);

  @override
  Future<ReflutterResponse<User>> getUserById(String id) async {
    final url = '$baseUrl/users/$id';
    var request = new ReflutterRequest(
        method: 'GET', url: url, headers: headers, body: json.encode(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          new User.fromJson(json.decode(rawResponse.body)), rawResponse);
    } else {
      response =
          new ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<User>> postUser(User user) async {
    final url = '$baseUrl/users';
    var request = new ReflutterRequest(
        method: 'POST', url: url, headers: headers, body: json.encode(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          new User.fromJson(json.decode(rawResponse.body)), rawResponse);
    } else {
      response =
          new ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<User>> updateUser(String userId, User user) async {
    final url = '$baseUrl/users/$userId';
    var request = new ReflutterRequest(
        method: 'PUT', url: url, headers: headers, body: json.encode(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          new User.fromJson(json.decode(rawResponse.body)), rawResponse);
    } else {
      response =
          new ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<dynamic>> deleteUser(String id) async {
    final url = '$baseUrl/users/$id';
    var request = new ReflutterRequest(
        method: 'DELETE', url: url, headers: headers, body: json.encode(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = new ReflutterResponse.empty(rawResponse);
    } else {
      response =
          new ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return await interceptResponse(response);
  }
}
