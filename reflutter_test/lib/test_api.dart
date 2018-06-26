import 'dart:async';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart';
import 'package:reflutter/reflutter.dart';

part 'test_api.api.dart';
part 'test_api.g.dart';

@JsonSerializable()
class HealthResponse extends Object with _$HealthResponseSerializerMixin {
  String value;

  HealthResponse(this.value);
  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);
}

@ReflutterHttp(name: 'TestApi')
abstract class TestApiDefinition {
  @Get('/')
  Future<ReflutterResponse<HealthResponse>> healthcheck();
}
