import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ConnectionsApi
void main() {
  final instance = Openapi().getConnectionsApi();

  group(ConnectionsApi, () {
    // Check If Connected
    //
    // Check if two users are connected.
    //
    //Future<JsonObject> checkIfConnectedApiV1ConnectionsCheckUser1IdUser2IdGet(int user1Id, int user2Id) async
    test('test checkIfConnectedApiV1ConnectionsCheckUser1IdUser2IdGet', () async {
      // TODO
    });

    // Create Connection
    //
    // Create a new connection between two users.
    //
    //Future<ConnectionRead> createConnectionApiV1ConnectionsPost(ConnectionCreateRequest connectionCreateRequest) async
    test('test createConnectionApiV1ConnectionsPost', () async {
      // TODO
    });

    // Get 1Hop Connections
    //
    // Get 1-hop connections (accepted) for a user.
    //
    //Future<JsonObject> get1hopConnectionsApiV1Connections1hopUserIdGet(int userId) async
    test('test get1hopConnectionsApiV1Connections1hopUserIdGet', () async {
      // TODO
    });

    // Get 2Hop Connections
    //
    // Get 2-hop user IDs for a user.
    //
    //Future<JsonObject> get2hopConnectionsApiV1Connections2hopUserIdGet(int userId) async
    test('test get2hopConnectionsApiV1Connections2hopUserIdGet', () async {
      // TODO
    });

    // Get Connection
    //
    // Get a connection by ID.
    //
    //Future<ConnectionRead> getConnectionApiV1ConnectionsConnectionIdGet(String connectionId) async
    test('test getConnectionApiV1ConnectionsConnectionIdGet', () async {
      // TODO
    });

    // Get Connection Between Users
    //
    // Get connection between two users.
    //
    //Future<ConnectionRead> getConnectionBetweenUsersApiV1ConnectionsBetweenUser1IdUser2IdGet(int user1Id, int user2Id) async
    test('test getConnectionBetweenUsersApiV1ConnectionsBetweenUser1IdUser2IdGet', () async {
      // TODO
    });

    // Get Connections
    //
    // Get multiple connections with pagination.
    //
    //Future<BuiltList<ConnectionRead>> getConnectionsApiV1ConnectionsGet({ int skip, int limit }) async
    test('test getConnectionsApiV1ConnectionsGet', () async {
      // TODO
    });

    // Get Pending Connections
    //
    // Get pending connections for a user.
    //
    //Future<JsonObject> getPendingConnectionsApiV1ConnectionsPendingUserIdGet(int userId) async
    test('test getPendingConnectionsApiV1ConnectionsPendingUserIdGet', () async {
      // TODO
    });

    // Get User Connections
    //
    // Get all connections for a user.
    //
    //Future<BuiltList<ConnectionRead>> getUserConnectionsApiV1ConnectionsUsersUserIdGet(int userId) async
    test('test getUserConnectionsApiV1ConnectionsUsersUserIdGet', () async {
      // TODO
    });

  });
}
