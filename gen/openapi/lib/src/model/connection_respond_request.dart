//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'connection_respond_request.g.dart';

/// ConnectionRespondRequest
///
/// Properties:
/// * [action] 
/// * [responderId] 
@BuiltValue()
abstract class ConnectionRespondRequest implements Built<ConnectionRespondRequest, ConnectionRespondRequestBuilder> {
  @BuiltValueField(wireName: r'action')
  String get action;

  @BuiltValueField(wireName: r'responder_id')
  int get responderId;

  ConnectionRespondRequest._();

  factory ConnectionRespondRequest([void updates(ConnectionRespondRequestBuilder b)]) = _$ConnectionRespondRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConnectionRespondRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConnectionRespondRequest> get serializer => _$ConnectionRespondRequestSerializer();
}

class _$ConnectionRespondRequestSerializer implements PrimitiveSerializer<ConnectionRespondRequest> {
  @override
  final Iterable<Type> types = const [ConnectionRespondRequest, _$ConnectionRespondRequest];

  @override
  final String wireName = r'ConnectionRespondRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConnectionRespondRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(String),
    );
    yield r'responder_id';
    yield serializers.serialize(
      object.responderId,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConnectionRespondRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConnectionRespondRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.action = valueDes;
          break;
        case r'responder_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.responderId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConnectionRespondRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConnectionRespondRequestBuilder();
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

