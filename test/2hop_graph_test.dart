import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:playground/widgets/network_tab.dart';
import 'package:playground/widgets/network_graph_widget.dart';
import 'package:playground/widgets/network_graph_node.dart';
import 'package:playground/services/storage_service.dart';
import 'package:playground/models/profile.dart';
import 'package:playground/models/connection.dart';
import 'package:provider/provider.dart';

void main() {
  group('2-Hop Graph Rendering Tests', () {
    testWidgets('2-hop nodes have connections to 1-hop nodes', (WidgetTester tester) async {
      // Create mock storage service
      final storage = MockStorageService();
      
      // Create test widget
      await tester.pumpWidget(
        ChangeNotifierProvider<StorageService>(
          create: (_) => storage,
          child: MaterialApp(
            home: Scaffold(
              body: NetworkTab(),
            ),
          ),
        ),
      );

      // Wait for the graph to load
      await tester.pumpAndSettle();

      // Find the NetworkGraphWidget
      expect(find.byType(NetworkGraphWidget), findsOneWidget);
      
      // Get the NetworkGraphWidget instance
      final graphWidget = tester.widget<NetworkGraphWidget>(find.byType(NetworkGraphWidget));
      
      // Verify nodes are present
      expect(graphWidget.nodes, isNotEmpty);
      
      // Find 2-hop nodes (depth == 2)
      final twoHopNodes = graphWidget.nodes.where((node) => node.depth == 2);
      expect(twoHopNodes, isNotEmpty, reason: 'Should have 2-hop nodes');
      
      // Verify each 2-hop node has connections
      for (final twoHopNode in twoHopNodes) {
        expect(twoHopNode.connections, isNotEmpty, 
            reason: '2-hop node ${twoHopNode.id} should have connections');
        print('✓ 2-hop node ${twoHopNode.id} has ${twoHopNode.connections.length} connections');
        
        // Verify connections point to valid nodes
        for (final connectionId in twoHopNode.connections) {
          final connectedNode = graphWidget.nodes.firstWhere(
            (node) => node.id == connectionId,
            orElse: () => throw Exception('Connected node $connectionId not found'),
          );
          expect(connectedNode.isDirectConnection, isTrue,
              reason: '2-hop node should connect to 1-hop nodes only');
          print('  -> Connected to 1-hop node ${connectedNode.id}');
        }
      }
    });
  });
}

// Mock StorageService for testing
class MockStorageService extends StorageService {
  @override
  Future<List<Profile>> getConnectedProfiles() async {
    return [
      Profile(
        id: '1hop_1',
        userName: 'Direct Connection 1',
        major: 'Computer Science',
        interests: 'Technology',
      ),
      Profile(
        id: '1hop_2', 
        userName: 'Direct Connection 2',
        major: 'Business',
        interests: 'Marketing',
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> getTwoHopConnectionsWithMapping() async {
    return {
      'profiles': [
        Profile(
          id: '2hop_1',
          userName: 'Friend of Friend 1',
          major: 'Engineering',
          interests: 'Design',
        ),
        Profile(
          id: '2hop_2',
          userName: 'Friend of Friend 2', 
          major: 'Design',
          interests: 'Art',
        ),
      ],
      'connections': {
        '2hop_1': '1hop_1',
        '2hop_2': '1hop_2',
      },
    };
  }

  @override
  Profile? get currentProfile => Profile(
    id: 'current_user',
    userName: 'Current User',
    major: 'Computer Science',
    interests: 'Technology',
  );

  @override
  List<Connection> get connections => [
    // Mock connections
  ];
}