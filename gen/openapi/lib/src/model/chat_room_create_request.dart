//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_room_create_request.g.dart';

/// Request model for creating chat room with optional invitation.
///
/// Properties:
/// * [user1Id] 
/// * [user2Id] 
/// * [restaurant] 
/// * [invitationData] 
@BuiltValue()
abstract class ChatRoomCreateRequest implements Built<ChatRoomCreateRequest, ChatRoomCreateRequestBuilder> {
  @BuiltValueField(wireName: r'user1_id')
  int get user1Id;

  @BuiltValueField(wireName: r'user2_id')
  int get user2Id;

  @BuiltValueField(wireName: r'restaurant')
  String get restaurant;

  @BuiltValueField(wireName: r'invitation_data')
  BuiltMap<String, JsonObject?>? get invitationData;

  ChatRoomCreateRequest._();

  factory ChatRoomCreateRequest([void updates(ChatRoomCreateRequestBuilder b)]) = _$ChatRoomCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatRoomCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatRoomCreateRequest> get serializer => _$ChatRoomCreateRequestSerializer();
}

class _$ChatRoomCreateRequestSerializer implements PrimitiveSerializer<ChatRoomCreateRequest> {
  @override
  final Iterable<Type> types = const [ChatRoomCreateRequest, _$ChatRoomCreateRequest];

  @override
  final String wireName = r'ChatRoomCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatRoomCreateRequest object, {
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
    yield r'restaurant';
    yield serializers.serialize(
      object.restaurant,
      specifiedType: const FullType(String),
    );
    if (object.invitationData != null) {
      yield r'invitation_data';
      yield serializers.serialize(
        object.invitationData,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatRoomCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatRoomCreateRequestBuilder result,
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
        case r'restaurant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.restaurant = valueDes;
          break;
        case r'invitation_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.invitationData.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatRoomCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatRoomCreateRequestBuilder();
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

