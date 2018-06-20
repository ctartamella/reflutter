library reflutter.example;

import 'dart:async';
import 'package:http/http.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:reflutter/reflutter.dart';
import 'models/user.dart';

part 'example.api.dart';

/// definition
@ReflutterHttp(name: 'Api')
abstract class ApiDefinition {
  @Get('/users/:id')
  Future<ReflutterResponse<User>> getUserById(@Param() String id);

  @Post('/users')
  Future<ReflutterResponse<User>> postUser(@Body() User user);

  @Put('/users/:uid')
  Future<ReflutterResponse<User>> updateUser(
      @Param('uid') String userId, @Body() User user);

  @Delete('/users/:id')
  Future<ReflutterResponse> deleteUser(@Param() String id);

  @Get('/users')
  Future<ReflutterResponse<List<User>>> search(
      @QueryParam('n') String name, @QueryParam('e') String email);
}
