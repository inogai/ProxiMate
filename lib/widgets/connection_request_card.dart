import 'package:flutter/material.dart';
import '../models/meeting.dart';

class ConnectionRequestCard extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final String? senderName;
  final bool isFromMe;

  const ConnectionRequestCard({
    super.key,
    required this.message,
    this.onAccept,
    this.onDecline,
    this.senderName,
    this.isFromMe = false,
  });

  @override
  State<ConnectionRequestCard> createState() => _ConnectionRequestCardState();
}

class _ConnectionRequestCardState extends State<ConnectionRequestCard> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  @override
  Widget build(BuildContext context) {
    final status =
        widget.message.invitationData?['status'] as String? ?? 'pending';

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
          const SizedBox(height: 12),
          _buildMessageContent(status),
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
          backgroundColor: widget.isFromMe ? Colors.blue : Colors.purple,
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
                  widget.isFromMe ? Icons.send : Icons.contact_page,
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
                widget.isFromMe
                    ? 'Name Card Request Sent'
                    : 'Name Card Request Received',
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
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue[700]!;
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

  Widget _buildMessageContent(String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.contact_page, color: Colors.purple[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isFromMe
                  ? 'You requested to collect their name card'
                  : 'They want to collect your name card',
              style: TextStyle(
                color: Colors.purple[900],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
                backgroundColor: Colors.purple,
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
    } else if (status == "accepted") {
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
              'Name card shared successfully',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else if (status == "declined") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: Colors.red[700], size: 16),
            const SizedBox(width: 6),
            Text(
              'Request declined',
              style: TextStyle(
                color: Colors.red[700],
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
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, color: Colors.blue[700], size: 16),
            const SizedBox(width: 6),
            Text(
              'Waiting for response...',
              style: TextStyle(
                color: Colors.blue[700],
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

  Color _getCardColor(String status) {
    switch (status) {
      case "pending":
        return Colors.blue.shade50;
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
        return Colors.blue.shade200;
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
