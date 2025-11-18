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
    final newFriends = storage.newFriends;
    final yourConnections = storage.yourConnections;

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
              text: 'New Friends (${newFriends.length})',
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
                _buildPeerList(newFriends, 'No new friends nearby'),
                _buildPeerList(
                    yourConnections, 'No connections found nearby'),
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

    return Column(
      children: [
        // Hint at the top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '* ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Text(
                  'Tags highlighted in orange match your interests',
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
                return _buildPeerCard(context, peer);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeerCard(BuildContext context, Peer peer) {
    final storage = context.read<StorageService>();
    final currentProfile = storage.currentProfile;
    
    // Get user's majors and interests for comparison
    final userMajors = currentProfile?.major?.split(',').map((e) => e.trim().toLowerCase()).toSet() ?? {};
    final userInterests = currentProfile?.interests?.split(',').map((e) => e.trim().toLowerCase()).toSet() ?? {};
    
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
                    backgroundImage: peer.profileImageUrl != null
                        ? NetworkImage(peer.profileImageUrl!)
                        : null,
                    child: peer.profileImageUrl == null
                        ? Text(
                            peer.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                          peer.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          peer.school,
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
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...peer.major.split(',').map((major) {
                    final isMatch = userMajors.contains(major.trim().toLowerCase());
                    return _buildTag(context, major.trim(), Icons.school, 
                        isMatch ? Colors.orange : Colors.grey);
                  }),
                  ...peer.interests.split(',').map((interest) {
                    final isMatch = userInterests.contains(interest.trim().toLowerCase());
                    return _buildTag(context, interest.trim(), Icons.favorite, 
                        isMatch ? Colors.orange : Colors.grey);
                  }),
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

  Widget _buildTag(BuildContext context, String label, IconData icon, Color color) {
    final isHighlighted = color == Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.orange.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? Colors.orange.shade300 : Colors.grey.shade400,
          width: 1
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isHighlighted ? Colors.orange.shade700 : Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? Colors.orange.shade900 : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
