import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DefaultApi
void main() {
  final instance = Openapi().getDefaultApi();

  group(DefaultApi, () {
    // Accept Invitation
    //
    //Future<JsonObject> acceptInvitationInvitationsInvitationIdAcceptPut(String invitationId) async
    test('test acceptInvitationInvitationsInvitationIdAcceptPut', () async {
      // TODO
    });

    // Collect Name Card
    //
    //Future<InvitationRead> collectNameCardInvitationsInvitationIdCollectNameCardPut(String invitationId) async
    test('test collectNameCardInvitationsInvitationIdCollectNameCardPut', () async {
      // TODO
    });

    // Create Activity
    //
    //Future<ActivityRead> createActivityActivitiesPost(ActivityCreate activityCreate) async
    test('test createActivityActivitiesPost', () async {
      // TODO
    });

    // Create Chatroom
    //
    //Future<ChatRoomRead> createChatroomChatroomsPost(ChatRoomBase chatRoomBase) async
    test('test createChatroomChatroomsPost', () async {
      // TODO
    });

    // Create Invitation
    //
    //Future<InvitationRead> createInvitationInvitationsPost(InvitationCreate invitationCreate) async
    test('test createInvitationInvitationsPost', () async {
      // TODO
    });

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

    // Decline Invitation
    //
    //Future<InvitationRead> declineInvitationInvitationsInvitationIdDeclinePut(String invitationId) async
    test('test declineInvitationInvitationsInvitationIdDeclinePut', () async {
      // TODO
    });

    // Delete Activity
    //
    //Future<JsonObject> deleteActivityActivitiesActivityIdDelete(String activityId) async
    test('test deleteActivityActivitiesActivityIdDelete', () async {
      // TODO
    });

    // Delete Avatar
    //
    //Future<BuiltMap<String, JsonObject>> deleteAvatarUsersUserIdAvatarDelete(int userId) async
    test('test deleteAvatarUsersUserIdAvatarDelete', () async {
      // TODO
    });

    // Find Chatroom Between Users
    //
    //Future<JsonObject> findChatroomBetweenUsersChatroomsFindGet(int user1Id, int user2Id) async
    test('test findChatroomBetweenUsersChatroomsFindGet', () async {
      // TODO
    });

    // Get Activities
    //
    //Future<BuiltList<ActivityRead>> getActivitiesActivitiesGet() async
    test('test getActivitiesActivitiesGet', () async {
      // TODO
    });

    // Get Batch Locations
    //
    //Future<BuiltList<LocationRead>> getBatchLocationsLocationsBatchGet(String userIds) async
    test('test getBatchLocationsLocationsBatchGet', () async {
      // TODO
    });

    // Get Chat Messages
    //
    //Future<BuiltList<ChatMessageRead>> getChatMessagesChatroomsChatroomIdMessagesGet(String chatroomId) async
    test('test getChatMessagesChatroomsChatroomIdMessagesGet', () async {
      // TODO
    });

    // Get Chatroom
    //
    //Future<ChatRoomRead> getChatroomChatroomsChatroomIdGet(String chatroomId) async
    test('test getChatroomChatroomsChatroomIdGet', () async {
      // TODO
    });

    // Get Chatrooms
    //
    //Future<BuiltList<ChatRoomRead>> getChatroomsChatroomsGet(int userId) async
    test('test getChatroomsChatroomsGet', () async {
      // TODO
    });

    // Get Invitations
    //
    //Future<BuiltList<InvitationRead>> getInvitationsInvitationsGet(int userId) async
    test('test getInvitationsInvitationsGet', () async {
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

    // Get User
    //
    //Future<UserRead> getUserUsersUserIdGet(int userId) async
    test('test getUserUsersUserIdGet', () async {
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

    // Mark Chat Opened
    //
    //Future<InvitationRead> markChatOpenedInvitationsInvitationIdChatOpenedPut(String invitationId) async
    test('test markChatOpenedInvitationsInvitationIdChatOpenedPut', () async {
      // TODO
    });

    // Mark Not Good Match
    //
    //Future<InvitationRead> markNotGoodMatchInvitationsInvitationIdNotGoodMatchPut(String invitationId) async
    test('test markNotGoodMatchInvitationsInvitationIdNotGoodMatchPut', () async {
      // TODO
    });

    // Root
    //
    //Future<JsonObject> rootGet() async
    test('test rootGet', () async {
      // TODO
    });

    // Send Chat Message
    //
    //Future<ChatMessageRead> sendChatMessageChatroomsChatroomIdMessagesPost(String chatroomId, ChatMessageCreateRequest chatMessageCreateRequest) async
    test('test sendChatMessageChatroomsChatroomIdMessagesPost', () async {
      // TODO
    });

    // Update User Location
    //
    //Future<LocationRead> updateUserLocationUsersUserIdLocationPost(int userId, LocationBase locationBase) async
    test('test updateUserLocationUsersUserIdLocationPost', () async {
      // TODO
    });

    // Update User
    //
    //Future<UserRead> updateUserUsersUserIdPut(int userId, UserUpdate userUpdate) async
    test('test updateUserUsersUserIdPut', () async {
      // TODO
    });

    // Upload Avatar
    //
    //Future<BuiltMap<String, JsonObject>> uploadAvatarUsersUserIdAvatarPost(int userId, MultipartFile file) async
    test('test uploadAvatarUsersUserIdAvatarPost', () async {
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
