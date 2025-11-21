// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LocationCreate extends LocationCreate {
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final int userId;

  factory _$LocationCreate([void Function(LocationCreateBuilder)? updates]) =>
      (LocationCreateBuilder()..update(updates))._build();

  _$LocationCreate._(
      {required this.latitude, required this.longitude, required this.userId})
      : super._();
  @override
  LocationCreate rebuild(void Function(LocationCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LocationCreateBuilder toBuilder() => LocationCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LocationCreate &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LocationCreate')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('userId', userId))
        .toString();
  }
}

class LocationCreateBuilder
    implements Builder<LocationCreate, LocationCreateBuilder> {
  _$LocationCreate? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  LocationCreateBuilder() {
    LocationCreate._defaults(this);
  }

  LocationCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LocationCreate other) {
    _$v = other as _$LocationCreate;
  }

  @override
  void update(void Function(LocationCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LocationCreate build() => _build();

  _$LocationCreate _build() {
    final _$result = _$v ??
        _$LocationCreate._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'LocationCreate', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'LocationCreate', 'longitude'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'LocationCreate', 'userId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
