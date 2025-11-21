//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_room_base.g.dart';

/// ChatRoomBase
///
/// Properties:
/// * [user1Id] 
/// * [user2Id] 
/// * [restaurant] 
@BuiltValue()
abstract class ChatRoomBase implements Built<ChatRoomBase, ChatRoomBaseBuilder> {
  @BuiltValueField(wireName: r'user1_id')
  int get user1Id;

  @BuiltValueField(wireName: r'user2_id')
  int get user2Id;

  @BuiltValueField(wireName: r'restaurant')
  String get restaurant;

  ChatRoomBase._();

  factory ChatRoomBase([void updates(ChatRoomBaseBuilder b)]) = _$ChatRoomBase;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatRoomBaseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatRoomBase> get serializer => _$ChatRoomBaseSerializer();
}

class _$ChatRoomBaseSerializer implements PrimitiveSerializer<ChatRoomBase> {
  @override
  final Iterable<Type> types = const [ChatRoomBase, _$ChatRoomBase];

  @override
  final String wireName = r'ChatRoomBase';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatRoomBase object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatRoomBase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatRoomBaseBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatRoomBase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatRoomBaseBuilder();
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

