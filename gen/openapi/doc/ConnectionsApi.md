# openapi.api.ConnectionsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**checkIfConnectedApiV1ConnectionsCheckUser1IdUser2IdGet**](ConnectionsApi.md#checkifconnectedapiv1connectionscheckuser1iduser2idget) | **GET** /api/v1/connections/check/{user1_id}/{user2_id} | Check If Connected
[**createConnectionApiV1ConnectionsPost**](ConnectionsApi.md#createconnectionapiv1connectionspost) | **POST** /api/v1/connections/ | Create Connection
[**getConnectionApiV1ConnectionsConnectionIdGet**](ConnectionsApi.md#getconnectionapiv1connectionsconnectionidget) | **GET** /api/v1/connections/{connection_id} | Get Connection
[**getConnectionBetweenUsersApiV1ConnectionsBetweenUser1IdUser2IdGet**](ConnectionsApi.md#getconnectionbetweenusersapiv1connectionsbetweenuser1iduser2idget) | **GET** /api/v1/connections/between/{user1_id}/{user2_id} | Get Connection Between Users
[**getConnectionsApiV1ConnectionsGet**](ConnectionsApi.md#getconnectionsapiv1connectionsget) | **GET** /api/v1/connections/ | Get Connections
[**getUserConnectionsApiV1ConnectionsUsersUserIdGet**](ConnectionsApi.md#getuserconnectionsapiv1connectionsusersuseridget) | **GET** /api/v1/connections/users/{user_id} | Get User Connections


# **checkIfConnectedApiV1ConnectionsCheckUser1IdUser2IdGet**
> JsonObject checkIfConnectedApiV1ConnectionsCheckUser1IdUser2IdGet(user1Id, user2Id)

Check If Connected

Check if two users are connected.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getConnectionsApi();
final int user1Id = 56; // int | 
final int user2Id = 56; // int | 

try {
    final response = api.checkIfConnectedApiV1ConnectionsCheckUser1IdUser2IdGet(user1Id, user2Id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConnectionsApi->checkIfConnectedApiV1ConnectionsCheckUser1IdUser2IdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **user1Id** | **int**|  | 
 **user2Id** | **int**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createConnectionApiV1ConnectionsPost**
> ConnectionRead createConnectionApiV1ConnectionsPost(user1Id, user2Id, invitationId)

Create Connection

Create a new connection between two users.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getConnectionsApi();
final int user1Id = 56; // int | 
final int user2Id = 56; // int | 
final String invitationId = invitationId_example; // String | 

try {
    final response = api.createConnectionApiV1ConnectionsPost(user1Id, user2Id, invitationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConnectionsApi->createConnectionApiV1ConnectionsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **user1Id** | **int**|  | 
 **user2Id** | **int**|  | 
 **invitationId** | **String**|  | 

### Return type

[**ConnectionRead**](ConnectionRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConnectionApiV1ConnectionsConnectionIdGet**
> ConnectionRead getConnectionApiV1ConnectionsConnectionIdGet(connectionId)

Get Connection

Get a connection by ID.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getConnectionsApi();
final String connectionId = connectionId_example; // String | 

try {
    final response = api.getConnectionApiV1ConnectionsConnectionIdGet(connectionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConnectionsApi->getConnectionApiV1ConnectionsConnectionIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **connectionId** | **String**|  | 

### Return type

[**ConnectionRead**](ConnectionRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConnectionBetweenUsersApiV1ConnectionsBetweenUser1IdUser2IdGet**
> ConnectionRead getConnectionBetweenUsersApiV1ConnectionsBetweenUser1IdUser2IdGet(user1Id, user2Id)

Get Connection Between Users

Get connection between two users.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getConnectionsApi();
final int user1Id = 56; // int | 
final int user2Id = 56; // int | 

try {
    final response = api.getConnectionBetweenUsersApiV1ConnectionsBetweenUser1IdUser2IdGet(user1Id, user2Id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConnectionsApi->getConnectionBetweenUsersApiV1ConnectionsBetweenUser1IdUser2IdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **user1Id** | **int**|  | 
 **user2Id** | **int**|  | 

### Return type

[**ConnectionRead**](ConnectionRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConnectionsApiV1ConnectionsGet**
> BuiltList<ConnectionRead> getConnectionsApiV1ConnectionsGet(skip, limit)

Get Connections

Get multiple connections with pagination.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getConnectionsApi();
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.getConnectionsApiV1ConnectionsGet(skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConnectionsApi->getConnectionsApiV1ConnectionsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;ConnectionRead&gt;**](ConnectionRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserConnectionsApiV1ConnectionsUsersUserIdGet**
> BuiltList<ConnectionRead> getUserConnectionsApiV1ConnectionsUsersUserIdGet(userId)

Get User Connections

Get all connections for a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getConnectionsApi();
final int userId = 56; // int | 

try {
    final response = api.getUserConnectionsApiV1ConnectionsUsersUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConnectionsApi->getUserConnectionsApiV1ConnectionsUsersUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**BuiltList&lt;ConnectionRead&gt;**](ConnectionRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

