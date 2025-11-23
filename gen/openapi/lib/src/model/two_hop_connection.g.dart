// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'two_hop_connection.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TwoHopConnection extends TwoHopConnection {
  @override
  final int twoHopUserId;
  @override
  final int oneHopUserId;

  factory _$TwoHopConnection(
          [void Function(TwoHopConnectionBuilder)? updates]) =>
      (TwoHopConnectionBuilder()..update(updates))._build();

  _$TwoHopConnection._({required this.twoHopUserId, required this.oneHopUserId})
      : super._();
  @override
  TwoHopConnection rebuild(void Function(TwoHopConnectionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TwoHopConnectionBuilder toBuilder() =>
      TwoHopConnectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TwoHopConnection &&
        twoHopUserId == other.twoHopUserId &&
        oneHopUserId == other.oneHopUserId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, twoHopUserId.hashCode);
    _$hash = $jc(_$hash, oneHopUserId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TwoHopConnection')
          ..add('twoHopUserId', twoHopUserId)
          ..add('oneHopUserId', oneHopUserId))
        .toString();
  }
}

class TwoHopConnectionBuilder
    implements Builder<TwoHopConnection, TwoHopConnectionBuilder> {
  _$TwoHopConnection? _$v;

  int? _twoHopUserId;
  int? get twoHopUserId => _$this._twoHopUserId;
  set twoHopUserId(int? twoHopUserId) => _$this._twoHopUserId = twoHopUserId;

  int? _oneHopUserId;
  int? get oneHopUserId => _$this._oneHopUserId;
  set oneHopUserId(int? oneHopUserId) => _$this._oneHopUserId = oneHopUserId;

  TwoHopConnectionBuilder() {
    TwoHopConnection._defaults(this);
  }

  TwoHopConnectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _twoHopUserId = $v.twoHopUserId;
      _oneHopUserId = $v.oneHopUserId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TwoHopConnection other) {
    _$v = other as _$TwoHopConnection;
  }

  @override
  void update(void Function(TwoHopConnectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TwoHopConnection build() => _build();

  _$TwoHopConnection _build() {
    final _$result = _$v ??
        _$TwoHopConnection._(
          twoHopUserId: BuiltValueNullFieldError.checkNotNull(
              twoHopUserId, r'TwoHopConnection', 'twoHopUserId'),
          oneHopUserId: BuiltValueNullFieldError.checkNotNull(
              oneHopUserId, r'TwoHopConnection', 'oneHopUserId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
