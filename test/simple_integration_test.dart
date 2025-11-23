import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App should initialize without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(storage: null)); // This will fail, need proper setup
    
    // Verify that the app loads (either register screen or main screen)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}