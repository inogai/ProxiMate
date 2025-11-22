//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invitation_read.g.dart';

/// Schema for reading invitation data.
///
/// Properties:
/// * [senderId] 
/// * [receiverId] 
/// * [activityId] 
/// * [restaurant] 
/// * [status] 
/// * [iceBreakers] 
/// * [sentByMe] 
/// * [nameCardCollected] 
/// * [chatOpened] 
/// * [id] 
/// * [createdAt] 
@BuiltValue()
abstract class InvitationRead implements Built<InvitationRead, InvitationReadBuilder> {
  @BuiltValueField(wireName: r'sender_id')
  int get senderId;

  @BuiltValueField(wireName: r'receiver_id')
  int get receiverId;

  @BuiltValueField(wireName: r'activity_id')
  String get activityId;

  @BuiltValueField(wireName: r'restaurant')
  String get restaurant;

  @BuiltValueField(wireName: r'status')
  String? get status;

  @BuiltValueField(wireName: r'ice_breakers')
  String? get iceBreakers;

  @BuiltValueField(wireName: r'sent_by_me')
  bool? get sentByMe;

  @BuiltValueField(wireName: r'name_card_collected')
  bool? get nameCardCollected;

  @BuiltValueField(wireName: r'chat_opened')
  bool? get chatOpened;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'created_at')
  String get createdAt;

  InvitationRead._();

  factory InvitationRead([void updates(InvitationReadBuilder b)]) = _$InvitationRead;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvitationReadBuilder b) => b
      ..status = 'pending'
      ..iceBreakers = '[]'
      ..sentByMe = false
      ..nameCardCollected = false
      ..chatOpened = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvitationRead> get serializer => _$InvitationReadSerializer();
}

class _$InvitationReadSerializer implements PrimitiveSerializer<InvitationRead> {
  @override
  final Iterable<Type> types = const [InvitationRead, _$InvitationRead];

  @override
  final String wireName = r'InvitationRead';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvitationRead object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sender_id';
    yield serializers.serialize(
      object.senderId,
      specifiedType: const FullType(int),
    );
    yield r'receiver_id';
    yield serializers.serialize(
      object.receiverId,
      specifiedType: const FullType(int),
    );
    yield r'activity_id';
    yield serializers.serialize(
      object.activityId,
      specifiedType: const FullType(String),
    );
    yield r'restaurant';
    yield serializers.serialize(
      object.restaurant,
      specifiedType: const FullType(String),
    );
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
    if (object.iceBreakers != null) {
      yield r'ice_breakers';
      yield serializers.serialize(
        object.iceBreakers,
        specifiedType: const FullType(String),
      );
    }
    if (object.sentByMe != null) {
      yield r'sent_by_me';
      yield serializers.serialize(
        object.sentByMe,
        specifiedType: const FullType(bool),
      );
    }
    if (object.nameCardCollected != null) {
      yield r'name_card_collected';
      yield serializers.serialize(
        object.nameCardCollected,
        specifiedType: const FullType(bool),
      );
    }
    if (object.chatOpened != null) {
      yield r'chat_opened';
      yield serializers.serialize(
        object.chatOpened,
        specifiedType: const FullType(bool),
      );
    }
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
    InvitationRead object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InvitationReadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sender_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.senderId = valueDes;
          break;
        case r'receiver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.receiverId = valueDes;
          break;
        case r'activity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.activityId = valueDes;
          break;
        case r'restaurant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.restaurant = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'ice_breakers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.iceBreakers = valueDes;
          break;
        case r'sent_by_me':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.sentByMe = valueDes;
          break;
        case r'name_card_collected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.nameCardCollected = valueDes;
          break;
        case r'chat_opened':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.chatOpened = valueDes;
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
  InvitationRead deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvitationReadBuilder();
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

