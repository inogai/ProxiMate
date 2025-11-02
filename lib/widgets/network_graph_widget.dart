import 'package:flutter/material.dart';

/// Node in the network graph
class NetworkNode {
  final String id;
  final String name;
  final String? school;
  final Color color;
  Offset position;
  Offset velocity;
  bool isDragging;
  final List<String> connections;

  NetworkNode({
    required this.id,
    required this.name,
    this.school,
    required this.color,
    required this.position,
    this.connections = const [],
  })  : velocity = Offset.zero,
        isDragging = false;
}

/// Interactive network graph widget with Obsidian-like visualization
class NetworkGraphWidget extends StatefulWidget {
  final List<NetworkNode> nodes;
  final Function(NetworkNode)? onNodeTap;
  final String? initialSelectedNodeId;

  const NetworkGraphWidget({
    super.key,
    required this.nodes,
    this.onNodeTap,
    this.initialSelectedNodeId,
  });

  @override
  State<NetworkGraphWidget> createState() => _NetworkGraphWidgetState();
}

class _NetworkGraphWidgetState extends State<NetworkGraphWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  NetworkNode? _selectedNode;
  NetworkNode? _draggingNode;
  Offset _dragOffset = Offset.zero;
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;

  // Physics simulation parameters
  static const double nodeRadius = 30.0;
  static const double damping = 0.85; // Higher damping for quicker settle

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updatePhysics);
    // Don't start animation automatically - physics disabled for stationary nodes
    // _animationController.repeat();
    
    // Set initial selected node if provided
    if (widget.initialSelectedNodeId != null) {
      _selectedNode = widget.nodes.firstWhere(
        (node) => node.id == widget.initialSelectedNodeId,
        orElse: () => widget.nodes.first,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    // Only apply physics when a node is being dragged or settling
    if (_draggingNode == null) {
      // Check if any node has velocity (is settling after drag)
      bool hasMovement = false;
      for (final node in widget.nodes) {
        if (node.velocity.distance > 0.1) {
          hasMovement = true;
          break;
        }
      }
      
      if (!hasMovement) {
        _animationController.stop();
        return;
      }
    }

    setState(() {
      // Only apply damping to slow down nodes after drag
      for (int i = 0; i < widget.nodes.length; i++) {
        if (widget.nodes[i].isDragging) continue;

        // Apply damping to velocity
        widget.nodes[i].velocity *= damping;
        
        // Update position based on velocity
        widget.nodes[i].position += widget.nodes[i].velocity;
        
        // Stop movement if velocity is very small
        if (widget.nodes[i].velocity.distance < 0.1) {
          widget.nodes[i].velocity = Offset.zero;
        }
      }
    });
  }

  void _onNodePanStart(NetworkNode node, DragStartDetails details) {
    setState(() {
      _draggingNode = node;
      node.isDragging = true;
      _dragOffset = details.localPosition - node.position;
    });
  }

  void _onNodePanUpdate(NetworkNode node, DragUpdateDetails details) {
    setState(() {
      node.position = details.localPosition - _dragOffset;
      node.velocity = Offset.zero;
    });
  }

  void _onNodePanEnd(NetworkNode node, DragEndDetails details) {
    setState(() {
      node.isDragging = false;
      _draggingNode = null;
      
      // Add velocity based on drag velocity for bounce effect
      node.velocity = details.velocity.pixelsPerSecond * 0.05;
      
      // Start animation to handle the settling
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    });
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
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      child: Container(
        color: Colors.grey[900],
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background grid
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(
                scale: _scale,
                offset: _panOffset,
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
                      nodes: widget.nodes,
                      selectedNode: _selectedNode,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: widget.nodes.map((node) {
                        return Positioned(
                          left: node.position.dx - nodeRadius,
                          top: node.position.dy - nodeRadius,
                          child: GestureDetector(
                            onPanStart: (details) =>
                                _onNodePanStart(node, details),
                            onPanUpdate: (details) =>
                                _onNodePanUpdate(node, details),
                            onPanEnd: (details) => _onNodePanEnd(node, details),
                            onTap: () {
                              setState(() {
                                _selectedNode = node;
                              });
                              widget.onNodeTap?.call(node);
                            },
                            child: _buildNode(node),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            // Controls overlay
            Positioned(
              top: 16,
              right: 16,
              child: _buildControls(),
            ),
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

  Widget _buildNode(NetworkNode node) {
    final isSelected = _selectedNode?.id == node.id;
    final isYou = node.id == 'you';
    final baseSize = isYou ? nodeRadius * 2.6 : nodeRadius * 2;
    final size = isSelected ? baseSize * 1.2 : baseSize;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: node.color,
        border: Border.all(
          color: isSelected
              ? Colors.white
              : isYou
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.3),
          width: isSelected ? 3 : (isYou ? 3 : 2),
        ),
        boxShadow: [
          BoxShadow(
            color: node.color.withOpacity(0.5),
            blurRadius: isSelected ? 20 : (isYou ? 15 : 10),
            spreadRadius: isSelected ? 5 : (isYou ? 4 : 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          isYou ? 'YOU' : node.name.split(' ').map((e) => e[0]).take(2).join(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSelected ? (isYou ? 18 : 16) : (isYou ? 16 : 14),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      color: Colors.black.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                setState(() {
                  _scale = (_scale + 0.2).clamp(0.5, 3.0);
                });
              },
              tooltip: 'Zoom In',
            ),
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white),
              onPressed: () {
                setState(() {
                  _scale = (_scale - 0.2).clamp(0.5, 3.0);
                });
              },
              tooltip: 'Zoom Out',
            ),
            IconButton(
              icon: const Icon(Icons.center_focus_strong, color: Colors.white),
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
    if (_selectedNode == null) return const SizedBox.shrink();

    return Card(
      color: Colors.black.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedNode!.color,
              ),
              child: Center(
                child: Text(
                  _selectedNode!.id == 'you'
                      ? 'YOU'
                      : _selectedNode!.name.split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedNode!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedNode!.school != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedNode!.school!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedNode!.connections.length} connections',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedNode = null;
                });
              },
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

  NetworkGraphPainter({
    required this.nodes,
    this.selectedNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

        final isHighlighted = selectedNode?.id == node.id ||
            selectedNode?.id == connectedNode.id;

        connectionPaint.color = isHighlighted
            ? Colors.white.withOpacity(0.6)
            : Colors.white.withOpacity(0.1);
        connectionPaint.strokeWidth = isHighlighted ? 3 : 1.5;

        canvas.drawLine(
          node.position,
          connectedNode.position,
          connectionPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(NetworkGraphPainter oldDelegate) => true;
}

/// Painter for the background grid
class GridPainter extends CustomPainter {
  final double scale;
  final Offset offset;

  GridPainter({required this.scale, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const gridSize = 50.0;

    for (double x = 0; x < size.width; x += gridSize * scale) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gridSize * scale) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) =>
      scale != oldDelegate.scale || offset != oldDelegate.offset;
}
