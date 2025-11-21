import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DefaultApi
void main() {
  final instance = Openapi().getDefaultApi();

  group(DefaultApi, () {
    // Create Location
    //
    //Future<LocationRead> createLocationLocationsPost(LocationCreate locationCreate) async
    test('test createLocationLocationsPost', () async {
      // TODO
    });

    // Create User
    //
    //Future<UserRead> createUserUsersPost(UserCreate userCreate) async
    test('test createUserUsersPost', () async {
      // TODO
    });

    // Get Batch Locations
    //
    //Future<BuiltList<LocationRead>> getBatchLocationsLocationsBatchGet(String userIds) async
    test('test getBatchLocationsLocationsBatchGet', () async {
      // TODO
    });

    // Get Nearby Users
    //
    //Future<BuiltList<UserReadWithDistance>> getNearbyUsersUsersNearbyGet(num latitude, num longitude, { num radiusKm, int limit }) async
    test('test getNearbyUsersUsersNearbyGet', () async {
      // TODO
    });

    // Get User Locations
    //
    //Future<BuiltList<LocationRead>> getUserLocationsLocationsUserIdGet(int userId) async
    test('test getUserLocationsLocationsUserIdGet', () async {
      // TODO
    });

    // Get Users
    //
    //Future<BuiltList<UserRead>> getUsersUsersGet({ String school, String major, String interests, int limit, int offset }) async
    test('test getUsersUsersGet', () async {
      // TODO
    });

    // Health Check
    //
    //Future<JsonObject> healthCheckHealthGet() async
    test('test healthCheckHealthGet', () async {
      // TODO
    });

    // Root
    //
    //Future<JsonObject> rootGet() async
    test('test rootGet', () async {
      // TODO
    });

    // Visualize Db
    //
    //Future<String> visualizeDbVisualizeGet() async
    test('test visualizeDbVisualizeGet', () async {
      // TODO
    });

  });
}
