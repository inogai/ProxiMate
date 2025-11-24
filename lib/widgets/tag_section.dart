import 'package:flutter/material.dart';
import 'tag_chip.dart';

/// A card showing a title + inline chips for tags (majors, interests, etc.)
class TagSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> tags;
  final Set<String>? matchingTags;

  const TagSection({
    super.key,
    required this.icon,
    required this.title,
    required this.tags,
    this.matchingTags,
  });

  @override
  Widget build(BuildContext context) {
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
                return TagChip(label: tag, icon: icon, highlighted: isMatch);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
