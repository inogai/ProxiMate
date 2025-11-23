// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConnectionCreateRequest extends ConnectionCreateRequest {
  @override
  final int user1Id;
  @override
  final int user2Id;
  @override
  final String invitationId;
  @override
  final String? status;

  factory _$ConnectionCreateRequest(
          [void Function(ConnectionCreateRequestBuilder)? updates]) =>
      (ConnectionCreateRequestBuilder()..update(updates))._build();

  _$ConnectionCreateRequest._(
      {required this.user1Id,
      required this.user2Id,
      required this.invitationId,
      this.status})
      : super._();
  @override
  ConnectionCreateRequest rebuild(
          void Function(ConnectionCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConnectionCreateRequestBuilder toBuilder() =>
      ConnectionCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConnectionCreateRequest &&
        user1Id == other.user1Id &&
        user2Id == other.user2Id &&
        invitationId == other.invitationId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user1Id.hashCode);
    _$hash = $jc(_$hash, user2Id.hashCode);
    _$hash = $jc(_$hash, invitationId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConnectionCreateRequest')
          ..add('user1Id', user1Id)
          ..add('user2Id', user2Id)
          ..add('invitationId', invitationId)
          ..add('status', status))
        .toString();
  }
}

class ConnectionCreateRequestBuilder
    implements
        Builder<ConnectionCreateRequest, ConnectionCreateRequestBuilder> {
  _$ConnectionCreateRequest? _$v;

  int? _user1Id;
  int? get user1Id => _$this._user1Id;
  set user1Id(int? user1Id) => _$this._user1Id = user1Id;

  int? _user2Id;
  int? get user2Id => _$this._user2Id;
  set user2Id(int? user2Id) => _$this._user2Id = user2Id;

  String? _invitationId;
  String? get invitationId => _$this._invitationId;
  set invitationId(String? invitationId) => _$this._invitationId = invitationId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  ConnectionCreateRequestBuilder() {
    ConnectionCreateRequest._defaults(this);
  }

  ConnectionCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user1Id = $v.user1Id;
      _user2Id = $v.user2Id;
      _invitationId = $v.invitationId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConnectionCreateRequest other) {
    _$v = other as _$ConnectionCreateRequest;
  }

  @override
  void update(void Function(ConnectionCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConnectionCreateRequest build() => _build();

  _$ConnectionCreateRequest _build() {
    final _$result = _$v ??
        _$ConnectionCreateRequest._(
          user1Id: BuiltValueNullFieldError.checkNotNull(
              user1Id, r'ConnectionCreateRequest', 'user1Id'),
          user2Id: BuiltValueNullFieldError.checkNotNull(
              user2Id, r'ConnectionCreateRequest', 'user2Id'),
          invitationId: BuiltValueNullFieldError.checkNotNull(
              invitationId, r'ConnectionCreateRequest', 'invitationId'),
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
