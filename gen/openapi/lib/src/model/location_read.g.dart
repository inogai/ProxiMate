// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_read.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LocationRead extends LocationRead {
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final int id;
  @override
  final int userId;
  @override
  final DateTime timestamp;

  factory _$LocationRead([void Function(LocationReadBuilder)? updates]) =>
      (LocationReadBuilder()..update(updates))._build();

  _$LocationRead._(
      {required this.latitude,
      required this.longitude,
      required this.id,
      required this.userId,
      required this.timestamp})
      : super._();
  @override
  LocationRead rebuild(void Function(LocationReadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LocationReadBuilder toBuilder() => LocationReadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LocationRead &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        id == other.id &&
        userId == other.userId &&
        timestamp == other.timestamp;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LocationRead')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('id', id)
          ..add('userId', userId)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class LocationReadBuilder
    implements Builder<LocationRead, LocationReadBuilder> {
  _$LocationRead? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  LocationReadBuilder() {
    LocationRead._defaults(this);
  }

  LocationReadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _id = $v.id;
      _userId = $v.userId;
      _timestamp = $v.timestamp;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LocationRead other) {
    _$v = other as _$LocationRead;
  }

  @override
  void update(void Function(LocationReadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LocationRead build() => _build();

  _$LocationRead _build() {
    final _$result = _$v ??
        _$LocationRead._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'LocationRead', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'LocationRead', 'longitude'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'LocationRead', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'LocationRead', 'userId'),
          timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp, r'LocationRead', 'timestamp'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
