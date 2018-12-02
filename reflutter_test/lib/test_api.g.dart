// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) {
  return HealthResponse(value: json['value'] as String);
}

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{'value': instance.value};

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) {
  return UserResponse(
      users: (json['users'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{'users': instance.users};
