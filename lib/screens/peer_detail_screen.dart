import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/peer.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';
import '../utils/toast_utils.dart';
import '../widgets/profile_avatar.dart';
import 'activity_selection_screen.dart';
import 'main_screen.dart';
import 'venue_recommendation_screen.dart';
import '../widgets/match_badge.dart';
import '../widgets/tag_section.dart';
import '../widgets/info_section.dart';

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
      // Use a column so the content can scroll while the button stays pinned
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                        ProfileAvatar(
                          name: widget.peer.name,
                          imagePath: widget.peer.profileImageUrl,
                          size: 120,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.peer.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MatchBadge(matchScore: widget.peer.matchScore),
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.peer.distance.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                            InfoSection(
                              icon: Icons.school,
                              title: 'School',
                              content: widget.peer.school,
                            ),
                            const SizedBox(height: 16),
                            TagSection(
                              icon: Icons.book,
                              title: 'Major',
                              tags: widget.peer.major
                                  .split(',')
                                  .map((e) => e.trim())
                                  .toList(),
                              matchingTags: userMajors,
                            ),
                            const SizedBox(height: 16),
                            TagSection(
                              icon: Icons.favorite,
                              title: 'Interests',
                              tags: widget.peer.interests
                                  .split(',')
                                  .map((e) => e.trim())
                                  .toList(),
                              matchingTags: userInterests,
                            ),
                            const SizedBox(height: 16),
                            InfoSection(
                              icon: Icons.history_edu,
                              title: 'Background',
                              content: widget.peer.background,
                            ),
                            const SizedBox(height: 32),
                            // (button moved to bottomNavigationBar)
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Pin the send-invite control to the bottom so it remains visible even
      // when the main content scrolls. Add a top divider to separate it from
      // the scrollable content above.
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.6),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tag, info and match UI are now reusable widgets in lib/widgets/

  Future<void> _handleSendInvite() async {
    // First, show activity selection screen
    final selectedActivity = await Navigator.push<Activity>(
      context,
      MaterialPageRoute(builder: (context) => const ActivitySelectionScreen()),
    );

    // If user cancelled activity selection, don't send invitation
    if (selectedActivity == null || !mounted) {
      return;
    }

    // Second, show venue selection screen after activity selection
    final selectedVenue = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VenueRecommendationScreen(selectedActivity: selectedActivity.name),
      ),
    );

    // If user cancelled venue selection, don't send invitation
    if (selectedVenue == null || !mounted) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await context.read<StorageService>().sendInvitation(
        widget.peer,
        selectedVenue, // Use selected venue name instead of activity name
      );

      if (mounted) {
        // Pop all routes and push MainScreen with invitations tab selected
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                const MainScreen(initialIndex: 2), // 2 = Invitations tab
          ),
          (route) => false,
        );

        ToastUtils.showSuccess(
          context,
          'Invitation sent to ${widget.peer.name} for ${selectedActivity.name} at ${selectedVenue}!',
        );
      }
    } catch (e) {
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
