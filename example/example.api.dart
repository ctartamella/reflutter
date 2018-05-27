// GENERATED CODE - DO NOT MODIFY BY HAND

part of flutter_refit.example;

// **************************************************************************
// Generator: JaguarHttpGenerator
// **************************************************************************

class Api extends RefitApiDefinition implements ApiDefinition {
  Api(Client client, String baseUrl, Map headers, SerializerRepo serializers)
      : super(client, baseUrl, headers, serializers);

  Future<RefitResponse<User>> getUserById(String id) async {
    final url = '$baseUrl/users/:id';
    var request = new RefitRequest(
        method: 'GET',
        url: url,
        headers: headers,
        body: serializers.serialize(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new RefitResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new RefitResponse.error(rawResponse);
    }
    ;
    response = await interceptResponse(response);
    return response;
  }

  Future<RefitResponse<User>> postUser(User user) async {
    final url = '$baseUrl/users';
    var request = new RefitRequest(
        method: 'POST',
        url: url,
        headers: headers,
        body: serializers.serialize(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new RefitResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new RefitResponse.error(rawResponse);
    }
    ;
    response = await interceptResponse(response);
    return response;
  }

  Future<RefitResponse<User>> updateUser(String userId, User user) async {
    final url = '$baseUrl/users/:uid';
    var request = new RefitRequest(
        method: 'PUT',
        url: url,
        headers: headers,
        body: serializers.serialize(user));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new RefitResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new RefitResponse.error(rawResponse);
    }
    ;
    response = await interceptResponse(response);
    return response;
  }

  Future<RefitResponse<dynamic>> deleteUser(String id) async {
    final url = '$baseUrl/users/:id';
    var request = new RefitRequest(
        method: 'DELETE',
        url: url,
        headers: headers,
        body: serializers.serialize(id));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new RefitResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new RefitResponse.error(rawResponse);
    }
    ;
    response = await interceptResponse(response);
    return response;
  }

  Future<RefitResponse<List<User>>> search(String name, String email) async {
    final url = '$baseUrl/users';
    var request = new RefitRequest(
        method: 'GET',
        url: url,
        headers: headers,
        body: serializers.serialize(email));
    request = await interceptRequest(request);
    final rawResponse = await request.send(client);
    var response = null;
    if (responseSuccessful(rawResponse)) {
      response = new RefitResponse(
          serializers.deserialize(rawResponse.body, type: User), rawResponse);
    } else {
      response = new RefitResponse.error(rawResponse);
    }
    ;
    response = await interceptResponse(response);
    return response;
  }
}
