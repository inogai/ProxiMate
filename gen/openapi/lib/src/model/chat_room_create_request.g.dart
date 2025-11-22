// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatRoomCreateRequest extends ChatRoomCreateRequest {
  @override
  final int user1Id;
  @override
  final int user2Id;
  @override
  final String restaurant;
  @override
  final BuiltMap<String, JsonObject?>? invitationData;

  factory _$ChatRoomCreateRequest(
          [void Function(ChatRoomCreateRequestBuilder)? updates]) =>
      (ChatRoomCreateRequestBuilder()..update(updates))._build();

  _$ChatRoomCreateRequest._(
      {required this.user1Id,
      required this.user2Id,
      required this.restaurant,
      this.invitationData})
      : super._();
  @override
  ChatRoomCreateRequest rebuild(
          void Function(ChatRoomCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatRoomCreateRequestBuilder toBuilder() =>
      ChatRoomCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatRoomCreateRequest &&
        user1Id == other.user1Id &&
        user2Id == other.user2Id &&
        restaurant == other.restaurant &&
        invitationData == other.invitationData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user1Id.hashCode);
    _$hash = $jc(_$hash, user2Id.hashCode);
    _$hash = $jc(_$hash, restaurant.hashCode);
    _$hash = $jc(_$hash, invitationData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatRoomCreateRequest')
          ..add('user1Id', user1Id)
          ..add('user2Id', user2Id)
          ..add('restaurant', restaurant)
          ..add('invitationData', invitationData))
        .toString();
  }
}

class ChatRoomCreateRequestBuilder
    implements Builder<ChatRoomCreateRequest, ChatRoomCreateRequestBuilder> {
  _$ChatRoomCreateRequest? _$v;

  int? _user1Id;
  int? get user1Id => _$this._user1Id;
  set user1Id(int? user1Id) => _$this._user1Id = user1Id;

  int? _user2Id;
  int? get user2Id => _$this._user2Id;
  set user2Id(int? user2Id) => _$this._user2Id = user2Id;

  String? _restaurant;
  String? get restaurant => _$this._restaurant;
  set restaurant(String? restaurant) => _$this._restaurant = restaurant;

  MapBuilder<String, JsonObject?>? _invitationData;
  MapBuilder<String, JsonObject?> get invitationData =>
      _$this._invitationData ??= MapBuilder<String, JsonObject?>();
  set invitationData(MapBuilder<String, JsonObject?>? invitationData) =>
      _$this._invitationData = invitationData;

  ChatRoomCreateRequestBuilder() {
    ChatRoomCreateRequest._defaults(this);
  }

  ChatRoomCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user1Id = $v.user1Id;
      _user2Id = $v.user2Id;
      _restaurant = $v.restaurant;
      _invitationData = $v.invitationData?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatRoomCreateRequest other) {
    _$v = other as _$ChatRoomCreateRequest;
  }

  @override
  void update(void Function(ChatRoomCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatRoomCreateRequest build() => _build();

  _$ChatRoomCreateRequest _build() {
    _$ChatRoomCreateRequest _$result;
    try {
      _$result = _$v ??
          _$ChatRoomCreateRequest._(
            user1Id: BuiltValueNullFieldError.checkNotNull(
                user1Id, r'ChatRoomCreateRequest', 'user1Id'),
            user2Id: BuiltValueNullFieldError.checkNotNull(
                user2Id, r'ChatRoomCreateRequest', 'user2Id'),
            restaurant: BuiltValueNullFieldError.checkNotNull(
                restaurant, r'ChatRoomCreateRequest', 'restaurant'),
            invitationData: _invitationData?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'invitationData';
        _invitationData?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ChatRoomCreateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
