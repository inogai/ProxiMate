//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'two_hop_connection.g.dart';

/// TypedDict for 2-hop connection results.
///
/// Properties:
/// * [twoHopUserId] 
/// * [oneHopUserId] 
@BuiltValue()
abstract class TwoHopConnection implements Built<TwoHopConnection, TwoHopConnectionBuilder> {
  @BuiltValueField(wireName: r'two_hop_user_id')
  int get twoHopUserId;

  @BuiltValueField(wireName: r'one_hop_user_id')
  int get oneHopUserId;

  TwoHopConnection._();

  factory TwoHopConnection([void updates(TwoHopConnectionBuilder b)]) = _$TwoHopConnection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TwoHopConnectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TwoHopConnection> get serializer => _$TwoHopConnectionSerializer();
}

class _$TwoHopConnectionSerializer implements PrimitiveSerializer<TwoHopConnection> {
  @override
  final Iterable<Type> types = const [TwoHopConnection, _$TwoHopConnection];

  @override
  final String wireName = r'TwoHopConnection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TwoHopConnection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'two_hop_user_id';
    yield serializers.serialize(
      object.twoHopUserId,
      specifiedType: const FullType(int),
    );
    yield r'one_hop_user_id';
    yield serializers.serialize(
      object.oneHopUserId,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TwoHopConnection object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TwoHopConnectionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'two_hop_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.twoHopUserId = valueDes;
          break;
        case r'one_hop_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.oneHopUserId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TwoHopConnection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TwoHopConnectionBuilder();
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

