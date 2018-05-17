library jaguar_http.example;

import 'dart:async';
import 'package:http/http.dart';
import 'package:flutter_refit/serializer.dart';
import '../lib/flutter_refit.dart';
import 'models/user.dart';

part 'example.g.dart';

/// definition
@RefitHttp(name: "Api")
abstract class ApiDefinition {
  @Get("/users/:id")
  Future<RefitResponse<User>> getUserById(@Param() String id);

  @Post("/users")
  Future<RefitResponse<User>> postUser(@Body() User user);

  @Put("/users/:uid")
  Future<RefitResponse<User>> updateUser(
      @Param("uid") String userId, @Body() User user);

  @Delete("/users/:id")
  Future<RefitResponse> deleteUser(@Param() String id);

  @Get("/users")
  Future<RefitResponse<List<User>>> search(
      {@QueryParam("n") String name, @QueryParam("e") String email});
}

JsonRepo repo = new JsonRepo()..add(new UserSerializer());

void main() {
  ApiDefinition api = new Api(
      client: new IOClient(),
      baseUrl: "http://localhost:9000",
      serializers: repo)
    ..requestInterceptors.add((RefitRequest req) {
      req.headers["Authorization"] = "TOKEN";
      return req;
    });

  api.getUserById("userId").then((RefitResponse res) {
    print(res);
  }, onError: (e) {
    print(e);
  });
}