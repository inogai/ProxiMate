import 'package:flutter_test/flutter_test.dart';
import 'package:playground/services/storage_service.dart';
import 'package:playground/services/api_service.dart';
import 'package:playground/models/profile.dart';
import 'package:playground/models/peer.dart';
import 'package:openapi/openapi.dart';

void main() {
  group('Invitation API Integration Tests', () {
    late StorageService storageService;
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
      storageService = StorageService();
    });

    test('should load activities from API', () async {
      // This test verifies that activities can be loaded from the API
      try {
        final activities = await apiService.getActivities();
        expect(activities.isNotEmpty, true);
        print('Loaded ${activities.length} activities from API');
        
        for (final activity in activities) {
          print('Activity: ${activity.name} (${activity.id})');
        }
      } catch (e) {
        fail('Failed to load activities from API: $e');
      }
    });

    test('should create invitation via API', () async {
      // First load activities to get a valid activity ID
      try {
        final activities = await apiService.getActivities();
        if (activities.isEmpty) {
          fail('No activities available to test invitation creation');
        }

        final activityId = activities.first.id;
        print('Using activity: ${activities.first.name} ($activityId)');

        // TODO: Update test for new message-based invitation system
        // Old invitation API has been removed
        print('Invitation API test skipped - API removed');
      } catch (e) {
        fail('Failed to create invitation: $e');
      }
    });
  });
}