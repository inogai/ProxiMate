import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:playground/widgets/network_tab.dart';
import 'package:playground/models/profile.dart';
import 'package:playground/models/connection.dart';
import 'package:playground/services/storage_service.dart';

/// A small fake storage service used to count how many times the
/// network data-fetch methods are invoked by NetworkTab.
class FakeStorageService extends StorageService {
  // We'll implement only the needed subset for the NetworkTab test.
  Profile? _fakeProfile;
  List<Connection> _fakeConnections = [];

  @override
  Profile? get currentProfile => _fakeProfile;

  @override
  List<Connection> get connections => _fakeConnections;

  int getConnectedProfilesCallCount = 0;
  int getTwoHopConnectionsCallCount = 0;

  FakeStorageService({Profile? currentProfile}) {
    _fakeProfile = currentProfile;
    _fakeConnections = [];
  }

  @override
  Future<List<Profile>> getConnectedProfiles() async {
    getConnectedProfilesCallCount += 1;
    return [
      Profile(
        id: '2',
        userName: 'Bob',
        major: 'CS',
        interests: null,
        background: null,
        profileImagePath: null,
      ),
    ];
  }

  @override
  Future<TwoHopConnectionsResult> getTwoHopConnectionsWithMapping() async {
    getTwoHopConnectionsCallCount += 1;
    return TwoHopConnectionsResult(profiles: [], connections: {});
  }

  // The class implements a large surface - add stub implementations for the rest
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('NetworkTab does not re-fetch network data on rebuild', (
    WidgetTester tester,
  ) async {
    final fake = FakeStorageService(
      currentProfile: Profile(
        id: '1',
        userName: 'Alice',
        major: 'Math',
        interests: null,
        background: null,
        profileImagePath: null,
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<StorageService>.value(
        value: fake,
        child: const MaterialApp(home: Scaffold(body: NetworkTab())),
      ),
    );

    // allow async fetches to resolve
    await tester.pumpAndSettle();

    expect(
      fake.getConnectedProfilesCallCount,
      1,
      reason: 'getConnectedProfiles should be called exactly once',
    );
    expect(
      fake.getTwoHopConnectionsCallCount,
      1,
      reason: 'getTwoHopConnections should be called exactly once',
    );

    // Trigger a rebuild via notifyListeners()
    fake.notifyListeners();
    await tester.pump();
    await tester.pumpAndSettle();

    // Counts should not increase because the widget caches the future
    expect(fake.getConnectedProfilesCallCount, 1);
    expect(fake.getTwoHopConnectionsCallCount, 1);
  });
}
