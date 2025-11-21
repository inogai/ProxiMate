import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

/// Simple test screen to verify location permissions and functionality
class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  final ApiService _apiService = ApiService();
  late LocationService _locationService;
  String _status = 'Initializing...';
  String _locationInfo = '';
  String _permissionInfo = '';

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(_apiService);
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    setState(() {
      _status = 'Checking location services...';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      setState(() {
        _status += '\nLocation services enabled: $serviceEnabled';
      });

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      setState(() {
        _permissionInfo = 'Current permission: $permission';
      });

      // Try to get current location
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _locationInfo = 'Lat: ${position.latitude.toStringAsFixed(6)}, '
                          'Lng: ${position.longitude.toStringAsFixed(6)}\n'
                          'Accuracy: ${position.accuracy.toStringAsFixed(2)}m\n'
                          'Timestamp: ${position.timestamp}';
          _status += '\n✅ Location access successful!';
        });
      } else {
        setState(() {
          _status += '\n❌ Could not get location';
        });
      }
    } catch (e) {
      setState(() {
        _status += '\n❌ Error: $e';
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _status = 'Requesting permission...';
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      setState(() {
        _permissionInfo = 'Permission after request: $permission';
        _status += '\nPermission requested: $permission';
      });

      // Try getting location again
      await _checkLocationStatus();
    } catch (e) {
      setState(() {
        _status += '\n❌ Permission request error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Permission Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_status),
            ),
            const SizedBox(height: 16),
            Text(
              'Permission Info:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_permissionInfo),
            ),
            const SizedBox(height: 16),
            Text(
              'Location Info:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_locationInfo.isEmpty ? 'No location data' : _locationInfo),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: const Text('Request Permission'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _checkLocationStatus,
                  child: const Text('Refresh Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}