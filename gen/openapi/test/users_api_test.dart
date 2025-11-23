import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for UsersApi
void main() {
  final instance = Openapi().getUsersApi();

  group(UsersApi, () {
    // Create User
    //
    // Create a new user.
    //
    //Future<UserRead> createUserApiV1UsersPost(UserCreate userCreate) async
    test('test createUserApiV1UsersPost', () async {
      // TODO
    });

    // Delete User
    //
    // Delete a user.
    //
    //Future deleteUserApiV1UsersUserIdDelete(int userId) async
    test('test deleteUserApiV1UsersUserIdDelete', () async {
      // TODO
    });

    // Get Or Create User
    //
    // Get existing user or create new one.
    //
    //Future<UserRead> getOrCreateUserApiV1UsersGetOrCreatePost(UserCreate userCreate) async
    test('test getOrCreateUserApiV1UsersGetOrCreatePost', () async {
      // TODO
    });

    // Get User
    //
    // Get a user by ID.
    //
    //Future<UserRead> getUserApiV1UsersUserIdGet(int userId) async
    test('test getUserApiV1UsersUserIdGet', () async {
      // TODO
    });

    // Get User By Username
    //
    // Get a user by username.
    //
    //Future<UserRead> getUserByUsernameApiV1UsersUsernameUsernameGet(String username) async
    test('test getUserByUsernameApiV1UsersUsernameUsernameGet', () async {
      // TODO
    });

    // Get Users
    //
    // Get multiple users with pagination.
    //
    //Future<BuiltList<UserRead>> getUsersApiV1UsersGet({ int skip, int limit }) async
    test('test getUsersApiV1UsersGet', () async {
      // TODO
    });

    // Remove Avatar
    //
    // Remove avatar for a user.
    //
    //Future<UserRead> removeAvatarApiV1UsersUserIdAvatarDelete(int userId) async
    test('test removeAvatarApiV1UsersUserIdAvatarDelete', () async {
      // TODO
    });

    // Update User
    //
    // Update a user.
    //
    //Future<UserRead> updateUserApiV1UsersUserIdPut(int userId, UserUpdate userUpdate) async
    test('test updateUserApiV1UsersUserIdPut', () async {
      // TODO
    });

    // Upload Avatar
    //
    // Upload avatar for a user.
    //
    //Future<UserRead> uploadAvatarApiV1UsersUserIdAvatarPost(int userId, MultipartFile file) async
    test('test uploadAvatarApiV1UsersUserIdAvatarPost', () async {
      // TODO
    });

  });
}
