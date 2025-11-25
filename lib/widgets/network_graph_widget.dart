import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../widgets/profile_avatar.dart';
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

  // Physics constants
  static const double repulsionStrength = 150.0; // Repulsion force strength
  static const double attractionStrength =
      10; // Increased attraction strength for stronger edge pulling
  static const double damping = 0.85; // Damping factor for quick settling (0-1)
  static const double minDistance = 80.0; // Minimum distance between nodes
  static const double idealEdgeLength =
      100.0; // Ideal length for edges (increased for better visibility)
  static const double maxVelocity =
      10.0; // Maximum velocity to prevent instability
  static const double physicsTimeStep = 0.016; // ~60fps physics timestep

  // Physics state
  bool _physicsEnabled = true;
  Ticker? _physicsTicker;

  @override
  void initState() {
    super.initState();
    // Create a copy of nodes to maintain state
    _nodes = List.from(widget.nodes);

    // Initialize velocities for all nodes
    for (final node in _nodes) {
      node.velocity = Offset.zero;
    }

    // Set initial selected node if provided
    if (widget.initialSelectedNodeId != null) {
      _selectedNode = _nodes.firstWhere(
        (node) => node.id == widget.initialSelectedNodeId,
        orElse: () => _nodes.first,
      );
    }

    // Start physics simulation
    _startPhysicsSimulation();
  }

  @override
  void didUpdateWidget(NetworkGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update nodes if the widget's nodes changed significantly
    if (widget.nodes.length != oldWidget.nodes.length ||
        !widget.nodes.every(
          (node) => oldWidget.nodes.any((oldNode) => oldNode.id == node.id),
        )) {
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
    _physicsTicker?.dispose();
    super.dispose();
  }

  void _startPhysicsSimulation() {
    _physicsTicker = Ticker((elapsed) {
      if (_physicsEnabled && mounted) {
        _updatePhysics(physicsTimeStep);
      }
    });
    _physicsTicker!.start();
  }

  void _updatePhysics(double deltaTime) {
    if (!mounted) return;

    setState(() {
      // Calculate forces for each node
      for (final node in _nodes) {
        if (node.isTextNode || node.isDragging) continue;

        Offset totalForce = Offset.zero;

        // 1. Calculate repulsion forces from all other nodes
        totalForce += _calculateRepulsionForces(node);

        // 2. Calculate attraction forces along edges
        totalForce += _calculateAttractionForces(node);

        // Update velocity with force and damping
        node.velocity = (node.velocity + totalForce * deltaTime) * damping;

        // Clamp velocity to prevent instability
        final velocityMagnitude = node.velocity.distance;
        if (velocityMagnitude > maxVelocity) {
          node.velocity = (node.velocity / velocityMagnitude) * maxVelocity;
        }

        // Update position
        node.position += node.velocity * deltaTime;
      }

      // Handle collisions between nodes
      _handleCollisions();

      // Enforce 2-hop boundaries
      _enforce2HopBoundaries();

      // Ensure nodes stay in viewport
      _ensureNodesInViewport();
    });
  }

  /// Calculate repulsion forces from all other nodes
  Offset _calculateRepulsionForces(NetworkNode node) {
    Offset totalForce = Offset.zero;

    for (final otherNode in _nodes) {
      if (otherNode.id == node.id || otherNode.isTextNode) continue;

      final direction = node.position - otherNode.position;
      final distance = direction.distance;

      // Apply repulsion only if nodes are too close
      if (distance < minDistance * 2 && distance > 0) {
        // Calculate repulsion force (stronger when closer)
        final forceMagnitude = repulsionStrength / (distance * distance);
        final forceDirection = direction / distance; // Normalize direction
        totalForce += forceDirection * forceMagnitude;
      }
    }

    return totalForce;
  }

  /// Calculate attraction forces along connected edges
  Offset _calculateAttractionForces(NetworkNode node) {
    Offset totalForce = Offset.zero;

    for (final connectionId in node.connections) {
      final connectedNode = _nodes.firstWhere(
        (n) => n.id == connectionId,
        orElse: () => node,
      );

      if (connectedNode.id == node.id) continue;

      final direction = connectedNode.position - node.position;
      final distance = direction.distance;

      if (distance > 0) {
        // Hooke's law: F = k * (distance - restLength)
        final springForce = attractionStrength * (distance - idealEdgeLength);

        final totalAttraction = springForce;

        final forceDirection = direction / distance; // Normalize direction
        totalForce += forceDirection * totalAttraction;
      }
    }

    return totalForce;
  }

  /// Enforce hard boundary for 2-hop nodes to stay outside 1-hop circle
  void _enforce2HopBoundaries() {
    // Find current user node (center)
    NetworkNode? currentUserNode;
    try {
      currentUserNode = _nodes.firstWhere(
        (n) => n.id == 'you' || (!n.isTextNode && n.connections.isNotEmpty),
      );
    } catch (e) {
      return; // No current user found
    }

    // Calculate 1-hop radius
    final directConnections = _nodes.where((n) => n.isDirectConnection);
    double maxDistance = 0;

    for (final conn in directConnections) {
      final distance = (conn.position - currentUserNode.position).distance;
      maxDistance = math.max(maxDistance, distance);
    }

    // Use consistent radius calculation with the visual circle
    final oneHopRadius = maxDistance > 0 ? maxDistance + 50 : 200;
    final minDistance = oneHopRadius + 10; // Minimum distance from center

    // Check each 2-hop node
    for (final node in _nodes) {
      if (node.depth != 2 || node.isDragging || node.isTextNode) continue;

      final distanceFromCenter =
          (node.position - currentUserNode.position).distance;

      // Hard boundary: if node is inside the boundary, move it to the boundary
      if (distanceFromCenter < minDistance) {
        final directionFromCenter = (node.position - currentUserNode.position);
        if (directionFromCenter.distance > 0) {
          // Normalize the direction to get the unit vector from center to node
          final unitDirection =
              directionFromCenter / directionFromCenter.distance;

          // Place node exactly at the boundary
          node.position =
              currentUserNode.position +
              Offset(
                unitDirection.dx * minDistance,
                unitDirection.dy * minDistance,
              );

          // Reduce velocity significantly to prevent oscillation
          node.velocity = node.velocity * 0.1;
        }
      }
    }
  }

  /// Handle collisions between nodes
  void _handleCollisions() {
    for (int i = 0; i < _nodes.length; i++) {
      for (int j = i + 1; j < _nodes.length; j++) {
        final nodeA = _nodes[i];
        final nodeB = _nodes[j];

        if (nodeA.isTextNode || nodeB.isTextNode) continue;

        final direction = nodeB.position - nodeA.position;
        final distance = direction.distance;
        final minCollisionDistance = nodeRadius * 2.5;

        if (distance < minCollisionDistance && distance > 0) {
          // Nodes are colliding, separate them
          final overlap = minCollisionDistance - distance;
          final separation = (direction / distance) * (overlap * 0.5);

          // Apply separation if not dragging
          if (!nodeA.isDragging) {
            nodeA.position -= separation;
            nodeA.velocity *= 0.5; // Reduce velocity on collision
          }
          if (!nodeB.isDragging) {
            nodeB.position += separation;
            nodeB.velocity *= 0.5; // Reduce velocity on collision
          }
        }
      }
    }
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
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Highlight Common Tags'),
                subtitle: Text(
                  'Show full opacity for connections with shared major or interests',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
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
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
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

      // Apply drag delta directly (physics will handle repulsion/attraction)
      // Don't divide by scale since gesture detector is already inside Transform.scale
      nodeInState.position += details.delta;

      // Set velocity based on drag movement for smooth physics transition
      nodeInState.velocity = details.delta * 0.5;
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
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
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
              painter: GridPainter(
                scale: _scale,
                offset: _panOffset,
                theme: theme,
              ),
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
                            behavior: HitTestBehavior
                                .opaque, // Ensure gesture detection works
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
                color: _highlightCommonInterests
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface,
              ),
              onPressed: _showFilterDialog,
              tooltip: 'Filter Network',
            ),
            Divider(
              color: theme.colorScheme.onSurface.withOpacity(0.24),
              height: 1,
            ),
            IconButton(
              icon: Icon(
                _physicsEnabled ? Icons.pause : Icons.play_arrow,
                color: _physicsEnabled
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface,
              ),
              onPressed: () {
                setState(() {
                  _physicsEnabled = !_physicsEnabled;
                });
              },
              tooltip: _physicsEnabled ? 'Pause Physics' : 'Resume Physics',
            ),
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
              icon: Icon(
                Icons.center_focus_strong,
                color: theme.colorScheme.onSurface,
              ),
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
                  color: Colors.transparent,
                ),
                child: ProfileAvatar(
                  name: _selectedNode!.name,
                  imagePath: _selectedNode!.profileImagePath,
                  size: 50,
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
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
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
                                      ? theme.colorScheme.secondary.withOpacity(
                                          0.3,
                                        )
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: matches
                                        ? theme.colorScheme.secondary
                                              .withOpacity(0.5)
                                        : theme.colorScheme.onSurface
                                              .withOpacity(0.5),
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
                                    ? theme.colorScheme.secondary.withOpacity(
                                        0.3,
                                      )
                                    : theme.colorScheme.onSurface.withOpacity(
                                        0.3,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: matches
                                      ? theme.colorScheme.secondary.withOpacity(
                                          0.5,
                                        )
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.5,
                                        ),
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
        final baseOpacity = 0.5;
        final highlightOpacity = 1.0;

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
        (node) =>
            node.id == 'you' ||
            (!node.isTextNode && node.connections.isNotEmpty),
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

    // Calculate 1-hop radius - make it bigger to capture all nodes
    double radius;
    if (custom1HopRadius != null) {
      radius = custom1HopRadius!;
    } else {
      // Calculate based on distance to furthest direct connection, then add extra padding
      final directConnections = nodes.where((n) => n.isDirectConnection);
      double maxDistance = 0;

      for (final node in directConnections) {
        final distance = (node.position - currentUserNode.position).distance;
        maxDistance = math.max(maxDistance, distance);
      }

      // Make it significantly bigger to capture all nodes with good margin
      radius = maxDistance > 0 ? maxDistance + 50 : 200; // Add generous padding
    }

    // Draw red overlay circle with fill
    final circlePaint = Paint()
      ..color = Colors.red.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(currentUserNode.position, radius, circlePaint);

    // Draw red border
    final borderPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..isAntiAlias = true;

    canvas.drawCircle(
      currentUserNode.position,
      radius,
      borderPaint,
    ); // Add "Your connections" text above the circle
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
      currentUserNode.position.dx - textPainter.width / 2,
      currentUserNode.position.dy - radius - 25,
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
