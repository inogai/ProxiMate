//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_read.g.dart';

/// Schema for reading user data.
///
/// Properties:
/// * [username] 
/// * [school] 
/// * [major] 
/// * [interests] 
/// * [bio] 
/// * [avatarUrl] 
/// * [id] 
/// * [createdAt] 
@BuiltValue()
abstract class UserRead implements Built<UserRead, UserReadBuilder> {
  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'school')
  String? get school;

  @BuiltValueField(wireName: r'major')
  String? get major;

  @BuiltValueField(wireName: r'interests')
  String? get interests;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'id')
  int get id;

  @BuiltValueField(wireName: r'created_at')
  String get createdAt;

  UserRead._();

  factory UserRead([void updates(UserReadBuilder b)]) = _$UserRead;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserReadBuilder b) => b
      ..school = ''
      ..major = ''
      ..interests = ''
      ..bio = '';

  @BuiltValueSerializer(custom: true)
  static Serializer<UserRead> get serializer => _$UserReadSerializer();
}

class _$UserReadSerializer implements PrimitiveSerializer<UserRead> {
  @override
  final Iterable<Type> types = const [UserRead, _$UserRead];

  @override
  final String wireName = r'UserRead';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserRead object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    if (object.school != null) {
      yield r'school';
      yield serializers.serialize(
        object.school,
        specifiedType: const FullType(String),
      );
    }
    if (object.major != null) {
      yield r'major';
      yield serializers.serialize(
        object.major,
        specifiedType: const FullType(String),
      );
    }
    if (object.interests != null) {
      yield r'interests';
      yield serializers.serialize(
        object.interests,
        specifiedType: const FullType(String),
      );
    }
    if (object.bio != null) {
      yield r'bio';
      yield serializers.serialize(
        object.bio,
        specifiedType: const FullType(String),
      );
    }
    if (object.avatarUrl != null) {
      yield r'avatar_url';
      yield serializers.serialize(
        object.avatarUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(int),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserRead object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserReadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'school':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.school = valueDes;
          break;
        case r'major':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.major = valueDes;
          break;
        case r'interests':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.interests = valueDes;
          break;
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bio = valueDes;
          break;
        case r'avatar_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarUrl = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.id = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserRead deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserReadBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

