import 'package:flutter/material.dart';
import 'package:playground/widgets/chats_tab.dart';
import 'package:provider/provider.dart';

import '../models/connection.dart';
import '../services/storage_service.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _tabs = [
    const NetworkTab(),
    const FindPeersTab(),
    const ChatsTab(),
    const ProfileTab(),
  ];

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
            _currentIndex = index;
          });
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
