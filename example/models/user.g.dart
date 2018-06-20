// GENERATED CODE - DO NOT MODIFY BY HAND

part of flutter_refit.user;

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$UserSerializer implements Serializer<User> {
  @override
  Map<String, dynamic> toMap(User model,
      {bool withType: false, String typeKey}) {
    Map<String, dynamic> ret;
    if (model != null) {
      ret = <String, dynamic>{};
      setNullableValue(ret, 'name', model.name);
      setNullableValue(ret, 'email', model.email);
      setTypeKeyValue(typeKey, modelString(), withType, ret);
    }
    return ret;
  }

  @override
  User fromMap(Map<String, dynamic> map, {User model}) {
    if (map == null) {
      return null;
    }
    final obj = model ?? new User();
    obj.name = map['name'] as String;
    obj.email = map['email'] as String;
    return obj;
  }

  @override
  String modelString() => 'User';
}
