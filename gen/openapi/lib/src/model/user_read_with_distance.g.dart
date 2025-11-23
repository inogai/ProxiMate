// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_read_with_distance.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserReadWithDistance extends UserReadWithDistance {
  @override
  final int id;
  @override
  final String displayname;
  @override
  final String school;
  @override
  final String major;
  @override
  final String interests;
  @override
  final String bio;
  @override
  final String? avatarUrl;
  @override
  final String createdAt;
  @override
  final num? distanceKm;

  factory _$UserReadWithDistance(
          [void Function(UserReadWithDistanceBuilder)? updates]) =>
      (UserReadWithDistanceBuilder()..update(updates))._build();

  _$UserReadWithDistance._(
      {required this.id,
      required this.displayname,
      required this.school,
      required this.major,
      required this.interests,
      required this.bio,
      this.avatarUrl,
      required this.createdAt,
      this.distanceKm})
      : super._();
  @override
  UserReadWithDistance rebuild(
          void Function(UserReadWithDistanceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserReadWithDistanceBuilder toBuilder() =>
      UserReadWithDistanceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserReadWithDistance &&
        id == other.id &&
        displayname == other.displayname &&
        school == other.school &&
        major == other.major &&
        interests == other.interests &&
        bio == other.bio &&
        avatarUrl == other.avatarUrl &&
        createdAt == other.createdAt &&
        distanceKm == other.distanceKm;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayname.hashCode);
    _$hash = $jc(_$hash, school.hashCode);
    _$hash = $jc(_$hash, major.hashCode);
    _$hash = $jc(_$hash, interests.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, distanceKm.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserReadWithDistance')
          ..add('id', id)
          ..add('displayname', displayname)
          ..add('school', school)
          ..add('major', major)
          ..add('interests', interests)
          ..add('bio', bio)
          ..add('avatarUrl', avatarUrl)
          ..add('createdAt', createdAt)
          ..add('distanceKm', distanceKm))
        .toString();
  }
}

class UserReadWithDistanceBuilder
    implements Builder<UserReadWithDistance, UserReadWithDistanceBuilder> {
  _$UserReadWithDistance? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _displayname;
  String? get displayname => _$this._displayname;
  set displayname(String? displayname) => _$this._displayname = displayname;

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

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  num? _distanceKm;
  num? get distanceKm => _$this._distanceKm;
  set distanceKm(num? distanceKm) => _$this._distanceKm = distanceKm;

  UserReadWithDistanceBuilder() {
    UserReadWithDistance._defaults(this);
  }

  UserReadWithDistanceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayname = $v.displayname;
      _school = $v.school;
      _major = $v.major;
      _interests = $v.interests;
      _bio = $v.bio;
      _avatarUrl = $v.avatarUrl;
      _createdAt = $v.createdAt;
      _distanceKm = $v.distanceKm;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserReadWithDistance other) {
    _$v = other as _$UserReadWithDistance;
  }

  @override
  void update(void Function(UserReadWithDistanceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserReadWithDistance build() => _build();

  _$UserReadWithDistance _build() {
    final _$result = _$v ??
        _$UserReadWithDistance._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'UserReadWithDistance', 'id'),
          displayname: BuiltValueNullFieldError.checkNotNull(
              displayname, r'UserReadWithDistance', 'displayname'),
          school: BuiltValueNullFieldError.checkNotNull(
              school, r'UserReadWithDistance', 'school'),
          major: BuiltValueNullFieldError.checkNotNull(
              major, r'UserReadWithDistance', 'major'),
          interests: BuiltValueNullFieldError.checkNotNull(
              interests, r'UserReadWithDistance', 'interests'),
          bio: BuiltValueNullFieldError.checkNotNull(
              bio, r'UserReadWithDistance', 'bio'),
          avatarUrl: avatarUrl,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'UserReadWithDistance', 'createdAt'),
          distanceKm: distanceKm,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
