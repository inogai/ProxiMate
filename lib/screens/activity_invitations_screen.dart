import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/meeting.dart';
import '../models/activity.dart';
import '../screens/chat_room_screen.dart';

/// Screen showing all invitations for a specific activity
class ActivityInvitationsScreen extends StatelessWidget {
  final Activity activity;

  const ActivityInvitationsScreen({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    
    // Filter invitations by this activity's ID
    final sentInvitations = storage.sentInvitations
        .where((i) => i.activityId == activity.id)
        .toList();
    final receivedInvitations = storage.receivedInvitations
        .where((i) => i.activityId == activity.id)
        .toList();
    final acceptedInvitations = storage.acceptedInvitations
        .where((i) => i.activityId == activity.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.name),
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
                      activity.description,
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
                // Show Chat button only if chat HAS been opened
                if (invitation.chatOpened)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final chatRoom =
                          storage.getChatRoomByPeerId(invitation.peerId);
                      if (chatRoom != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatRoomScreen(chatRoom: chatRoom),
                          ),
                        );
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
              Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 18, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Ice Breaker Questions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...invitation.iceBreakers.take(3).map((iceBreaker) {
                return Container(
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.question_answer,
                              size: 16, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              iceBreaker.question,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[900],
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          iceBreaker.answer,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            
            // Action buttons at bottom
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Chat for Meetup button - show only when chat NOT opened yet
            if (!invitation.chatOpened)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final chatRoom =
                        storage.getChatRoomByPeerId(invitation.peerId);
                    if (chatRoom != null) {
                      // Mark chat as opened
                      await storage.markChatOpened(invitation.id);
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
                  icon: const Icon(Icons.chat_bubble, size: 18),
                  label: const Text('Chat for Meetup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            
            // Not Good Match and Collect Name Card - show only after chat opened
            if (invitation.chatOpened) ...[
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
                      await storage.markNotGoodMatch(invitation.id);
                      // Delete the activity after declining
                      storage.deleteActivity(activity.id);
                      
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
                    await storage.collectNameCard(invitation.id);
                    // Delete the activity after collecting name card (activity finished)
                    storage.deleteActivity(activity.id);
                    
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
    final storage = context.read<StorageService>();
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
            
            // Mock action buttons (only show for pending invitations)
            if (isPending) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Mock Response:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await storage.mockAcceptSentInvitation(invitation.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${invitation.peerName} accepted your invitation!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accept'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await storage.mockDeclineSentInvitation(invitation.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${invitation.peerName} declined your invitation'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
