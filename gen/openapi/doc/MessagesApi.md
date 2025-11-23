# openapi.api.MessagesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**collectNameCardFromMessageApiV1MessagesMessageIdCollectCardPut**](MessagesApi.md#collectnamecardfrommessageapiv1messagesmessageidcollectcardput) | **PUT** /api/v1/messages/{message_id}/collect-card | Collect Name Card From Message
[**createConnectionRequestApiV1MessagesConnectionRequestPost**](MessagesApi.md#createconnectionrequestapiv1messagesconnectionrequestpost) | **POST** /api/v1/messages/connection-request | Create Connection Request
[**createInvitationMessageApiV1MessagesInvitationPost**](MessagesApi.md#createinvitationmessageapiv1messagesinvitationpost) | **POST** /api/v1/messages/invitation | Create Invitation Message
[**createMessageApiV1MessagesPost**](MessagesApi.md#createmessageapiv1messagespost) | **POST** /api/v1/messages/ | Create Message
[**deleteMessageApiV1MessagesMessageIdDelete**](MessagesApi.md#deletemessageapiv1messagesmessageiddelete) | **DELETE** /api/v1/messages/{message_id} | Delete Message
[**getChatRoomMessagesApiV1MessagesChatroomsChatRoomIdGet**](MessagesApi.md#getchatroommessagesapiv1messageschatroomschatroomidget) | **GET** /api/v1/messages/chatrooms/{chat_room_id} | Get Chat Room Messages
[**getInvitationMessagesApiV1MessagesInvitationsInvitationIdGet**](MessagesApi.md#getinvitationmessagesapiv1messagesinvitationsinvitationidget) | **GET** /api/v1/messages/invitations/{invitation_id} | Get Invitation Messages
[**getLatestMessageApiV1MessagesChatroomsChatRoomIdLatestGet**](MessagesApi.md#getlatestmessageapiv1messageschatroomschatroomidlatestget) | **GET** /api/v1/messages/chatrooms/{chat_room_id}/latest | Get Latest Message
[**getMessageApiV1MessagesMessageIdGet**](MessagesApi.md#getmessageapiv1messagesmessageidget) | **GET** /api/v1/messages/{message_id} | Get Message
[**getMessagesApiV1MessagesGet**](MessagesApi.md#getmessagesapiv1messagesget) | **GET** /api/v1/messages/ | Get Messages
[**getUserMessagesApiV1MessagesUsersSenderIdGet**](MessagesApi.md#getusermessagesapiv1messagesuserssenderidget) | **GET** /api/v1/messages/users/{sender_id} | Get User Messages
[**respondToConnectionRequestApiV1MessagesMessageIdConnectionRespondPut**](MessagesApi.md#respondtoconnectionrequestapiv1messagesmessageidconnectionrespondput) | **PUT** /api/v1/messages/{message_id}/connection-respond | Respond To Connection Request
[**respondToInvitationApiV1MessagesMessageIdInvitationRespondPut**](MessagesApi.md#respondtoinvitationapiv1messagesmessageidinvitationrespondput) | **PUT** /api/v1/messages/{message_id}/invitation-respond | Respond To Invitation
[**sendMessageApiV1MessagesSendPost**](MessagesApi.md#sendmessageapiv1messagessendpost) | **POST** /api/v1/messages/send | Send Message
[**updateMessageApiV1MessagesMessageIdPut**](MessagesApi.md#updatemessageapiv1messagesmessageidput) | **PUT** /api/v1/messages/{message_id} | Update Message


# **collectNameCardFromMessageApiV1MessagesMessageIdCollectCardPut**
> JsonObject collectNameCardFromMessageApiV1MessagesMessageIdCollectCardPut(messageId)

Collect Name Card From Message

Collect name card from accepted invitation and create connection.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String messageId = messageId_example; // String | 

try {
    final response = api.collectNameCardFromMessageApiV1MessagesMessageIdCollectCardPut(messageId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->collectNameCardFromMessageApiV1MessagesMessageIdCollectCardPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createConnectionRequestApiV1MessagesConnectionRequestPost**
> ChatMessageRead createConnectionRequestApiV1MessagesConnectionRequestPost(connectionRequestRequest, invitationId)

Create Connection Request

Create a new connection request message.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final ConnectionRequestRequest connectionRequestRequest = ; // ConnectionRequestRequest | 
final String invitationId = invitationId_example; // String | 

try {
    final response = api.createConnectionRequestApiV1MessagesConnectionRequestPost(connectionRequestRequest, invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->createConnectionRequestApiV1MessagesConnectionRequestPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **connectionRequestRequest** | [**ConnectionRequestRequest**](ConnectionRequestRequest.md)|  | 
 **invitationId** | **String**|  | [optional] 

### Return type

[**ChatMessageRead**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInvitationMessageApiV1MessagesInvitationPost**
> ChatMessageRead createInvitationMessageApiV1MessagesInvitationPost(chatRoomId, senderId, invitationId, activityId, restaurant, requestBody)

Create Invitation Message

Create a new invitation message.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String chatRoomId = chatRoomId_example; // String | 
final int senderId = 56; // int | 
final String invitationId = invitationId_example; // String | 
final String activityId = activityId_example; // String | 
final String restaurant = restaurant_example; // String | 
final BuiltList<String> requestBody = ; // BuiltList<String> | 

try {
    final response = api.createInvitationMessageApiV1MessagesInvitationPost(chatRoomId, senderId, invitationId, activityId, restaurant, requestBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->createInvitationMessageApiV1MessagesInvitationPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomId** | **String**|  | 
 **senderId** | **int**|  | 
 **invitationId** | **String**|  | 
 **activityId** | **String**|  | 
 **restaurant** | **String**|  | 
 **requestBody** | [**BuiltList&lt;String&gt;**](String.md)|  | [optional] 

### Return type

[**ChatMessageRead**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createMessageApiV1MessagesPost**
> ChatMessageRead createMessageApiV1MessagesPost(chatMessageCreate)

Create Message

Create a new chat message.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final ChatMessageCreate chatMessageCreate = ; // ChatMessageCreate | 

try {
    final response = api.createMessageApiV1MessagesPost(chatMessageCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->createMessageApiV1MessagesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatMessageCreate** | [**ChatMessageCreate**](ChatMessageCreate.md)|  | 

### Return type

[**ChatMessageRead**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteMessageApiV1MessagesMessageIdDelete**
> deleteMessageApiV1MessagesMessageIdDelete(messageId)

Delete Message

Delete a message.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String messageId = messageId_example; // String | 

try {
    api.deleteMessageApiV1MessagesMessageIdDelete(messageId);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->deleteMessageApiV1MessagesMessageIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatRoomMessagesApiV1MessagesChatroomsChatRoomIdGet**
> BuiltList<ChatMessageRead> getChatRoomMessagesApiV1MessagesChatroomsChatRoomIdGet(chatRoomId, skip, limit)

Get Chat Room Messages

Get all messages in a chat room.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String chatRoomId = chatRoomId_example; // String | 
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.getChatRoomMessagesApiV1MessagesChatroomsChatRoomIdGet(chatRoomId, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->getChatRoomMessagesApiV1MessagesChatroomsChatRoomIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomId** | **String**|  | 
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;ChatMessageRead&gt;**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvitationMessagesApiV1MessagesInvitationsInvitationIdGet**
> BuiltList<ChatMessageRead> getInvitationMessagesApiV1MessagesInvitationsInvitationIdGet(invitationId)

Get Invitation Messages

Get all messages related to an invitation.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.getInvitationMessagesApiV1MessagesInvitationsInvitationIdGet(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->getInvitationMessagesApiV1MessagesInvitationsInvitationIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationId** | **String**|  | 

### Return type

[**BuiltList&lt;ChatMessageRead&gt;**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLatestMessageApiV1MessagesChatroomsChatRoomIdLatestGet**
> ChatMessageRead getLatestMessageApiV1MessagesChatroomsChatRoomIdLatestGet(chatRoomId)

Get Latest Message

Get the latest message in a chat room.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String chatRoomId = chatRoomId_example; // String | 

try {
    final response = api.getLatestMessageApiV1MessagesChatroomsChatRoomIdLatestGet(chatRoomId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->getLatestMessageApiV1MessagesChatroomsChatRoomIdLatestGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomId** | **String**|  | 

### Return type

[**ChatMessageRead**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMessageApiV1MessagesMessageIdGet**
> ChatMessageRead getMessageApiV1MessagesMessageIdGet(messageId)

Get Message

Get a message by ID.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String messageId = messageId_example; // String | 

try {
    final response = api.getMessageApiV1MessagesMessageIdGet(messageId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->getMessageApiV1MessagesMessageIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **String**|  | 

### Return type

[**ChatMessageRead**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMessagesApiV1MessagesGet**
> BuiltList<ChatMessageRead> getMessagesApiV1MessagesGet(skip, limit)

Get Messages

Get multiple messages with pagination.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.getMessagesApiV1MessagesGet(skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->getMessagesApiV1MessagesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;ChatMessageRead&gt;**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserMessagesApiV1MessagesUsersSenderIdGet**
> BuiltList<ChatMessageRead> getUserMessagesApiV1MessagesUsersSenderIdGet(senderId)

Get User Messages

Get all messages sent by a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final int senderId = 56; // int | 

try {
    final response = api.getUserMessagesApiV1MessagesUsersSenderIdGet(senderId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->getUserMessagesApiV1MessagesUsersSenderIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **senderId** | **int**|  | 

### Return type

[**BuiltList&lt;ChatMessageRead&gt;**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **respondToConnectionRequestApiV1MessagesMessageIdConnectionRespondPut**
> JsonObject respondToConnectionRequestApiV1MessagesMessageIdConnectionRespondPut(messageId, connectionRespondRequest)

Respond To Connection Request

Respond to a connection request message.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String messageId = messageId_example; // String | 
final ConnectionRespondRequest connectionRespondRequest = ; // ConnectionRespondRequest | 

try {
    final response = api.respondToConnectionRequestApiV1MessagesMessageIdConnectionRespondPut(messageId, connectionRespondRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->respondToConnectionRequestApiV1MessagesMessageIdConnectionRespondPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **String**|  | 
 **connectionRespondRequest** | [**ConnectionRespondRequest**](ConnectionRespondRequest.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **respondToInvitationApiV1MessagesMessageIdInvitationRespondPut**
> JsonObject respondToInvitationApiV1MessagesMessageIdInvitationRespondPut(messageId, invitationRespondRequest)

Respond To Invitation

Respond to an invitation message.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String messageId = messageId_example; // String | 
final InvitationRespondRequest invitationRespondRequest = ; // InvitationRespondRequest | 

try {
    final response = api.respondToInvitationApiV1MessagesMessageIdInvitationRespondPut(messageId, invitationRespondRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->respondToInvitationApiV1MessagesMessageIdInvitationRespondPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **String**|  | 
 **invitationRespondRequest** | [**InvitationRespondRequest**](InvitationRespondRequest.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendMessageApiV1MessagesSendPost**
> ChatMessageRead sendMessageApiV1MessagesSendPost(chatRoomId, senderId, text, invitationId)

Send Message

Send a message in a chat room.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String chatRoomId = chatRoomId_example; // String | 
final int senderId = 56; // int | 
final String text = text_example; // String | 
final String invitationId = invitationId_example; // String | 

try {
    final response = api.sendMessageApiV1MessagesSendPost(chatRoomId, senderId, text, invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->sendMessageApiV1MessagesSendPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomId** | **String**|  | 
 **senderId** | **int**|  | 
 **text** | **String**|  | 
 **invitationId** | **String**|  | [optional] 

### Return type

[**ChatMessageRead**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateMessageApiV1MessagesMessageIdPut**
> ChatMessageRead updateMessageApiV1MessagesMessageIdPut(messageId, requestBody)

Update Message

Update a message.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessagesApi();
final String messageId = messageId_example; // String | 
final BuiltMap<String, JsonObject> requestBody = Object; // BuiltMap<String, JsonObject> | 

try {
    final response = api.updateMessageApiV1MessagesMessageIdPut(messageId, requestBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MessagesApi->updateMessageApiV1MessagesMessageIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **String**|  | 
 **requestBody** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)|  | 

### Return type

[**ChatMessageRead**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

