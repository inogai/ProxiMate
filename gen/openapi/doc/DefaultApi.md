# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptInvitationInvitationsInvitationIdAcceptPut**](DefaultApi.md#acceptinvitationinvitationsinvitationidacceptput) | **PUT** /invitations/{invitation_id}/accept | Accept Invitation
[**collectNameCardInvitationsInvitationIdCollectNameCardPut**](DefaultApi.md#collectnamecardinvitationsinvitationidcollectnamecardput) | **PUT** /invitations/{invitation_id}/collect-name-card | Collect Name Card
[**createActivityActivitiesPost**](DefaultApi.md#createactivityactivitiespost) | **POST** /activities | Create Activity
[**createChatroomChatroomsPost**](DefaultApi.md#createchatroomchatroomspost) | **POST** /chatrooms | Create Chatroom
[**createInvitationInvitationsPost**](DefaultApi.md#createinvitationinvitationspost) | **POST** /invitations | Create Invitation
[**createLocationLocationsPost**](DefaultApi.md#createlocationlocationspost) | **POST** /locations/ | Create Location
[**createUserUsersPost**](DefaultApi.md#createuseruserspost) | **POST** /users/ | Create User
[**declineInvitationInvitationsInvitationIdDeclinePut**](DefaultApi.md#declineinvitationinvitationsinvitationiddeclineput) | **PUT** /invitations/{invitation_id}/decline | Decline Invitation
[**deleteActivityActivitiesActivityIdDelete**](DefaultApi.md#deleteactivityactivitiesactivityiddelete) | **DELETE** /activities/{activity_id} | Delete Activity
[**deleteAvatarUsersUserIdAvatarDelete**](DefaultApi.md#deleteavatarusersuseridavatardelete) | **DELETE** /users/{user_id}/avatar | Delete Avatar
[**findChatroomBetweenUsersChatroomsFindGet**](DefaultApi.md#findchatroombetweenuserschatroomsfindget) | **GET** /chatrooms/find | Find Chatroom Between Users
[**getActivitiesActivitiesGet**](DefaultApi.md#getactivitiesactivitiesget) | **GET** /activities | Get Activities
[**getBatchLocationsLocationsBatchGet**](DefaultApi.md#getbatchlocationslocationsbatchget) | **GET** /locations/batch | Get Batch Locations
[**getChatMessagesChatroomsChatroomIdMessagesGet**](DefaultApi.md#getchatmessageschatroomschatroomidmessagesget) | **GET** /chatrooms/{chatroom_id}/messages | Get Chat Messages
[**getChatroomChatroomsChatroomIdGet**](DefaultApi.md#getchatroomchatroomschatroomidget) | **GET** /chatrooms/{chatroom_id} | Get Chatroom
[**getChatroomsChatroomsGet**](DefaultApi.md#getchatroomschatroomsget) | **GET** /chatrooms | Get Chatrooms
[**getInvitationsInvitationsGet**](DefaultApi.md#getinvitationsinvitationsget) | **GET** /invitations | Get Invitations
[**getNearbyUsersUsersNearbyGet**](DefaultApi.md#getnearbyusersusersnearbyget) | **GET** /users/nearby | Get Nearby Users
[**getUserLocationsLocationsUserIdGet**](DefaultApi.md#getuserlocationslocationsuseridget) | **GET** /locations/{user_id} | Get User Locations
[**getUserUsersUserIdGet**](DefaultApi.md#getuserusersuseridget) | **GET** /users/{user_id} | Get User
[**getUsersUsersGet**](DefaultApi.md#getusersusersget) | **GET** /users/ | Get Users
[**healthCheckHealthGet**](DefaultApi.md#healthcheckhealthget) | **GET** /health | Health Check
[**markChatOpenedInvitationsInvitationIdChatOpenedPut**](DefaultApi.md#markchatopenedinvitationsinvitationidchatopenedput) | **PUT** /invitations/{invitation_id}/chat-opened | Mark Chat Opened
[**markNotGoodMatchInvitationsInvitationIdNotGoodMatchPut**](DefaultApi.md#marknotgoodmatchinvitationsinvitationidnotgoodmatchput) | **PUT** /invitations/{invitation_id}/not-good-match | Mark Not Good Match
[**rootGet**](DefaultApi.md#rootget) | **GET** / | Root
[**sendChatMessageChatroomsChatroomIdMessagesPost**](DefaultApi.md#sendchatmessagechatroomschatroomidmessagespost) | **POST** /chatrooms/{chatroom_id}/messages | Send Chat Message
[**updateUserLocationUsersUserIdLocationPost**](DefaultApi.md#updateuserlocationusersuseridlocationpost) | **POST** /users/{user_id}/location | Update User Location
[**updateUserUsersUserIdPut**](DefaultApi.md#updateuserusersuseridput) | **PUT** /users/{user_id} | Update User
[**uploadAvatarUsersUserIdAvatarPost**](DefaultApi.md#uploadavatarusersuseridavatarpost) | **POST** /users/{user_id}/avatar | Upload Avatar
[**visualizeDbVisualizeGet**](DefaultApi.md#visualizedbvisualizeget) | **GET** /visualize | Visualize Db


# **acceptInvitationInvitationsInvitationIdAcceptPut**
> InvitationRead acceptInvitationInvitationsInvitationIdAcceptPut(invitationId)

Accept Invitation

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.acceptInvitationInvitationsInvitationIdAcceptPut(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->acceptInvitationInvitationsInvitationIdAcceptPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationId** | **String**|  | 

### Return type

[**InvitationRead**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **collectNameCardInvitationsInvitationIdCollectNameCardPut**
> InvitationRead collectNameCardInvitationsInvitationIdCollectNameCardPut(invitationId)

Collect Name Card

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.collectNameCardInvitationsInvitationIdCollectNameCardPut(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->collectNameCardInvitationsInvitationIdCollectNameCardPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationId** | **String**|  | 

### Return type

[**InvitationRead**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createActivityActivitiesPost**
> ActivityRead createActivityActivitiesPost(activityCreate)

Create Activity

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final ActivityCreate activityCreate = ; // ActivityCreate | 

try {
    final response = api.createActivityActivitiesPost(activityCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createActivityActivitiesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activityCreate** | [**ActivityCreate**](ActivityCreate.md)|  | 

### Return type

[**ActivityRead**](ActivityRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createChatroomChatroomsPost**
> ChatRoomRead createChatroomChatroomsPost(chatRoomBase)

Create Chatroom

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final ChatRoomBase chatRoomBase = ; // ChatRoomBase | 

try {
    final response = api.createChatroomChatroomsPost(chatRoomBase);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createChatroomChatroomsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatRoomBase** | [**ChatRoomBase**](ChatRoomBase.md)|  | 

### Return type

[**ChatRoomRead**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInvitationInvitationsPost**
> InvitationRead createInvitationInvitationsPost(invitationCreate)

Create Invitation

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final InvitationCreate invitationCreate = ; // InvitationCreate | 

try {
    final response = api.createInvitationInvitationsPost(invitationCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createInvitationInvitationsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationCreate** | [**InvitationCreate**](InvitationCreate.md)|  | 

### Return type

[**InvitationRead**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLocationLocationsPost**
> LocationRead createLocationLocationsPost(locationCreate)

Create Location

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final LocationCreate locationCreate = ; // LocationCreate | 

try {
    final response = api.createLocationLocationsPost(locationCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createLocationLocationsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **locationCreate** | [**LocationCreate**](LocationCreate.md)|  | 

### Return type

[**LocationRead**](LocationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createUserUsersPost**
> UserRead createUserUsersPost(userCreate)

Create User

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final UserCreate userCreate = ; // UserCreate | 

try {
    final response = api.createUserUsersPost(userCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createUserUsersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userCreate** | [**UserCreate**](UserCreate.md)|  | 

### Return type

[**UserRead**](UserRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **declineInvitationInvitationsInvitationIdDeclinePut**
> InvitationRead declineInvitationInvitationsInvitationIdDeclinePut(invitationId)

Decline Invitation

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.declineInvitationInvitationsInvitationIdDeclinePut(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->declineInvitationInvitationsInvitationIdDeclinePut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationId** | **String**|  | 

### Return type

[**InvitationRead**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteActivityActivitiesActivityIdDelete**
> JsonObject deleteActivityActivitiesActivityIdDelete(activityId)

Delete Activity

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String activityId = activityId_example; // String | 

try {
    final response = api.deleteActivityActivitiesActivityIdDelete(activityId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->deleteActivityActivitiesActivityIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activityId** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteAvatarUsersUserIdAvatarDelete**
> BuiltMap<String, JsonObject> deleteAvatarUsersUserIdAvatarDelete(userId)

Delete Avatar

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int userId = 56; // int | 

try {
    final response = api.deleteAvatarUsersUserIdAvatarDelete(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->deleteAvatarUsersUserIdAvatarDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **findChatroomBetweenUsersChatroomsFindGet**
> ChatRoomRead findChatroomBetweenUsersChatroomsFindGet(user1Id, user2Id)

Find Chatroom Between Users

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int user1Id = 56; // int | First user ID
final int user2Id = 56; // int | Second user ID

try {
    final response = api.findChatroomBetweenUsersChatroomsFindGet(user1Id, user2Id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->findChatroomBetweenUsersChatroomsFindGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **user1Id** | **int**| First user ID | 
 **user2Id** | **int**| Second user ID | 

### Return type

[**ChatRoomRead**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActivitiesActivitiesGet**
> BuiltList<ActivityRead> getActivitiesActivitiesGet()

Get Activities

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.getActivitiesActivitiesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getActivitiesActivitiesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;ActivityRead&gt;**](ActivityRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBatchLocationsLocationsBatchGet**
> BuiltList<LocationRead> getBatchLocationsLocationsBatchGet(userIds)

Get Batch Locations

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String userIds = userIds_example; // String | Comma-separated list of user IDs

try {
    final response = api.getBatchLocationsLocationsBatchGet(userIds);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getBatchLocationsLocationsBatchGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userIds** | **String**| Comma-separated list of user IDs | 

### Return type

[**BuiltList&lt;LocationRead&gt;**](LocationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatMessagesChatroomsChatroomIdMessagesGet**
> BuiltList<ChatMessageRead> getChatMessagesChatroomsChatroomIdMessagesGet(chatroomId)

Get Chat Messages

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String chatroomId = chatroomId_example; // String | 

try {
    final response = api.getChatMessagesChatroomsChatroomIdMessagesGet(chatroomId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getChatMessagesChatroomsChatroomIdMessagesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatroomId** | **String**|  | 

### Return type

[**BuiltList&lt;ChatMessageRead&gt;**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatroomChatroomsChatroomIdGet**
> ChatRoomRead getChatroomChatroomsChatroomIdGet(chatroomId)

Get Chatroom

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String chatroomId = chatroomId_example; // String | 

try {
    final response = api.getChatroomChatroomsChatroomIdGet(chatroomId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getChatroomChatroomsChatroomIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatroomId** | **String**|  | 

### Return type

[**ChatRoomRead**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatroomsChatroomsGet**
> BuiltList<ChatRoomRead> getChatroomsChatroomsGet(userId)

Get Chatrooms

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int userId = 56; // int | User ID to get chat rooms for

try {
    final response = api.getChatroomsChatroomsGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getChatroomsChatroomsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**| User ID to get chat rooms for | 

### Return type

[**BuiltList&lt;ChatRoomRead&gt;**](ChatRoomRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvitationsInvitationsGet**
> BuiltList<InvitationRead> getInvitationsInvitationsGet(userId)

Get Invitations

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int userId = 56; // int | User ID to get invitations for

try {
    final response = api.getInvitationsInvitationsGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getInvitationsInvitationsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**| User ID to get invitations for | 

### Return type

[**BuiltList&lt;InvitationRead&gt;**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNearbyUsersUsersNearbyGet**
> BuiltList<UserReadWithDistance> getNearbyUsersUsersNearbyGet(latitude, longitude, radiusKm, limit)

Get Nearby Users

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final num latitude = 8.14; // num | Current latitude
final num longitude = 8.14; // num | Current longitude
final num radiusKm = 8.14; // num | Search radius in kilometers
final int limit = 56; // int | Maximum results

try {
    final response = api.getNearbyUsersUsersNearbyGet(latitude, longitude, radiusKm, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getNearbyUsersUsersNearbyGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **latitude** | **num**| Current latitude | 
 **longitude** | **num**| Current longitude | 
 **radiusKm** | **num**| Search radius in kilometers | [optional] [default to 5.0]
 **limit** | **int**| Maximum results | [optional] [default to 20]

### Return type

[**BuiltList&lt;UserReadWithDistance&gt;**](UserReadWithDistance.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserLocationsLocationsUserIdGet**
> BuiltList<LocationRead> getUserLocationsLocationsUserIdGet(userId)

Get User Locations

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int userId = 56; // int | 

try {
    final response = api.getUserLocationsLocationsUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getUserLocationsLocationsUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**BuiltList&lt;LocationRead&gt;**](LocationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserUsersUserIdGet**
> UserRead getUserUsersUserIdGet(userId)

Get User

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int userId = 56; // int | 

try {
    final response = api.getUserUsersUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getUserUsersUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**UserRead**](UserRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUsersUsersGet**
> BuiltList<UserRead> getUsersUsersGet(school, major, interests, limit, offset)

Get Users

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String school = school_example; // String | Filter by school name
final String major = major_example; // String | Filter by major/field of study
final String interests = interests_example; // String | Filter by interests (partial match)
final int limit = 56; // int | Maximum number of results
final int offset = 56; // int | Pagination offset

try {
    final response = api.getUsersUsersGet(school, major, interests, limit, offset);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getUsersUsersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **school** | **String**| Filter by school name | [optional] 
 **major** | **String**| Filter by major/field of study | [optional] 
 **interests** | **String**| Filter by interests (partial match) | [optional] 
 **limit** | **int**| Maximum number of results | [optional] [default to 50]
 **offset** | **int**| Pagination offset | [optional] [default to 0]

### Return type

[**BuiltList&lt;UserRead&gt;**](UserRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **healthCheckHealthGet**
> JsonObject healthCheckHealthGet()

Health Check

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.healthCheckHealthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->healthCheckHealthGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markChatOpenedInvitationsInvitationIdChatOpenedPut**
> InvitationRead markChatOpenedInvitationsInvitationIdChatOpenedPut(invitationId)

Mark Chat Opened

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.markChatOpenedInvitationsInvitationIdChatOpenedPut(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->markChatOpenedInvitationsInvitationIdChatOpenedPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationId** | **String**|  | 

### Return type

[**InvitationRead**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markNotGoodMatchInvitationsInvitationIdNotGoodMatchPut**
> InvitationRead markNotGoodMatchInvitationsInvitationIdNotGoodMatchPut(invitationId)

Mark Not Good Match

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.markNotGoodMatchInvitationsInvitationIdNotGoodMatchPut(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->markNotGoodMatchInvitationsInvitationIdNotGoodMatchPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationId** | **String**|  | 

### Return type

[**InvitationRead**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rootGet**
> JsonObject rootGet()

Root

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.rootGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->rootGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendChatMessageChatroomsChatroomIdMessagesPost**
> ChatMessageRead sendChatMessageChatroomsChatroomIdMessagesPost(chatroomId, chatMessageCreateRequest)

Send Chat Message

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String chatroomId = chatroomId_example; // String | 
final ChatMessageCreateRequest chatMessageCreateRequest = ; // ChatMessageCreateRequest | 

try {
    final response = api.sendChatMessageChatroomsChatroomIdMessagesPost(chatroomId, chatMessageCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->sendChatMessageChatroomsChatroomIdMessagesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatroomId** | **String**|  | 
 **chatMessageCreateRequest** | [**ChatMessageCreateRequest**](ChatMessageCreateRequest.md)|  | 

### Return type

[**ChatMessageRead**](ChatMessageRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUserLocationUsersUserIdLocationPost**
> LocationRead updateUserLocationUsersUserIdLocationPost(userId, locationBase)

Update User Location

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int userId = 56; // int | 
final LocationBase locationBase = ; // LocationBase | 

try {
    final response = api.updateUserLocationUsersUserIdLocationPost(userId, locationBase);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateUserLocationUsersUserIdLocationPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 
 **locationBase** | [**LocationBase**](LocationBase.md)|  | 

### Return type

[**LocationRead**](LocationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUserUsersUserIdPut**
> UserRead updateUserUsersUserIdPut(userId, userUpdate)

Update User

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int userId = 56; // int | 
final UserUpdate userUpdate = ; // UserUpdate | 

try {
    final response = api.updateUserUsersUserIdPut(userId, userUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateUserUsersUserIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 
 **userUpdate** | [**UserUpdate**](UserUpdate.md)|  | 

### Return type

[**UserRead**](UserRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadAvatarUsersUserIdAvatarPost**
> BuiltMap<String, JsonObject> uploadAvatarUsersUserIdAvatarPost(userId, file)

Upload Avatar

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final int userId = 56; // int | 
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | 

try {
    final response = api.uploadAvatarUsersUserIdAvatarPost(userId, file);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->uploadAvatarUsersUserIdAvatarPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 
 **file** | **MultipartFile**|  | 

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **visualizeDbVisualizeGet**
> String visualizeDbVisualizeGet()

Visualize Db

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.visualizeDbVisualizeGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->visualizeDbVisualizeGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/html

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

