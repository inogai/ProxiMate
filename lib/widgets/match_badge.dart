import 'package:flutter/material.dart';

/// Small rounded badge showing a percentage match.
class MatchBadge extends StatelessWidget {
  final double matchScore; // 0..1

  const MatchBadge({super.key, required this.matchScore});

  @override
  Widget build(BuildContext context) {
    final percentage = (matchScore * 100).round();
    Color badgeColor;

    if (percentage >= 70) {
      badgeColor = Theme.of(context).colorScheme.primary;
    } else if (percentage >= 40) {
      badgeColor = Theme.of(context).colorScheme.primary;
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
}
