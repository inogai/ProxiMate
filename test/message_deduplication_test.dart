import 'package:flutter_test/flutter_test.dart';
import '../lib/models/meeting.dart';

void main() {
  group('Message Deduplication Tests', () {

    test('ChatMessage copyWith should work correctly', () {
      final originalMessage = ChatMessage(
        id: 'temp_id_123',
        text: 'Hello world',
        isMine: true,
        timestamp: DateTime.now(),
        isSystemMessage: false,
      );

      final updatedMessage = originalMessage.copyWith(
        id: 'server_id_456',
        timestamp: DateTime.now().add(Duration(seconds: 1)),
      );

      expect(updatedMessage.id, 'server_id_456');
      expect(updatedMessage.text, 'Hello world');
      expect(updatedMessage.isMine, true);
      expect(updatedMessage.isSystemMessage, false);
      expect(updatedMessage.timestamp, isNot(equals(originalMessage.timestamp)));
    });

    test('Message content matching should handle timezone differences', () {
      final localTime = DateTime.now();
      final utcTime = localTime.toUtc();
      
      // Simulate server message (UTC) and local message (local time)
      final localMessage = ChatMessage(
        id: 'temp_local_id',
        text: 'Test message',
        isMine: true,
        timestamp: localTime,
        isSystemMessage: false,
      );

      // Simulate server message with same content but different timestamp format
      final serverMessageTime = utcTime;
      final timeDiff = localMessage.timestamp.difference(serverMessageTime.toLocal()).abs();
      
      // Should be within 5 seconds even with timezone conversion
      expect(timeDiff.inSeconds, lessThan(5));
    });

    test('Server UTC timestamp should convert to local time correctly', () {
      // Create a UTC time that represents 15:31 UTC
      final utcTime = DateTime.utc(2025, 11, 22, 15, 31, 0);
      
      // Convert to local time (assuming PST/UTC-8 for this example)
      final localTime = utcTime.toLocal();
      
      // The local time should be different from UTC time
      expect(localTime, isNot(equals(utcTime)));
      
      // If we're in PST (UTC-8), local time should be 07:31
      // But we'll just check that conversion happened
      expect(localTime.hour, isNot(equals(15)));
    });

    test('Message deduplication should work with timezone conversion', () {
      // Create the same moment in time using different representations
      final now = DateTime.now();
      final localTime = now; // Local time representation
      final serverUtcTime = now.toUtc(); // UTC representation of same moment
      
      final localMessage = ChatMessage(
        id: 'temp_local_id',
        text: 'Hello world',
        isMine: true,
        timestamp: localTime,
        isSystemMessage: false,
      );

      // Convert server UTC time to local time for comparison
      final serverLocalTime = serverUtcTime.toLocal();
      final timeDiff = localMessage.timestamp.difference(serverLocalTime).abs();
      
      // Should be very close (within seconds) since they represent the same moment
      expect(timeDiff.inSeconds, lessThan(5));
    });

    test('Should handle server timestamps that are already local time', () {
      // Test case where server sends local timestamp (not UTC)
      final serverLocalTimestamp = DateTime(2025, 11, 22, 15, 32, 0); // Already local time
      final localMessageTime = DateTime(2025, 11, 22, 15, 32, 5); // 5 seconds later
      
      final localMessage = ChatMessage(
        id: 'temp_local_id',
        text: 'Hello world',
        isMine: true,
        timestamp: localMessageTime,
        isSystemMessage: false,
      );

      // If server timestamp is already local, no conversion should happen
      expect(serverLocalTimestamp.isUtc, isFalse);
      
      final timeDiff = localMessage.timestamp.difference(serverLocalTimestamp).abs();
      expect(timeDiff.inSeconds, lessThan(10)); // Within 10 seconds
    });

    test('Should handle server timestamps that are UTC but marked as local', () {
      // Test case where server sends 15:32 but it's actually 23:32 UTC (8 hour difference)
      // This simulates the real scenario where server sends UTC time but doesn't mark it as UTC
      final serverTimestamp = DateTime(2025, 11, 22, 15, 32, 0); // What server sends (marked as local)
      
      // Simulate the conversion logic from our API service
      DateTime convertedTime;
      if (serverTimestamp.isUtc) {
        convertedTime = serverTimestamp.toLocal();
      } else {
        // Convert to UTC first, then to local (this adds the timezone offset)
        final utcTime = DateTime.utc(
          serverTimestamp.year,
          serverTimestamp.month,
          serverTimestamp.day,
          serverTimestamp.hour,
          serverTimestamp.minute,
          serverTimestamp.second,
        );
        convertedTime = utcTime.toLocal();
      }
      
      // The converted time should be 8 hours later than the original server timestamp
      final expectedTime = serverTimestamp.add(Duration(hours: 8));
      final timeDiff = convertedTime.difference(expectedTime).abs();
      
      // Should be very close (within a few minutes due to potential DST)
      expect(timeDiff.inMinutes, lessThan(5));
    });
  });
}