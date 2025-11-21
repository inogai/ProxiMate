# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createLocationLocationsPost**](DefaultApi.md#createlocationlocationspost) | **POST** /locations/ | Create Location
[**createUserUsersPost**](DefaultApi.md#createuseruserspost) | **POST** /users/ | Create User
[**getUserLocationsLocationsUserIdGet**](DefaultApi.md#getuserlocationslocationsuseridget) | **GET** /locations/{user_id} | Get User Locations
[**getUserUsersUserIdGet**](DefaultApi.md#getuserusersuseridget) | **GET** /users/{user_id} | Get User
[**healthCheckHealthGet**](DefaultApi.md#healthcheckhealthget) | **GET** /health | Health Check
[**rootGet**](DefaultApi.md#rootget) | **GET** / | Root
[**updateUserUsersUserIdPut**](DefaultApi.md#updateuserusersuseridput) | **PUT** /users/{user_id} | Update User


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

