

import 'dart:async';
import 'dart:convert';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:http/http.dart';
import 'package:reflutter/reflutter.dart';

part 'test_api.api.dart';
part 'test_api.g.dart';

abstract class HealthResponse implements Built<HealthResponse, HealthResponseBuilder> {
  String get value;

  HealthResponse._();
  factory HealthResponse([updates(HealthResponseBuilder b)]) = _$HealthResponse;
  
  // Add serialization support by defining this static getter.
  static Serializer<HealthResponse> get serializer => _$loginSerializer;
}

@SerializersFor(const [
  HealthResponse
])

final Serializers serializers = _$serializers;


@ReflutterHttp(name: 'TestApi')
abstract class TestApiDefinition {
  @Get('/')
  Future<ReflutterResponse<String>> healthcheck();
}