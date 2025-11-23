// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_request_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConnectionRequestRequest extends ConnectionRequestRequest {
  @override
  final String chatRoomId;
  @override
  final int targetUserId;
  @override
  final int senderId;

  factory _$ConnectionRequestRequest(
          [void Function(ConnectionRequestRequestBuilder)? updates]) =>
      (ConnectionRequestRequestBuilder()..update(updates))._build();

  _$ConnectionRequestRequest._(
      {required this.chatRoomId,
      required this.targetUserId,
      required this.senderId})
      : super._();
  @override
  ConnectionRequestRequest rebuild(
          void Function(ConnectionRequestRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConnectionRequestRequestBuilder toBuilder() =>
      ConnectionRequestRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConnectionRequestRequest &&
        chatRoomId == other.chatRoomId &&
        targetUserId == other.targetUserId &&
        senderId == other.senderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, chatRoomId.hashCode);
    _$hash = $jc(_$hash, targetUserId.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConnectionRequestRequest')
          ..add('chatRoomId', chatRoomId)
          ..add('targetUserId', targetUserId)
          ..add('senderId', senderId))
        .toString();
  }
}

class ConnectionRequestRequestBuilder
    implements
        Builder<ConnectionRequestRequest, ConnectionRequestRequestBuilder> {
  _$ConnectionRequestRequest? _$v;

  String? _chatRoomId;
  String? get chatRoomId => _$this._chatRoomId;
  set chatRoomId(String? chatRoomId) => _$this._chatRoomId = chatRoomId;

  int? _targetUserId;
  int? get targetUserId => _$this._targetUserId;
  set targetUserId(int? targetUserId) => _$this._targetUserId = targetUserId;

  int? _senderId;
  int? get senderId => _$this._senderId;
  set senderId(int? senderId) => _$this._senderId = senderId;

  ConnectionRequestRequestBuilder() {
    ConnectionRequestRequest._defaults(this);
  }

  ConnectionRequestRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _chatRoomId = $v.chatRoomId;
      _targetUserId = $v.targetUserId;
      _senderId = $v.senderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConnectionRequestRequest other) {
    _$v = other as _$ConnectionRequestRequest;
  }

  @override
  void update(void Function(ConnectionRequestRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConnectionRequestRequest build() => _build();

  _$ConnectionRequestRequest _build() {
    final _$result = _$v ??
        _$ConnectionRequestRequest._(
          chatRoomId: BuiltValueNullFieldError.checkNotNull(
              chatRoomId, r'ConnectionRequestRequest', 'chatRoomId'),
          targetUserId: BuiltValueNullFieldError.checkNotNull(
              targetUserId, r'ConnectionRequestRequest', 'targetUserId'),
          senderId: BuiltValueNullFieldError.checkNotNull(
              senderId, r'ConnectionRequestRequest', 'senderId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
