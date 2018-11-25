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
    var request = ReflutterRequest(
        method: 'GET', url: url, headers: headers, body: json.encode(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    ReflutterResponse response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = ReflutterResponse(
          User.fromJson(json.decode(rawResponse.body) as Map<String, String>),
          rawResponse);
    } else {
      response = ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return (await interceptResponse(response)
        as Future<ReflutterResponse<User>>);
  }

  @override
  Future<ReflutterResponse<User>> postUser(User user) async {
    final url = '$baseUrl/users';
    var request = ReflutterRequest(
        method: 'POST', url: url, headers: headers, body: json.encode(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    ReflutterResponse response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = ReflutterResponse(
          User.fromJson(json.decode(rawResponse.body) as Map<String, String>),
          rawResponse);
    } else {
      response = ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return (await interceptResponse(response)
        as Future<ReflutterResponse<User>>);
  }

  @override
  Future<ReflutterResponse<User>> updateUser(String userId, User user) async {
    final url = '$baseUrl/users/$userId';
    var request = ReflutterRequest(
        method: 'PUT', url: url, headers: headers, body: json.encode(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    ReflutterResponse response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = ReflutterResponse(
          User.fromJson(json.decode(rawResponse.body) as Map<String, String>),
          rawResponse);
    } else {
      response = ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return (await interceptResponse(response)
        as Future<ReflutterResponse<User>>);
  }

  @override
  Future<ReflutterResponse<dynamic>> deleteUser(String id) async {
    final url = '$baseUrl/users/$id';
    var request = ReflutterRequest(
        method: 'DELETE', url: url, headers: headers, body: json.encode(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    ReflutterResponse response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = ReflutterResponse.empty(rawResponse);
    } else {
      response = ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return (await interceptResponse(response)
        as Future<ReflutterResponse<dynamic>>);
  }

  @override
  Future<ReflutterResponse<List<User>>> search(
      {String name: 'John Doe', String email}) async {
    final queryStr = paramsToQueryUri({
      'n': '$name',
      'e': '$email',
    });
    final url = '$baseUrl/users?$queryStr';
    var request = ReflutterRequest(
        method: 'GET', url: url, headers: headers, body: json.encode(email));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    ReflutterResponse response = null;
    if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      response = ReflutterResponse(
          List<User>.from(json.decode(rawResponse.body) as Iterable),
          rawResponse);
    } else {
      response = ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);
    }
    ;
    return (await interceptResponse(response)
        as Future<ReflutterResponse<List<User>>>);
  }
}
