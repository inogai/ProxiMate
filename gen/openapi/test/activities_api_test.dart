import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ActivitiesApi
void main() {
  final instance = Openapi().getActivitiesApi();

  group(ActivitiesApi, () {
    // Create Activity
    //
    // Create a new activity.
    //
    //Future<ActivityRead> createActivityApiV1ActivitiesPost(ActivityCreate activityCreate) async
    test('test createActivityApiV1ActivitiesPost', () async {
      // TODO
    });

    // Delete Activity
    //
    // Delete an activity.
    //
    //Future deleteActivityApiV1ActivitiesActivityIdDelete(String activityId) async
    test('test deleteActivityApiV1ActivitiesActivityIdDelete', () async {
      // TODO
    });

    // Get Activities
    //
    // Get multiple activities with pagination.
    //
    //Future<BuiltList<ActivityRead>> getActivitiesApiV1ActivitiesGet({ int skip, int limit }) async
    test('test getActivitiesApiV1ActivitiesGet', () async {
      // TODO
    });

    // Get Activity
    //
    // Get an activity by ID.
    //
    //Future<ActivityRead> getActivityApiV1ActivitiesActivityIdGet(String activityId) async
    test('test getActivityApiV1ActivitiesActivityIdGet', () async {
      // TODO
    });

    // Search Activities
    //
    // Search activities by name.
    //
    //Future<BuiltList<ActivityRead>> searchActivitiesApiV1ActivitiesSearchGet(String q, { int skip, int limit }) async
    test('test searchActivitiesApiV1ActivitiesSearchGet', () async {
      // TODO
    });

    // Update Activity
    //
    // Update an activity.
    //
    //Future<ActivityRead> updateActivityApiV1ActivitiesActivityIdPut(String activityId, BuiltMap<String, JsonObject> requestBody) async
    test('test updateActivityApiV1ActivitiesActivityIdPut', () async {
      // TODO
    });

  });
}
