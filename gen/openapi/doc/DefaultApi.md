# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthCheckApiV1HealthGet**](DefaultApi.md#healthcheckapiv1healthget) | **GET** /api/v1/health | Health Check
[**readRootGet**](DefaultApi.md#readrootget) | **GET** / | Read Root
[**visualizeDbApiV1VisualizeGet**](DefaultApi.md#visualizedbapiv1visualizeget) | **GET** /api/v1/visualize | Visualize Db


# **healthCheckApiV1HealthGet**
> JsonObject healthCheckApiV1HealthGet()

Health Check

Health check endpoint.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.healthCheckApiV1HealthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->healthCheckApiV1HealthGet: $e\n');
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

# **readRootGet**
> JsonObject readRootGet()

Read Root

Root endpoint.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.readRootGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->readRootGet: $e\n');
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

# **visualizeDbApiV1VisualizeGet**
> String visualizeDbApiV1VisualizeGet()

Visualize Db

Generate HTML visualization of all database data.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.visualizeDbApiV1VisualizeGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->visualizeDbApiV1VisualizeGet: $e\n');
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

