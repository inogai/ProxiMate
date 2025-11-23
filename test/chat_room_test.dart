import 'package:flutter_test/flutter_test.dart';
import '../lib/models/meeting.dart';

void main() {
  group('Chat Room Model Tests', () {
    test('ChatRoom should create with user pair structure', () {
      final chatRoom = ChatRoom(
        id: 'test_chat_1',
        user1Id: 'user1',
        user2Id: 'user2',
        restaurant: 'Test Restaurant',
        createdAt: DateTime.now(),
      );

      expect(chatRoom.id, 'test_chat_1');
      expect(chatRoom.user1Id, 'user1');
      expect(chatRoom.user2Id, 'user2');
      expect(chatRoom.restaurant, 'Test Restaurant');
      expect(chatRoom.messages, isEmpty);
    });

    test('ChatRoom should correctly identify other user', () {
      final chatRoom = ChatRoom(
        id: 'test_chat_1',
        user1Id: 'user1',
        user2Id: 'user2',
        restaurant: 'Test Restaurant',
        createdAt: DateTime.now(),
      );

      expect(chatRoom.getOtherUserId('user1'), 'user2');
      expect(chatRoom.getOtherUserId('user2'), 'user1');
    });

    test('ChatRoom should correctly check user containment', () {
      final chatRoom = ChatRoom(
        id: 'test_chat_1',
        user1Id: 'user1',
        user2Id: 'user2',
        restaurant: 'Test Restaurant',
        createdAt: DateTime.now(),
      );

      expect(chatRoom.containsUser('user1'), isTrue);
      expect(chatRoom.containsUser('user2'), isTrue);
      expect(chatRoom.containsUser('user3'), isFalse);
    });

    test('ChatMessage should support system messages', () {
      final systemMessage = ChatMessage(
        id: 'system_msg_1',
        text: '🎉 Invitation accepted! Let\'s meet at Test Restaurant',
        isMine: false,
        timestamp: DateTime.now(),
        messageType: MessageType.system,
      );

      final regularMessage = ChatMessage(
        id: 'regular_msg_1',
        text: 'Hello there!',
        isMine: true,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      );

      expect(systemMessage.isSystemMessage, isTrue);
      expect(regularMessage.isSystemMessage, isFalse);
      expect(systemMessage.text, contains('🎉'));
    });

    test('ChatRoom should handle messages with system messages', () {
      final invitationMessage = ChatMessage(
        id: 'invitation_msg',
        text: '🎉 Invitation accepted! Let\'s meet at Test Restaurant',
        isMine: false,
        timestamp: DateTime.now(),
        messageType: MessageType.system,
      );

      final chatRoom = ChatRoom(
        id: 'test_chat_1',
        user1Id: 'user1',
        user2Id: 'user2',
        restaurant: 'Test Restaurant',
        createdAt: DateTime.now(),
        messages: [invitationMessage],
      );

      expect(chatRoom.messages.length, 1);
      expect(chatRoom.messages.first.isSystemMessage, isTrue);
      expect(chatRoom.messages.first.text, contains('Invitation accepted'));
    });
  });
}