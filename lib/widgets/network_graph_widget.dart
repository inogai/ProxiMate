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
  })  : velocity = Offset.zero,
        isDragging = false;
}

/// Interactive network graph widget with Obsidian-like visualization
class NetworkGraphWidget extends StatefulWidget {
  final List<NetworkNode> nodes;
  final Function(NetworkNode)? onNodeTap;
  final Function(NetworkNode)? onInfoBarTap;
  final String? initialSelectedNodeId;
  final String? currentUserId;
  final String? currentUserMajor;
  final String? currentUserInterests;

  const NetworkGraphWidget({
    super.key,
    required this.nodes,
    this.onNodeTap,
    this.onInfoBarTap,
    this.initialSelectedNodeId,
    this.currentUserId,
    this.currentUserMajor,
    this.currentUserInterests,
  });

  @override
  State<NetworkGraphWidget> createState() => _NetworkGraphWidgetState();
}

class _NetworkGraphWidgetState extends State<NetworkGraphWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  NetworkNode? _selectedNode;
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  bool _hideNoCommonInterests = false;

  // Physics simulation parameters
  static const double nodeRadius = 30.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    );
    // Physics disabled for better performance
    
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

  void _onNodePanStart(NetworkNode node, DragStartDetails details, double offset) {
    setState(() {
      node.isDragging = true;
    });
  }

  bool _hasCommonInterests(NetworkNode node) {
    // Always show current user, text nodes, and direct connections
    if (node.id == widget.currentUserId || node.isTextNode || node.isDirectConnection) return true;
    
    // Check for common major
    if (widget.currentUserMajor != null && node.major != null) {
      if (node.major!.toLowerCase() == widget.currentUserMajor!.toLowerCase()) {
        return true;
      }
    }
    
    // Check for common interests
    if (widget.currentUserInterests != null && node.interests != null) {
      final currentUserInterestsList = widget.currentUserInterests!
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
              const Text(
                'Filter extended connections by common interests',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Filter Common Tags Only'),
                subtitle: const Text(
                  'Hide connections with no shared major or interests',
                  style: TextStyle(fontSize: 12),
                ),
                value: _hideNoCommonInterests,
                onChanged: (bool value) {
                  setState(() {
                    _hideNoCommonInterests = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _onNodePanUpdate(NetworkNode node, DragUpdateDetails details, double offset) {
    if (!mounted) return;
    setState(() {
      // Use delta for smooth incremental updates instead of recalculating position
      node.position += details.delta / _scale;
      node.velocity = Offset.zero;
    });
  }

  void _onNodePanEnd(NetworkNode node, DragEndDetails details) {
    setState(() {
      node.isDragging = false;
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
    // Filter nodes based on common interests setting
    final visibleNodes = _hideNoCommonInterests
        ? widget.nodes.where((node) => _hasCommonInterests(node)).toList()
        : widget.nodes;

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
                      nodes: visibleNodes,
                      selectedNode: _selectedNode,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: visibleNodes.map((node) {
                        final isSelected = _selectedNode?.id == node.id;
                        final isYou = widget.currentUserId != null && node.id == widget.currentUserId;
                        final baseSize = isYou ? nodeRadius * 2.6 : nodeRadius * 2;
                        final size = isSelected ? baseSize * 1.2 : baseSize;
                        final offset = size / 2;
                        
                        // For text nodes, center differently
                        if (node.isTextNode) {
                          return Positioned(
                            left: node.position.dx,
                            top: node.position.dy,
                            child: Transform.translate(
                              offset: const Offset(-125, -10), // Center the ~250px wide text
                              child: SizedBox(
                                width: 250,
                                child: GestureDetector(
                                  onTap: () {
                                    // Text nodes are not interactive
                                  },
                                  child: _buildNode(node),
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return Positioned(
                          left: node.position.dx - offset,
                          top: node.position.dy - offset,
                          child: GestureDetector(
                            onPanStart: (details) =>
                                _onNodePanStart(node, details, offset),
                            onPanUpdate: (details) =>
                                _onNodePanUpdate(node, details, offset),
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

    final isSelected = _selectedNode?.id == node.id;
    final isYou = widget.currentUserId != null && node.id == widget.currentUserId;
    final baseSize = isYou ? nodeRadius * 2.6 : nodeRadius * 2;
    final size = isSelected ? baseSize * 1.2 : baseSize;
    final double opacity = node.isDirectConnection 
        ? 1.0 
        : (node.depth != null && node.depth! >= 2 ? 0.25 : 0.4);

    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: node.profileImagePath == null ? node.color : Colors.transparent,
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
        child: ClipOval(
          child: node.profileImagePath != null
              ? RepaintBoundary(
                  child: Image(
                    image: _getImageProvider(node.profileImagePath!),
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
                            isYou ? 'YOU' : node.name.split(' ').map((e) => e[0]).take(2).join(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isSelected ? (isYou ? 18 : 16) : (isYou ? 16 : 14),
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
                      isYou ? 'YOU' : node.name.split(' ').map((e) => e[0]).take(2).join(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSelected ? (isYou ? 18 : 16) : (isYou ? 16 : 14),
                      ),
                    ),
                  ),
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
              icon: Icon(
                _hideNoCommonInterests ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: _hideNoCommonInterests ? Colors.green : Colors.white,
              ),
              onPressed: _showFilterDialog,
              tooltip: 'Filter Network',
            ),
            const Divider(color: Colors.white24, height: 1),
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
    final bool isCurrentUser = _selectedNode!.id == 'you' || _selectedNode!.id == widget.currentUserId;

    return Card(
      color: Colors.black.withOpacity(0.85),
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
                  color: _selectedNode!.profileImagePath == null ? _selectedNode!.color : Colors.transparent,
                ),
                child: ClipOval(
                  child: _selectedNode!.profileImagePath != null
                      ? RepaintBoundary(
                          child: Image(
                            image: _getImageProvider(_selectedNode!.profileImagePath!),
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
                                        : _selectedNode!.name.split(' ').map((e) => e[0]).take(2).join(),
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                  : _selectedNode!.name.split(' ').map((e) => e[0]).take(2).join(),
                              style: const TextStyle(
                                color: Colors.white,
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (_selectedNode!.major != null)
                          Builder(
                            builder: (context) {
                              final bool matches = widget.currentUserMajor != null &&
                                  _selectedNode!.major!.toLowerCase() ==
                                      widget.currentUserMajor!.toLowerCase();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: matches
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: matches
                                          ? Colors.green.withOpacity(0.5)
                                          : Colors.grey.withOpacity(0.5)),
                                ),
                                child: Text(
                                  _selectedNode!.major!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (_selectedNode!.interests != null)
                          ..._selectedNode!.interests!.split(',').map((interest) {
                            final trimmedInterest = interest.trim();
                            final currentUserInterestsList = widget.currentUserInterests
                                ?.split(',')
                                .map((i) => i.trim().toLowerCase())
                                .toList() ?? [];
                            final bool matches = currentUserInterestsList
                                .contains(trimmedInterest.toLowerCase());
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: matches
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: matches
                                        ? Colors.green.withOpacity(0.5)
                                        : Colors.grey.withOpacity(0.5)),
                              ),
                              child: Text(
                                trimmedInterest,
                                style: const TextStyle(
                                  color: Colors.white,
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
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
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
                icon: const Icon(Icons.close, color: Colors.white),
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

  ImageProvider _getImageProvider(String imagePath) {
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
        
        // Make connection line more transparent if either node is indirect
        final isIndirectConnection = !node.isDirectConnection || !connectedNode.isDirectConnection;
        final baseOpacity = isIndirectConnection ? 0.05 : 0.1;
        final highlightOpacity = isIndirectConnection ? 0.3 : 0.6;

        connectionPaint.color = isHighlighted
            ? Colors.white.withOpacity(highlightOpacity)
            : Colors.white.withOpacity(baseOpacity);
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
