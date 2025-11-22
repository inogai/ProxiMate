// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_read.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessageRead extends ChatMessageRead {
  @override
  final String chatRoomId;
  @override
  final int senderId;
  @override
  final String text;
  @override
  final bool? isMine;
  @override
  final String? invitationId;
  @override
  final String id;
  @override
  final DateTime timestamp;

  factory _$ChatMessageRead([void Function(ChatMessageReadBuilder)? updates]) =>
      (ChatMessageReadBuilder()..update(updates))._build();

  _$ChatMessageRead._(
      {required this.chatRoomId,
      required this.senderId,
      required this.text,
      this.isMine,
      this.invitationId,
      required this.id,
      required this.timestamp})
      : super._();
  @override
  ChatMessageRead rebuild(void Function(ChatMessageReadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageReadBuilder toBuilder() => ChatMessageReadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessageRead &&
        chatRoomId == other.chatRoomId &&
        senderId == other.senderId &&
        text == other.text &&
        isMine == other.isMine &&
        invitationId == other.invitationId &&
        id == other.id &&
        timestamp == other.timestamp;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, chatRoomId.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, isMine.hashCode);
    _$hash = $jc(_$hash, invitationId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessageRead')
          ..add('chatRoomId', chatRoomId)
          ..add('senderId', senderId)
          ..add('text', text)
          ..add('isMine', isMine)
          ..add('invitationId', invitationId)
          ..add('id', id)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class ChatMessageReadBuilder
    implements Builder<ChatMessageRead, ChatMessageReadBuilder> {
  _$ChatMessageRead? _$v;

  String? _chatRoomId;
  String? get chatRoomId => _$this._chatRoomId;
  set chatRoomId(String? chatRoomId) => _$this._chatRoomId = chatRoomId;

  int? _senderId;
  int? get senderId => _$this._senderId;
  set senderId(int? senderId) => _$this._senderId = senderId;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  bool? _isMine;
  bool? get isMine => _$this._isMine;
  set isMine(bool? isMine) => _$this._isMine = isMine;

  String? _invitationId;
  String? get invitationId => _$this._invitationId;
  set invitationId(String? invitationId) => _$this._invitationId = invitationId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  ChatMessageReadBuilder() {
    ChatMessageRead._defaults(this);
  }

  ChatMessageReadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _chatRoomId = $v.chatRoomId;
      _senderId = $v.senderId;
      _text = $v.text;
      _isMine = $v.isMine;
      _invitationId = $v.invitationId;
      _id = $v.id;
      _timestamp = $v.timestamp;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessageRead other) {
    _$v = other as _$ChatMessageRead;
  }

  @override
  void update(void Function(ChatMessageReadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessageRead build() => _build();

  _$ChatMessageRead _build() {
    final _$result = _$v ??
        _$ChatMessageRead._(
          chatRoomId: BuiltValueNullFieldError.checkNotNull(
              chatRoomId, r'ChatMessageRead', 'chatRoomId'),
          senderId: BuiltValueNullFieldError.checkNotNull(
              senderId, r'ChatMessageRead', 'senderId'),
          text: BuiltValueNullFieldError.checkNotNull(
              text, r'ChatMessageRead', 'text'),
          isMine: isMine,
          invitationId: invitationId,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ChatMessageRead', 'id'),
          timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp, r'ChatMessageRead', 'timestamp'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
