//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/activity_create.dart';
import 'package:openapi/src/model/activity_read.dart';
import 'package:openapi/src/model/chat_message_create.dart';
import 'package:openapi/src/model/chat_message_read.dart';
import 'package:openapi/src/model/chat_room_create_request.dart';
import 'package:openapi/src/model/chat_room_read.dart';
import 'package:openapi/src/model/connection_read.dart';
import 'package:openapi/src/model/http_validation_error.dart';
import 'package:openapi/src/model/location_create.dart';
import 'package:openapi/src/model/location_read.dart';
import 'package:openapi/src/model/location_update.dart';
import 'package:openapi/src/model/user_create.dart';
import 'package:openapi/src/model/user_read.dart';
import 'package:openapi/src/model/user_read_with_distance.dart';
import 'package:openapi/src/model/user_update.dart';
import 'package:openapi/src/model/validation_error.dart';
import 'package:openapi/src/model/validation_error_loc_inner.dart';

part 'serializers.g.dart';

@SerializersFor([
  ActivityCreate,
  ActivityRead,
  ChatMessageCreate,
  ChatMessageRead,
  ChatRoomCreateRequest,
  ChatRoomRead,
  ConnectionRead,
  HTTPValidationError,
  LocationCreate,
  LocationRead,
  LocationUpdate,
  UserCreate,
  UserRead,
  UserReadWithDistance,
  UserUpdate,
  ValidationError,
  ValidationErrorLocInner,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(UserReadWithDistance)]),
        () => ListBuilder<UserReadWithDistance>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ActivityRead)]),
        () => ListBuilder<ActivityRead>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ConnectionRead)]),
        () => ListBuilder<ConnectionRead>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ChatMessageRead)]),
        () => ListBuilder<ChatMessageRead>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
        () => MapBuilder<String, JsonObject>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(LocationRead)]),
        () => ListBuilder<LocationRead>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ChatRoomRead)]),
        () => ListBuilder<ChatRoomRead>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(UserRead)]),
        () => ListBuilder<UserRead>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
