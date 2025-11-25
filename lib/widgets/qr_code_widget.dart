import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/storage_service.dart';
import '../widgets/profile_avatar.dart';

/// Widget displaying a QR code for adding connections
class QRCodeWidget extends StatelessWidget {
  const QRCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final currentProfile = storage.currentProfile;
    final userId = currentProfile?.id ?? '';

    if (userId.isEmpty) {
      return Center(
        child: Text('Unable to generate QR code: No user ID found'),
      );
    }

    final qrData = 'proximate://addConnection?id=$userId';

    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Main card container
            Container(
              width: 320,
              margin: const EdgeInsets.only(top: 32), // Space for avatar
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(
                24,
                56,
                24,
                24,
              ), // Extra top padding for avatar
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User name and title
                  if (currentProfile != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      currentProfile.userName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ProxiMate User',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // QR Code in the center of the card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 160.0,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Explanatory text below the QR code
                  Text(
                    'Share this QR code with others to let them connect with you',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Avatar positioned to overlap the card
            if (currentProfile != null)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: ProfileAvatar(
                  name: currentProfile.userName,
                  imagePath: currentProfile.profileImagePath,
                  size: 64,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
