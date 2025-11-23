//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'connection_read.g.dart';

/// Schema for reading connection data.
///
/// Properties:
/// * [user1Id] 
/// * [user2Id] 
/// * [invitationId] 
/// * [id] 
/// * [createdAt] 
@BuiltValue()
abstract class ConnectionRead implements Built<ConnectionRead, ConnectionReadBuilder> {
  @BuiltValueField(wireName: r'user1_id')
  int get user1Id;

  @BuiltValueField(wireName: r'user2_id')
  int get user2Id;

  @BuiltValueField(wireName: r'invitation_id')
  String get invitationId;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'created_at')
  String get createdAt;

  ConnectionRead._();

  factory ConnectionRead([void updates(ConnectionReadBuilder b)]) = _$ConnectionRead;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConnectionReadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConnectionRead> get serializer => _$ConnectionReadSerializer();
}

class _$ConnectionReadSerializer implements PrimitiveSerializer<ConnectionRead> {
  @override
  final Iterable<Type> types = const [ConnectionRead, _$ConnectionRead];

  @override
  final String wireName = r'ConnectionRead';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConnectionRead object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user1_id';
    yield serializers.serialize(
      object.user1Id,
      specifiedType: const FullType(int),
    );
    yield r'user2_id';
    yield serializers.serialize(
      object.user2Id,
      specifiedType: const FullType(int),
    );
    yield r'invitation_id';
    yield serializers.serialize(
      object.invitationId,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
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
    ConnectionRead object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConnectionReadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user1_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.user1Id = valueDes;
          break;
        case r'user2_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.user2Id = valueDes;
          break;
        case r'invitation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.invitationId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  ConnectionRead deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConnectionReadBuilder();
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

