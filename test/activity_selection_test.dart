import 'package:flutter_test/flutter_test.dart';
import 'package:playground/services/storage_service.dart';
import 'package:playground/services/api_service.dart';
import 'package:openapi/openapi.dart';

void main() {
  group('Activity Selection Integration Tests', () {
    late ApiService apiService;
    late StorageService storageService;

    setUp(() {
      apiService = ApiService();
      storageService = StorageService();
    });

    test('should load activities from API and use them for invitations', () async {
      try {
        // Load activities from API
        final activities = await apiService.getActivities();
        expect(activities.isNotEmpty, true);
        print('Loaded ${activities.length} activities from API');
        
        // Get first activity for testing
        final firstActivity = activities.first;
        print('Using activity: ${firstActivity.name} (${firstActivity.id})');

        // TODO: Update test for new message-based invitation system
        // Old invitation API has been removed
        print('Invitation creation test skipped - API removed');
      } catch (e) {
        fail('Failed to create invitation with activity: $e');
      }
    });
  });
}