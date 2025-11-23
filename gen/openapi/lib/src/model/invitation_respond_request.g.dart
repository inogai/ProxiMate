// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_respond_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InvitationRespondRequest extends InvitationRespondRequest {
  @override
  final String action;
  @override
  final int responderId;

  factory _$InvitationRespondRequest(
          [void Function(InvitationRespondRequestBuilder)? updates]) =>
      (InvitationRespondRequestBuilder()..update(updates))._build();

  _$InvitationRespondRequest._(
      {required this.action, required this.responderId})
      : super._();
  @override
  InvitationRespondRequest rebuild(
          void Function(InvitationRespondRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InvitationRespondRequestBuilder toBuilder() =>
      InvitationRespondRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InvitationRespondRequest &&
        action == other.action &&
        responderId == other.responderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, responderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InvitationRespondRequest')
          ..add('action', action)
          ..add('responderId', responderId))
        .toString();
  }
}

class InvitationRespondRequestBuilder
    implements
        Builder<InvitationRespondRequest, InvitationRespondRequestBuilder> {
  _$InvitationRespondRequest? _$v;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  int? _responderId;
  int? get responderId => _$this._responderId;
  set responderId(int? responderId) => _$this._responderId = responderId;

  InvitationRespondRequestBuilder() {
    InvitationRespondRequest._defaults(this);
  }

  InvitationRespondRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _responderId = $v.responderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InvitationRespondRequest other) {
    _$v = other as _$InvitationRespondRequest;
  }

  @override
  void update(void Function(InvitationRespondRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InvitationRespondRequest build() => _build();

  _$InvitationRespondRequest _build() {
    final _$result = _$v ??
        _$InvitationRespondRequest._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'InvitationRespondRequest', 'action'),
          responderId: BuiltValueNullFieldError.checkNotNull(
              responderId, r'InvitationRespondRequest', 'responderId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
