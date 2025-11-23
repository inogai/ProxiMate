//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'connection_create_request.g.dart';

/// ConnectionCreateRequest
///
/// Properties:
/// * [user1Id] 
/// * [user2Id] 
/// * [invitationId] 
/// * [status] 
@BuiltValue()
abstract class ConnectionCreateRequest implements Built<ConnectionCreateRequest, ConnectionCreateRequestBuilder> {
  @BuiltValueField(wireName: r'user1_id')
  int get user1Id;

  @BuiltValueField(wireName: r'user2_id')
  int get user2Id;

  @BuiltValueField(wireName: r'invitation_id')
  String get invitationId;

  @BuiltValueField(wireName: r'status')
  String? get status;

  ConnectionCreateRequest._();

  factory ConnectionCreateRequest([void updates(ConnectionCreateRequestBuilder b)]) = _$ConnectionCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConnectionCreateRequestBuilder b) => b
      ..status = 'pending';

  @BuiltValueSerializer(custom: true)
  static Serializer<ConnectionCreateRequest> get serializer => _$ConnectionCreateRequestSerializer();
}

class _$ConnectionCreateRequestSerializer implements PrimitiveSerializer<ConnectionCreateRequest> {
  @override
  final Iterable<Type> types = const [ConnectionCreateRequest, _$ConnectionCreateRequest];

  @override
  final String wireName = r'ConnectionCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConnectionCreateRequest object, {
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
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ConnectionCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConnectionCreateRequestBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConnectionCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConnectionCreateRequestBuilder();
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

