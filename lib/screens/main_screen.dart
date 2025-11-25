import 'package:flutter/material.dart';
import 'package:playground/widgets/chats_tab.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import '../models/connection.dart';
import '../services/storage_service.dart';
import '../services/chat_service.dart';
import '../services/api_service.dart';
import '../widgets/find_peers_tab.dart';
import '../widgets/network_tab.dart';
import '../widgets/profile_tab.dart';

/// Main screen with tab navigation
class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  int _previousIndex = 0;

  final GlobalKey _chatsTabKey = GlobalKey();
  final GlobalKey _networkTabKey = GlobalKey();

  List<Widget> get _tabs => [
    NetworkTab(key: _networkTabKey),
    const FindPeersTab(),
    ChatsTab(key: _chatsTabKey),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _previousIndex = widget.initialIndex;

    // Handle deep links
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    final appLinks = AppLinks();

    // Handle initial link if app was launched from a deep link
    try {
      final initialLink = await appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink.toString());
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }

    // Listen for incoming links
    appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri.toString());
        }
      },
      onError: (err) {
        print('Error listening to link stream: $err');
      },
    );
  }

  void _handleDeepLink(String link) {
    print('Handling deep link: $link');
    final uri = Uri.parse(link);
    if (uri.scheme == 'proximate' && uri.host == 'addConnection') {
      final targetUserId = uri.queryParameters['id'];
      if (targetUserId != null && targetUserId.isNotEmpty) {
        _handleAddConnection(targetUserId);
      }
    }
  }

  void _handleAddConnection(String targetUserId) async {
    if (!mounted) return;

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection request sent!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error adding connection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add connection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final currentUserId = storage.currentProfile?.id ?? '';
    final userConnections = storage.connections
        .where(
          (c) =>
              (c.fromProfileId == currentUserId ||
                  c.toProfileId == currentUserId) &&
              c.status == ConnectionStatus.accepted,
        )
        .toList();
    final connectionCount = userConnections.length;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = index;
          });

          // Trigger refresh when switching to network tab (index 0)
          if (index == 0 && _previousIndex != 0) {
            // Use a delayed callback to ensure tab is fully visible
            Future.delayed(const Duration(milliseconds: 300), () {
              // Refresh network data
              try {
                final networkTabState = _networkTabKey.currentState as dynamic;
                if (networkTabState != null &&
                    networkTabState.refreshNetworkData != null) {
                  networkTabState.refreshNetworkData();
                }
              } catch (e) {
                print('Error refreshing network: $e');
              }
            });
          }

          // Trigger refresh when switching to chats tab (index 2)
          if (index == 2 && _previousIndex != 2) {
            // Use a delayed callback to ensure tab is fully visible
            Future.delayed(const Duration(milliseconds: 300), () {
              // Just trigger ChatService refresh directly
              try {
                final chatService = context.read<ChatService?>();
                if (chatService != null) {
                  chatService.refreshChatRooms();
                }
              } catch (e) {
                print('Error refreshing chats: $e');
              }
            });
          }
        },
        destinations: [
          NavigationDestination(
            icon: Badge(
              label: Text('$connectionCount'),
              isLabelVisible: connectionCount > 0,
              child: const Icon(Icons.hub_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$connectionCount'),
              isLabelVisible: connectionCount > 0,
              child: const Icon(Icons.hub),
            ),
            label: 'ProxiNet',
          ),
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'ProxiMate',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
