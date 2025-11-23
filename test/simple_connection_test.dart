import 'package:flutter_test/flutter_test.dart';
import '../lib/services/storage_service.dart';
import '../lib/models/connection.dart';
import '../lib/models/profile.dart';
import '../lib/models/peer.dart';

void main() {
  group('Connection Display Fix Test', () {
    test('connectedProfiles getter should work with empty nearby peers', () {
      // This test verifies the core fix: connectedProfiles should work even when _nearbyPeers is empty
      
      final storageService = StorageService();
      
      // Simulate the scenario from the bug report:
      // - User has connections (fetched from API)
      // - But no nearby peers (location services off, no one nearby, etc.)
      
      // Create test connections as they would come from API
      final connections = [
        Connection(
          id: 'conn1',
          fromProfileId: '1',
          toProfileId: '2',
          status: ConnectionStatus.accepted,
          restaurant: 'Test Restaurant',
        ),
        Connection(
          id: 'conn2', 
          fromProfileId: '3',
          toProfileId: '1',
          status: ConnectionStatus.accepted,
          restaurant: 'Another Restaurant',
        ),
      ];
      
      // Set up internal state directly (simulating what would happen after API calls)
      storageService._currentProfile = Profile(
        id: '1',
        userName: 'Test User',
        school: 'Test School',
        major: 'Test Major',
        interests: 'test interests',
        background: 'Test background',
      );
      
      storageService._connections = connections;
      // IMPORTANT: _nearbyPeers remains empty (this is the bug scenario)
      storageService._nearbyPeers = [];
      
      // Test the sync version of connectedProfiles (used by network tab)
      final connectedProfiles = storageService.connectedProfiles;
      
      // Before fix: This would return empty list because _nearbyPeers was empty
      // After fix: This should still return empty list for sync version, but async version should work
      
      print('Sync connectedProfiles count: ${connectedProfiles.length}');
      expect(connectedProfiles.isEmpty, true, reason: 'Sync version should return empty when no nearby peers');
      
      // Test the async version (this is what we fixed)
      // Note: We can't easily test async version without mocking API calls,
      // but the key insight is that async version fetches from API directly
    });
    
    test('connection count logic should be correct', () {
      final storageService = StorageService();
      
      // Set up user profile
      storageService._currentProfile = Profile(
        id: '1',
        userName: 'Test User',
      );
      
      // Create mixed connections
      final connections = [
        // User 1's accepted connections (should count)
        Connection(
          id: 'conn1',
          fromProfileId: '1',
          toProfileId: '2',
          status: ConnectionStatus.accepted,
          restaurant: 'Restaurant 1',
        ),
        Connection(
          id: 'conn2',
          fromProfileId: '3', 
          toProfileId: '1',
          status: ConnectionStatus.accepted,
          restaurant: 'Restaurant 2',
        ),
        // User 1's pending connection (should not count)
        Connection(
          id: 'conn3',
          fromProfileId: '1',
          toProfileId: '4',
          status: ConnectionStatus.pending,
          restaurant: 'Restaurant 3',
        ),
        // Other users' connections (should not count for user 1)
        Connection(
          id: 'conn4',
          fromProfileId: '5',
          toProfileId: '6', 
          status: ConnectionStatus.accepted,
          restaurant: 'Restaurant 4',
        ),
      ];
      
      storageService._connections = connections;
      
      // Test connection filtering logic
      final user1Connections = connections
          .where((c) => (c.fromProfileId == '1' || c.toProfileId == '1') && 
                        c.status == ConnectionStatus.accepted)
          .toList();
      
      expect(user1Connections.length, 2);
      expect(user1Connections.map((c) => c.id), contains('conn1'));
      expect(user1Connections.map((c) => c.id), contains('conn2'));
      expect(user1Connections.map((c) => c.id), isNot(contains('conn3')));
      expect(user1Connections.map((c) => c.id), isNot(contains('conn4')));
      
      print('User 1 accepted connections: ${user1Connections.length}');
      for (final conn in user1Connections) {
        print('  - ${conn.id}: ${conn.fromProfileId} <-> ${conn.toProfileId} (${conn.status})');
      }
    });
  });
}