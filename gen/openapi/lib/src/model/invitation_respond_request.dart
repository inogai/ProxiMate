//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invitation_respond_request.g.dart';

/// InvitationRespondRequest
///
/// Properties:
/// * [action] 
/// * [responderId] 
@BuiltValue()
abstract class InvitationRespondRequest implements Built<InvitationRespondRequest, InvitationRespondRequestBuilder> {
  @BuiltValueField(wireName: r'action')
  String get action;

  @BuiltValueField(wireName: r'responder_id')
  int get responderId;

  InvitationRespondRequest._();

  factory InvitationRespondRequest([void updates(InvitationRespondRequestBuilder b)]) = _$InvitationRespondRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvitationRespondRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvitationRespondRequest> get serializer => _$InvitationRespondRequestSerializer();
}

class _$InvitationRespondRequestSerializer implements PrimitiveSerializer<InvitationRespondRequest> {
  @override
  final Iterable<Type> types = const [InvitationRespondRequest, _$InvitationRespondRequest];

  @override
  final String wireName = r'InvitationRespondRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvitationRespondRequest object, {
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
    InvitationRespondRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InvitationRespondRequestBuilder result,
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
  InvitationRespondRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvitationRespondRequestBuilder();
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

