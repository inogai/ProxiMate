# openapi.api.ActivitiesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createActivityApiV1ActivitiesPost**](ActivitiesApi.md#createactivityapiv1activitiespost) | **POST** /api/v1/activities/ | Create Activity
[**deleteActivityApiV1ActivitiesActivityIdDelete**](ActivitiesApi.md#deleteactivityapiv1activitiesactivityiddelete) | **DELETE** /api/v1/activities/{activity_id} | Delete Activity
[**getActivitiesApiV1ActivitiesGet**](ActivitiesApi.md#getactivitiesapiv1activitiesget) | **GET** /api/v1/activities/ | Get Activities
[**getActivityApiV1ActivitiesActivityIdGet**](ActivitiesApi.md#getactivityapiv1activitiesactivityidget) | **GET** /api/v1/activities/{activity_id} | Get Activity
[**searchActivitiesApiV1ActivitiesSearchGet**](ActivitiesApi.md#searchactivitiesapiv1activitiessearchget) | **GET** /api/v1/activities/search | Search Activities
[**updateActivityApiV1ActivitiesActivityIdPut**](ActivitiesApi.md#updateactivityapiv1activitiesactivityidput) | **PUT** /api/v1/activities/{activity_id} | Update Activity


# **createActivityApiV1ActivitiesPost**
> ActivityRead createActivityApiV1ActivitiesPost(activityCreate)

Create Activity

Create a new activity.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getActivitiesApi();
final ActivityCreate activityCreate = ; // ActivityCreate | 

try {
    final response = api.createActivityApiV1ActivitiesPost(activityCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ActivitiesApi->createActivityApiV1ActivitiesPost: $e\n');
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

# **deleteActivityApiV1ActivitiesActivityIdDelete**
> deleteActivityApiV1ActivitiesActivityIdDelete(activityId)

Delete Activity

Delete an activity.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getActivitiesApi();
final String activityId = activityId_example; // String | 

try {
    api.deleteActivityApiV1ActivitiesActivityIdDelete(activityId);
} on DioException catch (e) {
    print('Exception when calling ActivitiesApi->deleteActivityApiV1ActivitiesActivityIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activityId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActivitiesApiV1ActivitiesGet**
> BuiltList<ActivityRead> getActivitiesApiV1ActivitiesGet(skip, limit)

Get Activities

Get multiple activities with pagination.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getActivitiesApi();
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.getActivitiesApiV1ActivitiesGet(skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ActivitiesApi->getActivitiesApiV1ActivitiesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;ActivityRead&gt;**](ActivityRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getActivityApiV1ActivitiesActivityIdGet**
> ActivityRead getActivityApiV1ActivitiesActivityIdGet(activityId)

Get Activity

Get an activity by ID.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getActivitiesApi();
final String activityId = activityId_example; // String | 

try {
    final response = api.getActivityApiV1ActivitiesActivityIdGet(activityId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ActivitiesApi->getActivityApiV1ActivitiesActivityIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activityId** | **String**|  | 

### Return type

[**ActivityRead**](ActivityRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchActivitiesApiV1ActivitiesSearchGet**
> BuiltList<ActivityRead> searchActivitiesApiV1ActivitiesSearchGet(q, skip, limit)

Search Activities

Search activities by name.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getActivitiesApi();
final String q = q_example; // String | Search query for activity names
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.searchActivitiesApiV1ActivitiesSearchGet(q, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ActivitiesApi->searchActivitiesApiV1ActivitiesSearchGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**| Search query for activity names | 
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;ActivityRead&gt;**](ActivityRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateActivityApiV1ActivitiesActivityIdPut**
> ActivityRead updateActivityApiV1ActivitiesActivityIdPut(activityId, requestBody)

Update Activity

Update an activity.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getActivitiesApi();
final String activityId = activityId_example; // String | 
final BuiltMap<String, JsonObject> requestBody = Object; // BuiltMap<String, JsonObject> | 

try {
    final response = api.updateActivityApiV1ActivitiesActivityIdPut(activityId, requestBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ActivitiesApi->updateActivityApiV1ActivitiesActivityIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activityId** | **String**|  | 
 **requestBody** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)|  | 

### Return type

[**ActivityRead**](ActivityRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

