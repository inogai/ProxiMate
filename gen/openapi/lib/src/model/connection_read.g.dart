// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_read.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConnectionRead extends ConnectionRead {
  @override
  final int user1Id;
  @override
  final int user2Id;
  @override
  final String invitationId;
  @override
  final String id;
  @override
  final String createdAt;

  factory _$ConnectionRead([void Function(ConnectionReadBuilder)? updates]) =>
      (ConnectionReadBuilder()..update(updates))._build();

  _$ConnectionRead._(
      {required this.user1Id,
      required this.user2Id,
      required this.invitationId,
      required this.id,
      required this.createdAt})
      : super._();
  @override
  ConnectionRead rebuild(void Function(ConnectionReadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConnectionReadBuilder toBuilder() => ConnectionReadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConnectionRead &&
        user1Id == other.user1Id &&
        user2Id == other.user2Id &&
        invitationId == other.invitationId &&
        id == other.id &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user1Id.hashCode);
    _$hash = $jc(_$hash, user2Id.hashCode);
    _$hash = $jc(_$hash, invitationId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConnectionRead')
          ..add('user1Id', user1Id)
          ..add('user2Id', user2Id)
          ..add('invitationId', invitationId)
          ..add('id', id)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ConnectionReadBuilder
    implements Builder<ConnectionRead, ConnectionReadBuilder> {
  _$ConnectionRead? _$v;

  int? _user1Id;
  int? get user1Id => _$this._user1Id;
  set user1Id(int? user1Id) => _$this._user1Id = user1Id;

  int? _user2Id;
  int? get user2Id => _$this._user2Id;
  set user2Id(int? user2Id) => _$this._user2Id = user2Id;

  String? _invitationId;
  String? get invitationId => _$this._invitationId;
  set invitationId(String? invitationId) => _$this._invitationId = invitationId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  ConnectionReadBuilder() {
    ConnectionRead._defaults(this);
  }

  ConnectionReadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user1Id = $v.user1Id;
      _user2Id = $v.user2Id;
      _invitationId = $v.invitationId;
      _id = $v.id;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConnectionRead other) {
    _$v = other as _$ConnectionRead;
  }

  @override
  void update(void Function(ConnectionReadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConnectionRead build() => _build();

  _$ConnectionRead _build() {
    final _$result = _$v ??
        _$ConnectionRead._(
          user1Id: BuiltValueNullFieldError.checkNotNull(
              user1Id, r'ConnectionRead', 'user1Id'),
          user2Id: BuiltValueNullFieldError.checkNotNull(
              user2Id, r'ConnectionRead', 'user2Id'),
          invitationId: BuiltValueNullFieldError.checkNotNull(
              invitationId, r'ConnectionRead', 'invitationId'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ConnectionRead', 'id'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ConnectionRead', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
