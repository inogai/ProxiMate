import 'package:flutter/material.dart';

/// Dialog for collecting user ratings (1-5 stars)
/// Requires reason if rating is 1 or 2 stars
class RatingDialog extends StatefulWidget {
  final String peerName;

  const RatingDialog({
    super.key,
    required this.peerName,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool get _needsReason => _rating > 0 && _rating <= 2;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate ${widget.peerName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Star rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starNumber = index + 1;
                  return IconButton(
                    icon: Icon(
                      starNumber <= _rating ? Icons.star : Icons.star_border,
                      color: starNumber <= _rating
                          ? Colors.amber
                          : Colors.grey.shade400,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = starNumber;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingText(_rating),
                  style: TextStyle(
                    fontSize: 12,
                    color: _rating <= 2 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            // Reason field (required for 1-2 stars)
            if (_needsReason) ...[
              const SizedBox(height: 16),
              const Text(
                'Please tell us what went wrong:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter your reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.red.shade50,
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: _rating == 0 ||
                  (_needsReason && _reasonController.text.trim().isEmpty)
              ? null
              : () {
                  Navigator.pop(context, {
                    'rating': _rating,
                    'reason': _needsReason ? _reasonController.text.trim() : null,
                  });
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Red flags!';
      case 2:
        return 'Needs Improvement';
      case 3:
        return 'Normal';
      case 4:
        return 'Good Person';
      case 5:
        return 'Very Nice!';
      default:
        return '';
    }
  }
}
