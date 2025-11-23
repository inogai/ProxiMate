import 'package:flutter_test/flutter_test.dart';
import '../lib/services/storage_service.dart';
import '../lib/models/connection.dart';
import '../lib/models/profile.dart';

void main() {
  group('Connection Fix Verification', () {
    test('StorageService has required methods for connection display', () {
      final storageService = StorageService();
      
      // Verify that the key methods exist
      expect(storageService.connectedProfiles, isA<List<Profile>>());
      expect(storageService.getConnectedProfiles(), isA<Future<List<Profile>>>());
      expect(storageService.connections, isA<List<Connection>>());
      expect(storageService.hasUser, isA<bool>());
      
      print('✓ All required methods exist');
    });
    
    test('Connection model can be created correctly', () {
      final connection = Connection(
        id: 'test-conn-1',
        fromProfileId: '1',
        toProfileId: '2',
        restaurant: 'Test Restaurant',
        collectedAt: DateTime.now(),
        status: ConnectionStatus.accepted,
      );
      
      expect(connection.id, equals('test-conn-1'));
      expect(connection.fromProfileId, equals('1'));
      expect(connection.toProfileId, equals('2'));
      expect(connection.status, equals(ConnectionStatus.accepted));
      
      print('✓ Connection model works correctly');
    });
    
    test('Profile model can be created correctly', () {
      final profile = Profile(
        id: '1',
        userName: 'Test User',
        school: 'Test School',
        major: 'Test Major',
        interests: 'test interests',
        background: 'Test background',
      );
      
      expect(profile.id, equals('1'));
      expect(profile.userName, equals('Test User'));
      expect(profile.interests, equals('test interests'));
      
      print('✓ Profile model works correctly');
    });
  });
}