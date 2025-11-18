import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/connection.dart';
import '../models/profile.dart';
import '../models/meeting.dart';
import '../screens/chat_room_screen.dart';
import 'network_graph_widget.dart';

/// Network tab widget showing connections
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
    final connections = storage.connections;

    return Scaffold(
      body: _showGraph
          ? _buildNetworkGraph(context)
          : _buildNetworkGrid(context),
      floatingActionButton: connections.isNotEmpty
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

  Widget _buildNetworkGraph(BuildContext context) {
    final storage = context.watch<StorageService>();
    final currentProfile = storage.currentProfile;
    final connections = storage.connections;
    final connectedProfiles = storage.connectedProfiles;
    final nearbyPeers = storage.nearbyPeers;

    if (currentProfile == null) {
      return const Center(child: Text('No profile'));
    }

    final size = MediaQuery.of(context).size;
    final nodes = <NetworkNode>[];

    // Always add current user as center node
    nodes.add(NetworkNode(
      id: currentProfile.id,
      name: currentProfile.userName,
      school: currentProfile.school ?? '',
      major: currentProfile.major,
      interests: currentProfile.interests,
      color: Colors.blue,
      position: Offset(size.width * 0.5, size.height * 0.5),
      connections: connections.map((c) => c.toProfileId).toList(),
      profileImagePath: currentProfile.profileImagePath,
    ));

    // If no connections, add a text node above current user
    if (connectedProfiles.isEmpty) {
      // Add a dummy text node positioned north of the user
      nodes.add(NetworkNode(
        id: 'empty_message',
        name: 'Start by finding new connections at "Find Peers"',
        school: '',
        color: Colors.transparent,
        position: Offset(size.width * 0.5, size.height * 0.5 - 150),
        connections: [],
        isDirectConnection: false,
        isTextNode: true,
      ));
      
      return Stack(
        children: [
          NetworkGraphWidget(
            nodes: nodes,
            initialSelectedNodeId: currentProfile.id,
            currentUserId: currentProfile.id,
            currentUserMajor: currentProfile.major,
            currentUserInterests: currentProfile.interests,
            onInfoBarTap: (node) => _showCurrentUserProfile(context),
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
                      'ProxiMate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No connections yet',
                      style: TextStyle(
                        color: Colors.white70,
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

    // Position connected profiles around current user
    final List<String> directConnectionIds = [];
    for (int i = 0; i < connectedProfiles.length; i++) {
      final profile = connectedProfiles[i];
      final angle = (i / connectedProfiles.length) * 2 * pi;
      final radius = min(size.width, size.height) * 0.25;

      // Try to find matching peer to get profileImageUrl, or use profile's own image path
      String? imageUrl;
      if (nearbyPeers.isNotEmpty) {
        try {
          final matchingPeer = nearbyPeers.firstWhere(
            (peer) => peer.id == profile.id,
          );
          imageUrl = matchingPeer.profileImageUrl;
        } catch (e) {
          // No matching peer found, use profile's image path
          imageUrl = profile.profileImagePath;
        }
      } else {
        imageUrl = profile.profileImagePath;
      }

      directConnectionIds.add(profile.id);

      nodes.add(NetworkNode(
        id: profile.id,
        name: profile.userName,
        school: profile.school ?? '',
        major: profile.major,
        interests: profile.interests,
        color: Colors.orange,
        position: Offset(
          size.width * 0.5 + radius * cos(angle),
          size.height * 0.5 + radius * sin(angle),
        ),
        connections: [currentProfile.id],
        profileImagePath: imageUrl,
        isDirectConnection: true,
      ));
    }

    // Add mock secondary connections using database-like system
    if (connectedProfiles.isNotEmpty) {
      // Use the mock network database to add secondary connections
      final database = storage.generateMockNetworkDatabase();
      final profiles = database['profiles'] as Map<String, dynamic>;
      final connections = database['connections'] as List<Map<String, String>>;
      
      // Build adjacency map: profile key -> list of connected profile keys
      final adjacencyMap = <String, List<String>>{};
      for (final conn in connections) {
        final from = conn['from']!;
        final to = conn['to']!;
        adjacencyMap.putIfAbsent(from, () => []).add(to);
        adjacencyMap.putIfAbsent(to, () => []).add(from);
      }
      
      // Identify which mock profiles are "direct friends" (friends with 'you')
      // These are: mock_0, mock_1, mock_3, mock_5, mock_7, mock_13
      final directFriendIds = ['mock_0', 'mock_1', 'mock_3', 'mock_5', 'mock_7', 'mock_13'];
      
      // Map real connection IDs to mock direct friend IDs
      final realToMockMap = <String, String>{};
      final directNodeIds = directConnectionIds.toSet();
      
      for (int i = 0; i < min(directNodeIds.length, directFriendIds.length); i++) {
        realToMockMap[directConnectionIds[i]] = directFriendIds[i];
      }
      
      // BFS to find all reachable profiles and their actual connections in the mock network
      final visited = <String>{};
      final queue = <({String key, int depth, String fromRealId})>[];
      final profileInfo = <String, ({int depth, String fromRealId, List<String> mockConnections})>{};
      
      // Start BFS from the mapped mock profiles (these represent real connections)
      for (final entry in realToMockMap.entries) {
        final realId = entry.key;
        final mockKey = entry.value;
        queue.add((key: mockKey, depth: 0, fromRealId: realId));
        visited.add(mockKey);
      }
      
      while (queue.isNotEmpty) {
        final current = queue.removeAt(0);
        
        // Get actual connections for this profile from adjacency map
        final actualConnections = adjacencyMap[current.key] ?? [];
        
        // Record this profile with its actual mock network connections
        if (current.depth > 0) {
          profileInfo[current.key] = (
            depth: current.depth, 
            fromRealId: current.fromRealId,
            mockConnections: actualConnections,
          );
        }
        
        // Explore neighbors
        for (final neighbor in actualConnections) {
          if (!visited.contains(neighbor) && !realToMockMap.containsValue(neighbor)) {
            visited.add(neighbor);
            queue.add((
              key: neighbor,
              depth: current.depth + 1,
              fromRealId: current.fromRealId,
            ));
          }
        }
      }
      
      // Create a map to store mock ID to node for connection references
      final mockIdToNodeId = <String, String>{};
      
      // Add nodes for profiles found through BFS
      for (final entry in profileInfo.entries) {
        final profileKey = entry.key;
        final depth = entry.value.depth;
        final fromRealId = entry.value.fromRealId;
        final mockConnections = entry.value.mockConnections;
        
        final profileData = profiles[profileKey] as Map<String, dynamic>;
        final mockId = profileData['id'] as String;
        
        // Find the real connection node this path came from (for positioning)
        final directNode = nodes.firstWhere(
          (n) => n.id == fromRealId,
          orElse: () => nodes[1],
        );
        
        // Calculate position based on depth (further out = higher depth)
        final depthRadius = min(size.width, size.height) * (0.30 + (depth * 0.12));
        
        // Calculate how many nodes from this direct connection already
        final existingFromThis = nodes.where(
          (n) => !n.isDirectConnection && n.connections.isNotEmpty
        ).length;
        
        // Position around the direct connection
        final baseAngle = atan2(
          directNode.position.dy - size.height * 0.5,
          directNode.position.dx - size.width * 0.5,
        );
        
        // Spread in an arc (more spread as more nodes)
        final spreadAngle = (existingFromThis * (pi / 5)) - (pi / 2.5);
        
        // Determine connections: connect to direct friend if depth 1, otherwise to mock friends
        final nodeConnections = <String>[];
        if (depth == 1) {
          // Direct connection to real friend
          nodeConnections.add(fromRealId);
        } else {
          // Connect to actual mock friends that are already added as nodes
          for (final mockConn in mockConnections) {
            // Check if this mock connection maps to a real connection
            if (realToMockMap.containsValue(mockConn)) {
              // Find the real ID that maps to this mock ID
              final realId = realToMockMap.entries
                  .firstWhere((e) => e.value == mockConn, orElse: () => MapEntry('', ''))
                  .key;
              if (realId.isNotEmpty) {
                nodeConnections.add(realId);
              }
            } else if (mockIdToNodeId.containsKey(mockConn)) {
              // This is another mock profile already added
              nodeConnections.add(mockIdToNodeId[mockConn]!);
            }
          }
        }
        
        final newNode = NetworkNode(
          id: mockId,
          name: profileData['name'] as String,
          school: profileData['school'] as String,
          major: profileData['major'] as String?,
          interests: profileData['interests'] as String?,
          color: Colors.grey,
          position: Offset(
            size.width * 0.5 + depthRadius * cos(baseAngle + spreadAngle),
            size.height * 0.5 + depthRadius * sin(baseAngle + spreadAngle),
          ),
          connections: nodeConnections,
          profileImagePath: profileData['imageUrl'] as String,
          isDirectConnection: false,
          depth: depth,
        );
        
        nodes.add(newNode);
        mockIdToNodeId[mockId] = mockId;
      }
    }

    return Stack(
      children: [
        NetworkGraphWidget(
          nodes: nodes,
          initialSelectedNodeId: currentProfile.id,
          currentUserId: currentProfile.id,
          currentUserMajor: currentProfile.major,
          currentUserInterests: currentProfile.interests,
          onInfoBarTap: (node) {
            if (node.id == currentProfile.id) {
              _showCurrentUserProfile(context);
            } else {
              final profile = connectedProfiles.firstWhere((p) => p.id == node.id);
              final connection = connections.firstWhere((c) => c.toProfileId == node.id);
              _showConnectionDetails(context, profile, connection);
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
                    'ProxiMate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${connections.length} ${connections.length == 1 ? 'Connection' : 'Connections'}',
                    style: TextStyle(
                      color: Colors.white70,
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

  void _showCurrentUserProfile(BuildContext context) {
    final storage = context.read<StorageService>();
    final profile = storage.currentProfile;
    if (profile == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
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
                  backgroundImage: profile.profileImagePath != null
                      ? _getImageProvider(profile.profileImagePath!)
                      : null,
                  child: profile.profileImagePath == null
                      ? Text(
                          profile.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.userName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              if (profile.school != null)
                _buildDetailRow(
                  context,
                  Icons.school,
                  'School',
                  profile.school!,
                  Colors.blue,
                ),
              if (profile.school != null) const SizedBox(height: 16),
              if (profile.major != null)
                _buildDetailRow(
                  context,
                  Icons.book,
                  'Major',
                  profile.major!,
                  Colors.green,
                ),
              if (profile.major != null) const SizedBox(height: 16),
              if (profile.interests != null)
                _buildDetailRow(
                  context,
                  Icons.interests,
                  'Interests',
                  profile.interests!,
                  Colors.orange,
                ),
              if (profile.interests != null) const SizedBox(height: 16),
              if (profile.background != null)
                _buildDetailRow(
                  context,
                  Icons.person,
                  'Background',
                  profile.background!,
                  Colors.purple,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConnectionDetails(BuildContext context, Profile profile, Connection connection) {
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
                  backgroundImage: profile.profileImagePath != null
                      ? _getImageProvider(profile.profileImagePath!)
                      : null,
                  child: profile.profileImagePath == null
                      ? Text(
                          profile.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.userName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              if (profile.school != null)
                _buildDetailRow(
                  context,
                  Icons.school,
                  'School',
                  profile.school!,
                  Colors.blue,
                ),
              if (profile.school != null) const SizedBox(height: 16),
              if (profile.major != null)
                _buildDetailRow(
                  context,
                  Icons.book,
                  'Major',
                  profile.major!,
                  Colors.green,
                ),
              if (profile.major != null) const SizedBox(height: 16),
              if (profile.interests != null)
                _buildDetailRow(
                  context,
                  Icons.interests,
                  'Interests',
                  profile.interests!,
                  Colors.orange,
                ),
              if (profile.interests != null) const SizedBox(height: 16),
              if (profile.background != null)
                _buildDetailRow(
                  context,
                  Icons.person,
                  'Background',
                  profile.background!,
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
                      'Met at ${connection.restaurant}',
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
                    _formatFullDate(connection.collectedAt),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openChat(context, profile, connection);
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, Profile profile, Connection connection) {
    final storage = context.read<StorageService>();
    
    // Find or create chat room for this connection
    ChatRoom? chatRoom = storage.chatRooms.firstWhere(
      (room) => room.peerId == profile.id,
      orElse: () => ChatRoom(
        id: 'chat_${profile.id}',
        peerId: profile.id,
        peerName: profile.userName,
        restaurant: connection.restaurant,
        createdAt: DateTime.now(),
        messages: [],
      ),
    );
    
    // Add chat room if it doesn't exist
    if (!storage.chatRooms.any((room) => room.peerId == profile.id)) {
      // We can't directly add to storage here, but the chat room screen will handle it
      // For now, just navigate with the chat room
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
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

  Widget _buildNetworkGrid(BuildContext context) {
    final storage = context.watch<StorageService>();
    final connections = storage.connections;
    final connectedProfiles = storage.connectedProfiles;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'My Network (${connections.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = connectedProfiles[index];
                final connection = connections[index];
                return _buildConnectionCard(context, profile, connection);
              },
              childCount: connectedProfiles.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard(BuildContext context, Profile profile, Connection connection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _showConnectionDetails(context, profile, connection),
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
                    backgroundImage: profile.profileImagePath != null
                        ? _getImageProvider(profile.profileImagePath!)
                        : null,
                    child: profile.profileImagePath == null
                        ? Text(
                            profile.userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.userName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        if (profile.major != null && profile.school != null)
                          Text(
                            '${profile.major} • ${profile.school}',
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
              if (profile.interests != null)
                Row(
                  children: [
                    Icon(Icons.interests, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.interests!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (profile.interests != null) const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Met at ${connection.restaurant}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(connection.collectedAt),
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
