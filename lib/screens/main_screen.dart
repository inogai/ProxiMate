import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../widgets/profile_tab.dart';
import '../widgets/home_tab.dart';
import '../widgets/invitations_tab.dart';
import '../widgets/network_tab.dart';

/// Main screen with tab navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const InvitationsTab(),
    const NetworkTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final nameCardCount = storage.nameCards.length;

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
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.mail_outline),
            selectedIcon: Icon(Icons.mail),
            label: 'Invitations',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$nameCardCount'),
              isLabelVisible: nameCardCount > 0,
              child: const Icon(Icons.contacts_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$nameCardCount'),
              isLabelVisible: nameCardCount > 0,
              child: const Icon(Icons.contacts),
            ),
            label: 'Network',
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
