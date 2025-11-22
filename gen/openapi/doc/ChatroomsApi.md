# openapi.api.ChatroomsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createChatroomWithInvitationApiV1ChatroomsPost**](ChatroomsApi.md#createchatroomwithinvitationapiv1chatroomspost) | **POST** /api/v1/chatrooms/ | Create Chatroom With Invitation
[**deleteChatRoomApiV1ChatroomsChatRoomIdDelete**](ChatroomsApi.md#deletechatroomapiv1chatroomschatroomiddelete) | **DELETE** /api/v1/chatrooms/{chat_room_id} | Delete Chat Room
[**getChatRoomApiV1ChatroomsChatRoomIdGet**](ChatroomsApi.md#getchatroomapiv1chatroomschatroomidget) | **GET** /api/v1/chatrooms/{chat_room_id} | Get Chat Room
[**getChatRoomsApiV1ChatroomsGet**](ChatroomsApi.md#getchatroomsapiv1chatroomsget) | **GET** /api/v1/chatrooms/ | Get Chat Rooms
[**getChatRoomsByRestaurantApiV1ChatroomsRestaurantRestaurantGet**](ChatroomsApi.md#getchatroomsbyrestaurantapiv1chatroomsrestaurantrestaurantget) | **GET** /api/v1/chatrooms/restaurant/{restaurant} | Get Chat Rooms By Restaurant
[**getOrCreateChatRoomApiV1ChatroomsGetOrCreatePost**](ChatroomsApi.md#getorcreatechatroomapiv1chatroomsgetorcreatepost) | **POST** /api/v1/chatrooms/get-or-create | Get Or Create Chat Room
[**getUserChatRoomsApiV1ChatroomsUsersUserIdGet**](ChatroomsApi.md#getuserchatroomsapiv1chatroomsusersuseridget) | **GET** /api/v1/chatrooms/users/{user_id} | Get User Chat Rooms
[**updateChatRoomApiV1ChatroomsChatRoomIdPut**](ChatroomsApi.md#updatechatroomapiv1chatroomschatroomidput) | **PUT** /api/v1/chatrooms/{chat_room_id} | Update Chat Room


# **createChatroomWithInvitationApiV1ChatroomsPost**
> ChatRoomRead createChatroomWithInvitationApiV1ChatroomsPost(chatRoomCreateRequest)

Create Chatroom With Invitation

Create a new chat room with optional initial invitation message.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatroomsApi();
final ChatRoomCreateRequest chatRoomCreateRequest = ; // ChatRoomCreateRequest | 

try {
    final response = api.createChatroomWithInvitationApiV1ChatroomsPost(chatRoomCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatroomsApi->createChatroomWithInvitationApiV1ChatroomsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomCreateRequest** | [**ChatRoomCreateRequest**](ChatRoomCreateRequest.md)|  | 

### Return type

[**ChatRoomRead**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteChatRoomApiV1ChatroomsChatRoomIdDelete**
> deleteChatRoomApiV1ChatroomsChatRoomIdDelete(chatRoomId)

Delete Chat Room

Delete a chat room.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatroomsApi();
final String chatRoomId = chatRoomId_example; // String | 

try {
    api.deleteChatRoomApiV1ChatroomsChatRoomIdDelete(chatRoomId);
} on DioException catch (e) {
    print('Exception when calling ChatroomsApi->deleteChatRoomApiV1ChatroomsChatRoomIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatRoomApiV1ChatroomsChatRoomIdGet**
> ChatRoomRead getChatRoomApiV1ChatroomsChatRoomIdGet(chatRoomId)

Get Chat Room

Get a chat room by ID.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatroomsApi();
final String chatRoomId = chatRoomId_example; // String | 

try {
    final response = api.getChatRoomApiV1ChatroomsChatRoomIdGet(chatRoomId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatroomsApi->getChatRoomApiV1ChatroomsChatRoomIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomId** | **String**|  | 

### Return type

[**ChatRoomRead**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatRoomsApiV1ChatroomsGet**
> BuiltList<ChatRoomRead> getChatRoomsApiV1ChatroomsGet(skip, limit)

Get Chat Rooms

Get multiple chat rooms with pagination.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatroomsApi();
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.getChatRoomsApiV1ChatroomsGet(skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatroomsApi->getChatRoomsApiV1ChatroomsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;ChatRoomRead&gt;**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatRoomsByRestaurantApiV1ChatroomsRestaurantRestaurantGet**
> BuiltList<ChatRoomRead> getChatRoomsByRestaurantApiV1ChatroomsRestaurantRestaurantGet(restaurant)

Get Chat Rooms By Restaurant

Get all chat rooms for a specific restaurant.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatroomsApi();
final String restaurant = restaurant_example; // String | 

try {
    final response = api.getChatRoomsByRestaurantApiV1ChatroomsRestaurantRestaurantGet(restaurant);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatroomsApi->getChatRoomsByRestaurantApiV1ChatroomsRestaurantRestaurantGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **restaurant** | **String**|  | 

### Return type

[**BuiltList&lt;ChatRoomRead&gt;**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOrCreateChatRoomApiV1ChatroomsGetOrCreatePost**
> ChatRoomRead getOrCreateChatRoomApiV1ChatroomsGetOrCreatePost(user1Id, user2Id, restaurant)

Get Or Create Chat Room

Get existing chat room between users or create a new one.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatroomsApi();
final int user1Id = 56; // int | 
final int user2Id = 56; // int | 
final String restaurant = restaurant_example; // String | 

try {
    final response = api.getOrCreateChatRoomApiV1ChatroomsGetOrCreatePost(user1Id, user2Id, restaurant);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatroomsApi->getOrCreateChatRoomApiV1ChatroomsGetOrCreatePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **user1Id** | **int**|  | 
 **user2Id** | **int**|  | 
 **restaurant** | **String**|  | 

### Return type

[**ChatRoomRead**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserChatRoomsApiV1ChatroomsUsersUserIdGet**
> BuiltList<ChatRoomRead> getUserChatRoomsApiV1ChatroomsUsersUserIdGet(userId)

Get User Chat Rooms

Get all chat rooms for a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatroomsApi();
final int userId = 56; // int | 

try {
    final response = api.getUserChatRoomsApiV1ChatroomsUsersUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatroomsApi->getUserChatRoomsApiV1ChatroomsUsersUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**BuiltList&lt;ChatRoomRead&gt;**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateChatRoomApiV1ChatroomsChatRoomIdPut**
> ChatRoomRead updateChatRoomApiV1ChatroomsChatRoomIdPut(chatRoomId, requestBody)

Update Chat Room

Update a chat room.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatroomsApi();
final String chatRoomId = chatRoomId_example; // String | 
final BuiltMap<String, JsonObject> requestBody = Object; // BuiltMap<String, JsonObject> | 

try {
    final response = api.updateChatRoomApiV1ChatroomsChatRoomIdPut(chatRoomId, requestBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatroomsApi->updateChatRoomApiV1ChatroomsChatRoomIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomId** | **String**|  | 
 **requestBody** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)|  | 

### Return type

[**ChatRoomRead**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

