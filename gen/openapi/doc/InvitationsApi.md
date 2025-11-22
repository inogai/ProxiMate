# openapi.api.InvitationsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptInvitationApiV1InvitationsInvitationIdAcceptPost**](InvitationsApi.md#acceptinvitationapiv1invitationsinvitationidacceptpost) | **POST** /api/v1/invitations/{invitation_id}/accept | Accept Invitation
[**createInvitationApiV1InvitationsPost**](InvitationsApi.md#createinvitationapiv1invitationspost) | **POST** /api/v1/invitations/ | Create Invitation
[**declineInvitationApiV1InvitationsInvitationIdDeclinePost**](InvitationsApi.md#declineinvitationapiv1invitationsinvitationiddeclinepost) | **POST** /api/v1/invitations/{invitation_id}/decline | Decline Invitation
[**deleteInvitationApiV1InvitationsInvitationIdDelete**](InvitationsApi.md#deleteinvitationapiv1invitationsinvitationiddelete) | **DELETE** /api/v1/invitations/{invitation_id} | Delete Invitation
[**getActivityInvitationsApiV1InvitationsActivityActivityIdGet**](InvitationsApi.md#getactivityinvitationsapiv1invitationsactivityactivityidget) | **GET** /api/v1/invitations/activity/{activity_id} | Get Activity Invitations
[**getInvitationApiV1InvitationsInvitationIdGet**](InvitationsApi.md#getinvitationapiv1invitationsinvitationidget) | **GET** /api/v1/invitations/{invitation_id} | Get Invitation
[**getInvitationsApiV1InvitationsGet**](InvitationsApi.md#getinvitationsapiv1invitationsget) | **GET** /api/v1/invitations/ | Get Invitations
[**getPendingInvitationsApiV1InvitationsPendingUserIdGet**](InvitationsApi.md#getpendinginvitationsapiv1invitationspendinguseridget) | **GET** /api/v1/invitations/pending/{user_id} | Get Pending Invitations
[**getReceivedInvitationsApiV1InvitationsReceivedUserIdGet**](InvitationsApi.md#getreceivedinvitationsapiv1invitationsreceiveduseridget) | **GET** /api/v1/invitations/received/{user_id} | Get Received Invitations
[**getSentInvitationsApiV1InvitationsSentUserIdGet**](InvitationsApi.md#getsentinvitationsapiv1invitationssentuseridget) | **GET** /api/v1/invitations/sent/{user_id} | Get Sent Invitations
[**updateInvitationApiV1InvitationsInvitationIdPut**](InvitationsApi.md#updateinvitationapiv1invitationsinvitationidput) | **PUT** /api/v1/invitations/{invitation_id} | Update Invitation


# **acceptInvitationApiV1InvitationsInvitationIdAcceptPost**
> InvitationRead acceptInvitationApiV1InvitationsInvitationIdAcceptPost(invitationId)

Accept Invitation

Accept an invitation.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.acceptInvitationApiV1InvitationsInvitationIdAcceptPost(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->acceptInvitationApiV1InvitationsInvitationIdAcceptPost: $e\n');
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

# **createInvitationApiV1InvitationsPost**
> InvitationRead createInvitationApiV1InvitationsPost(invitationCreate)

Create Invitation

Create a new invitation.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final InvitationCreate invitationCreate = ; // InvitationCreate | 

try {
    final response = api.createInvitationApiV1InvitationsPost(invitationCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->createInvitationApiV1InvitationsPost: $e\n');
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

# **declineInvitationApiV1InvitationsInvitationIdDeclinePost**
> InvitationRead declineInvitationApiV1InvitationsInvitationIdDeclinePost(invitationId)

Decline Invitation

Decline an invitation.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.declineInvitationApiV1InvitationsInvitationIdDeclinePost(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->declineInvitationApiV1InvitationsInvitationIdDeclinePost: $e\n');
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

# **deleteInvitationApiV1InvitationsInvitationIdDelete**
> deleteInvitationApiV1InvitationsInvitationIdDelete(invitationId)

Delete Invitation

Delete an invitation.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final String invitationId = invitationId_example; // String | 

try {
    api.deleteInvitationApiV1InvitationsInvitationIdDelete(invitationId);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->deleteInvitationApiV1InvitationsInvitationIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActivityInvitationsApiV1InvitationsActivityActivityIdGet**
> BuiltList<InvitationRead> getActivityInvitationsApiV1InvitationsActivityActivityIdGet(activityId)

Get Activity Invitations

Get all invitations for an activity.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final String activityId = activityId_example; // String | 

try {
    final response = api.getActivityInvitationsApiV1InvitationsActivityActivityIdGet(activityId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->getActivityInvitationsApiV1InvitationsActivityActivityIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activityId** | **String**|  | 

### Return type

[**BuiltList&lt;InvitationRead&gt;**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvitationApiV1InvitationsInvitationIdGet**
> InvitationRead getInvitationApiV1InvitationsInvitationIdGet(invitationId)

Get Invitation

Get an invitation by ID.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final String invitationId = invitationId_example; // String | 

try {
    final response = api.getInvitationApiV1InvitationsInvitationIdGet(invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->getInvitationApiV1InvitationsInvitationIdGet: $e\n');
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

# **getInvitationsApiV1InvitationsGet**
> BuiltList<InvitationRead> getInvitationsApiV1InvitationsGet(skip, limit)

Get Invitations

Get multiple invitations with pagination.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.getInvitationsApiV1InvitationsGet(skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->getInvitationsApiV1InvitationsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;InvitationRead&gt;**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPendingInvitationsApiV1InvitationsPendingUserIdGet**
> BuiltList<InvitationRead> getPendingInvitationsApiV1InvitationsPendingUserIdGet(userId)

Get Pending Invitations

Get all pending invitations for a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final int userId = 56; // int | 

try {
    final response = api.getPendingInvitationsApiV1InvitationsPendingUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->getPendingInvitationsApiV1InvitationsPendingUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**BuiltList&lt;InvitationRead&gt;**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReceivedInvitationsApiV1InvitationsReceivedUserIdGet**
> BuiltList<InvitationRead> getReceivedInvitationsApiV1InvitationsReceivedUserIdGet(userId)

Get Received Invitations

Get all invitations received by a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final int userId = 56; // int | 

try {
    final response = api.getReceivedInvitationsApiV1InvitationsReceivedUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->getReceivedInvitationsApiV1InvitationsReceivedUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**BuiltList&lt;InvitationRead&gt;**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSentInvitationsApiV1InvitationsSentUserIdGet**
> BuiltList<InvitationRead> getSentInvitationsApiV1InvitationsSentUserIdGet(userId)

Get Sent Invitations

Get all invitations sent by a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final int userId = 56; // int | 

try {
    final response = api.getSentInvitationsApiV1InvitationsSentUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->getSentInvitationsApiV1InvitationsSentUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**BuiltList&lt;InvitationRead&gt;**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateInvitationApiV1InvitationsInvitationIdPut**
> InvitationRead updateInvitationApiV1InvitationsInvitationIdPut(invitationId, requestBody)

Update Invitation

Update an invitation.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInvitationsApi();
final String invitationId = invitationId_example; // String | 
final BuiltMap<String, JsonObject> requestBody = Object; // BuiltMap<String, JsonObject> | 

try {
    final response = api.updateInvitationApiV1InvitationsInvitationIdPut(invitationId, requestBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling InvitationsApi->updateInvitationApiV1InvitationsInvitationIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitationId** | **String**|  | 
 **requestBody** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)|  | 

### Return type

[**InvitationRead**](InvitationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

