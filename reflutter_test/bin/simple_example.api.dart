// GENERATED CODE - DO NOT MODIFY BY HAND

part of simple_example;

// **************************************************************************
// ReflutterHttpGenerator
// **************************************************************************

class Api extends ReflutterApiDefinition implements ApiDefinition {
  Api(Client client, String baseUrl, {Map<String, String> headers})
      : super(client, baseUrl, headers);

  @override
  Future<List<User>> getUsers() async {
    final url = '$baseUrl/users';
    var request = ReflutterRequest(method: 'GET', url: url, headers: headers);
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return null;
    }
    final response = (json.decode(rawResponse.body) as Iterable<User>)
        .map((m) => User.fromJson(m as Map<String, dynamic>))
        .toList();
    return await interceptResponse(response);
  }

  @override
  Future<User> getUserById(String id) async {
    final url = '$baseUrl/users/$id';
    var request = ReflutterRequest(
        method: 'GET', url: url, headers: headers, body: json.encode(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return null;
    }
    final response =
        User.fromJson(json.decode(rawResponse.body) as Map<String, dynamic>);
    return await interceptResponse(response);
  }

  @override
  Future<User> postUser(User user) async {
    final url = '$baseUrl/users';
    var request = ReflutterRequest(
        method: 'POST', url: url, headers: headers, body: json.encode(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return null;
    }
    final response =
        User.fromJson(json.decode(rawResponse.body) as Map<String, dynamic>);
    return await interceptResponse(response);
  }

  @override
  Future<User> updateUser(String userId, User user) async {
    final url = '$baseUrl/users/$userId';
    var request = ReflutterRequest(
        method: 'PUT', url: url, headers: headers, body: json.encode(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return null;
    }
    final response =
        User.fromJson(json.decode(rawResponse.body) as Map<String, dynamic>);
    return await interceptResponse(response);
  }

  @override
  Future<dynamic> deleteUser(String id) async {
    final url = '$baseUrl/users/$id';
    var request = ReflutterRequest(
        method: 'DELETE', url: url, headers: headers, body: json.encode(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return null;
    }
    final response = rawResponse;
    return await interceptResponse(response);
  }

  @override
  Future<List<User>> search({String name = 'John Doe', String email}) async {
    final queryStr = paramsToQueryUri({
      'n': '$name',
      'e': '$email',
    });
    final url = '$baseUrl/users?$queryStr';
    var request = ReflutterRequest(
        method: 'GET', url: url, headers: headers, body: json.encode(email));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return null;
    }
    final response = (json.decode(rawResponse.body) as Iterable<User>)
        .map((m) => User.fromJson(m as Map<String, dynamic>))
        .toList();
    return await interceptResponse(response);
  }
}
