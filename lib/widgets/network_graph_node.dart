import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  const NetworkNodeWidget({
    super.key,
    required this.node,
    this.selectedNode,
    this.currentUserId,
    this.currentUserMajor,
    this.currentUserInterests,
    this.highlightCommonInterests = false,
    this.nodeRadius = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return _buildNode(context, node);
  }

  bool _hasCommonInterests(NetworkNode node) {
    // Always show current user, text nodes, and direct connections
    if (node.id == currentUserId ||
        node.isTextNode ||
        node.isDirectConnection) {
      return true;
    }

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

    // Calculate opacity based on filter state and common interests
    final hasCommonTags = _hasCommonInterests(node);
    double opacity;
    if (node.isDirectConnection) {
      opacity = 1.0;
    } else if (highlightCommonInterests) {
      // When filter is on, full opacity for common interests, reduced for others
      opacity = hasCommonTags
          ? 1.0
          : (node.depth != null && node.depth! >= 2 ? 0.25 : 0.4);
    } else {
      // Default opacity based on depth
      opacity = node.depth != null && node.depth! >= 2 ? 0.25 : 0.4;
    }

    // Determine if node should have secondary outline (non-direct connection with common tags)
    final bool hasSecondaryOutline = !node.isDirectConnection && hasCommonTags;

    Widget nodeWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: node.profileImagePath == null ? node.color : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.surface
              : isYou
              ? theme.colorScheme.surface.withOpacity(0.8)
              : hasSecondaryOutline
              ? theme.colorScheme.secondary
              : theme.colorScheme.surface.withOpacity(0.3),
          width: isSelected ? 3 : (isYou ? 3 : (hasSecondaryOutline ? 2.5 : 2)),
        ),
        boxShadow: [
          BoxShadow(
            color: hasSecondaryOutline
                ? theme.colorScheme.secondary
                : node.color,
            blurRadius: isSelected
                ? 20
                : (isYou ? 15 : (hasSecondaryOutline ? 12 : 10)),
            spreadRadius: isSelected
                ? 5
                : (isYou ? 4 : (hasSecondaryOutline ? 3 : 2)),
          ),
        ],
      ),
      child: ClipOval(
        child: node.profileImagePath != null
            ? RepaintBoundary(
                child: Image(
                  image: NetworkNodeWidget.getImageProvider(
                    node.profileImagePath!,
                  ),
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: node.color,
                      child: Center(
                        child: Text(
                          isYou
                              ? 'YOU'
                              : node.name
                                    .split(' ')
                                    .map((e) => e[0])
                                    .take(2)
                                    .join(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: isSelected
                                ? (isYou
                                      ? 18
                                      : isTwoHop
                                      ? 12
                                      : 16)
                                : (isYou
                                      ? 16
                                      : isTwoHop
                                      ? 10
                                      : 14),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Container(
                color: node.color,
                child: Center(
                  child: Text(
                    isYou
                        ? 'YOU'
                        : node.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected
                          ? (isYou
                                ? 18
                                : isTwoHop
                                ? 12
                                : 16)
                          : (isYou
                                ? 16
                                : isTwoHop
                                ? 10
                                : 14),
                    ),
                  ),
                ),
              ),
      ),
    );

    if (isTwoHop) {
      nodeWidget = Opacity(opacity: 0.6, child: nodeWidget);

      nodeWidget = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 4,
            height: size + 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          nodeWidget,
        ],
      );
    }

    return nodeWidget;
  }

  static ImageProvider getImageProvider(String imagePath) {
    if (kIsWeb) {
      if (imagePath.startsWith('data:')) {
        // Base64 data URL
        return MemoryImage(base64Decode(imagePath.split(',')[1]));
      } else {
        // Blob URL or network URL
        return NetworkImage(imagePath);
      }
    } else {
      // Mobile: file path
      return FileImage(File(imagePath));
    }
  }
}
