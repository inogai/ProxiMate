// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_read.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatRoomRead extends ChatRoomRead {
  @override
  final int user1Id;
  @override
  final int user2Id;
  @override
  final String restaurant;
  @override
  final String id;
  @override
  final DateTime createdAt;

  factory _$ChatRoomRead([void Function(ChatRoomReadBuilder)? updates]) =>
      (ChatRoomReadBuilder()..update(updates))._build();

  _$ChatRoomRead._(
      {required this.user1Id,
      required this.user2Id,
      required this.restaurant,
      required this.id,
      required this.createdAt})
      : super._();
  @override
  ChatRoomRead rebuild(void Function(ChatRoomReadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatRoomReadBuilder toBuilder() => ChatRoomReadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatRoomRead &&
        user1Id == other.user1Id &&
        user2Id == other.user2Id &&
        restaurant == other.restaurant &&
        id == other.id &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user1Id.hashCode);
    _$hash = $jc(_$hash, user2Id.hashCode);
    _$hash = $jc(_$hash, restaurant.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatRoomRead')
          ..add('user1Id', user1Id)
          ..add('user2Id', user2Id)
          ..add('restaurant', restaurant)
          ..add('id', id)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ChatRoomReadBuilder
    implements Builder<ChatRoomRead, ChatRoomReadBuilder> {
  _$ChatRoomRead? _$v;

  int? _user1Id;
  int? get user1Id => _$this._user1Id;
  set user1Id(int? user1Id) => _$this._user1Id = user1Id;

  int? _user2Id;
  int? get user2Id => _$this._user2Id;
  set user2Id(int? user2Id) => _$this._user2Id = user2Id;

  String? _restaurant;
  String? get restaurant => _$this._restaurant;
  set restaurant(String? restaurant) => _$this._restaurant = restaurant;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ChatRoomReadBuilder() {
    ChatRoomRead._defaults(this);
  }

  ChatRoomReadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user1Id = $v.user1Id;
      _user2Id = $v.user2Id;
      _restaurant = $v.restaurant;
      _id = $v.id;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatRoomRead other) {
    _$v = other as _$ChatRoomRead;
  }

  @override
  void update(void Function(ChatRoomReadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatRoomRead build() => _build();

  _$ChatRoomRead _build() {
    final _$result = _$v ??
        _$ChatRoomRead._(
          user1Id: BuiltValueNullFieldError.checkNotNull(
              user1Id, r'ChatRoomRead', 'user1Id'),
          user2Id: BuiltValueNullFieldError.checkNotNull(
              user2Id, r'ChatRoomRead', 'user2Id'),
          restaurant: BuiltValueNullFieldError.checkNotNull(
              restaurant, r'ChatRoomRead', 'restaurant'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'ChatRoomRead', 'id'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ChatRoomRead', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
