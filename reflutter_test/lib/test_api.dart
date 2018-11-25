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

@ReflutterHttp(name: 'TestApi')
abstract class TestApiDefinition {
  @Get('/')
  Future<ReflutterResponse<HealthResponse>> healthcheck();
}
