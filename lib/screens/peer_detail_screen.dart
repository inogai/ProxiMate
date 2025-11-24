import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/peer.dart';
import '../models/activity.dart';
import '../models/meeting.dart';
import '../services/storage_service.dart';
import '../utils/toast_utils.dart';
import 'activity_selection_screen.dart';
import 'main_screen.dart';
import 'chat_room_screen.dart';

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
      appBar: AppBar(title: const Text('Peer Profile')),
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
                    backgroundImage: widget.peer.profileImageUrl != null
                        ? NetworkImage(widget.peer.profileImageUrl!)
                        : null,
                    child: widget.peer.profileImageUrl == null
                        ? Text(
                            widget.peer.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
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
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.peer.distance.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
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
              child: Consumer<StorageService>(
                builder: (context, storage, _) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        context,
                        icon: Icons.school,
                        title: 'School',
                        content: widget.peer.school,
                      ),
                      const SizedBox(height: 16),
                      _buildTagSection(
                        context,
                        icon: Icons.book,
                        title: 'Major',
                        tags: widget.peer.major
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                        color: Colors.grey,
                        matchingTags: userMajors,
                      ),
                      const SizedBox(height: 16),
                      _buildTagSection(
                        context,
                        icon: Icons.favorite,
                        title: 'Interests',
                        tags: widget.peer.interests
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                        color: Colors.grey,
                        matchingTags: userInterests,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        context,
                        icon: Icons.history_edu,
                        title: 'Background',
                        content: widget.peer.background,
                      ),
                      const SizedBox(height: 32),
                      // Action buttons
                      Row(
                        children: [
                          // Send Activity Invitation button
                          Expanded(
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
                                  : const Icon(Icons.event),
                              label: Text(
                                _isSending
                                    ? 'Sending Invite...'
                                    : 'Send Activity Invitation',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> tags,
    required Color color,
    Set<String>? matchingTags,
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final isMatch =
                    matchingTags?.contains(tag.toLowerCase()) ?? false;
                return _buildTag(context, tag, isMatch ? Colors.orange : color);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label, Color color) {
    final isHighlighted = color == Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.orange.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? Colors.orange.shade300 : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isHighlighted ? Colors.orange.shade900 : Colors.grey.shade700,
          fontSize: 13,
          fontWeight: FontWeight.w500,
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
            Text(content, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchBadge(BuildContext context, double matchScore) {
    final percentage = (matchScore * 100).round();
    Color badgeColor;

    if (percentage >= 70) {
      badgeColor = Theme.of(context).colorScheme.primary;
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
    // First, show activity selection screen
    final selectedActivity = await Navigator.push<Activity>(
      context,
      MaterialPageRoute(builder: (context) => const ActivitySelectionScreen()),
    );

    // // // print('Activity selected: ${selectedActivity?.name}');

    // If user cancelled activity selection, don't send invitation
    if (selectedActivity == null || !mounted) {
      // // // print('Activity selection cancelled or widget not mounted');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // // // print('Calling sendInvitation...');
      await context.read<StorageService>().sendInvitation(
        widget.peer,
        selectedActivity.name, // Use activity name as restaurant for now
      );
      // // // print('sendInvitation completed successfully');

      if (mounted) {
        // Pop all routes and push MainScreen with invitations tab selected
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                const MainScreen(initialIndex: 1), // 1 = Invitations tab
          ),
          (route) => false,
        );

        ToastUtils.showSuccess(
          context,
          'Invitation sent to ${widget.peer.name} for ${selectedActivity.name}!',
        );
      }
    } catch (e) {
      // // // print('Error sending invitation: $e');

      // Log the error
      // // // debugPrint('Failed to send invitation to ${widget.peer.name}: $e');

      if (mounted) {
        ToastUtils.showError(
          context,
          'Failed to send invitation: ${e.toString()}',
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
