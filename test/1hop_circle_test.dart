import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/network_graph_widget.dart';
import '../lib/widgets/network_graph_node.dart';
import 'package:flutter/material.dart';

void main() {
  group('1-Hop Circle Tests', () {
    test('NetworkGraphWidget accepts 1-hop circle parameters', () {
      final nodes = [
        NetworkNode(
          id: 'you',
          name: 'Current User',
          color: Colors.blue,
          position: const Offset(200, 200),
          connections: ['1', '2'],
          isDirectConnection: false,
        ),
        NetworkNode(
          id: '1',
          name: 'Connection 1',
          color: Colors.orange,
          position: const Offset(100, 150),
          connections: ['you'],
          isDirectConnection: true,
        ),
        NetworkNode(
          id: '2',
          name: 'Connection 2',
          color: Colors.orange,
          position: const Offset(300, 150),
          connections: ['you'],
          isDirectConnection: true,
        ),
      ];

      // Test with 1-hop circle enabled
      final widgetWithCircle = NetworkGraphWidget(
        nodes: nodes,
        show1HopCircle: true,
        custom1HopRadius: 150.0,
        currentUserId: 'you',
      );

      expect(widgetWithCircle.show1HopCircle, true);
      expect(widgetWithCircle.custom1HopRadius, 150.0);

      // Test with 1-hop circle disabled
      final widgetWithoutCircle = NetworkGraphWidget(
        nodes: nodes,
        show1HopCircle: false,
        currentUserId: 'you',
      );

      expect(widgetWithoutCircle.show1HopCircle, false);
      expect(widgetWithoutCircle.custom1HopRadius, null);

      print('✓ 1-hop circle parameters work correctly');
    });

    test('NetworkGraphPainter includes 1-hop circle parameters', () {
      final painter = NetworkGraphPainter(
        nodes: [],
        theme: ThemeData.light(),
        show1HopCircle: true,
        custom1HopRadius: 200.0,
      );

      expect(painter.show1HopCircle, true);
      expect(painter.custom1HopRadius, 200.0);

      print('✓ NetworkGraphPainter accepts 1-hop circle parameters');
    });

    test('Offset distance calculation works correctly', () {
      final offset1 = const Offset(0, 0);
      final offset2 = const Offset(3, 4);
      final offset3 = const Offset(100, 100);

      // Test distance calculation (should be 5 for 3-4-5 triangle)
      expect(offset1.distance, 0.0);
      expect((offset2 - offset1).distance, 5.0);
      
      // Test distance to 100,100 (should be sqrt(100^2 + 100^2) ≈ 141.42)
      final distanceTo100 = (offset3 - offset1).distance;
      expect(distanceTo100, closeTo(141.42, 0.01));

      print('✓ Offset distance calculation works correctly');
    });
  });
}