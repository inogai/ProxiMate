import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for InvitationsApi
void main() {
  final instance = Openapi().getInvitationsApi();

  group(InvitationsApi, () {
    // Accept Invitation
    //
    // Accept an invitation.
    //
    //Future<InvitationRead> acceptInvitationApiV1InvitationsInvitationIdAcceptPost(String invitationId) async
    test('test acceptInvitationApiV1InvitationsInvitationIdAcceptPost', () async {
      // TODO
    });

    // Create Invitation
    //
    // Create a new invitation.
    //
    //Future<InvitationRead> createInvitationApiV1InvitationsPost(InvitationCreate invitationCreate) async
    test('test createInvitationApiV1InvitationsPost', () async {
      // TODO
    });

    // Decline Invitation
    //
    // Decline an invitation.
    //
    //Future<InvitationRead> declineInvitationApiV1InvitationsInvitationIdDeclinePost(String invitationId) async
    test('test declineInvitationApiV1InvitationsInvitationIdDeclinePost', () async {
      // TODO
    });

    // Delete Invitation
    //
    // Delete an invitation.
    //
    //Future deleteInvitationApiV1InvitationsInvitationIdDelete(String invitationId) async
    test('test deleteInvitationApiV1InvitationsInvitationIdDelete', () async {
      // TODO
    });

    // Get Activity Invitations
    //
    // Get all invitations for an activity.
    //
    //Future<BuiltList<InvitationRead>> getActivityInvitationsApiV1InvitationsActivityActivityIdGet(String activityId) async
    test('test getActivityInvitationsApiV1InvitationsActivityActivityIdGet', () async {
      // TODO
    });

    // Get Invitation
    //
    // Get an invitation by ID.
    //
    //Future<InvitationRead> getInvitationApiV1InvitationsInvitationIdGet(String invitationId) async
    test('test getInvitationApiV1InvitationsInvitationIdGet', () async {
      // TODO
    });

    // Get Invitations
    //
    // Get multiple invitations with pagination.
    //
    //Future<BuiltList<InvitationRead>> getInvitationsApiV1InvitationsGet({ int skip, int limit }) async
    test('test getInvitationsApiV1InvitationsGet', () async {
      // TODO
    });

    // Get Pending Invitations
    //
    // Get all pending invitations for a user.
    //
    //Future<BuiltList<InvitationRead>> getPendingInvitationsApiV1InvitationsPendingUserIdGet(int userId) async
    test('test getPendingInvitationsApiV1InvitationsPendingUserIdGet', () async {
      // TODO
    });

    // Get Received Invitations
    //
    // Get all invitations received by a user.
    //
    //Future<BuiltList<InvitationRead>> getReceivedInvitationsApiV1InvitationsReceivedUserIdGet(int userId) async
    test('test getReceivedInvitationsApiV1InvitationsReceivedUserIdGet', () async {
      // TODO
    });

    // Get Sent Invitations
    //
    // Get all invitations sent by a user.
    //
    //Future<BuiltList<InvitationRead>> getSentInvitationsApiV1InvitationsSentUserIdGet(int userId) async
    test('test getSentInvitationsApiV1InvitationsSentUserIdGet', () async {
      // TODO
    });

    // Update Invitation
    //
    // Update an invitation.
    //
    //Future<InvitationRead> updateInvitationApiV1InvitationsInvitationIdPut(String invitationId, BuiltMap<String, JsonObject> requestBody) async
    test('test updateInvitationApiV1InvitationsInvitationIdPut', () async {
      // TODO
    });

  });
}
