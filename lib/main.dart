import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'services/storage_service.dart';
import 'services/chat_service.dart';
import 'services/peer_discovery_service.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location permissions at app startup using geolocator
  await _requestLocationPermissions();

  // Create storage service and load persisted data
  final storage = StorageService();
  await storage.loadUserProfile();

  runApp(MyApp(storage: storage));
}

Future<void> _requestLocationPermissions() async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled');
      return;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('Initial permission check: $permission');

    if (permission == LocationPermission.denied) {
      debugPrint('Permission denied, requesting...');
      permission = await Geolocator.requestPermission();
      debugPrint('Permission after request: $permission');
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission permanently denied');
    }
  } catch (e) {
    debugPrint('Error requesting location permissions: $e');
    // Continue without permissions - app will handle gracefully
  }
}

class MyApp extends StatelessWidget {
  final StorageService storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFe39044),
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storage),
        // ChatService depends on authenticated userId from StorageService.
        ChangeNotifierProxyProvider<StorageService, ChatService>(
          create: (_) => ChatService(userId: 0),
          update: (_, storage, previous) {
            final userId = int.tryParse(storage.apiUserId ?? '') ?? 0;
            // Reuse the existing ChatService instance and update its user.
            if (previous == null) return ChatService(userId: userId);
            previous.updateUser(userId);
            return previous;
          },
        ),
        ChangeNotifierProvider(create: (_) => PeerDiscoveryService()),
      ],
      child: MaterialApp(
        title: 'Profile App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 2,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: storage.hasUser ? const MainScreen() : const RegisterScreen(),
      ),
    );
  }
}
