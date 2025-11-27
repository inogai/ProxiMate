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
    // Handle text-only nodes
    if (node.isTextNode) {
      return Text(
        node.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final isSelected = selectedNode?.id == node.id;
    final isYou = currentUserId != null && node.id == currentUserId;
    final isTwoHop = node.depth == 2;
    
    final baseSize = isYou
        ? nodeRadius * 2.6
        : isTwoHop
            ? nodeRadius * 1.5
            : nodeRadius * 2;
    final size = isSelected ? baseSize * 1.2 : baseSize;

    // Calculate opacity based on connection type and common interests
    double opacity;
    if (node.isDirectConnection) {
      opacity = 1.0;
    } else if (highlightCommonInterests) {
      // When filter is on, full opacity for common interests, reduced for others
      opacity = _hasCommonInterests(node) ? 1.0 : (node.depth != null && node.depth! >= 2 ? 0.25 : 0.4);
    } else {
      // Default opacity based on depth
      opacity = node.depth != null && node.depth! >= 2 ? 0.25 : 0.4;
    }

    // Determine if node should have green outline (non-direct connection with common tags)
    final bool hasGreenOutline = !node.isDirectConnection && _hasCommonInterests(node);

    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Colors.white
                : isYou
                    ? Colors.white.withOpacity(0.8)
                    : hasGreenOutline
                        ? Colors.green
                        : Colors.white.withOpacity(0.3),
            width: isSelected ? 3 : (isYou ? 3 : (hasGreenOutline ? 2.5 : 2)),
          ),
          boxShadow: [
            BoxShadow(
              color: hasGreenOutline 
                  ? Colors.green.withOpacity(0.6) 
                  : node.color.withOpacity(0.5),
              blurRadius: isSelected ? 20 : (isYou ? 15 : (hasGreenOutline ? 12 : 10)),
              spreadRadius: isSelected ? 5 : (isYou ? 4 : (hasGreenOutline ? 3 : 2)),
            ),
          ],
        ),
        child: ClipOval(
          child: ProfileAvatar(
            name: node.name,
            imagePath: node.profileImagePath,
            size: size,
          ),
        ),
      ),
    );
  }

  bool _hasCommonInterests(NetworkNode node) {
    // Always show current user, text nodes, and direct connections
    if (node.id == currentUserId || node.isTextNode || node.isDirectConnection) return true;
    
    // Check for common major
    if (currentUserMajor != null && node.major != null) {
      if (node.major!.toLowerCase() == currentUserMajor!.toLowerCase()) {
        return true;
      }
    }
    
    // Check for common interests
    if (currentUserInterests != null && node.interests != null) {
      final currentUserInterestsList = currentUserInterests!
          .split(',')
          .map((i) => i.trim().toLowerCase())
          .toList();
      final nodeInterestsList = node.interests!
          .split(',')
          .map((i) => i.trim().toLowerCase())
          .toList();
      
      for (final interest in nodeInterestsList) {
        if (currentUserInterestsList.contains(interest)) {
          return true;
        }
      }
    }
    
    return false;
  }
}
