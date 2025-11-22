// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LocationUpdate extends LocationUpdate {
  @override
  final num? latitude;
  @override
  final num? longitude;

  factory _$LocationUpdate([void Function(LocationUpdateBuilder)? updates]) =>
      (LocationUpdateBuilder()..update(updates))._build();

  _$LocationUpdate._({this.latitude, this.longitude}) : super._();
  @override
  LocationUpdate rebuild(void Function(LocationUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LocationUpdateBuilder toBuilder() => LocationUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LocationUpdate &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LocationUpdate')
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class LocationUpdateBuilder
    implements Builder<LocationUpdate, LocationUpdateBuilder> {
  _$LocationUpdate? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  LocationUpdateBuilder() {
    LocationUpdate._defaults(this);
  }

  LocationUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LocationUpdate other) {
    _$v = other as _$LocationUpdate;
  }

  @override
  void update(void Function(LocationUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LocationUpdate build() => _build();

  _$LocationUpdate _build() {
    final _$result = _$v ??
        _$LocationUpdate._(
          latitude: latitude,
          longitude: longitude,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
