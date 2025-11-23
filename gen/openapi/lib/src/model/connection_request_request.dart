//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'connection_request_request.g.dart';

/// ConnectionRequestRequest
///
/// Properties:
/// * [chatRoomId] 
/// * [targetUserId] 
/// * [senderId] 
@BuiltValue()
abstract class ConnectionRequestRequest implements Built<ConnectionRequestRequest, ConnectionRequestRequestBuilder> {
  @BuiltValueField(wireName: r'chat_room_id')
  String get chatRoomId;

  @BuiltValueField(wireName: r'target_user_id')
  int get targetUserId;

  @BuiltValueField(wireName: r'sender_id')
  int get senderId;

  ConnectionRequestRequest._();

  factory ConnectionRequestRequest([void updates(ConnectionRequestRequestBuilder b)]) = _$ConnectionRequestRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConnectionRequestRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConnectionRequestRequest> get serializer => _$ConnectionRequestRequestSerializer();
}

class _$ConnectionRequestRequestSerializer implements PrimitiveSerializer<ConnectionRequestRequest> {
  @override
  final Iterable<Type> types = const [ConnectionRequestRequest, _$ConnectionRequestRequest];

  @override
  final String wireName = r'ConnectionRequestRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConnectionRequestRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'chat_room_id';
    yield serializers.serialize(
      object.chatRoomId,
      specifiedType: const FullType(String),
    );
    yield r'target_user_id';
    yield serializers.serialize(
      object.targetUserId,
      specifiedType: const FullType(int),
    );
    yield r'sender_id';
    yield serializers.serialize(
      object.senderId,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConnectionRequestRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConnectionRequestRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'chat_room_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.chatRoomId = valueDes;
          break;
        case r'target_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.targetUserId = valueDes;
          break;
        case r'sender_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.senderId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConnectionRequestRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConnectionRequestRequestBuilder();
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

