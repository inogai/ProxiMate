import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../services/storage_service.dart';
import '../models/meeting.dart';
import '../models/activity.dart';
import '../screens/chat_room_screen.dart';
import '../widgets/rating_dialog.dart';

/// Screen showing all invitations for a specific activity
class ActivityInvitationsScreen extends StatefulWidget {
  final Activity activity;

  const ActivityInvitationsScreen({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityInvitationsScreen> createState() => _ActivityInvitationsScreenState();
}

class _ActivityInvitationsScreenState extends State<ActivityInvitationsScreen> {
  Timer? _autoResponseTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Start timer for auto-responding to pending invitations after 5 seconds
    _autoResponseTimer = Timer(const Duration(seconds: 5), _autoRespondToPendingInvitations);
  }

  @override
  void dispose() {
    _autoResponseTimer?.cancel();
    super.dispose();
  }

  Future<void> _autoRespondToPendingInvitations() async {
    if (!mounted) return;
    
    final storage = context.read<StorageService>();
    final sentInvitations = storage.sentInvitations
        .where((i) => i.activityId == widget.activity.id && i.isPending)
        .toList();

    for (final invitation in sentInvitations) {
      // Random chance: 70% accept, 30% decline
      final shouldAccept = _random.nextDouble() < 0.7;
      
      if (shouldAccept) {
        await storage.mockAcceptSentInvitation(invitation.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${invitation.peerName} accepted your invitation!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await storage.mockDeclineSentInvitation(invitation.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${invitation.peerName} declined your invitation'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      
      // Add a small delay between responses to make it feel more natural
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    
    // Filter invitations by this activity's ID
    final sentInvitations = storage.sentInvitations
        .where((i) => i.activityId == widget.activity.id)
        .toList();
    final receivedInvitations = storage.receivedInvitations
        .where((i) => i.activityId == widget.activity.id)
        .toList();
    final acceptedInvitations = storage.acceptedInvitations
        .where((i) => i.activityId == widget.activity.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.activity.description,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Accepted Invitations - Chat Available
            if (acceptedInvitations.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Accepted - Ready to Meet Up',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 12),
              ...acceptedInvitations.map((invitation) =>
                  _buildAcceptedCard(context, invitation, storage)),
              const SizedBox(height: 24),
            ],

            // Received Invitations - Need Action
            _buildSectionHeader(
              context,
              'Received Invitations',
              Icons.mail,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            // Mock button to simulate receiving an invitation
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await storage.mockReceiveInvitation();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mock invitation received!'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.bug_report, size: 18),
                label: const Text('Mock Receive Invitation (Debug)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange.shade300),
                ),
              ),
            ),
            if (receivedInvitations.isNotEmpty) ...[
              ...receivedInvitations.map(
                  (invitation) => _buildReceivedCard(context, invitation)),
            ],
            const SizedBox(height: 24),

            // Sent Invitations - Waiting
            if (sentInvitations.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Sent Invitations',
                Icons.send,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              ...sentInvitations.map(
                  (invitation) => _buildSentCard(context, invitation)),
              const SizedBox(height: 24),
            ],

            // Empty State
            if (sentInvitations.isEmpty &&
                receivedInvitations.isEmpty &&
                acceptedInvitations.isEmpty) ...[
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No invitations yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search for peers and send invitations!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildAcceptedCard(
    BuildContext context,
    Invitation invitation,
    StorageService storage,
  ) {
    // Skip rendering if name card is already collected
    if (invitation.nameCardCollected) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and name
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.green,
                  child: Text(
                    invitation.peerName[0].toUpperCase(),
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
                        invitation.peerName,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.restaurant,
                              size: 14, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text(
                            invitation.restaurant,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Chat button in top right corner
                ElevatedButton.icon(
                  onPressed: () async {
                    final chatRoom =
                        storage.getChatRoomByPeerId(invitation.peerId);
                    if (chatRoom != null) {
                      // Mark chat as opened if not already
                      if (!invitation.chatOpened) {
                        await storage.markChatOpened(invitation.id);
                      }
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatRoomScreen(chatRoom: chatRoom),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            
            // Ice-breaking questions section
            if (invitation.iceBreakers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Meetup Ice Breaker Questions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
              ),
              const SizedBox(height: 12),
              ...invitation.iceBreakers.map((iceBreaker) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        iceBreaker.question,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[900],
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        iceBreaker.answer,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            
            // Action buttons at bottom (only show after chat opened)
            if (invitation.chatOpened) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              // Not Good Match button (full width)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Not a Good Match?'),
                        content: const Text(
                          'This will decline the invitation, remove the chat, and delete this activity. Are you sure?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      // Show rating dialog after confirmation
                      if (context.mounted) {
                        final ratingData = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => RatingDialog(
                            peerName: invitation.peerName,
                          ),
                        );

                        // Process rating if provided
                        if (ratingData != null) {
                          await storage.addUserRating(
                            ratedUserId: invitation.peerId,
                            rating: ratingData['rating'] as int,
                            reason: ratingData['reason'] as String?,
                          );
                        }
                      }

                      await storage.markNotGoodMatch(invitation.id);
                      // Delete the activity after declining
                      storage.deleteActivity(widget.activity.id);
                      
                      if (context.mounted) {
                        // Navigate back to prevent showing deleted activity
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Activity deleted'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Not Good Match'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Collect Name Card button (full width)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Show rating dialog before collecting name card
                    final ratingData = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => RatingDialog(
                        peerName: invitation.peerName,
                      ),
                    );

                    // Process rating if provided
                    if (ratingData != null) {
                      await storage.addUserRating(
                        ratedUserId: invitation.peerId,
                        rating: ratingData['rating'] as int,
                        reason: ratingData['reason'] as String?,
                      );
                    }

                    await storage.collectNameCard(invitation.id);
                    // Delete the activity after collecting name card (activity finished)
                    storage.deleteActivity(widget.activity.id);
                    
                    if (context.mounted) {
                      // Navigate back since activity is deleted
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${invitation.peerName}\'s name card collected! Activity completed.',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.contacts, size: 18),
                  label: const Text('Collect Name Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedCard(BuildContext context, Invitation invitation) {
    final storage = context.read<StorageService>();
    
    // Check if there's already an accepted invitation for THIS activity
    final hasAccepted = storage.acceptedInvitations
        .any((i) => i.activityId == invitation.activityId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.orange,
                  child: Text(
                    invitation.peerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.peerName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wants to eat at ${invitation.restaurant}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasAccepted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.orange[800]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can only accept 1 invitation per activity. Others will be auto-declined and your sent invitations will be deleted.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Decline button (full width)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context
                      .read<StorageService>()
                      .declineInvitation(invitation.id);
                },
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Decline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Accept button (full width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context
                      .read<StorageService>()
                      .acceptInvitation(invitation.id);
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentCard(BuildContext context, Invitation invitation) {
    final isPending = invitation.isPending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isPending
                      ? Colors.grey
                      : invitation.isAccepted
                          ? Colors.green
                          : Colors.red,
                  child: Text(
                    invitation.peerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.peerName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.restaurant, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            invitation.restaurant,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.orange.withOpacity(0.2)
                        : invitation.isAccepted
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isPending
                        ? 'Pending'
                        : invitation.isAccepted
                            ? 'Accepted'
                            : 'Declined',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPending
                          ? Colors.orange
                          : invitation.isAccepted
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
