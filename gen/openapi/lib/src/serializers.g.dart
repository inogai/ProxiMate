// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(ActivityCreate.serializer)
      ..add(ActivityRead.serializer)
      ..add(ChatMessageCreate.serializer)
      ..add(ChatMessageRead.serializer)
      ..add(ChatRoomCreateRequest.serializer)
      ..add(ChatRoomRead.serializer)
      ..add(ConnectionRead.serializer)
      ..add(HTTPValidationError.serializer)
      ..add(LocationCreate.serializer)
      ..add(LocationRead.serializer)
      ..add(LocationUpdate.serializer)
      ..add(UserCreate.serializer)
      ..add(UserRead.serializer)
      ..add(UserReadWithDistance.serializer)
      ..add(UserUpdate.serializer)
      ..add(ValidationError.serializer)
      ..add(ValidationErrorLocInner.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ValidationError)]),
          () => ListBuilder<ValidationError>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(ValidationErrorLocInner)]),
          () => ListBuilder<ValidationErrorLocInner>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
