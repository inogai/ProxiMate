// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_read.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InvitationRead extends InvitationRead {
  @override
  final int senderId;
  @override
  final int receiverId;
  @override
  final String activityId;
  @override
  final String restaurant;
  @override
  final String? status;
  @override
  final String? iceBreakers;
  @override
  final bool? sentByMe;
  @override
  final bool? nameCardCollected;
  @override
  final bool? chatOpened;
  @override
  final String id;
  @override
  final String createdAt;

  factory _$InvitationRead([void Function(InvitationReadBuilder)? updates]) =>
      (InvitationReadBuilder()..update(updates))._build();

  _$InvitationRead._(
      {required this.senderId,
      required this.receiverId,
      required this.activityId,
      required this.restaurant,
      this.status,
      this.iceBreakers,
      this.sentByMe,
      this.nameCardCollected,
      this.chatOpened,
      required this.id,
      required this.createdAt})
      : super._();
  @override
  InvitationRead rebuild(void Function(InvitationReadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InvitationReadBuilder toBuilder() => InvitationReadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InvitationRead &&
        senderId == other.senderId &&
        receiverId == other.receiverId &&
        activityId == other.activityId &&
        restaurant == other.restaurant &&
        status == other.status &&
        iceBreakers == other.iceBreakers &&
        sentByMe == other.sentByMe &&
        nameCardCollected == other.nameCardCollected &&
        chatOpened == other.chatOpened &&
        id == other.id &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jc(_$hash, receiverId.hashCode);
    _$hash = $jc(_$hash, activityId.hashCode);
    _$hash = $jc(_$hash, restaurant.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, iceBreakers.hashCode);
    _$hash = $jc(_$hash, sentByMe.hashCode);
    _$hash = $jc(_$hash, nameCardCollected.hashCode);
    _$hash = $jc(_$hash, chatOpened.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InvitationRead')
          ..add('senderId', senderId)
          ..add('receiverId', receiverId)
          ..add('activityId', activityId)
          ..add('restaurant', restaurant)
          ..add('status', status)
          ..add('iceBreakers', iceBreakers)
          ..add('sentByMe', sentByMe)
          ..add('nameCardCollected', nameCardCollected)
          ..add('chatOpened', chatOpened)
          ..add('id', id)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class InvitationReadBuilder
    implements Builder<InvitationRead, InvitationReadBuilder> {
  _$InvitationRead? _$v;

  int? _senderId;
  int? get senderId => _$this._senderId;
  set senderId(int? senderId) => _$this._senderId = senderId;

  int? _receiverId;
  int? get receiverId => _$this._receiverId;
  set receiverId(int? receiverId) => _$this._receiverId = receiverId;

  String? _activityId;
  String? get activityId => _$this._activityId;
  set activityId(String? activityId) => _$this._activityId = activityId;

  String? _restaurant;
  String? get restaurant => _$this._restaurant;
  set restaurant(String? restaurant) => _$this._restaurant = restaurant;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _iceBreakers;
  String? get iceBreakers => _$this._iceBreakers;
  set iceBreakers(String? iceBreakers) => _$this._iceBreakers = iceBreakers;

  bool? _sentByMe;
  bool? get sentByMe => _$this._sentByMe;
  set sentByMe(bool? sentByMe) => _$this._sentByMe = sentByMe;

  bool? _nameCardCollected;
  bool? get nameCardCollected => _$this._nameCardCollected;
  set nameCardCollected(bool? nameCardCollected) =>
      _$this._nameCardCollected = nameCardCollected;

  bool? _chatOpened;
  bool? get chatOpened => _$this._chatOpened;
  set chatOpened(bool? chatOpened) => _$this._chatOpened = chatOpened;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  InvitationReadBuilder() {
    InvitationRead._defaults(this);
  }

  InvitationReadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _senderId = $v.senderId;
      _receiverId = $v.receiverId;
      _activityId = $v.activityId;
      _restaurant = $v.restaurant;
      _status = $v.status;
      _iceBreakers = $v.iceBreakers;
      _sentByMe = $v.sentByMe;
      _nameCardCollected = $v.nameCardCollected;
      _chatOpened = $v.chatOpened;
      _id = $v.id;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InvitationRead other) {
    _$v = other as _$InvitationRead;
  }

  @override
  void update(void Function(InvitationReadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InvitationRead build() => _build();

  _$InvitationRead _build() {
    final _$result = _$v ??
        _$InvitationRead._(
          senderId: BuiltValueNullFieldError.checkNotNull(
              senderId, r'InvitationRead', 'senderId'),
          receiverId: BuiltValueNullFieldError.checkNotNull(
              receiverId, r'InvitationRead', 'receiverId'),
          activityId: BuiltValueNullFieldError.checkNotNull(
              activityId, r'InvitationRead', 'activityId'),
          restaurant: BuiltValueNullFieldError.checkNotNull(
              restaurant, r'InvitationRead', 'restaurant'),
          status: status,
          iceBreakers: iceBreakers,
          sentByMe: sentByMe,
          nameCardCollected: nameCardCollected,
          chatOpened: chatOpened,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'InvitationRead', 'id'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'InvitationRead', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
