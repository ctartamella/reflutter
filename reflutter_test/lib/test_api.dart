import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reflutter/reflutter.dart';

part 'test_api.api.dart';
part 'test_api.g.dart';

@JsonSerializable()
class HealthResponse {
  final String value;

  HealthResponse({this.value});

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);
}

@JsonSerializable()
class UserResponse {
  final List<String> users;

  UserResponse({this.users});

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

@ReflutterHttp(name: 'TestApi')
abstract class TestApiDefinition {
  @Get('/')
  Future<HealthResponse> healthcheck();

  @Get('/users')
  Future<UserResponse> listUsers(
      {@QueryParam('sort_order') sortOrder,
      @QueryParam('sort_field') sortField});
}
