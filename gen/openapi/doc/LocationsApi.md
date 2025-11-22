# openapi.api.LocationsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createLocationApiV1LocationsPost**](LocationsApi.md#createlocationapiv1locationspost) | **POST** /api/v1/locations/ | Create Location
[**deleteLocationApiV1LocationsLocationIdDelete**](LocationsApi.md#deletelocationapiv1locationslocationiddelete) | **DELETE** /api/v1/locations/{location_id} | Delete Location
[**findNearbyUsersApiV1LocationsNearbyUsersGet**](LocationsApi.md#findnearbyusersapiv1locationsnearbyusersget) | **GET** /api/v1/locations/nearby/users | Find Nearby Users
[**getBatchLocationsApiV1LocationsBatchGet**](LocationsApi.md#getbatchlocationsapiv1locationsbatchget) | **GET** /api/v1/locations/batch | Get Batch Locations
[**getLocationApiV1LocationsLocationIdGet**](LocationsApi.md#getlocationapiv1locationslocationidget) | **GET** /api/v1/locations/{location_id} | Get Location
[**getUserLatestLocationApiV1LocationsUsersUserIdLatestGet**](LocationsApi.md#getuserlatestlocationapiv1locationsusersuseridlatestget) | **GET** /api/v1/locations/users/{user_id}/latest | Get User Latest Location
[**getUserLocationHistoryApiV1LocationsUsersUserIdGet**](LocationsApi.md#getuserlocationhistoryapiv1locationsusersuseridget) | **GET** /api/v1/locations/users/{user_id} | Get User Location History
[**updateLocationApiV1LocationsLocationIdPut**](LocationsApi.md#updatelocationapiv1locationslocationidput) | **PUT** /api/v1/locations/{location_id} | Update Location


# **createLocationApiV1LocationsPost**
> LocationRead createLocationApiV1LocationsPost(locationCreate)

Create Location

Create a new location for a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLocationsApi();
final LocationCreate locationCreate = ; // LocationCreate | 

try {
    final response = api.createLocationApiV1LocationsPost(locationCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LocationsApi->createLocationApiV1LocationsPost: $e\n');
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

# **deleteLocationApiV1LocationsLocationIdDelete**
> deleteLocationApiV1LocationsLocationIdDelete(locationId)

Delete Location

Delete a location.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLocationsApi();
final int locationId = 56; // int | 

try {
    api.deleteLocationApiV1LocationsLocationIdDelete(locationId);
} on DioException catch (e) {
    print('Exception when calling LocationsApi->deleteLocationApiV1LocationsLocationIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **locationId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **findNearbyUsersApiV1LocationsNearbyUsersGet**
> BuiltList<UserReadWithDistance> findNearbyUsersApiV1LocationsNearbyUsersGet(latitude, longitude, radiusKm, limit)

Find Nearby Users

Find users within a specified radius.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLocationsApi();
final num latitude = 8.14; // num | Current latitude
final num longitude = 8.14; // num | Current longitude
final num radiusKm = 8.14; // num | Search radius in kilometers
final int limit = 56; // int | Maximum results

try {
    final response = api.findNearbyUsersApiV1LocationsNearbyUsersGet(latitude, longitude, radiusKm, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LocationsApi->findNearbyUsersApiV1LocationsNearbyUsersGet: $e\n');
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

# **getBatchLocationsApiV1LocationsBatchGet**
> BuiltList<LocationRead> getBatchLocationsApiV1LocationsBatchGet(userIds)

Get Batch Locations

Get latest locations for multiple users.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLocationsApi();
final String userIds = userIds_example; // String | Comma-separated list of user IDs

try {
    final response = api.getBatchLocationsApiV1LocationsBatchGet(userIds);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LocationsApi->getBatchLocationsApiV1LocationsBatchGet: $e\n');
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

# **getLocationApiV1LocationsLocationIdGet**
> LocationRead getLocationApiV1LocationsLocationIdGet(locationId)

Get Location

Get a specific location by ID.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLocationsApi();
final int locationId = 56; // int | 

try {
    final response = api.getLocationApiV1LocationsLocationIdGet(locationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LocationsApi->getLocationApiV1LocationsLocationIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **locationId** | **int**|  | 

### Return type

[**LocationRead**](LocationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserLatestLocationApiV1LocationsUsersUserIdLatestGet**
> LocationRead getUserLatestLocationApiV1LocationsUsersUserIdLatestGet(userId)

Get User Latest Location

Get latest location for a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLocationsApi();
final int userId = 56; // int | 

try {
    final response = api.getUserLatestLocationApiV1LocationsUsersUserIdLatestGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LocationsApi->getUserLatestLocationApiV1LocationsUsersUserIdLatestGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**LocationRead**](LocationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserLocationHistoryApiV1LocationsUsersUserIdGet**
> BuiltList<LocationRead> getUserLocationHistoryApiV1LocationsUsersUserIdGet(userId, limit)

Get User Location History

Get location history for a user.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLocationsApi();
final int userId = 56; // int | 
final int limit = 56; // int | Maximum number of locations

try {
    final response = api.getUserLocationHistoryApiV1LocationsUsersUserIdGet(userId, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LocationsApi->getUserLocationHistoryApiV1LocationsUsersUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 
 **limit** | **int**| Maximum number of locations | [optional] [default to 10]

### Return type

[**BuiltList&lt;LocationRead&gt;**](LocationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateLocationApiV1LocationsLocationIdPut**
> LocationRead updateLocationApiV1LocationsLocationIdPut(locationId, locationUpdate)

Update Location

Update an existing location.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLocationsApi();
final int locationId = 56; // int | 
final LocationUpdate locationUpdate = ; // LocationUpdate | 

try {
    final response = api.updateLocationApiV1LocationsLocationIdPut(locationId, locationUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LocationsApi->updateLocationApiV1LocationsLocationIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **locationId** | **int**|  | 
 **locationUpdate** | [**LocationUpdate**](LocationUpdate.md)|  | 

### Return type

[**LocationRead**](LocationRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

