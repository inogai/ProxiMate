//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'location_create.g.dart';

/// Schema for creating a new location.
///
/// Properties:
/// * [latitude] - Latitude coordinate
/// * [longitude] - Longitude coordinate
/// * [userId] 
@BuiltValue()
abstract class LocationCreate implements Built<LocationCreate, LocationCreateBuilder> {
  /// Latitude coordinate
  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  /// Longitude coordinate
  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  @BuiltValueField(wireName: r'user_id')
  int get userId;

  LocationCreate._();

  factory LocationCreate([void updates(LocationCreateBuilder b)]) = _$LocationCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LocationCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LocationCreate> get serializer => _$LocationCreateSerializer();
}

class _$LocationCreateSerializer implements PrimitiveSerializer<LocationCreate> {
  @override
  final Iterable<Type> types = const [LocationCreate, _$LocationCreate];

  @override
  final String wireName = r'LocationCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LocationCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LocationCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LocationCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LocationCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LocationCreateBuilder();
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

