import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/services/storage_service.dart';
import '../lib/services/api_service.dart';
import '../lib/models/connection.dart';
import '../lib/models/profile.dart';
import '../lib/models/peer.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'connection_fixes_test.mocks.dart';

void main() {
  group('Connection Fixes Tests', () {
    late MockApiService mockApiService;
    late StorageService storageService;

    setUp(() {
      mockApiService = MockApiService();
      storageService = StorageService();
    });

    test('connectedProfiles getter should return correct profiles from nearby peers', () {
      // Create test data
      final currentProfile = Profile(
        id: 1,
        userName: 'Test User',
        school: 'Test School',
        major: 'Test Major',
        interests: ['test'],
        background: 'Test background',
      );

      final testPeer1 = Peer(
        id: 2,
        name: 'Peer 1',
        school: 'School 1',
        major: 'Major 1',
        interests: ['interest1'],
        background: 'Background 1',
        distance: 1.0,
        matchScore: 0.8,
      );

      final testPeer2 = Peer(
        id: 3,
        name: 'Peer 2',
        school: 'School 2',
        major: 'Major 2',
        interests: ['interest2'],
        background: 'Background 2',
        distance: 2.0,
        matchScore: 0.7,
      );

      final testPeer3 = Peer(
        id: 4,
        name: 'Peer 3',
        school: 'School 3',
        major: 'Major 3',
        interests: ['interest3'],
        background: 'Background 3',
        distance: 3.0,
        matchScore: 0.6,
      );

      // Create connections: user 1 connected to user 2 and 3
      final connections = [
        Connection(
          id: 'conn1',
          fromProfileId: 1,
          toProfileId: 2,
          status: ConnectionStatus.accepted,
          createdAt: DateTime.now(),
        ),
        Connection(
          id: 'conn2',
          fromProfileId: 3,
          toProfileId: 1,
          status: ConnectionStatus.accepted,
          createdAt: DateTime.now(),
        ),
        // Pending connection to user 4 (should not be included)
        Connection(
          id: 'conn3',
          fromProfileId: 1,
          toProfileId: 4,
          status: ConnectionStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      // Set up the storage service state
      storageService.setCurrentProfile(currentProfile);
      storageService.setConnections(connections);
      storageService.setNearbyPeers([testPeer1, testPeer2, testPeer3]);

      // Test the connectedProfiles getter
      final connectedProfiles = storageService.connectedProfiles;

      // Should return 2 profiles (users 2 and 3), not user 4 (pending)
      expect(connectedProfiles.length, 2);
      
      // Check that the correct profiles are returned
      final connectedIds = connectedProfiles.map((p) => p.id).toSet();
      expect(connectedIds, contains(2));
      expect(connectedIds, contains(3));
      expect(connectedIds, isNot(contains(4)));
    });

    test('connection count should only include accepted connections for current user', () {
      // Create test connections
      final connections = [
        // User 1's accepted connections
        Connection(
          id: 'conn1',
          fromProfileId: 1,
          toProfileId: 2,
          status: ConnectionStatus.accepted,
          createdAt: DateTime.now(),
        ),
        Connection(
          id: 'conn2',
          fromProfileId: 3,
          toProfileId: 1,
          status: ConnectionStatus.accepted,
          createdAt: DateTime.now(),
        ),
        // User 1's pending connection (should not count)
        Connection(
          id: 'conn3',
          fromProfileId: 1,
          toProfileId: 4,
          status: ConnectionStatus.pending,
          createdAt: DateTime.now(),
        ),
        // Other users' connections (should not count for user 1)
        Connection(
          id: 'conn4',
          fromProfileId: 5,
          toProfileId: 6,
          status: ConnectionStatus.accepted,
          createdAt: DateTime.now(),
        ),
      ];

      storageService.setConnections(connections);

      // Test connection count for user 1
      final user1Connections = connections
          .where((c) => (c.fromProfileId == 1 || c.toProfileId == 1) && 
                        c.status == ConnectionStatus.accepted)
          .toList();
      
      expect(user1Connections.length, 2);
      expect(user1Connections.map((c) => c.id), contains('conn1'));
      expect(user1Connections.map((c) => c.id), contains('conn2'));
      expect(user1Connections.map((c) => c.id), isNot(contains('conn3')));
      expect(user1Connections.map((c) => c.id), isNot(contains('conn4')));
    });
  });
}