// GENERATED CODE - DO NOT MODIFY BY HAND

part of reflutter.example;

// **************************************************************************
// ReflutterHttpGenerator
// **************************************************************************

class Api extends ReflutterApiDefinition implements ApiDefinition {
  Api(Client client, String baseUrl, Map headers, SerializerRepo serializers)
      : super(client, baseUrl, headers, serializers);

  @override
  Future<ReflutterResponse<User>> getUserById(String id) async {
    final url = '$baseUrl/users/$id';
    var request = new ReflutterRequest(
        method: 'GET',
        url: url,
        headers: headers,
        body: serializers.serialize(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new ReflutterResponse.error(rawResponse);
    }
    ;
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<User>> postUser(User user) async {
    final url = '$baseUrl/users';
    var request = new ReflutterRequest(
        method: 'POST',
        url: url,
        headers: headers,
        body: serializers.serialize(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new ReflutterResponse.error(rawResponse);
    }
    ;
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<User>> updateUser(String userId, User user) async {
    final url = '$baseUrl/users/$userId';
    var request = new ReflutterRequest(
        method: 'PUT',
        url: url,
        headers: headers,
        body: serializers.serialize(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new ReflutterResponse.error(rawResponse);
    }
    ;
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<dynamic>> deleteUser(String id) async {
    final url = '$baseUrl/users/$id';
    var request = new ReflutterRequest(
        method: 'DELETE',
        url: url,
        headers: headers,
        body: serializers.serialize(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          serializers.deserialize(rawResponse.body, type: null), rawResponse);
    } else {
      response = new ReflutterResponse.error(rawResponse);
    }
    ;
    return await interceptResponse(response);
  }

  @override
  Future<ReflutterResponse<List<User>>> search(
      String name, String email) async {
    final url = '$baseUrl/users';
    var request = new ReflutterRequest(
        method: 'GET',
        url: url,
        headers: headers,
        body: serializers.serialize(email));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new ReflutterResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new ReflutterResponse.error(rawResponse);
    }
    ;
    return await interceptResponse(response);
  }
}
