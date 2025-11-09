import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/peer.dart';
import 'peer_detail_screen.dart';

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
    // Create or get the search activity (removes any duplicate search activities)
    context.read<StorageService>().createOrGetSearchActivity();
    await _searchPeers();
  }

  Future<void> _searchPeers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<StorageService>().searchNearbyPeers();
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
    final peersWantToEat = storage.peersWantToEat;
    final peersNotWantToEat = storage.peersNotWantToEat;

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
              icon: const Icon(Icons.restaurant),
              text: 'Want to Eat (${peersWantToEat.length})',
            ),
            Tab(
              icon: const Icon(Icons.no_meals),
              text: 'Not Now (${peersNotWantToEat.length})',
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
                _buildPeerList(peersWantToEat, 'No peers want to eat right now'),
                _buildPeerList(
                    peersNotWantToEat, 'No peers in this category'),
              ],
            ),
    );
  }

  Widget _buildPeerList(List<Peer> peers, String emptyMessage) {
    if (peers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _searchPeers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: peers.length,
        itemBuilder: (context, index) {
          final peer = peers[index];
          return _buildPeerCard(context, peer);
        },
      ),
    );
  }

  Widget _buildPeerCard(BuildContext context, Peer peer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PeerDetailScreen(peer: peer),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      peer.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          peer.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${peer.major} • ${peer.school}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _buildMatchBadge(context, peer.matchScore),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${peer.distance.toStringAsFixed(1)} km away',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      peer.interests,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PeerDetailScreen(peer: peer),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View Profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchBadge(BuildContext context, double matchScore) {
    final percentage = (matchScore * 100).round();
    Color badgeColor;

    if (percentage >= 70) {
      badgeColor = Colors.green;
    } else if (percentage >= 40) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Text(
        '$percentage% Match',
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
