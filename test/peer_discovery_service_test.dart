import 'package:flutter_test/flutter_test.dart';
import 'package:built_collection/built_collection.dart';

import '../lib/services/peer_discovery_service.dart';
import '../lib/services/api_service.dart';
import '../lib/models/profile.dart';
import 'package:openapi/openapi.dart';

class FakeApiService extends ApiService {
  FakeApiService() : super(baseUrl: 'http://localhost:8000');

  @override
  Future<BuiltList<UserReadWithDistance>> getNearbyUsers(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
    int? limit,
  }) async {
    final users = [
      UserReadWithDistance(
        (b) => b
          ..id = 2
          ..displayname = 'Alice'
          ..school = 'MIT'
          ..major = 'Computer Science'
          ..interests = 'AI,ML'
          ..bio = 'Grad student'
          ..avatarUrl = 'https://example.com/alice.png'
          ..createdAt = '2023-01-01T00:00:00Z'
          ..distanceKm = 1.5,
      ),
      UserReadWithDistance(
        (b) => b
          ..id = 3
          ..displayname = 'Bob'
          ..school = 'Stanford'
          ..major = 'Design'
          ..interests = 'UI/UX'
          ..bio = 'Designer'
          ..avatarUrl = 'https://example.com/bob.png'
          ..createdAt = '2023-01-01T00:00:00Z'
          ..distanceKm = 0.5,
      ),
    ];

    return BuiltList<UserReadWithDistance>(users);
  }
}

void main() {
  group('PeerDiscoveryService', () {
    test('maps nearby users to Peer and computes match score', () async {
      final fakeApi = FakeApiService();
      final service = PeerDiscoveryService(apiService: fakeApi);

      final profile = Profile(
        id: '1',
        userName: 'Tester',
        major: 'Computer Science',
        interests: 'AI,ML,Design',
      );

      final peers = await service.searchNearbyPeers(
        profile,
        latitude: 0.0,
        longitude: 0.0,
      );

      expect(peers.length, 2);

      // Sorted by distance ascending, Bob (0.5) should come before Alice (1.5)
      expect(peers[0].name, 'Bob');
      expect(peers[1].name, 'Alice');

      // Match score should be computed and in range
      expect(peers[0].matchScore >= 0.0 && peers[0].matchScore <= 1.0, true);
      expect(peers[1].matchScore >= 0.0 && peers[1].matchScore <= 1.0, true);
    });
  });
}
