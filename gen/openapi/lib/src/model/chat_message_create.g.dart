// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessageCreate extends ChatMessageCreate {
  @override
  final String chatRoomId;
  @override
  final int senderId;
  @override
  final String text;
  @override
  final bool? isMine;
  @override
  final String? messageType;
  @override
  final String? invitationData;

  factory _$ChatMessageCreate(
          [void Function(ChatMessageCreateBuilder)? updates]) =>
      (ChatMessageCreateBuilder()..update(updates))._build();

  _$ChatMessageCreate._(
      {required this.chatRoomId,
      required this.senderId,
      required this.text,
      this.isMine,
      this.messageType,
      this.invitationData})
      : super._();
  @override
  ChatMessageCreate rebuild(void Function(ChatMessageCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageCreateBuilder toBuilder() =>
      ChatMessageCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessageCreate &&
        chatRoomId == other.chatRoomId &&
        senderId == other.senderId &&
        text == other.text &&
        isMine == other.isMine &&
        messageType == other.messageType &&
        invitationData == other.invitationData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, chatRoomId.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, isMine.hashCode);
    _$hash = $jc(_$hash, messageType.hashCode);
    _$hash = $jc(_$hash, invitationData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessageCreate')
          ..add('chatRoomId', chatRoomId)
          ..add('senderId', senderId)
          ..add('text', text)
          ..add('isMine', isMine)
          ..add('messageType', messageType)
          ..add('invitationData', invitationData))
        .toString();
  }
}

class ChatMessageCreateBuilder
    implements Builder<ChatMessageCreate, ChatMessageCreateBuilder> {
  _$ChatMessageCreate? _$v;

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

  String? _messageType;
  String? get messageType => _$this._messageType;
  set messageType(String? messageType) => _$this._messageType = messageType;

  String? _invitationData;
  String? get invitationData => _$this._invitationData;
  set invitationData(String? invitationData) =>
      _$this._invitationData = invitationData;

  ChatMessageCreateBuilder() {
    ChatMessageCreate._defaults(this);
  }

  ChatMessageCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _chatRoomId = $v.chatRoomId;
      _senderId = $v.senderId;
      _text = $v.text;
      _isMine = $v.isMine;
      _messageType = $v.messageType;
      _invitationData = $v.invitationData;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessageCreate other) {
    _$v = other as _$ChatMessageCreate;
  }

  @override
  void update(void Function(ChatMessageCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessageCreate build() => _build();

  _$ChatMessageCreate _build() {
    final _$result = _$v ??
        _$ChatMessageCreate._(
          chatRoomId: BuiltValueNullFieldError.checkNotNull(
              chatRoomId, r'ChatMessageCreate', 'chatRoomId'),
          senderId: BuiltValueNullFieldError.checkNotNull(
              senderId, r'ChatMessageCreate', 'senderId'),
          text: BuiltValueNullFieldError.checkNotNull(
              text, r'ChatMessageCreate', 'text'),
          isMine: isMine,
          messageType: messageType,
          invitationData: invitationData,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
