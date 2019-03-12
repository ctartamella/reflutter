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
  @Get('/users')
  Future<List<User>> getUsers();

  @Get('/users/:id')
  Future<User> getUserById(@Param() String id);

  @Post('/users')
  Future<User> postUser(@Body() User user);

  @Put('/users/:uid')
  Future<User> updateUser(
    @Param('uid') String userId, @Body() User user
  );

  @Delete('/users/:id')
  Future deleteUser(@Param() String id);

  @Get('/users')
  Future<List<User>> search({
    @QueryParam('n') String name = 'John Doe',
    @QueryParam('e') String email
  });
}

void main() async {
  final api = Api(Client(), 'http://localhost');
  final user = await api.getUserById('1');

  print('Username ${user.name}');
}
