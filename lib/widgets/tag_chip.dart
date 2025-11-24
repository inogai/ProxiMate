import 'package:flutter/material.dart';

/// Small chip-like tag with an icon and a label. Can be highlighted.
class TagChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlighted;

  const TagChip({
    super.key,
    required this.label,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? primaryColor.withOpacity(0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? primaryColor.withOpacity(0.3)
              : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlighted ? primaryColor : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: highlighted ? primaryColor : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
