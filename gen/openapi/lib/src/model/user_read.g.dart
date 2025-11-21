// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_read.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserRead extends UserRead {
  @override
  final String username;
  @override
  final String? school;
  @override
  final String? major;
  @override
  final String? interests;
  @override
  final String? bio;
  @override
  final String? avatarUrl;
  @override
  final int id;
  @override
  final DateTime createdAt;

  factory _$UserRead([void Function(UserReadBuilder)? updates]) =>
      (UserReadBuilder()..update(updates))._build();

  _$UserRead._(
      {required this.username,
      this.school,
      this.major,
      this.interests,
      this.bio,
      this.avatarUrl,
      required this.id,
      required this.createdAt})
      : super._();
  @override
  UserRead rebuild(void Function(UserReadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserReadBuilder toBuilder() => UserReadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserRead &&
        username == other.username &&
        school == other.school &&
        major == other.major &&
        interests == other.interests &&
        bio == other.bio &&
        avatarUrl == other.avatarUrl &&
        id == other.id &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, school.hashCode);
    _$hash = $jc(_$hash, major.hashCode);
    _$hash = $jc(_$hash, interests.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserRead')
          ..add('username', username)
          ..add('school', school)
          ..add('major', major)
          ..add('interests', interests)
          ..add('bio', bio)
          ..add('avatarUrl', avatarUrl)
          ..add('id', id)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class UserReadBuilder implements Builder<UserRead, UserReadBuilder> {
  _$UserRead? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _school;
  String? get school => _$this._school;
  set school(String? school) => _$this._school = school;

  String? _major;
  String? get major => _$this._major;
  set major(String? major) => _$this._major = major;

  String? _interests;
  String? get interests => _$this._interests;
  set interests(String? interests) => _$this._interests = interests;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  UserReadBuilder() {
    UserRead._defaults(this);
  }

  UserReadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _school = $v.school;
      _major = $v.major;
      _interests = $v.interests;
      _bio = $v.bio;
      _avatarUrl = $v.avatarUrl;
      _id = $v.id;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserRead other) {
    _$v = other as _$UserRead;
  }

  @override
  void update(void Function(UserReadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserRead build() => _build();

  _$UserRead _build() {
    final _$result = _$v ??
        _$UserRead._(
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'UserRead', 'username'),
          school: school,
          major: major,
          interests: interests,
          bio: bio,
          avatarUrl: avatarUrl,
          id: BuiltValueNullFieldError.checkNotNull(id, r'UserRead', 'id'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'UserRead', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
