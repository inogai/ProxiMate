//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message_read.g.dart';

/// Schema for reading chat message data.
///
/// Properties:
/// * [chatRoomId] 
/// * [senderId] 
/// * [text] 
/// * [messageType] 
/// * [invitationId] 
/// * [invitationData] 
/// * [id] 
/// * [timestamp] 
@BuiltValue()
abstract class ChatMessageRead implements Built<ChatMessageRead, ChatMessageReadBuilder> {
  @BuiltValueField(wireName: r'chat_room_id')
  String get chatRoomId;

  @BuiltValueField(wireName: r'sender_id')
  int get senderId;

  @BuiltValueField(wireName: r'text')
  String get text;

  @BuiltValueField(wireName: r'message_type')
  String? get messageType;

  @BuiltValueField(wireName: r'invitation_id')
  String? get invitationId;

  @BuiltValueField(wireName: r'invitation_data')
  String? get invitationData;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'timestamp')
  String get timestamp;

  ChatMessageRead._();

  factory ChatMessageRead([void updates(ChatMessageReadBuilder b)]) = _$ChatMessageRead;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessageReadBuilder b) => b
      ..messageType = 'text';

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessageRead> get serializer => _$ChatMessageReadSerializer();
}

class _$ChatMessageReadSerializer implements PrimitiveSerializer<ChatMessageRead> {
  @override
  final Iterable<Type> types = const [ChatMessageRead, _$ChatMessageRead];

  @override
  final String wireName = r'ChatMessageRead';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessageRead object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'chat_room_id';
    yield serializers.serialize(
      object.chatRoomId,
      specifiedType: const FullType(String),
    );
    yield r'sender_id';
    yield serializers.serialize(
      object.senderId,
      specifiedType: const FullType(int),
    );
    yield r'text';
    yield serializers.serialize(
      object.text,
      specifiedType: const FullType(String),
    );
    if (object.messageType != null) {
      yield r'message_type';
      yield serializers.serialize(
        object.messageType,
        specifiedType: const FullType(String),
      );
    }
    if (object.invitationId != null) {
      yield r'invitation_id';
      yield serializers.serialize(
        object.invitationId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.invitationData != null) {
      yield r'invitation_data';
      yield serializers.serialize(
        object.invitationData,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'timestamp';
    yield serializers.serialize(
      object.timestamp,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatMessageRead object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessageReadBuilder result,
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
        case r'sender_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.senderId = valueDes;
          break;
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.text = valueDes;
          break;
        case r'message_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.messageType = valueDes;
          break;
        case r'invitation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.invitationId = valueDes;
          break;
        case r'invitation_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.invitationData = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'timestamp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timestamp = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatMessageRead deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessageReadBuilder();
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

