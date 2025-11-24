import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'network_graph_node.dart';

/// Extension for Offset to calculate distance
extension OffsetExtension on Offset {
  double get distance => math.sqrt(dx * dx + dy * dy);
}

/// Interactive network graph widget with Obsidian-like visualization
class NetworkGraphWidget extends StatefulWidget {
  final List<NetworkNode> nodes;
  final Function(NetworkNode)? onNodeTap;
  final Function(NetworkNode)? onInfoBarTap;
  final Function(NetworkNode)? onInvite; // New callback for 2-hop invites
  final String? initialSelectedNodeId;
  final String? currentUserId;
  final String? currentUserMajor;
  final String? currentUserInterests;
  final bool show1HopCircle;
  final double? custom1HopRadius;

  const NetworkGraphWidget({
    super.key,
    required this.nodes,
    this.onNodeTap,
    this.onInfoBarTap,
    this.onInvite,
    this.initialSelectedNodeId,
    this.currentUserId,
    this.currentUserMajor,
    this.currentUserInterests,
    this.show1HopCircle = false,
    this.custom1HopRadius,
  });

  @override
  State<NetworkGraphWidget> createState() => _NetworkGraphWidgetState();
}

class _NetworkGraphWidgetState extends State<NetworkGraphWidget> {
  late List<NetworkNode> _nodes;
  NetworkNode? _selectedNode;
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  bool _highlightCommonInterests = false;
  Size? _viewportSize;

  // Physics simulation parameters
  static const double nodeRadius = 30.0;

  @override
  void initState() {
    super.initState();
    // Create a copy of nodes to maintain state
    _nodes = List.from(widget.nodes);

    // Set initial selected node if provided
    if (widget.initialSelectedNodeId != null) {
      _selectedNode = _nodes.firstWhere(
        (node) => node.id == widget.initialSelectedNodeId,
        orElse: () => _nodes.first,
      );
    }
  }

  @override
  void didUpdateWidget(NetworkGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update nodes if the widget's nodes changed significantly
    if (widget.nodes.length != oldWidget.nodes.length || 
        !widget.nodes.every((node) => oldWidget.nodes.any((oldNode) => oldNode.id == node.id))) {
      _nodes = List.from(widget.nodes);
      
      // Update selected node reference if it exists
      if (_selectedNode != null) {
        _selectedNode = _nodes.firstWhere(
          (node) => node.id == _selectedNode!.id,
          orElse: () => _nodes.isNotEmpty ? _nodes.first : _selectedNode!,
        );
      }
    }
  }

  void _ensureNodesInViewport() {
    if (_viewportSize == null) return;

    final margin = nodeRadius * 2;

    for (final node in _nodes) {
      if (node.isTextNode) continue;

      // Clamp node positions to viewport bounds
      final clampedX = node.position.dx.clamp(
        margin,
        _viewportSize!.width - margin,
      );
      final clampedY = node.position.dy.clamp(
        margin,
        _viewportSize!.height - margin,
      );

      // Only update if outside bounds
      if (node.position.dx != clampedX || node.position.dy != clampedY) {
        node.position = Offset(clampedX, clampedY);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onNodePanStart(
    NetworkNode node,
    DragStartDetails details,
    double offset,
  ) {
    setState(() {
      node.isDragging = true;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Network'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Highlight extended connections with common interests',
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Highlight Common Tags'),
                 subtitle: Text(
                   'Show full opacity for connections with shared major or interests',
                   style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                 ),
                value: _highlightCommonInterests,
                onChanged: (bool value) {
                  setState(() {
                    _highlightCommonInterests = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
             ),
          ],
        );
      },
    );
  }

  void _onNodePanUpdate(
    NetworkNode node,
    DragUpdateDetails details,
    double offset,
  ) {
    if (!mounted) return;
    setState(() {
      // Find the node in our local state and update it
      final nodeInState = _nodes.firstWhere((n) => n.id == node.id);
      // Use delta for smooth incremental updates
      // Don't divide by scale since gesture detector is already inside Transform.scale
      nodeInState.position += details.delta;
      nodeInState.velocity = Offset.zero;
    });
  }

  void _onNodePanEnd(NetworkNode node, DragEndDetails details) {
    setState(() {
      node.isDragging = false;
    });
  }

  void _showInviteDialog(BuildContext context, NetworkNode node) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invite ${node.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (node.major != null) ...[
                Text(
                  'Major: ${node.major}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'This person is a friend of your connection. Would you like to send them an invitation to connect?',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onInvite?.call(node);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invitation sent to ${node.name}!'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Handle zoom
      final newScale = (_scale * details.scale).clamp(0.5, 3.0);
      _scale = newScale;

      // Handle pan
      _panOffset += details.focalPoint - _lastFocalPoint;
      _lastFocalPoint = details.focalPoint;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Capture viewport size for physics
    final size = MediaQuery.of(context).size;
    if (_viewportSize != size) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _viewportSize != size) {
          _viewportSize = size;
          _ensureNodesInViewport();
          if (mounted) {
            setState(() {});
          }
        }
      });
    }

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      child: Container(
        color: theme.colorScheme.surface,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background grid
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(scale: _scale, offset: _panOffset, theme: theme),
            ),
            // Network graph
            Transform.translate(
              offset: _panOffset,
              child: Transform.scale(
                scale: _scale,
                alignment: Alignment.center,
                child: SizedBox.expand(
                  child: CustomPaint(
                     painter: NetworkGraphPainter(
                        nodes: _nodes,
                        selectedNode: _selectedNode,
                        theme: theme,
                        show1HopCircle: widget.show1HopCircle,
                        custom1HopRadius: widget.custom1HopRadius,
                      ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: _nodes.map((node) {
                        final isSelected = _selectedNode?.id == node.id;
                        final isYou =
                            widget.currentUserId != null &&
                            node.id == widget.currentUserId;
                        final baseSize = isYou
                            ? nodeRadius * 2.6
                            : nodeRadius * 2;
                        final size = isSelected ? baseSize * 1.2 : baseSize;
                        final offset = size / 2;
                        // For text nodes, center differently
                        if (node.isTextNode) {
                          return Positioned(
                            left: node.position.dx,
                            top: node.position.dy,
                            child: Transform.translate(
                              offset: const Offset(
                                -125,
                                -10,
                              ), // Center the ~250px wide text
                              child: SizedBox(
                                width: 250,
                                child: GestureDetector(
                                  onTap: () {
                                    // Text nodes are not interactive
                                  },
                                  child: NetworkNodeWidget(
                                    node: node,
                                    selectedNode: _selectedNode,
                                    currentUserId: widget.currentUserId,
                                    currentUserMajor: widget.currentUserMajor,
                                    currentUserInterests:
                                        widget.currentUserInterests,
                                    highlightCommonInterests:
                                        _highlightCommonInterests,
                                    nodeRadius: nodeRadius,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                         return Positioned(
                           left: node.position.dx - offset,
                           top: node.position.dy - offset,
                           child: GestureDetector(
                             behavior: HitTestBehavior.opaque, // Ensure gesture detection works
                             onPanStart: (details) =>
                                 _onNodePanStart(node, details, offset),
                             onPanUpdate: (details) =>
                                 _onNodePanUpdate(node, details, offset),
                             onPanEnd: (details) => _onNodePanEnd(node, details),
                              onTap: () {
                                setState(() {
                                  _selectedNode = node;
                                });
                                
                                // Check if this is a 2-hop node and handle invite
                                if (node.depth == 2) {
                                  _showInviteDialog(context, node);
                                } else {
                                  widget.onNodeTap?.call(node);
                                }
                              },
                             child: NetworkNodeWidget(
                              node: node,
                              selectedNode: _selectedNode,
                              currentUserId: widget.currentUserId,
                              currentUserMajor: widget.currentUserMajor,
                              currentUserInterests: widget.currentUserInterests,
                              highlightCommonInterests:
                                  _highlightCommonInterests,
                              nodeRadius: nodeRadius,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            // Controls overlay
            Positioned(top: 16, right: 16, child: _buildControls()),
            // Selected node info
            if (_selectedNode != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildSelectedNodeInfo(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            IconButton(
              icon: Icon(
                _highlightCommonInterests
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: _highlightCommonInterests ? theme.colorScheme.secondary : theme.colorScheme.onSurface,
              ),
              onPressed: _showFilterDialog,
              tooltip: 'Filter Network',
            ),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.24), height: 1),
            IconButton(
              icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
              onPressed: () {
                setState(() {
                  _scale = (_scale + 0.2).clamp(0.5, 3.0);
                });
              },
              tooltip: 'Zoom In',
            ),
            IconButton(
              icon: Icon(Icons.remove, color: theme.colorScheme.onSurface),
              onPressed: () {
                setState(() {
                  _scale = (_scale - 0.2).clamp(0.5, 3.0);
                });
              },
              tooltip: 'Zoom Out',
            ),
            IconButton(
              icon: Icon(Icons.center_focus_strong, color: theme.colorScheme.onSurface),
              onPressed: () {
                setState(() {
                  _scale = 1.0;
                  _panOffset = Offset.zero;
                });
              },
              tooltip: 'Reset View',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedNodeInfo() {
    final theme = Theme.of(context);
    if (_selectedNode == null) return const SizedBox.shrink();
    final bool isCurrentUser =
        _selectedNode!.id == 'you' || _selectedNode!.id == widget.currentUserId;

    return Card(
      color: theme.colorScheme.surface.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (widget.onInfoBarTap != null) {
                  widget.onInfoBarTap!(_selectedNode!);
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedNode!.profileImagePath == null
                      ? _selectedNode!.color
                      : Colors.transparent,
                ),
                child: ClipOval(
                  child: _selectedNode!.profileImagePath != null
                      ? RepaintBoundary(
                          child: Image(
                            image: NetworkNodeWidget.getImageProvider(
                              _selectedNode!.profileImagePath!,
                            ),
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            gaplessPlayback: true,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: _selectedNode!.color,
                                child: Center(
                                  child: Text(
                                    _selectedNode!.id == 'you'
                                        ? 'YOU'
                                        : _selectedNode!.name
                                              .split(' ')
                                              .map((e) => e[0])
                                              .take(2)
                                              .join(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          color: _selectedNode!.color,
                          child: Center(
                            child: Text(
                              _selectedNode!.id == 'you'
                                  ? 'YOU'
                                  : _selectedNode!.name
                                        .split(' ')
                                        .map((e) => e[0])
                                        .take(2)
                                        .join(),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.onInfoBarTap != null) {
                    widget.onInfoBarTap!(_selectedNode!);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedNode!.name,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedNode!.school != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _selectedNode!.school!,
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (_selectedNode!.major != null)
                          Builder(
                            builder: (context) {
                              final bool matches =
                                  widget.currentUserMajor != null &&
                                  _selectedNode!.major!.toLowerCase() ==
                                      widget.currentUserMajor!.toLowerCase();
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: matches
                                      ? theme.colorScheme.secondary.withOpacity(0.3)
                                      : theme.colorScheme.onSurface.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: matches
                                        ? theme.colorScheme.secondary.withOpacity(0.5)
                                        : theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  _selectedNode!.major!,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (_selectedNode!.interests != null)
                          ..._selectedNode!.interests!.split(',').map((
                            interest,
                          ) {
                            final trimmedInterest = interest.trim();
                            final currentUserInterestsList =
                                widget.currentUserInterests
                                    ?.split(',')
                                    .map((i) => i.trim().toLowerCase())
                                    .toList() ??
                                [];
                            final bool matches = currentUserInterestsList
                                .contains(trimmedInterest.toLowerCase());
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: matches
                                    ? theme.colorScheme.secondary.withOpacity(0.3)
                                    : theme.colorScheme.onSurface.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: matches
                                      ? theme.colorScheme.secondary.withOpacity(0.5)
                                      : theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                trimmedInterest,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!isCurrentUser && !_selectedNode!.isTextNode)
              Container(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    if (widget.onInfoBarTap != null) {
                      widget.onInfoBarTap!(_selectedNode!);
                    }
                  },
                  tooltip: 'Chat',
                ),
              ),
            Container(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                onPressed: () {
                  setState(() {
                    _selectedNode = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for the network graph connections
class NetworkGraphPainter extends CustomPainter {
  final List<NetworkNode> nodes;
  final NetworkNode? selectedNode;
  final ThemeData theme;
  final bool show1HopCircle;
  final double? custom1HopRadius;

  NetworkGraphPainter({
    required this.nodes, 
    this.selectedNode, 
    required this.theme,
    this.show1HopCircle = false,
    this.custom1HopRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw 1-hop circle first (so it appears behind connections)
    if (show1HopCircle) {
      _draw1HopCircle(canvas);
    }

    // Draw connections
    final connectionPaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final node in nodes) {
      for (final connectionId in node.connections) {
        final connectedNode = nodes.firstWhere(
          (n) => n.id == connectionId,
          orElse: () => node,
        );
        if (connectedNode.id == node.id) continue;

        final isHighlighted =
            selectedNode?.id == node.id || selectedNode?.id == connectedNode.id;

        // Make connection line more transparent if either node is indirect
        final isIndirectConnection =
            !node.isDirectConnection || !connectedNode.isDirectConnection;
        final baseOpacity = isIndirectConnection ? 0.05 : 0.1;
        final highlightOpacity = isIndirectConnection ? 0.3 : 0.6;

        connectionPaint.color = isHighlighted
            ? theme.colorScheme.onSurface.withOpacity(highlightOpacity)
            : theme.colorScheme.onSurface.withOpacity(baseOpacity);
        connectionPaint.strokeWidth = isHighlighted ? 3 : 1.5;

        canvas.drawLine(node.position, connectedNode.position, connectionPaint);
      }
    }
  }

  /// Draw red overlay circle showing 1-hop radius around current user
  void _draw1HopCircle(Canvas canvas) {
    // Find current user node (first non-text node, or node with 'you' id)
    NetworkNode? currentUserNode;
    try {
      currentUserNode = nodes.firstWhere(
        (node) => node.id == 'you' || (!node.isTextNode && node.connections.isNotEmpty),
      );
    } catch (e) {
      // If no 'you' node found, try first node with connections
      try {
        currentUserNode = nodes.firstWhere(
          (node) => !node.isTextNode && node.connections.isNotEmpty,
        );
      } catch (e) {
        return; // No suitable current user node found
      }
    }

    if (currentUserNode == null) return;

    // Calculate 1-hop radius - make it bigger to capture all nodes
    double radius;
    if (custom1HopRadius != null) {
      radius = custom1HopRadius!;
    } else {
      // Calculate based on distance to furthest direct connection, then add extra padding
      final directConnections = nodes.where((n) => n.isDirectConnection);
      double maxDistance = 0;
      
      for (final node in directConnections) {
        final distance = (node.position - currentUserNode!.position).distance;
        maxDistance = math.max(maxDistance, distance);
      }
      
      // Make it significantly bigger to capture all nodes with good margin
      radius = maxDistance > 0 ? maxDistance + 80 : 200; // Add generous padding
    }

    // Draw red overlay circle with fill
    final circlePaint = Paint()
      ..color = Colors.red.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(currentUserNode!.position, radius, circlePaint);
    
    // Draw red border
    final borderPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..isAntiAlias = true;
    
    canvas.drawCircle(currentUserNode!.position, radius, borderPaint);

    // Add "Your connections" text above the circle
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Your connections',
        style: TextStyle(
          color: Colors.red.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          backgroundColor: Colors.white.withOpacity(0.9),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Position text above the circle
    final textPosition = Offset(
      currentUserNode!.position.dx - textPainter.width / 2,
      currentUserNode!.position.dy - radius - 25,
    );
    
    // Draw text background
    final textBgPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    final textBgRect = Rect.fromLTWH(
      textPosition.dx - 4,
      textPosition.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(textBgRect, const Radius.circular(4)),
      textBgPaint,
    );
    
    // Draw text
    textPainter.paint(canvas, textPosition);
  }

  @override
  bool shouldRepaint(NetworkGraphPainter oldDelegate) => 
      show1HopCircle != oldDelegate.show1HopCircle ||
      custom1HopRadius != oldDelegate.custom1HopRadius;
}

/// Painter for the background grid
class GridPainter extends CustomPainter {
  final double scale;
  final Offset offset;
  final ThemeData theme;

  GridPainter({required this.scale, required this.offset, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(0.05)
      ..strokeWidth = 1;

    const gridSize = 50.0;

    for (double x = 0; x < size.width; x += gridSize * scale) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize * scale) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) =>
      scale != oldDelegate.scale || offset != oldDelegate.offset;
}
