import 'package:flutter/material.dart';
import 'package:playground/widgets/chats_tab.dart';
import 'package:provider/provider.dart';

import '../models/connection.dart';
import '../services/storage_service.dart';
import '../services/chat_service.dart';
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
