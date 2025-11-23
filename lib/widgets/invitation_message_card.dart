import 'package:flutter/material.dart';
import '../models/meeting.dart';

class InvitationMessageCard extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCollectCard;
  final VoidCallback? onNotGoodMatch;
  final Future<void> Function()? onRate;
  final String? senderName;
  final bool isFromMe;

  const InvitationMessageCard({
    super.key,
    required this.message,
    this.onAccept,
    this.onDecline,
    this.onCollectCard,
    this.onNotGoodMatch,
    this.onRate,
    this.senderName,
    this.isFromMe = false,
  });

  @override
  State<InvitationMessageCard> createState() => _InvitationMessageCardState();
}

class _InvitationMessageCardState extends State<InvitationMessageCard> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.message.invitationStatus ?? "pending";
    final restaurant =
        widget.message.invitationData?["restaurant"] as String? ?? '';
    final iceBreakers = widget.message.iceBreakers ?? [];
    final responseDeadline = widget.message.responseDeadline;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(status)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(status),
          if (restaurant.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildRestaurantInfo(restaurant),
          ],
          if (responseDeadline != null) ...[
            const SizedBox(height: 8),
            _buildDeadlineInfo(responseDeadline),
          ],
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

  Widget _buildHeader(String status) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: widget.isFromMe ? Colors.blue : Colors.orange,
          child: widget.senderName != null
              ? Text(
                  _getInitials(widget.senderName!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Icon(
                  widget.isFromMe ? Icons.send : Icons.mail_outline,
                  color: Colors.white,
                  size: 16,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isFromMe ? 'Invitation Sent' : 'Invitation Received',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
              ),
              if (widget.senderName != null)
                Text(
                  widget.senderName!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ),
        _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case "pending":
      case "": // Empty/null status from server - treat as pending
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange[700]!;
        text = "Pending";
        icon = Icons.pending;
        break;
      case "accepted":
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[700]!;
        text = "Accepted";
        icon = Icons.check_circle;
        break;
      case "declined":
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red[700]!;
        text = "Declined";
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey[700]!;
        text = "Unknown";
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo(String restaurant) {
    return Row(
      children: [
        Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          restaurant,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineInfo(DateTime deadline) {
    final now = DateTime.now();
    final isExpired = deadline.isBefore(now);
    final hoursRemaining = deadline.difference(now).inHours;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.access_time : Icons.schedule,
            color: isExpired ? Colors.red[700] : Colors.blue[700],
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isExpired ? 'Expired' : 'Respond in $hoursRemaining hours',
            style: TextStyle(
              color: isExpired ? Colors.red[700] : Colors.blue[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
    if (status == "pending" && !widget.isFromMe) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isDeclining ? null : () => _handleDecline(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isDeclining
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isAccepting ? null : () => _handleAccept(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isAccepting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Accept'),
            ),
          ),
        ],
      );
    } else if (status == "accepted" &&
        !(widget.message.isNameCardCollected ?? false)) {
      // Show rating button if available, but remove collect name card and not good match buttons
      // These are now handled in the chat room screen input area
      return Column(
        children: [
          if (widget.onRate != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleRate(),
                icon: const Icon(Icons.star),
                label: const Text('Rate Peer'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.amber),
                  foregroundColor: Colors.amber[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Show a status indicator instead of action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                const SizedBox(width: 6),
                Text(
                  'Name card options available in input area',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (widget.message.isNameCardCollected ?? false) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 16),
            const SizedBox(width: 6),
            Text(
              'Name card collected',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else if (widget.isFromMe && status == "pending") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, color: Colors.orange[700], size: 16),
            const SizedBox(width: 6),
            Text(
              'Waiting for response...',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _handleAccept() async {
    setState(() => _isAccepting = true);
    try {
      widget.onAccept?.call();
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  Future<void> _handleDecline() async {
    setState(() => _isDeclining = true);
    try {
      widget.onDecline?.call();
    } finally {
      if (mounted) {
        setState(() => _isDeclining = false);
      }
    }
  }

  Future<void> _handleRate() async {
    await widget.onRate?.call();
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
