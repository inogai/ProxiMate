# openapi.api.UsersApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createUserApiV1UsersPost**](UsersApi.md#createuserapiv1userspost) | **POST** /api/v1/users/ | Create User
[**deleteUserApiV1UsersUserIdDelete**](UsersApi.md#deleteuserapiv1usersuseriddelete) | **DELETE** /api/v1/users/{user_id} | Delete User
[**getOrCreateUserApiV1UsersGetOrCreatePost**](UsersApi.md#getorcreateuserapiv1usersgetorcreatepost) | **POST** /api/v1/users/get-or-create | Get Or Create User
[**getUserApiV1UsersUserIdGet**](UsersApi.md#getuserapiv1usersuseridget) | **GET** /api/v1/users/{user_id} | Get User
[**getUserByUsernameApiV1UsersUsernameUsernameGet**](UsersApi.md#getuserbyusernameapiv1usersusernameusernameget) | **GET** /api/v1/users/username/{username} | Get User By Username
[**getUsersApiV1UsersGet**](UsersApi.md#getusersapiv1usersget) | **GET** /api/v1/users/ | Get Users
[**updateUserApiV1UsersUserIdPut**](UsersApi.md#updateuserapiv1usersuseridput) | **PUT** /api/v1/users/{user_id} | Update User


# **createUserApiV1UsersPost**
> UserRead createUserApiV1UsersPost(userCreate)

Create User

Create a new user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUsersApi();
final UserCreate userCreate = ; // UserCreate | 

try {
    final response = api.createUserApiV1UsersPost(userCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->createUserApiV1UsersPost: $e\n');
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

# **deleteUserApiV1UsersUserIdDelete**
> deleteUserApiV1UsersUserIdDelete(userId)

Delete User

Delete a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUsersApi();
final int userId = 56; // int | 

try {
    api.deleteUserApiV1UsersUserIdDelete(userId);
} on DioException catch (e) {
    print('Exception when calling UsersApi->deleteUserApiV1UsersUserIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOrCreateUserApiV1UsersGetOrCreatePost**
> UserRead getOrCreateUserApiV1UsersGetOrCreatePost(userCreate)

Get Or Create User

Get existing user or create new one.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUsersApi();
final UserCreate userCreate = ; // UserCreate | 

try {
    final response = api.getOrCreateUserApiV1UsersGetOrCreatePost(userCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getOrCreateUserApiV1UsersGetOrCreatePost: $e\n');
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

# **getUserApiV1UsersUserIdGet**
> UserRead getUserApiV1UsersUserIdGet(userId)

Get User

Get a user by ID.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUsersApi();
final int userId = 56; // int | 

try {
    final response = api.getUserApiV1UsersUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getUserApiV1UsersUserIdGet: $e\n');
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

# **getUserByUsernameApiV1UsersUsernameUsernameGet**
> UserRead getUserByUsernameApiV1UsersUsernameUsernameGet(username)

Get User By Username

Get a user by username.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUsersApi();
final String username = username_example; // String | 

try {
    final response = api.getUserByUsernameApiV1UsersUsernameUsernameGet(username);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getUserByUsernameApiV1UsersUsernameUsernameGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 

### Return type

[**UserRead**](UserRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUsersApiV1UsersGet**
> BuiltList<UserRead> getUsersApiV1UsersGet(skip, limit)

Get Users

Get multiple users with pagination.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUsersApi();
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.getUsersApiV1UsersGet(skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getUsersApiV1UsersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;UserRead&gt;**](UserRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUserApiV1UsersUserIdPut**
> UserRead updateUserApiV1UsersUserIdPut(userId, userUpdate)

Update User

Update a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUsersApi();
final int userId = 56; // int | 
final UserUpdate userUpdate = ; // UserUpdate | 

try {
    final response = api.updateUserApiV1UsersUserIdPut(userId, userUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->updateUserApiV1UsersUserIdPut: $e\n');
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

