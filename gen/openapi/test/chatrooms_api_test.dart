import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ChatroomsApi
void main() {
  final instance = Openapi().getChatroomsApi();

  group(ChatroomsApi, () {
    // Create Chatroom With Invitation
    //
    // Create a new chat room with optional initial invitation message.
    //
    //Future<ChatRoomRead> createChatroomWithInvitationApiV1ChatroomsPost(ChatRoomCreateRequest chatRoomCreateRequest) async
    test('test createChatroomWithInvitationApiV1ChatroomsPost', () async {
      // TODO
    });

    // Delete Chat Room
    //
    // Delete a chat room.
    //
    //Future deleteChatRoomApiV1ChatroomsChatRoomIdDelete(String chatRoomId) async
    test('test deleteChatRoomApiV1ChatroomsChatRoomIdDelete', () async {
      // TODO
    });

    // Get Chat Room
    //
    // Get a chat room by ID.
    //
    //Future<ChatRoomRead> getChatRoomApiV1ChatroomsChatRoomIdGet(String chatRoomId) async
    test('test getChatRoomApiV1ChatroomsChatRoomIdGet', () async {
      // TODO
    });

    // Get Chat Rooms
    //
    // Get multiple chat rooms with pagination.
    //
    //Future<BuiltList<ChatRoomRead>> getChatRoomsApiV1ChatroomsGet({ int skip, int limit }) async
    test('test getChatRoomsApiV1ChatroomsGet', () async {
      // TODO
    });

    // Get Chat Rooms By Restaurant
    //
    // Get all chat rooms for a specific restaurant.
    //
    //Future<BuiltList<ChatRoomRead>> getChatRoomsByRestaurantApiV1ChatroomsRestaurantRestaurantGet(String restaurant) async
    test('test getChatRoomsByRestaurantApiV1ChatroomsRestaurantRestaurantGet', () async {
      // TODO
    });

    // Get Or Create Chat Room
    //
    // Get existing chat room between users or create a new one.
    //
    //Future<ChatRoomRead> getOrCreateChatRoomApiV1ChatroomsGetOrCreatePost(int user1Id, int user2Id, String restaurant) async
    test('test getOrCreateChatRoomApiV1ChatroomsGetOrCreatePost', () async {
      // TODO
    });

    // Get User Chat Rooms
    //
    // Get all chat rooms for a user.
    //
    //Future<BuiltList<ChatRoomRead>> getUserChatRoomsApiV1ChatroomsUsersUserIdGet(int userId) async
    test('test getUserChatRoomsApiV1ChatroomsUsersUserIdGet', () async {
      // TODO
    });

    // Update Chat Room
    //
    // Update a chat room.
    //
    //Future<ChatRoomRead> updateChatRoomApiV1ChatroomsChatRoomIdPut(String chatRoomId, BuiltMap<String, JsonObject> requestBody) async
    test('test updateChatRoomApiV1ChatroomsChatRoomIdPut', () async {
      // TODO
    });

  });
}
