import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for MessagesApi
void main() {
  final instance = Openapi().getMessagesApi();

  group(MessagesApi, () {
    // Collect Name Card From Message
    //
    // Collect name card from accepted invitation.
    //
    //Future<JsonObject> collectNameCardFromMessageApiV1MessagesMessageIdCollectCardPut(String messageId) async
    test('test collectNameCardFromMessageApiV1MessagesMessageIdCollectCardPut', () async {
      // TODO
    });

    // Create Message
    //
    // Create a new chat message.
    //
    //Future<ChatMessageRead> createMessageApiV1MessagesPost(ChatMessageCreate chatMessageCreate) async
    test('test createMessageApiV1MessagesPost', () async {
      // TODO
    });

    // Delete Message
    //
    // Delete a message.
    //
    //Future deleteMessageApiV1MessagesMessageIdDelete(String messageId) async
    test('test deleteMessageApiV1MessagesMessageIdDelete', () async {
      // TODO
    });

    // Get Chat Room Messages
    //
    // Get all messages in a chat room.
    //
    //Future<BuiltList<ChatMessageRead>> getChatRoomMessagesApiV1MessagesChatroomsChatRoomIdGet(String chatRoomId, { int skip, int limit }) async
    test('test getChatRoomMessagesApiV1MessagesChatroomsChatRoomIdGet', () async {
      // TODO
    });

    // Get Invitation Messages
    //
    // Get all messages related to an invitation.
    //
    //Future<BuiltList<ChatMessageRead>> getInvitationMessagesApiV1MessagesInvitationsInvitationIdGet(String invitationId) async
    test('test getInvitationMessagesApiV1MessagesInvitationsInvitationIdGet', () async {
      // TODO
    });

    // Get Latest Message
    //
    // Get the latest message in a chat room.
    //
    //Future<ChatMessageRead> getLatestMessageApiV1MessagesChatroomsChatRoomIdLatestGet(String chatRoomId) async
    test('test getLatestMessageApiV1MessagesChatroomsChatRoomIdLatestGet', () async {
      // TODO
    });

    // Get Message
    //
    // Get a message by ID.
    //
    //Future<ChatMessageRead> getMessageApiV1MessagesMessageIdGet(String messageId) async
    test('test getMessageApiV1MessagesMessageIdGet', () async {
      // TODO
    });

    // Get Messages
    //
    // Get multiple messages with pagination.
    //
    //Future<BuiltList<ChatMessageRead>> getMessagesApiV1MessagesGet({ int skip, int limit }) async
    test('test getMessagesApiV1MessagesGet', () async {
      // TODO
    });

    // Get User Messages
    //
    // Get all messages sent by a user.
    //
    //Future<BuiltList<ChatMessageRead>> getUserMessagesApiV1MessagesUsersSenderIdGet(int senderId) async
    test('test getUserMessagesApiV1MessagesUsersSenderIdGet', () async {
      // TODO
    });

    // Respond To Invitation Message
    //
    // Accept or decline invitation message.
    //
    //Future<JsonObject> respondToInvitationMessageApiV1MessagesMessageIdRespondPut(String messageId, String action) async
    test('test respondToInvitationMessageApiV1MessagesMessageIdRespondPut', () async {
      // TODO
    });

    // Send Message
    //
    // Send a message in a chat room.
    //
    //Future<ChatMessageRead> sendMessageApiV1MessagesSendPost(String chatRoomId, int senderId, String text, { bool isMine, String invitationId }) async
    test('test sendMessageApiV1MessagesSendPost', () async {
      // TODO
    });

    // Update Message
    //
    // Update a message.
    //
    //Future<ChatMessageRead> updateMessageApiV1MessagesMessageIdPut(String messageId, BuiltMap<String, JsonObject> requestBody) async
    test('test updateMessageApiV1MessagesMessageIdPut', () async {
      // TODO
    });

  });
}
