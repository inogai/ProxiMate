// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_base.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatRoomBase extends ChatRoomBase {
  @override
  final int user1Id;
  @override
  final int user2Id;
  @override
  final String restaurant;

  factory _$ChatRoomBase([void Function(ChatRoomBaseBuilder)? updates]) =>
      (ChatRoomBaseBuilder()..update(updates))._build();

  _$ChatRoomBase._(
      {required this.user1Id, required this.user2Id, required this.restaurant})
      : super._();
  @override
  ChatRoomBase rebuild(void Function(ChatRoomBaseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatRoomBaseBuilder toBuilder() => ChatRoomBaseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatRoomBase &&
        user1Id == other.user1Id &&
        user2Id == other.user2Id &&
        restaurant == other.restaurant;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user1Id.hashCode);
    _$hash = $jc(_$hash, user2Id.hashCode);
    _$hash = $jc(_$hash, restaurant.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatRoomBase')
          ..add('user1Id', user1Id)
          ..add('user2Id', user2Id)
          ..add('restaurant', restaurant))
        .toString();
  }
}

class ChatRoomBaseBuilder
    implements Builder<ChatRoomBase, ChatRoomBaseBuilder> {
  _$ChatRoomBase? _$v;

  int? _user1Id;
  int? get user1Id => _$this._user1Id;
  set user1Id(int? user1Id) => _$this._user1Id = user1Id;

  int? _user2Id;
  int? get user2Id => _$this._user2Id;
  set user2Id(int? user2Id) => _$this._user2Id = user2Id;

  String? _restaurant;
  String? get restaurant => _$this._restaurant;
  set restaurant(String? restaurant) => _$this._restaurant = restaurant;

  ChatRoomBaseBuilder() {
    ChatRoomBase._defaults(this);
  }

  ChatRoomBaseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user1Id = $v.user1Id;
      _user2Id = $v.user2Id;
      _restaurant = $v.restaurant;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatRoomBase other) {
    _$v = other as _$ChatRoomBase;
  }

  @override
  void update(void Function(ChatRoomBaseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatRoomBase build() => _build();

  _$ChatRoomBase _build() {
    final _$result = _$v ??
        _$ChatRoomBase._(
          user1Id: BuiltValueNullFieldError.checkNotNull(
              user1Id, r'ChatRoomBase', 'user1Id'),
          user2Id: BuiltValueNullFieldError.checkNotNull(
              user2Id, r'ChatRoomBase', 'user2Id'),
          restaurant: BuiltValueNullFieldError.checkNotNull(
              restaurant, r'ChatRoomBase', 'restaurant'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
