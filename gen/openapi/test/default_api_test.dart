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

    // Get User Locations
    //
    //Future<BuiltList<LocationRead>> getUserLocationsLocationsUserIdGet(int userId) async
    test('test getUserLocationsLocationsUserIdGet', () async {
      // TODO
    });

    // Get User
    //
    //Future<UserRead> getUserUsersUserIdGet(int userId) async
    test('test getUserUsersUserIdGet', () async {
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

    // Update User
    //
    //Future<UserRead> updateUserUsersUserIdPut(int userId, UserUpdate userUpdate) async
    test('test updateUserUsersUserIdPut', () async {
      // TODO
    });

  });
}
