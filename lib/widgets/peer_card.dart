import 'package:flutter/material.dart';
import '../models/peer.dart';
import 'match_badge.dart';
import 'tag_chip.dart';

/// A standalone card widget that displays peer information and tags.
class PeerCard extends StatelessWidget {
  final Peer peer;
  final Set<String> userMajors;
  final Set<String> userInterests;
  final VoidCallback? onTap;
  final VoidCallback? onViewProfile;

  const PeerCard({
    super.key,
    required this.peer,
    this.userMajors = const {},
    this.userInterests = const {},
    this.onTap,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage: peer.profileImageUrl != null
                        ? NetworkImage(peer.profileImageUrl!)
                        : null,
                    child: peer.profileImageUrl == null
                        ? Text(
                            peer.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          peer.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          peer.school,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  MatchBadge(matchScore: peer.matchScore),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${peer.distance.toStringAsFixed(1)} km away',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...peer.major.split(',').map((major) {
                    final isMatch = userMajors.contains(
                      major.trim().toLowerCase(),
                    );
                    return TagChip(
                      label: major.trim(),
                      icon: Icons.school,
                      highlighted: isMatch,
                    );
                  }),
                  ...peer.interests.split(',').map((interest) {
                    final isMatch = userInterests.contains(
                      interest.trim().toLowerCase(),
                    );
                    return TagChip(
                      label: interest.trim(),
                      icon: Icons.favorite,
                      highlighted: isMatch,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onViewProfile,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View Profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
