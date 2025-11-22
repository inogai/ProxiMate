// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_read.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActivityRead extends ActivityRead {
  @override
  final String name;
  @override
  final String description;
  @override
  final String id;
  @override
  final String createdAt;

  factory _$ActivityRead([void Function(ActivityReadBuilder)? updates]) =>
      (ActivityReadBuilder()..update(updates))._build();

  _$ActivityRead._(
      {required this.name,
      required this.description,
      required this.id,
      required this.createdAt})
      : super._();
  @override
  ActivityRead rebuild(void Function(ActivityReadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActivityReadBuilder toBuilder() => ActivityReadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActivityRead &&
        name == other.name &&
        description == other.description &&
        id == other.id &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActivityRead')
          ..add('name', name)
          ..add('description', description)
          ..add('id', id)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ActivityReadBuilder
    implements Builder<ActivityRead, ActivityReadBuilder> {
  _$ActivityRead? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  ActivityReadBuilder() {
    ActivityRead._defaults(this);
  }

  ActivityReadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _id = $v.id;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActivityRead other) {
    _$v = other as _$ActivityRead;
  }

  @override
  void update(void Function(ActivityReadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActivityRead build() => _build();

  _$ActivityRead _build() {
    final _$result = _$v ??
        _$ActivityRead._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ActivityRead', 'name'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'ActivityRead', 'description'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'ActivityRead', 'id'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ActivityRead', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
