import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/peer.dart';
import '../services/storage_service.dart';
import 'restaurant_selection_screen.dart';
import 'main_screen.dart';

/// Detailed view of a peer's profile
class PeerDetailScreen extends StatefulWidget {
  final Peer peer;

  const PeerDetailScreen({super.key, required this.peer});

  @override
  State<PeerDetailScreen> createState() => _PeerDetailScreenState();
}

class _PeerDetailScreenState extends State<PeerDetailScreen> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with avatar and match score
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.peer.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.peer.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMatchBadge(context, widget.peer.matchScore),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.peer.distance.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Profile details
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    context,
                    icon: Icons.school,
                    title: 'School',
                    content: widget.peer.school,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    context,
                    icon: Icons.book,
                    title: 'Major',
                    content: widget.peer.major,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    context,
                    icon: Icons.favorite,
                    title: 'Interests',
                    content: widget.peer.interests,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    context,
                    icon: Icons.history_edu,
                    title: 'Background',
                    content: widget.peer.background,
                  ),
                  const SizedBox(height: 32),
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _handleSendInvite,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.restaurant_menu),
                      label: Text(_isSending
                          ? 'Sending Invite...'
                          : 'Send Invitation to Eat'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: badgeColor, size: 20),
          const SizedBox(width: 8),
          Text(
            '$percentage% Match',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendInvite() async {
    // First, show restaurant selection screen
    final selectedRestaurant = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const RestaurantSelectionScreen(),
      ),
    );

    // If user cancelled restaurant selection, don't send invitation
    if (selectedRestaurant == null || !mounted) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await context.read<StorageService>().sendInvitation(
            widget.peer,
            selectedRestaurant,
          );

      if (mounted) {
        // Pop all routes and push MainScreen with invitations tab selected
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialIndex: 1), // 1 = Invitations tab
          ),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invitation sent to ${widget.peer.name} for $selectedRestaurant!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
}
