import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/connection.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import 'network_graph_node.dart';
import 'network_graph_widget.dart';

/// Network tab widget showing connections
class NetworkTab extends StatefulWidget {
  const NetworkTab({super.key});

  @override
  State<NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends State<NetworkTab> {
  bool _showGraph = true;
  bool _show1HopCircle = true; // Default to on

  Future<Map<String, dynamic>> _fetchNetworkData(StorageService storage) async {
    print('🏗️ _fetchNetworkData: Starting...');

    try {
      final results = await Future.wait([
        storage.getConnectedProfiles(),
        storage.getTwoHopConnectionsWithMapping(),
      ]);

      final twoHopResult = results[1] as Map<String, dynamic>;
      final result = {
        'direct': results[0] as List<Profile>,
        'twoHop': twoHopResult['profiles'] as List<Profile>,
        'twoHopConnections': twoHopResult['connections'] as Map<String, String>,
      };

      final directProfiles = result['direct'] as List<Profile>;
      final twoHopProfiles = result['twoHop'] as List<Profile>;
      print(
        '🏗️ _fetchNetworkData: Complete - Direct: ${directProfiles.length}, 2-hop: ${twoHopProfiles.length}',
      );
      return result;
    } catch (e) {
      print('🏗️ _fetchNetworkData: Error: $e');
      return {'direct': <Profile>[], 'twoHop': <Profile>[], 'twoHopConnections': <String, String>{}};
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final connections = storage.connections;

    return Scaffold(
      body: _showGraph
          ? _buildNetworkGraph(context)
          : _buildNetworkGrid(context),
      floatingActionButton: connections.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1-hop circle toggle
                FloatingActionButton(
                  heroTag: "1hop",
                  onPressed: () {
                    setState(() {
                      _show1HopCircle = !_show1HopCircle;
                    });
                  },
                  backgroundColor: _show1HopCircle
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                  child: Icon(
                    _show1HopCircle ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  tooltip: _show1HopCircle
                      ? 'Hide 1-Hop Circle'
                      : 'Show 1-Hop Circle',
                ),
                const SizedBox(height: 10),
                // View toggle
                FloatingActionButton(
                  heroTag: "view",
                  onPressed: () {
                    setState(() {
                      _showGraph = !_showGraph;
                    });
                  },
                  child: Icon(_showGraph ? Icons.list : Icons.hub),
                  tooltip: _showGraph ? 'List View' : 'Graph View',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildNetworkGraph(BuildContext context) {
    final storage = context.watch<StorageService>();
    final currentProfile = storage.currentProfile;
    final connections = storage.connections;
    final nearbyPeers = storage.nearbyPeers;

    if (currentProfile == null) {
      return const Center(child: Text('No profile'));
    }

    final size = MediaQuery.of(context).size;

    print('Building network graph with ${connections.length} connections');

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchNetworkData(storage),
      builder: (context, snapshot) {
        print(
          '🏗️ FutureBuilder snapshot state: ${snapshot.hasData ? "has data" : "loading"}',
        );

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final connectedProfiles = snapshot.data!['direct'] as List<Profile>;
        final twoHopProfiles = snapshot.data!['twoHop'] as List<Profile>;
        final twoHopConnections = snapshot.data!['twoHopConnections'] as Map<String, String>;

        print('🏗️ Connected profiles: ${connectedProfiles.length}');
        print('🏗️ 2-hop profiles: ${twoHopProfiles.length}');
        print('🏗️ 2-hop connections: ${twoHopConnections.length}');

        // Initialize nodes list
        final List<NetworkNode> nodes = [];
        
        print(
          '🏗️ Building network graph with total nodes: ${nodes.length + 1} (including current user)',
        );

        // Always add current user as center node
        nodes.add(
          NetworkNode(
            id: currentProfile.id,
            name: currentProfile.userName,
            school: currentProfile.school ?? '',
            major: currentProfile.major,
            interests: currentProfile.interests,
            color: Theme.of(context).colorScheme.primary,
            position: Offset(size.width * 0.5, size.height * 0.5),
            connections: connections.map((c) => c.toProfileId).toList(),
            profileImagePath: currentProfile.profileImagePath,
          ),
        );

        // If no connections, add a text node above current user
        if (connectedProfiles.isEmpty) {
          nodes.add(
            NetworkNode(
              id: 'empty_message',
              name: 'Start by finding new connections at "Find Peers"',
              school: '',
              color: Colors.transparent,
              position: Offset(size.width * 0.5, size.height * 0.5 - 150),
              connections: [],
              isDirectConnection: false,
              isTextNode: true,
            ),
          );

          return Stack(
            children: [
              NetworkGraphWidget(
                nodes: nodes,
                initialSelectedNodeId: currentProfile.id,
                currentUserId: currentProfile.id,
                currentUserMajor: currentProfile.major,
                currentUserInterests: currentProfile.interests,
                show1HopCircle: _show1HopCircle,
                onInfoBarTap: (node) => _showCurrentUserProfile(context),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Card(
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ProxiMate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No connections yet',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
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

          // Check if this connected profile is also a nearby peer
          NetworkNode? nearbyPeerNode;
          if (nearbyPeers.isNotEmpty) {
            final matchingPeer = nearbyPeers.firstWhere(
              (peer) => peer.id == profile.id,
              orElse: () => nearbyPeers.first, // fallback
            );
            nearbyPeerNode = NetworkNode(
              id: matchingPeer.id,
              name: matchingPeer.name,
              school: matchingPeer.school,
              major: matchingPeer.major,
              interests: matchingPeer.interests,
              color: Theme.of(context).colorScheme.secondary,
              position: Offset(
                size.width * 0.5 + radius * cos(angle),
                size.height * 0.5 + radius * sin(angle),
              ),
              connections: [currentProfile.id],
              profileImagePath: matchingPeer.profileImageUrl,
            );
          }

          nodes.add(
            NetworkNode(
              id: profile.id,
              name: profile.userName,
              school: profile.school ?? '',
              major: profile.major,
              interests: profile.interests,
              color: nearbyPeerNode != null
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.tertiary,
              position:
                  nearbyPeerNode?.position ??
                  Offset(
                    size.width * 0.5 + radius * cos(angle),
                    size.height * 0.5 + radius * sin(angle),
                  ),
              connections: [currentProfile.id],
              profileImagePath: profile.profileImagePath,
            ),
          );
          directConnectionIds.add(profile.id);
        }

        // Add 2-hop nodes around the direct connections
        print('🏗️ Adding ${twoHopProfiles.length} 2-hop nodes...');
        for (int i = 0; i < twoHopProfiles.length; i++) {
          final profile = twoHopProfiles[i];
          final angle = (i / twoHopProfiles.length) * 2 * pi;
          final radius =
              min(size.width, size.height) *
              0.35; // Slightly larger radius for 2-hop

          // Get the 1-hop connection this 2-hop node connects to
          final oneHopConnectionId = twoHopConnections[profile.id];
          final List<String> twoHopNodeConnections = oneHopConnectionId != null 
              ? [oneHopConnectionId] 
              : [];

          final node = NetworkNode(
            id: profile.id,
            name: profile.userName,
            school: profile.school ?? '',
            major: profile.major,
            interests: profile.interests,
            color: Colors.purple.withOpacity(
              0.8,
            ), // Bright purple for 2-hop to make them visible
            position: Offset(
              size.width * 0.5 + radius * cos(angle),
              size.height * 0.5 + radius * sin(angle),
            ),
            connections: twoHopNodeConnections, // Connect to the 1-hop node
            profileImagePath: profile.profileImagePath,
            isDirectConnection: false, // Mark as 2-hop
            depth: 2, // Set depth to 2
          );

          nodes.add(node);
          print(
            '🏗️ Added 2-hop node: ${profile.userName} at position ${node.position}, connected to: $oneHopConnectionId',
          );
        }
        print('🏗️ Total nodes after adding 2-hop: ${nodes.length}');

        return Stack(
          children: [
            NetworkGraphWidget(
              nodes: nodes,
              initialSelectedNodeId: currentProfile.id,
              currentUserId: currentProfile.id,
              currentUserMajor: currentProfile.major,
              currentUserInterests: currentProfile.interests,
              show1HopCircle: _show1HopCircle,
              onInfoBarTap: (node) {
                if (node.id == currentProfile.id) {
                  _showCurrentUserProfile(context);
                } else {
                  final profile = connectedProfiles.firstWhere(
                    (p) => p.id == node.id,
                    orElse: () => Profile(
                      id: node.id,
                      userName: node.name,
                      major: node.major,
                      interests: node.interests,
                      background: '',
                    ),
                  );
                  final connection = connections.firstWhere(
                    (c) => c.toProfileId == node.id,
                    orElse: () => Connection(
                      id: 'unknown',
                      fromProfileId: currentProfile.id,
                      toProfileId: node.id,
                      restaurant: 'Unknown',
                      collectedAt: DateTime.now(),
                    ),
                  );
                  _showConnectionDetails(context, profile, connection);
                }
              },
              onInvite: (node) => _sendInvitation(node),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Card(
                color: Colors.black.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                      const SizedBox(height: 4),
                      Text(
                        '${connections.length} ${connections.length == 1 ? 'Connection' : 'Connections'}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNetworkGrid(BuildContext context) {
    final storage = context.watch<StorageService>();
    final connections = storage.connections;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        final connection = connections[index];
        return Builder(
          builder: (context) {
            // Get the profile name from storage or use a default
            final storage = context.read<StorageService>();
            final profiles = storage.connectedProfiles;
            final profile = profiles.cast<Profile?>().firstWhere(
              (p) => p?.id == connection.toProfileId,
              orElse: () => null,
            );

            final displayName = profile?.userName ?? 'Unknown';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(displayName),
              subtitle: Text('Met at: ${connection.restaurant}'),
              trailing: Text(
                '${connection.collectedAt.day}/${connection.collectedAt.month}/${connection.collectedAt.year}',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              onTap: () {
                // TODO: Navigate to connection details
              },
            );
          },
        );
      },
    );
  }

  void _showCurrentUserProfile(BuildContext context) {
    final storage = context.read<StorageService>();
    final currentProfile = storage.currentProfile;
    final connections = storage.connections;

    if (currentProfile == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child:
                      currentProfile.profileImagePath != null &&
                          currentProfile.profileImagePath!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            currentProfile.profileImagePath!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).colorScheme.onPrimary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  currentProfile.userName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // School
                if (currentProfile.school != null &&
                    currentProfile.school!.isNotEmpty) ...[
                  Text(
                    currentProfile.school!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                // Major and Interests Tags
                if (currentProfile.major != null ||
                    currentProfile.interests != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (currentProfile.major != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            currentProfile.major!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (currentProfile.interests != null)
                        ...currentProfile.interests!.split(',').map((interest) {
                          final trimmedInterest = interest.trim();
                          if (trimmedInterest.isEmpty)
                            return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              trimmedInterest,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            connections.length.toString(),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          Text(
                            'Connections',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      Column(
                        children: [
                          Text(
                            storage.nearbyPeers.length.toString(),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
                          Text(
                            'Nearby Peers',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConnectionDetails(
    BuildContext context,
    Profile profile,
    Connection connection,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child:
                      profile.profileImagePath != null &&
                          profile.profileImagePath!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            profile.profileImagePath!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 40,
                                color: Theme.of(context).colorScheme.onPrimary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  profile.userName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // School
                if (profile.school != null && profile.school!.isNotEmpty) ...[
                  Text(
                    profile.school!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                // Major and Interests Tags
                if (profile.major != null || profile.interests != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (profile.major != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            profile.major!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (profile.interests != null)
                        ...profile.interests!.split(',').map((interest) {
                          final trimmedInterest = interest.trim();
                          if (trimmedInterest.isEmpty)
                            return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              trimmedInterest,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                // Connection Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Met at: ${connection.restaurant}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Date: ${connection.collectedAt.day}/${connection.collectedAt.month}/${connection.collectedAt.year}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: Navigate to chat
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chat feature coming soon!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Chat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendInvitation(NetworkNode node) {
    final storage = context.read<StorageService>();

    // TODO: Implement actual invitation sending via API
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to ${node.name}!'),
        duration: const Duration(seconds: 2),
      ),
    );

    print('📨 Invitation sent to 2-hop node: ${node.name} (${node.id})');
  }
}
