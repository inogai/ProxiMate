import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for LocationsApi
void main() {
  final instance = Openapi().getLocationsApi();

  group(LocationsApi, () {
    // Create Location
    //
    // Create a new location for a user.
    //
    //Future<LocationRead> createLocationApiV1LocationsPost(LocationCreate locationCreate) async
    test('test createLocationApiV1LocationsPost', () async {
      // TODO
    });

    // Delete Location
    //
    // Delete a location.
    //
    //Future deleteLocationApiV1LocationsLocationIdDelete(int locationId) async
    test('test deleteLocationApiV1LocationsLocationIdDelete', () async {
      // TODO
    });

    // Find Nearby Users
    //
    // Find users within a specified radius.
    //
    //Future<BuiltList<UserReadWithDistance>> findNearbyUsersApiV1LocationsNearbyUsersGet(num latitude, num longitude, { num radiusKm, int limit }) async
    test('test findNearbyUsersApiV1LocationsNearbyUsersGet', () async {
      // TODO
    });

    // Get Batch Locations
    //
    // Get latest locations for multiple users.
    //
    //Future<BuiltList<LocationRead>> getBatchLocationsApiV1LocationsBatchGet(String userIds) async
    test('test getBatchLocationsApiV1LocationsBatchGet', () async {
      // TODO
    });

    // Get Location
    //
    // Get a specific location by ID.
    //
    //Future<LocationRead> getLocationApiV1LocationsLocationIdGet(int locationId) async
    test('test getLocationApiV1LocationsLocationIdGet', () async {
      // TODO
    });

    // Get User Latest Location
    //
    // Get latest location for a user.
    //
    //Future<LocationRead> getUserLatestLocationApiV1LocationsUsersUserIdLatestGet(int userId) async
    test('test getUserLatestLocationApiV1LocationsUsersUserIdLatestGet', () async {
      // TODO
    });

    // Get User Location History
    //
    // Get location history for a user.
    //
    //Future<BuiltList<LocationRead>> getUserLocationHistoryApiV1LocationsUsersUserIdGet(int userId, { int limit }) async
    test('test getUserLocationHistoryApiV1LocationsUsersUserIdGet', () async {
      // TODO
    });

    // Update Location
    //
    // Update an existing location.
    //
    //Future<LocationRead> updateLocationApiV1LocationsLocationIdPut(int locationId, LocationUpdate locationUpdate) async
    test('test updateLocationApiV1LocationsLocationIdPut', () async {
      // TODO
    });

  });
}
