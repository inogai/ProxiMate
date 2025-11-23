import 'package:flutter/material.dart';
import '../models/meeting.dart';

class InvitationMessageCard extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCollectCard;
  final VoidCallback? onNotGoodMatch;

  const InvitationMessageCard({
    super.key,
    required this.message,
    this.onAccept,
    this.onDecline,
    this.onCollectCard,
    this.onNotGoodMatch,
  });

  @override
  Widget build(BuildContext context) {
    final invitationData = message.invitationData!;
    final status = invitationData["status"] as String;
    final restaurant = invitationData["restaurant"] as String;
    final iceBreakers = message.iceBreakers ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(status)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(restaurant),
          if (iceBreakers.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildIceBreakers(iceBreakers),
          ],
          const SizedBox(height: 16),
          _buildActionButtons(status),
        ],
      ),
    );
  }

  Widget _buildHeader(String restaurant) {
    return Row(
      children: [
        Icon(Icons.restaurant, color: Colors.orange[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Invitation to meet at $restaurant',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIceBreakers(List<IceBreaker> iceBreakers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ice Breaker Questions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        ...iceBreakers.map((ib) => _buildIceBreaker(ib)),
      ],
    );
  }

  Widget _buildIceBreaker(IceBreaker iceBreaker) {
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
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            iceBreaker.answer,
            style: TextStyle(
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    if (status == "pending") {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onDecline,
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: onAccept,
              child: const Text('Accept'),
            ),
          ),
        ],
      );
    } else if (status == "accepted" && !(message.isNameCardCollected ?? false)) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCollectCard,
              icon: const Icon(Icons.contacts),
              label: const Text('Collect Name Card'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onNotGoodMatch,
              icon: const Icon(Icons.close),
              label: const Text('Not Good Match'),
            ),
          ),
        ],
      );
    } else if (message.isNameCardCollected ?? false) {
      return const Text(
        'Name card collected ✓',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getCardColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange.shade50;
      case "accepted":
        return Colors.green.shade50;
      case "declined":
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange.shade200;
      case "accepted":
        return Colors.green.shade200;
      case "declined":
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }
}