import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/storage_service_wrapper.dart';
import '../services/chat_service.dart';
import '../services/api_service.dart';
import '../screens/register_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/qr_camera_screen.dart';
import 'profile_image_picker.dart';

/// Profile tab widget displaying user information
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();
    final profile = storageService.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Show / Scan QR Code',
            onPressed: () => _handleShowQRCode(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () => _handleEditProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('No profile data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        ProfileImagePicker(
                          currentImagePath: profile.profileImagePath,
                          onImageSelected: (avatarUrl) async {
                            debugPrint(
                              'ProfileTab: onImageSelected called with avatarUrl: $avatarUrl',
                            );
                            final storageService = context
                                .read<StorageService>();

                            if (avatarUrl != null) {
                              // Update profile with new avatar URL
                              debugPrint(
                                'ProfileTab: Updating profile with new avatar URL',
                              );
                              await storageService.updateAvatarOnly(avatarUrl);
                            } else {
                              // Remove avatar
                              debugPrint(
                                'ProfileTab: Removing avatar from profile',
                              );
                              await storageService.updateAvatarOnly(null);
                            }

                            debugPrint('ProfileTab: Profile update completed');
                          },
                          radius: 50,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.userName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoCard(
                    context,
                    icon: Icons.school,
                    title: 'School',
                    content: profile.school ?? 'Not specified',
                  ),
                  const SizedBox(height: 16),
                  _buildTagCard(
                    context,
                    icon: Icons.book,
                    title: 'Major',
                    tags:
                        profile.major
                            ?.split(',')
                            .map((e) => e.trim())
                            .toList() ??
                        [],
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  _buildTagCard(
                    context,
                    icon: Icons.favorite,
                    title: 'Interests',
                    tags:
                        profile.interests
                            ?.split(',')
                            .map((e) => e.trim())
                            .toList() ??
                        [],
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.history_edu,
                    title: 'Background',
                    content: profile.background ?? 'Not specified',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Theme.of(context).primaryColor),
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
            const SizedBox(height: 8),
            Text(content, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  void _handleEditProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EditProfileScreen()));
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final wrapper = StorageServiceWrapper(context);
              await wrapper.clearProfile();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleShowQRCode(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const QRCameraScreen()),
    );

    // Handle QR code scanning result
    if (result != null && result.isNotEmpty) {
      _handleDeepLink(context, result);
    }
  }

  Widget _buildTagCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> tags,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Theme.of(context).primaryColor),
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
            tags.isEmpty
                ? Text(
                    'Not specified',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map((tag) => _buildTag(context, tag, color))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleDeepLink(BuildContext context, String link) {
    print('Handling deep link: $link');
    final uri = Uri.parse(link);
    if (uri.scheme == 'proximate' && uri.host == 'addConnection') {
      final targetUserId = uri.queryParameters['id'];
      if (targetUserId != null && targetUserId.isNotEmpty) {
        _handleAddConnection(context, targetUserId);
      }
    }
  }

  void _handleAddConnection(BuildContext context, String targetUserId) async {
    final storage = context.read<StorageService>();
    final chatService = context.read<ChatService>();
    final currentUserIdInt = int.tryParse(storage.apiUserId ?? '') ?? 0;
    final targetId = int.tryParse(targetUserId) ?? 0;

    if (currentUserIdInt == 0 || targetId == 0) {
      print('Invalid user IDs: current=$currentUserIdInt, target=$targetId');
      return;
    }

    try {
      // Create or get chat room between current user and target user
      final chatRoom = await chatService.getOrCreateChatRoomBetweenUsers(
        currentUserIdInt,
        targetId,
        '', // No restaurant specified
      );

      if (chatRoom != null) {
        // Send connection request
        final apiService = ApiService();
        await apiService.createConnectionRequest(
          chatRoom.id,
          currentUserIdInt,
          targetId,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection request sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding connection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add connection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
