// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_respond_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConnectionRespondRequest extends ConnectionRespondRequest {
  @override
  final String action;
  @override
  final int responderId;

  factory _$ConnectionRespondRequest(
          [void Function(ConnectionRespondRequestBuilder)? updates]) =>
      (ConnectionRespondRequestBuilder()..update(updates))._build();

  _$ConnectionRespondRequest._(
      {required this.action, required this.responderId})
      : super._();
  @override
  ConnectionRespondRequest rebuild(
          void Function(ConnectionRespondRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConnectionRespondRequestBuilder toBuilder() =>
      ConnectionRespondRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConnectionRespondRequest &&
        action == other.action &&
        responderId == other.responderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, responderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConnectionRespondRequest')
          ..add('action', action)
          ..add('responderId', responderId))
        .toString();
  }
}

class ConnectionRespondRequestBuilder
    implements
        Builder<ConnectionRespondRequest, ConnectionRespondRequestBuilder> {
  _$ConnectionRespondRequest? _$v;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  int? _responderId;
  int? get responderId => _$this._responderId;
  set responderId(int? responderId) => _$this._responderId = responderId;

  ConnectionRespondRequestBuilder() {
    ConnectionRespondRequest._defaults(this);
  }

  ConnectionRespondRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _responderId = $v.responderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConnectionRespondRequest other) {
    _$v = other as _$ConnectionRespondRequest;
  }

  @override
  void update(void Function(ConnectionRespondRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConnectionRespondRequest build() => _build();

  _$ConnectionRespondRequest _build() {
    final _$result = _$v ??
        _$ConnectionRespondRequest._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'ConnectionRespondRequest', 'action'),
          responderId: BuiltValueNullFieldError.checkNotNull(
              responderId, r'ConnectionRespondRequest', 'responderId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
