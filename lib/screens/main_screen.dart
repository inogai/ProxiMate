import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../widgets/profile_tab.dart';
import '../widgets/find_peers_tab.dart';
import '../widgets/invitations_tab.dart';
import '../widgets/network_tab.dart';

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
    const InvitationsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final connectionCount = storage.connections.length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
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
            icon: Icon(Icons.mail_outline),
            selectedIcon: Icon(Icons.mail),
            label: 'Invitations',
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
