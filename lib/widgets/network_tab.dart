import 'dart:async';
import 'dart:math';

import 'package:anyhow/rust.dart';
import 'package:flutter/material.dart';
import 'package:playground/utils/toast_utils.dart';
import 'package:provider/provider.dart';

import '../models/connection.dart';
import '../models/profile.dart';
import '../screens/chat_room_screen.dart';
import '../services/chat_service.dart';
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
  Future<NetworkData>? _networkDataFuture;
  String? _lastProfileId;
  int _lastConnectionsLength = 0;

  Future<NetworkData> _fetchNetworkData(StorageService storage) async {
    print('🏗️ _fetchNetworkData: Starting...');

    try {
      final results = await Future.wait([
        storage.getConnectedProfiles(),
        storage.getTwoHopConnectionsWithMapping(),
      ]);

      final twoHopResult = results[1] as TwoHopConnectionsResult;
      final directProfiles = results[0] as List<Profile>;
      final twoHopProfiles = twoHopResult.profiles;

      // Transform connections to edge list
      final twoHopEdges = <NetworkEdge>[];
      final currentUserId = storage.currentProfile?.id ?? '';

      twoHopResult.connections.forEach((profileId, connectionList) {
        for (final connectionId in connectionList) {
          twoHopEdges.add(
            NetworkEdge(from: currentUserId, to: profileId, via: connectionId),
          );
        }
      });

      print(
        '🏗️ _fetchNetworkData: Complete - Direct: ${directProfiles.length}, 2-hop: ${twoHopProfiles.length}, edges: ${twoHopEdges.length}',
      );

      return NetworkData(
        connectedProfiles: directProfiles,
        twoHopProfiles: twoHopProfiles,
        twoHopEdges: twoHopEdges,
      );
    } catch (e) {
      print('🏗️ _fetchNetworkData: Error: $e');
      return NetworkData(
        connectedProfiles: <Profile>[],
        twoHopProfiles: <Profile>[],
        twoHopEdges: <NetworkEdge>[],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final connections = storage.connections;

    // Avoid re-creating the network fetch future on every build. Recreate
    // only when the current profile changes or the number of connections
    // changes (simple heuristic). This prevents frequent rebuilds from
    // triggering repeated API requests through FutureBuilder.
    final currentProfileId = storage.currentProfile?.id;
    final connectionsLength = connections.length;
    if (_networkDataFuture == null ||
        currentProfileId != _lastProfileId ||
        connectionsLength != _lastConnectionsLength) {
      _lastProfileId = currentProfileId;
      _lastConnectionsLength = connectionsLength;
      _networkDataFuture = _fetchNetworkData(storage);
    }

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

    if (currentProfile == null) {
      return const Center(child: Text('No profile'));
    }

    return FutureBuilder<NetworkData>(
      future: _networkDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final networkData = snapshot.data!;
        final nodes = _buildNetworkNodes(
          context,
          currentProfile,
          connections,
          networkData,
        );

        if (networkData.connectedProfiles.isEmpty) {
          return _buildEmptyNetworkGraph(context, currentProfile, nodes);
        }

        return _buildPopulatedNetworkGraph(
          context,
          currentProfile,
          nodes,
          connections,
        );
      },
    );
  }

  List<NetworkNode> _buildNetworkNodes(
    BuildContext context,
    Profile currentProfile,
    List<Connection> connections,
    NetworkData networkData,
  ) {
    final size = MediaQuery.of(context).size;
    final nodes = <NetworkNode>[];

    // Add current user as center node
    nodes.add(
      _createCurrentUserNode(context, currentProfile, size, connections),
    );

    // Add direct connection nodes
    _addDirectConnectionNodes(
      context,
      nodes,
      networkData.connectedProfiles,
      currentProfile,
      size,
    );

    // Add 2-hop nodes
    _addTwoHopNodes(
      context,
      nodes,
      networkData.twoHopProfiles,
      networkData.twoHopEdges,
      currentProfile,
      size,
    );

    return nodes;
  }

  NetworkNode _createCurrentUserNode(
    BuildContext context,
    Profile currentProfile,
    Size size,
    List<Connection> connections,
  ) {
    return NetworkNode(
      id: currentProfile.id,
      name: currentProfile.userName,
      school: currentProfile.school ?? '',
      major: currentProfile.major,
      interests: currentProfile.interests,
      color: Theme.of(context).colorScheme.primary,
      position: Offset(size.width * 0.5, size.height * 0.5),
      connections: connections.map((c) => c.toProfileId).toList(),
      profileImagePath: currentProfile.profileImagePath,
    );
  }

  void _addDirectConnectionNodes(
    BuildContext context,
    List<NetworkNode> nodes,
    List<Profile> connectedProfiles,
    Profile currentProfile,
    Size size,
  ) {
    final nearbyPeers = context.read<StorageService>().nearbyPeers;

    for (int i = 0; i < connectedProfiles.length; i++) {
      final profile = connectedProfiles[i];
      final angle = (i / connectedProfiles.length) * 2 * pi;
      final radius = min(size.width, size.height) * 0.25;

      // Check if this profile is in nearby peers to determine color
      final isNearby = nearbyPeers.any((peer) => peer.id == profile.id);

      nodes.add(
        NetworkNode(
          id: profile.id,
          name: profile.userName,
          school: profile.school ?? '',
          major: profile.major,
          interests: profile.interests,
          color: isNearby
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.tertiary,
          position: Offset(
            size.width * 0.5 + radius * cos(angle),
            size.height * 0.5 + radius * sin(angle),
          ),
          connections: [currentProfile.id],
          profileImagePath: profile.profileImagePath,
        ),
      );
    }
  }

  void _addTwoHopNodes(
    BuildContext context,
    List<NetworkNode> nodes,
    List<Profile> twoHopProfiles,
    List<NetworkEdge> twoHopEdges,
    Profile currentProfile,
    Size size,
  ) {
    // Calculate the 1-hop circle radius based on existing direct connections
    final oneHopRadius = min(size.width, size.height) * 0.25;
    // Position 2-hop nodes outside the 1-hop circle with larger margin
    final twoHopRadius =
        oneHopRadius +
        200; // Increase margin to ensure clearly outside 1-hop circle

    for (int i = 0; i < twoHopProfiles.length; i++) {
      final profile = twoHopProfiles[i];
      final angle = (i / twoHopProfiles.length) * 2 * pi;

      // Find all edges that end at this profile
      final profileEdges = twoHopEdges
          .where((edge) => edge.to == profile.id)
          .toList();
      final twoHopNodeConnections = profileEdges
          .map((edge) => edge.via)
          .toList();

      nodes.add(
        NetworkNode(
          id: profile.id,
          name: profile.userName,
          school: profile.school ?? '',
          major: profile.major,
          interests: profile.interests,
          color: Colors.purple.withOpacity(0.8),
          position: Offset(
            size.width * 0.5 + twoHopRadius * cos(angle),
            size.height * 0.5 + twoHopRadius * sin(angle),
          ),
          connections: twoHopNodeConnections,
          profileImagePath: profile.profileImagePath,
          isDirectConnection: false,
          depth: 2,
        ),
      );
    }
  }

  Widget _buildEmptyNetworkGraph(
    BuildContext context,
    Profile currentProfile,
    List<NetworkNode> nodes,
  ) {
    nodes.add(
      NetworkNode(
        id: 'empty_message',
        name: 'Start by finding new connections at "Find Peers"',
        school: '',
        color: Colors.transparent,
        position: Offset(
          MediaQuery.of(context).size.width * 0.5,
          MediaQuery.of(context).size.height * 0.5 - 150,
        ),
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
        _buildEmptyStateCard(context),
      ],
    );
  }

  Widget _buildPopulatedNetworkGraph(
    BuildContext context,
    Profile currentProfile,
    List<NetworkNode> nodes,
    List<Connection> connections,
  ) {
    return Stack(
      children: [
        NetworkGraphWidget(
          nodes: nodes,
          initialSelectedNodeId: currentProfile.id,
          currentUserId: currentProfile.id,
          currentUserMajor: currentProfile.major,
          currentUserInterests: currentProfile.interests,
          show1HopCircle: _show1HopCircle,
          onInfoBarTap: (node) =>
              _handleNodeTap(context, node, currentProfile, connections),
          onInvite: (node) => _sendInvitation(node, context),
        ),
        _buildNetworkStatsCard(context, connections),
      ],
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    return Positioned(
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
    );
  }

  Widget _buildNetworkStatsCard(
    BuildContext context,
    List<Connection> connections,
  ) {
    return Positioned(
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
              const SizedBox(height: 4),
              Text(
                '${connections.length} ${connections.length == 1 ? 'Connection' : 'Connections'}',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNodeTap(
    BuildContext context,
    NetworkNode node,
    Profile currentProfile,
    List<Connection> connections,
  ) async {
    if (node.id == currentProfile.id) {
      _showCurrentUserProfile(context);
      return;
    }

    final storage = context.read<StorageService>();
    final connectedProfiles = await storage.getConnectedProfiles();

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
}

/// Network edge representing a 2-hop connection
class NetworkEdge {
  final String from;
  final String to;
  final String via;

  NetworkEdge({required this.from, required this.to, required this.via});
}

class NetworkData {
  final List<Profile> connectedProfiles;
  final List<Profile> twoHopProfiles;
  final List<NetworkEdge> twoHopEdges;

  NetworkData({
    required this.connectedProfiles,
    required this.twoHopProfiles,
    required this.twoHopEdges,
  });
}

Widget _buildNetworkGrid(BuildContext context) {
  final storage = context.watch<StorageService>();
  final connections = storage.connections;

  // Prefer using the cached network future from the parent state if present to
  // avoid re-triggering API calls during rebuilds. If not available, fall
  // back to calling getConnectedProfiles directly.
  final parentState = context.findAncestorStateOfType<_NetworkTabState>();
  final connectedFuture = parentState?._networkDataFuture == null
      ? storage.getConnectedProfiles()
      : parentState!._networkDataFuture!.then((d) => d.connectedProfiles);

  return FutureBuilder<List<Profile>>(
    future: connectedFuture,
    builder: (context, profilesSnapshot) {
      if (!profilesSnapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final connectedProfiles = profilesSnapshot.data!;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: connections.length,
        itemBuilder: (context, index) {
          final connection = connections[index];
          final profile = connectedProfiles.cast<Profile?>().firstWhere(
            (p) => p?.id == connection.toProfileId,
            orElse: () => null as Profile?,
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          color: Theme.of(context).colorScheme.primaryContainer,
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
                                color: Theme.of(context).colorScheme.secondary,
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
  BuildContext parentContext,
  Profile profile,
  Connection connection,
) {
  showDialog(
    context: parentContext,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          color: Theme.of(context).colorScheme.primaryContainer,
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
                      onPressed: () async {
                        await ToastUtils.showFutureResult(
                          context,
                          _handleChatNavigationButton(
                            parentContext,
                            profile,
                            connection,
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

void _sendInvitation(NetworkNode node, BuildContext context) {
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

FutureResult<void> _handleChatNavigationButton(
  BuildContext parentContext,
  Profile profile,
  Connection connection,
) async {
  final storage = parentContext.read<StorageService>();
  final chatService = parentContext.read<ChatService>();
  final currentProfile = storage.currentProfile;

  if (currentProfile == null) {
    return bail('Current profile not found');
  }

  final user1Id = int.tryParse(currentProfile.id);
  final user2Id = int.tryParse(profile.id);

  if (user1Id == null || user2Id == null) {
    return bail('Invalid user IDs');
  }

  final chatRoom = await chatService.getOrCreateChatRoomBetweenUsers(
    user1Id,
    user2Id,
    connection.restaurant,
  );

  if (chatRoom == null) {
    return bail('Failed to get or create chat room');
  }

  if (!parentContext.mounted) return bail('Context no longer mounted');

  Navigator.push(
    parentContext,
    MaterialPageRoute(builder: (context) => ChatRoomScreen(chatRoom: chatRoom)),
  );

  return Ok(null);
}
