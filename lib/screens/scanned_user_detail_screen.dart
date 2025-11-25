import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/chat_service.dart';
import '../widgets/profile_avatar.dart';

/// Screen showing scanned user details after QR code scanning with option to add connection
class ScannedUserDetailScreen extends StatefulWidget {
  final String userId;

  const ScannedUserDetailScreen({super.key, required this.userId});

  @override
  State<ScannedUserDetailScreen> createState() =>
      _ScannedUserDetailScreenState();
}

class _ScannedUserDetailScreenState extends State<ScannedUserDetailScreen> {
  bool _isLoading = true;
  bool _isAddingConnection = false;
  Profile? _peerProfile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPeerDetails();
  }

  Future<void> _fetchPeerDetails() async {
    try {
      final apiService = ApiService(); // Create new instance
      final userId = int.tryParse(widget.userId);

      if (userId == null) {
        setState(() {
          _errorMessage = 'Invalid user ID';
          _isLoading = false;
        });
        return;
      }

      final userRead = await apiService.getUser(userId);

      final profile = Profile(
        id: userRead.id.toString(),
        userName: userRead.displayname,
        school: userRead.school?.isEmpty == true ? null : userRead.school,
        major: userRead.major?.isEmpty == true ? null : userRead.major,
        interests: userRead.interests?.isEmpty == true
            ? null
            : userRead.interests,
        background: userRead.bio?.isEmpty == true ? null : userRead.bio,
        profileImagePath: userRead.avatarUrl,
      );

      setState(() {
        _peerProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addConnection() async {
    if (_peerProfile == null) return;

    setState(() {
      _isAddingConnection = true;
    });

    try {
      HapticFeedback.mediumImpact();

      final storage = context.read<StorageService>();
      final chatService = context.read<ChatService>();
      final apiService = ApiService(); // Create new instance
      final currentUserIdInt = int.tryParse(storage.apiUserId ?? '') ?? 0;
      final targetId = int.tryParse(_peerProfile!.id) ?? 0;

      if (currentUserIdInt == 0 || targetId == 0) {
        throw Exception('Invalid user IDs');
      }

      // Create or get chat room between current user and target user
      // Using a default restaurant name for now
      final chatRoom = await chatService.getOrCreateChatRoomBetweenUsers(
        currentUserIdInt,
        targetId,
        'Default', // Default restaurant name
      );

      if (chatRoom == null) {
        throw Exception('Failed to create chat room');
      }

      // Create connection request
      await apiService.createConnectionRequest(
        chatRoom.id,
        currentUserIdInt,
        targetId,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection request sent to ${_peerProfile!.userName}!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to the previous screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add connection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAddingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (_peerProfile == null) {
      return const Center(child: Text('No profile data available'));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      ProfileAvatar(
                        name: _peerProfile!.userName,
                        imagePath: _peerProfile!.profileImagePath,
                        size: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _peerProfile!.userName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Profile information
                if (_peerProfile!.school != null) ...[
                  _buildInfoSection(
                    icon: Icons.school,
                    title: 'School',
                    content: _peerProfile!.school!,
                  ),
                  const SizedBox(height: 16),
                ],

                if (_peerProfile!.major != null) ...[
                  _buildInfoSection(
                    icon: Icons.book,
                    title: 'Major',
                    content: _peerProfile!.major!,
                  ),
                  const SizedBox(height: 16),
                ],

                if (_peerProfile!.interests != null) ...[
                  _buildInfoSection(
                    icon: Icons.favorite,
                    title: 'Interests',
                    content: _peerProfile!.interests!,
                  ),
                  const SizedBox(height: 16),
                ],

                if (_peerProfile!.background != null) ...[
                  _buildInfoSection(
                    icon: Icons.person,
                    title: 'Background',
                    content: _peerProfile!.background!,
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),

        // Add Connection Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAddingConnection ? null : _addConnection,
              icon: _isAddingConnection
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add),
              label: Text(
                _isAddingConnection ? 'Adding Connection...' : 'Add Connection',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(content, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
