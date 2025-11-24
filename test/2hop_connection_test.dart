import 'package:flutter_test/flutter_test.dart';
import 'package:playground/services/storage_service.dart';
import 'package:playground/models/profile.dart';

void main() {
  group('2-Hop Connection Tests', () {
    late StorageService storage;

    setUp(() {
      storage = StorageService();
    });

    test('getTwoHopConnectionsWithMapping returns profiles and connections', () async {
      final result = await storage.getTwoHopConnectionsWithMapping();
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('profiles'), isTrue);
      expect(result.containsKey('connections'), isTrue);
      
      final profiles = result['profiles'] as List<Profile>;
      final connections = result['connections'] as Map<String, String>;
      
      expect(profiles, isNotEmpty);
      expect(connections, isNotEmpty);
      
      // Verify each 2-hop profile has a connection mapping
      for (final profile in profiles) {
        expect(connections.containsKey(profile.id), isTrue,
            reason: '2-hop profile ${profile.id} should have a connection mapping');
      }
      
      print('✓ Found ${profiles.length} 2-hop profiles with ${connections.length} connections');
      
      // Print connection mappings for verification
      connections.forEach((twoHopId, oneHopId) {
        print('  2-hop $twoHopId -> 1-hop $oneHopId');
      });
    });

    test('2-hop connections have valid structure', () async {
      final result = await storage.getTwoHopConnectionsWithMapping();
      final profiles = result['profiles'] as List<Profile>;
      final connections = result['connections'] as Map<String, String>;

      // Verify each profile has required fields
      for (final profile in profiles) {
        expect(profile.id, isNotEmpty);
        expect(profile.userName, isNotEmpty);
        expect(profile.major, isNotNull);
        expect(profile.interests, isNotNull);
      }

      // Verify connection mappings are valid strings
      connections.forEach((twoHopId, oneHopId) {
        expect(twoHopId, isNotEmpty);
        expect(oneHopId, isNotEmpty);
      });
    });
  });
}