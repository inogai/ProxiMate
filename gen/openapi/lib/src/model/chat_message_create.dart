//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message_create.g.dart';

/// Schema for creating a new chat message.
///
/// Properties:
/// * [chatRoomId] 
/// * [senderId] 
/// * [text] 
/// * [isMine] 
/// * [messageType] 
/// * [invitationId] 
/// * [invitationData] 
@BuiltValue()
abstract class ChatMessageCreate implements Built<ChatMessageCreate, ChatMessageCreateBuilder> {
  @BuiltValueField(wireName: r'chat_room_id')
  String get chatRoomId;

  @BuiltValueField(wireName: r'sender_id')
  int get senderId;

  @BuiltValueField(wireName: r'text')
  String get text;

  @BuiltValueField(wireName: r'is_mine')
  bool? get isMine;

  @BuiltValueField(wireName: r'message_type')
  String? get messageType;

  @BuiltValueField(wireName: r'invitation_id')
  String? get invitationId;

  @BuiltValueField(wireName: r'invitation_data')
  String? get invitationData;

  ChatMessageCreate._();

  factory ChatMessageCreate([void updates(ChatMessageCreateBuilder b)]) = _$ChatMessageCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessageCreateBuilder b) => b
      ..isMine = false
      ..messageType = 'text';

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessageCreate> get serializer => _$ChatMessageCreateSerializer();
}

class _$ChatMessageCreateSerializer implements PrimitiveSerializer<ChatMessageCreate> {
  @override
  final Iterable<Type> types = const [ChatMessageCreate, _$ChatMessageCreate];

  @override
  final String wireName = r'ChatMessageCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessageCreate object, {
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
    if (object.isMine != null) {
      yield r'is_mine';
      yield serializers.serialize(
        object.isMine,
        specifiedType: const FullType(bool),
      );
    }
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatMessageCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessageCreateBuilder result,
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
        case r'is_mine':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isMine = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatMessageCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessageCreateBuilder();
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

