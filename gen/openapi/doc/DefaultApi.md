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
[**getBatchLocationsLocationsBatchGet**](DefaultApi.md#getbatchlocationslocationsbatchget) | **GET** /locations/batch | Get Batch Locations
[**getNearbyUsersUsersNearbyGet**](DefaultApi.md#getnearbyusersusersnearbyget) | **GET** /users/nearby | Get Nearby Users
[**getUserLocationsLocationsUserIdGet**](DefaultApi.md#getuserlocationslocationsuseridget) | **GET** /locations/{user_id} | Get User Locations
[**getUsersUsersGet**](DefaultApi.md#getusersusersget) | **GET** /users/ | Get Users
[**healthCheckHealthGet**](DefaultApi.md#healthcheckhealthget) | **GET** /health | Health Check
[**rootGet**](DefaultApi.md#rootget) | **GET** / | Root
[**visualizeDbVisualizeGet**](DefaultApi.md#visualizedbvisualizeget) | **GET** /visualize | Visualize Db


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

