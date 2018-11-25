library simple_example;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reflutter/reflutter.dart';

part 'simple_example.api.dart';
part 'simple_example.g.dart';

@JsonSerializable()
class User {
  String name;
  String email;

  User(this.name, this.email);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

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
      { @QueryParam('n') String name = 'John Doe', @QueryParam('e') String email });
}

void main() async {
  var api = Api(Client(), 'http://localhost');
  var user = await api.getUserById('1');

  print('Username ${user.body.name}');
}
