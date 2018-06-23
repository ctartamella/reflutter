library flutter_refit.user;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user.g.dart';

abstract class User implements Built<User, UserBuilder> {
  String get name;
  String get email;

  User._();
  factory User([updates(UserBuilder b)]) = _$User;
}

@SerializersFor(const [
  User
])

final Serializers serializers = _$serializers;
