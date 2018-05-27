library flutter_refit.example;

import 'dart:async';
import 'package:http/http.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import '../lib/flutter_refit.dart';
import 'models/user.dart';

part 'example.api.dart';

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
  Future<RefitResponse<List<User>>> search(@QueryParam("n") String name, @QueryParam("e") String email);
}
