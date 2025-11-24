import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:playground/services/chat_service.dart';
import 'package:playground/models/meeting.dart';

void main() {
  test(
    'ChatService polling calls refresh functions for rooms and messages',
    () async {
      final calls = <String>[];

      final rooms = [
        ChatRoom(
          id: 'r1',
          user1Id: '1',
          user2Id: '2',
          restaurant: 'A',
          createdAt: DateTime.now(),
        ),
        ChatRoom(
          id: 'r2',
          user1Id: '2',
          user2Id: '3',
          restaurant: 'B',
          createdAt: DateTime.now(),
        ),
      ];

      final service = ChatService(
        userId: 1,
        getChatRoomsOverride: () async => rooms,
        refreshChatRoomMessagesOverride: (id) async =>
            calls.add('refreshMsg:\$id'),
        refreshChatRoomsOverride: () async => calls.add('refreshRooms'),
        debugLog: (s) {},
      );

      // Ensure initial rooms are loaded so message polling has targets.
      await service.refreshChatRooms();

      service.startMessagePolling(interval: const Duration(milliseconds: 50));
      service.startChatRoomPolling(interval: const Duration(milliseconds: 80));

      // allow a few timer ticks
      await Future.delayed(const Duration(milliseconds: 220));

      // stop timers
      service.dispose();

      // Expected: at least one refresh for both rooms and at least one refreshRooms
      expect(calls.any((c) => c == 'refreshRooms'), isTrue);
      expect(
        calls.where((c) => c.startsWith('refreshMsg:')).length,
        greaterThanOrEqualTo(2),
      );
    },
  );
}
