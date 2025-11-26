import 'package:flutter/material.dart';

import '../widgets/profile_avatar.dart';

/// Custom painter for dashed circle border
class DashedCircleBorder extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCircleBorder({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // Create a dashed circle
    final double circumference = 2 * 3.14159265359 * radius;
    final int dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = (i * (dashWidth + dashSpace) / radius);
      final double sweepAngle = (dashWidth / radius);

      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! DashedCircleBorder ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Node in the network graph
class NetworkNode {
  final String id;
  final String name;
  final String? school;
  final String? major;
  final String? interests;
  final Color color;
  Offset position;
  Offset velocity;
  bool isDragging;
  final List<String> connections;
  final String? profileImagePath;
  final bool isDirectConnection;
  final int? depth;
  final bool isTextNode;

  NetworkNode({
    required this.id,
    required this.name,
    this.school,
    this.major,
    this.interests,
    required this.color,
    required this.position,
    this.connections = const [],
    this.profileImagePath,
    this.isDirectConnection = true,
    this.depth,
    this.isTextNode = false,
  }) : velocity = Offset.zero,
       isDragging = false;
}

/// Widget for rendering individual network nodes
class NetworkNodeWidget extends StatelessWidget {
  final NetworkNode node;
  final NetworkNode? selectedNode;
  final String? currentUserId;
  final String? currentUserMajor;
  final String? currentUserInterests;
  final bool highlightCommonInterests;
  final double nodeRadius;
  final bool isConnectedToSelected;

  const NetworkNodeWidget({
    super.key,
    required this.node,
    this.selectedNode,
    this.currentUserId,
    this.currentUserMajor,
    this.currentUserInterests,
    this.highlightCommonInterests = false,
    this.nodeRadius = 30.0,
    this.isConnectedToSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return _buildNode(context, node);
  }

  Widget _buildNode(BuildContext context, NetworkNode node) {
    final theme = Theme.of(context);

    // Handle text-only nodes
    if (node.isTextNode) {
      return Text(
        node.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final isSelected = selectedNode?.id == node.id;
    final isYou = currentUserId != null && node.id == currentUserId;
    final isTwoHop = node.depth == 2; // Check if this is a 2-hop node

    // Smaller size for 2-hop nodes
    final baseSize = isYou
        ? nodeRadius * 2.6
        : isTwoHop
        ? nodeRadius *
              1.5 // Smaller for 2-hop
        : nodeRadius * 2;
    final size = isSelected ? baseSize * 1.2 : baseSize;

    // Determine if we need to show a highlight border
    bool showHighlightBorder = isSelected || isConnectedToSelected;
    Color borderColor = isSelected
        ? Colors.red
        : isConnectedToSelected
        ? Colors.green
        : Colors.transparent;
    double borderWidth = isSelected
        ? 10.0
        : isConnectedToSelected
        ? 10.0
        : 0.0;

    Widget nodeWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Show dashed border for selected or connected nodes
          if (showHighlightBorder)
            Positioned.fill(
              child: CustomPaint(
                painter: DashedCircleBorder(
                  color: borderColor,
                  strokeWidth: borderWidth,
                ),
              ),
            ),
          // Profile avatar
          ProfileAvatar(
            name: node.name,
            imagePath: node.profileImagePath,
            size: size,
          ),
        ],
      ),
    );

    if (isTwoHop) {
      nodeWidget = Opacity(opacity: 0.6, child: nodeWidget);

      nodeWidget = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          nodeWidget,
          // Add lightbulb icon for 2-hop nodes with common interests
          if (highlightCommonInterests)
            Positioned(
              top: 1,
              right: 1,
              child: Icon(Icons.lightbulb, size: 16, color: Colors.yellow),
            ),
        ],
      );
    }

    return nodeWidget;
  }
}
