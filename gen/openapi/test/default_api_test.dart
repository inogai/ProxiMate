import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DefaultApi
void main() {
  final instance = Openapi().getDefaultApi();

  group(DefaultApi, () {
    // Health Check
    //
    // Health check endpoint.
    //
    //Future<JsonObject> healthCheckApiV1HealthGet() async
    test('test healthCheckApiV1HealthGet', () async {
      // TODO
    });

    // Read Root
    //
    // Root endpoint.
    //
    //Future<JsonObject> readRootGet() async
    test('test readRootGet', () async {
      // TODO
    });

    // Visualize Db
    //
    // Generate HTML visualization of all database data.
    //
    //Future<String> visualizeDbApiV1VisualizeGet() async
    test('test visualizeDbApiV1VisualizeGet', () async {
      // TODO
    });

  });
}
