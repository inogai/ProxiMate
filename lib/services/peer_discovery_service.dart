import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/peer.dart';
import '../models/profile.dart';
import 'api_service.dart';
import 'location_service.dart';

/// Service responsible for real-time peer discovery (no persistent caching).
///
/// This is intentionally focused only on discovery: obtaining the current
/// location, asking the API for nearby users, mapping responses to `Peer`
/// models, computing match scores (when `currentProfile` is provided), and
/// publishing the result to `nearbyPeers`.
class PeerDiscoveryService extends ChangeNotifier {
  final ApiService _apiService;
  final LocationService _locationService;

  PeerDiscoveryService({
    ApiService? apiService,
    LocationService? locationService,
  }) : _apiService = apiService ?? ApiService(),
       _locationService =
           locationService ?? LocationService(apiService ?? ApiService());

  // Current list of discovered peers (read-only consumer access)
  List<Peer> _nearbyPeers = [];
  List<Peer> get nearbyPeers => List.unmodifiable(_nearbyPeers);

  Timer? _pollTimer;

  /// Search for nearby peers using the configured ApiService/LocationService.
  ///
  /// If `userId` is provided we attempt to update the user's location before
  /// fetching nearby users. `currentProfile` is optional but when present the
  /// discovery service will compute per-peer match scores.
  Future<List<Peer>> searchNearbyPeers(
    Profile? currentProfile, {
    int? userId,
    double radiusKm = 5.0,
    int limit = 20,
    double? latitude,
    double? longitude,
  }) async {
    double lat;
    double lon;

    // If coordinates are provided (useful for tests), use them.
    if (latitude != null && longitude != null) {
      lat = latitude;
      lon = longitude;
    } else {
      // Acquire current GPS position
      final currentPosition = await _locationService.getCurrentLocation();
      if (currentPosition == null) {
        throw Exception('Location services unavailable');
      }

      lat = currentPosition.latitude;
      lon = currentPosition.longitude;

      // Optionally update user location on backend
      if (userId != null) {
        await _locationService.updateLocation(userId);
      }
    }

    // Ask API for nearby users
    final nearbyUsersWithDistance = await _apiService.getNearbyUsers(
      lat,
      lon,
      radiusKm: radiusKm,
      limit: limit,
    );

    // Map and apply match score
    final peers = nearbyUsersWithDistance
        .map((u) => _apiService.userReadWithDistanceToPeer(u))
        .map(
          (p) => currentProfile != null
              ? p.copyWith(
                  matchScore: Peer.calculateMatchScore(currentProfile, p),
                )
              : p,
        )
        .toList();

    peers.sort((a, b) {
      final distanceCompare = a.distance.compareTo(b.distance);
      if (distanceCompare != 0) return distanceCompare;
      return b.matchScore.compareTo(a.matchScore);
    });

    _nearbyPeers = peers;
    notifyListeners();
    return peers;
  }

  /// Start periodic polling to refresh nearby peers. This is useful when a
  /// real-time push mechanism is not available from the backend.
  void startPolling(
    Profile? currentProfile, {
    int? userId,
    Duration interval = const Duration(seconds: 45),
  }) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) async {
      try {
        await searchNearbyPeers(currentProfile, userId: userId);
      } catch (e) {
        _debugLog('Polling error: $e');
      }
    });
  }

  /// Stop periodic polling.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  void _debugLog(String msg) {
    if (kDebugMode) debugPrint('[PeerDiscoveryService] $msg');
  }
}
