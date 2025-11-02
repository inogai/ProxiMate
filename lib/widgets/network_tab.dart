import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/name_card.dart';
import 'network_graph_widget.dart';

/// Network tab widget showing collected name cards
class NetworkTab extends StatefulWidget {
  const NetworkTab({super.key});

  @override
  State<NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends State<NetworkTab> {
  bool _showGraph = true;

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final nameCards = storage.nameCards;

    return Scaffold(
      body: nameCards.isEmpty
          ? _buildEmptyState(context)
          : _showGraph
              ? _buildNetworkGraph(context, nameCards)
              : _buildNetworkGrid(context, nameCards),
      floatingActionButton: nameCards.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showGraph = !_showGraph;
                });
              },
              child: Icon(_showGraph ? Icons.list : Icons.hub),
              tooltip: _showGraph ? 'List View' : 'Graph View',
            )
          : null,
    );
  }

  Widget _buildNetworkGraph(BuildContext context, List<NameCard> nameCards) {
    // Create mock network with connections
    final size = MediaQuery.of(context).size;
    final random = Random(42); // Fixed seed for consistency
    
    // Generate nodes from name cards + mock connections
    final nodes = <NetworkNode>[];
    
    // Add YOU as the central node with random offset
    nodes.add(NetworkNode(
      id: 'you',
      name: 'YOU',
      school: 'Your University',
      color: Colors.amber,
      position: Offset(
        size.width * 0.5 + (random.nextDouble() - 0.5) * 40,
        size.height * 0.5 + (random.nextDouble() - 0.5) * 40,
      ),
      connections: [], // Will be populated below
    ));

    // Define mock people with their specific friend connections (by ID)
    // Varying friend counts: 1 to 6 friends per person
    final mockPeople = [
      {
        'id': 'mock_0',
        'name': 'Alex Chen',
        'school': 'MIT',
        'friends': ['you', 'mock_1', 'mock_2', 'mock_5', 'mock_8'], // 5 friends
        'color': Colors.blue,
      },
      {
        'id': 'mock_1',
        'name': 'Sarah Kim',
        'school': 'Stanford',
        'friends': ['you', 'mock_0', 'mock_3', 'mock_9'], // 4 friends
        'color': Colors.purple,
      },
      {
        'id': 'mock_2',
        'name': 'Mike Johnson',
        'school': 'Berkeley',
        'friends': ['mock_0', 'mock_4', 'mock_11'], // 3 friends
        'color': Colors.green,
      },
      {
        'id': 'mock_3',
        'name': 'Emma Davis',
        'school': 'Harvard',
        'friends': ['you', 'mock_1', 'mock_5', 'mock_6', 'mock_10'], // 5 friends
        'color': Colors.orange,
      },
      {
        'id': 'mock_4',
        'name': 'James Wilson',
        'school': 'Yale',
        'friends': ['mock_2', 'mock_6', 'mock_12'], // 3 friends
        'color': Colors.pink,
      },
      {
        'id': 'mock_5',
        'name': 'Lisa Martinez',
        'school': 'Princeton',
        'friends': ['you', 'mock_0', 'mock_3', 'mock_7', 'mock_9', 'mock_13'], // 6 friends (popular!)
        'color': Colors.teal,
      },
      {
        'id': 'mock_6',
        'name': 'Tom Anderson',
        'school': 'Columbia',
        'friends': ['mock_3', 'mock_4'], // 2 friends
        'color': Colors.red,
      },
      {
        'id': 'mock_7',
        'name': 'Nina Patel',
        'school': 'Cornell',
        'friends': ['you', 'mock_5', 'mock_11'], // 3 friends
        'color': Colors.indigo,
      },
      {
        'id': 'mock_8',
        'name': 'David Lee',
        'school': 'Duke',
        'friends': ['mock_0', 'mock_10'], // 2 friends
        'color': Colors.deepOrange,
      },
      {
        'id': 'mock_9',
        'name': 'Rachel Green',
        'school': 'Brown',
        'friends': ['mock_1', 'mock_5', 'mock_12', 'mock_13'], // 4 friends
        'color': Colors.lime,
      },
      {
        'id': 'mock_10',
        'name': 'Kevin Wang',
        'school': 'Caltech',
        'friends': ['mock_3', 'mock_8'], // 2 friends
        'color': Colors.cyan,
      },
      {
        'id': 'mock_11',
        'name': 'Sophia Torres',
        'school': 'Northwestern',
        'friends': ['mock_2', 'mock_7', 'mock_13'], // 3 friends
        'color': Colors.pinkAccent,
      },
      {
        'id': 'mock_12',
        'name': 'Ryan Cooper',
        'school': 'UPenn',
        'friends': ['mock_4', 'mock_9'], // 2 friends
        'color': Colors.blueGrey,
      },
      {
        'id': 'mock_13',
        'name': 'Maya Patel',
        'school': 'Dartmouth',
        'friends': ['you', 'mock_5', 'mock_9', 'mock_11'], // 4 friends
        'color': Colors.deepPurple,
      },
      {
        'id': 'mock_14',
        'name': 'Chris Martin',
        'school': 'Rice',
        'friends': ['mock_0'], // 1 friend (introvert!)
        'color': Colors.brown,
      },
    ];

    // Add actual name cards as nodes (they all connect to YOU)
    for (int i = 0; i < nameCards.length; i++) {
      final card = nameCards[i];
      final angle = (i / max(nameCards.length, 1)) * 2 * 3.14159 + random.nextDouble() * 0.5;
      final radius = min(size.width, size.height) * (0.25 + random.nextDouble() * 0.15);
      
      nodes.add(NetworkNode(
        id: card.peerId,
        name: card.name,
        school: card.school,
        color: Colors.cyan, // Will be updated based on distance
        position: Offset(
          size.width * 0.5 + radius * cos(angle) + (random.nextDouble() - 0.5) * 80,
          size.height * 0.5 + radius * sin(angle) + (random.nextDouble() - 0.5) * 80,
        ),
        connections: ['you'], // Name cards connect to YOU
      ));
      
      // Add connection from YOU to this name card
      nodes[0].connections.add(card.peerId);
    }

    // Add mock nodes scattered around the screen with better spacing
    final mockCount = min(mockPeople.length, 15);
    
    // Create a grid-like distribution with randomization
    final cols = 4;
    final rows = (mockCount / cols).ceil();
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;
    
    for (int i = 0; i < mockCount; i++) {
      final person = mockPeople[i];
      
      final col = i % cols;
      final row = i ~/ cols;
      
      // Position in cell center with random offset
      final baseX = cellWidth * (col + 0.5) + (random.nextDouble() - 0.5) * cellWidth * 0.6;
      final baseY = cellHeight * (row + 0.5) + (random.nextDouble() - 0.5) * cellHeight * 0.6;
      
      nodes.add(NetworkNode(
        id: person['id'] as String,
        name: person['name'] as String,
        school: person['school'] as String,
        color: person['color'] as Color, // Will be updated based on distance
        position: Offset(
          baseX.clamp(cellWidth * 0.1, size.width - cellWidth * 0.1),
          baseY.clamp(cellHeight * 0.1, size.height - cellHeight * 0.1),
        ),
        connections: List<String>.from(person['friends'] as List),
      ));
    }

    // Update YOU's connections based on mock people who listed 'you' as friend
    for (final person in mockPeople.take(mockCount)) {
      final friends = person['friends'] as List;
      if (friends.contains('you')) {
        nodes[0].connections.add(person['id'] as String);
      }
    }

    // Calculate connection distance from YOU for each node and assign gradient colors
    final distances = _calculateConnectionDistances(nodes);
    final maxDistance = distances.values.reduce((a, b) => a > b ? a : b);
    
    for (int i = 1; i < nodes.length; i++) {
      final distance = distances[nodes[i].id] ?? 999;
      if (distance == 999) {
        // Not connected - gray
        nodes[i] = NetworkNode(
          id: nodes[i].id,
          name: nodes[i].name,
          school: nodes[i].school,
          color: Colors.grey,
          position: nodes[i].position,
          connections: nodes[i].connections,
        );
      } else {
        // Gradient from close (cyan) to far (purple)
        final ratio = (distance - 1) / max(maxDistance - 1, 1);
        nodes[i] = NetworkNode(
          id: nodes[i].id,
          name: nodes[i].name,
          school: nodes[i].school,
          color: Color.lerp(Colors.cyan, Colors.deepPurple, ratio)!,
          position: nodes[i].position,
          connections: nodes[i].connections,
        );
      }
    }

    return Stack(
      children: [
        NetworkGraphWidget(
          nodes: nodes,
          initialSelectedNodeId: 'you', // Initialize with YOU selected
          onNodeTap: (node) {
            // Find the corresponding name card if it exists
            final nameCard = nameCards.firstWhere(
              (card) => card.peerId == node.id,
              orElse: () => nameCards.first,
            );
            if (nameCards.any((card) => card.peerId == node.id)) {
              _showNameCardDetails(context, nameCard);
            }
          },
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Card(
            color: Colors.black.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Network',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${nodes.length} people • ${_countConnections(nodes)} connections',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _countConnections(List<NetworkNode> nodes) {
    int total = 0;
    for (final node in nodes) {
      total += node.connections.length;
    }
    return total ~/ 2; // Divide by 2 because connections are bidirectional
  }

  /// Calculate the shortest connection distance from YOU to each node using BFS
  Map<String, int> _calculateConnectionDistances(List<NetworkNode> nodes) {
    final distances = <String, int>{'you': 0};
    final queue = <String>['you'];
    final visited = <String>{'you'};

    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      final currentDistance = distances[currentId]!;
      final currentNode = nodes.firstWhere((n) => n.id == currentId);

      for (final friendId in currentNode.connections) {
        if (!visited.contains(friendId)) {
          visited.add(friendId);
          distances[friendId] = currentDistance + 1;
          queue.add(friendId);
        }
      }
    }

    return distances;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Name Cards Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Collect name cards from people you meet\nto build your network!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkGrid(BuildContext context, List<NameCard> nameCards) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'My Network (${nameCards.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final nameCard = nameCards[index];
                return _buildNameCard(context, nameCard);
              },
              childCount: nameCards.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameCard(BuildContext context, NameCard nameCard) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _showNameCardDetails(context, nameCard),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      nameCard.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameCard.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${nameCard.major} • ${nameCard.school}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.interests, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nameCard.interests,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Met at ${nameCard.restaurant}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(nameCard.collectedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNameCardDetails(BuildContext context, NameCard nameCard) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    nameCard.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nameCard.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                Icons.school,
                'School',
                nameCard.school,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                Icons.book,
                'Major',
                nameCard.major,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                Icons.interests,
                'Interests',
                nameCard.interests,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                Icons.person,
                'Background',
                nameCard.background,
                Colors.purple,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Met at ${nameCard.restaurant}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatFullDate(nameCard.collectedAt),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
