import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/peer.dart';
import '../services/storage_service.dart';
import '../services/peer_discovery_service.dart';
import '../models/connection.dart';
import '../widgets/empty_state.dart';
import '../widgets/peer_card.dart';
import './peer_detail_screen.dart';

/// Screen for searching and viewing nearby peers with tabs
class SearchPeersScreen extends StatefulWidget {
  const SearchPeersScreen({super.key});

  @override
  State<SearchPeersScreen> createState() => _SearchPeersScreenState();
}

class _SearchPeersScreenState extends State<SearchPeersScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Delay initialization to after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndSearch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndSearch() async {
    // Kick off a discovery search using the dedicated discovery service.
    final storage = context.read<StorageService>();
    final discovery = context.read<PeerDiscoveryService>();
    final userId = storage.apiUserId != null
        ? int.tryParse(storage.apiUserId!)
        : null;
    await discovery.searchNearbyPeers(storage.currentProfile, userId: userId);
  }

  Future<void> _searchPeers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Searching for nearby peers (peer discovery) ...');
      final storage = context.read<StorageService>();
      final discovery = context.read<PeerDiscoveryService>();
      final userId = storage.apiUserId != null
          ? int.tryParse(storage.apiUserId!)
          : null;
      await discovery.searchNearbyPeers(storage.currentProfile, userId: userId);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final discovery = context.watch<PeerDiscoveryService>();
    final peers = discovery.nearbyPeers.where(
      (p) => p.id != storage.currentProfile?.id,
    );

    // Derive the lists from the live discovery results and storage connections
    final currentProfile = storage.currentProfile;
    final connectedIds = storage.connections
        .where(
          (c) =>
              (c.fromProfileId == currentProfile?.id ||
                  c.toProfileId == currentProfile?.id) &&
              c.status == ConnectionStatus.accepted,
        )
        .map(
          (c) => c.fromProfileId == currentProfile?.id
              ? c.toProfileId
              : c.fromProfileId,
        )
        .toSet();

    // There were a major bug here - AI though ``newFriends`` was existing connections!
    // It indeed is confusing, so renamed to ``potentialPeers``.
    final potentialPeers = peers
        .where((p) => !connectedIds.contains(p.id))
        .toList();

    final yourConnections = peers
        .where((p) => connectedIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Peers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _searchPeers,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.person_add),
              text: 'Potential Peers (${potentialPeers.length})',
            ),
            Tab(
              icon: const Icon(Icons.group),
              text: 'Your Connections (${yourConnections.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Searching for nearby peers...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPeerList(potentialPeers, 'No potential peers nearby'),
                _buildPeerList(yourConnections, 'No connections found nearby'),
              ],
            ),
    );
  }

  Widget _buildPeerList(List<Peer> peers, String emptyMessage) {
    if (peers.isEmpty) {
      return EmptyState(icon: Icons.person_search, message: emptyMessage);
    }

    // derive current user's majors/interests to pass to cards
    final storage = context.read<StorageService>();
    final currentProfile = storage.currentProfile;
    final userMajors =
        currentProfile?.major
            ?.split(',')
            .map((e) => e.trim().toLowerCase())
            .toSet() ??
        {};
    final userInterests =
        currentProfile?.interests
            ?.split(',')
            .map((e) => e.trim().toLowerCase())
            .toSet() ??
        {};

    return Column(
      children: [
        // Hint at the top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '* ',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Expanded(
                child: Text(
                  'Tags highlighted in color match your interests',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _searchPeers,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: peers.length,
              itemBuilder: (context, index) {
                final peer = peers[index];
                return PeerCard(
                  peer: peer,
                  userMajors: userMajors,
                  userInterests: userInterests,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PeerDetailScreen(peer: peer),
                      ),
                    );
                  },
                  onViewProfile: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PeerDetailScreen(peer: peer),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // removed helper rendering methods in favor of widget components (PeerCard, MatchBadge, TagChip)
}
