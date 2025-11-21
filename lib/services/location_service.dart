import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:openapi/openapi.dart';
import 'api_service.dart';

/// Service for handling GPS location tracking and permissions
class LocationService {
  final ApiService _apiService;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _locationUpdateTimer;
  Position? _lastKnownPosition;
  bool _isTracking = false;
  
  LocationService(this._apiService);
  
  /// Get current location with permission handling
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _debugLog('Location services are disabled');
        return null;
      }
      
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      _debugLog('Current permission check: $permission');
      
      if (permission == LocationPermission.denied) {
        _debugLog('Permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        _debugLog('Permission after request: $permission');
      }
      
      if (permission == LocationPermission.deniedForever) {
        _debugLog('Location permissions are permanently denied');
        return null;
      }
      
      // Get current position
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        _debugLog('High accuracy failed, trying medium: $e');
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 20),
          );
        } catch (e2) {
          _debugLog('Medium accuracy failed, trying low: $e2');
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 25),
            );
          } catch (e3) {
            _debugLog('All accuracy levels failed: $e3');
            return _lastKnownPosition;
          }
        }
      }
      
      if (position != null) {
        _lastKnownPosition = position;
        _debugLog('Current location: ${position.latitude}, ${position.longitude}');
      }
      return position;
      
    } catch (e) {
      _debugLog('Error getting current location: $e');
      return _lastKnownPosition; // Return last known position if available
    }
  }
  
  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to open location settings
        bool opened = await Geolocator.openLocationSettings();
        if (!opened) {
          _debugLog('Could not open location settings');
          return false;
        }
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return false;
        }
      }
      
      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      return permission == LocationPermission.always ||
             permission == LocationPermission.whileInUse;
             
    } catch (e) {
      _debugLog('Error requesting location permission: $e');
      // On macOS, permission might be handled by system dialog
      // Try to continue and let system handle permission request
      return false;
    }
  }
  
  /// Start periodic location tracking for a user
  Future<void> startLocationTracking(int userId) async {
    if (_isTracking) {
      _debugLog('Location tracking already started');
      return;
    }
    
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      _debugLog('Cannot start location tracking: no permission');
      return;
    }
    
    _isTracking = true;
    
    // Update location immediately
    await updateLocation(userId);
    
    // Set up periodic updates every 5 minutes
    _locationUpdateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => updateLocation(userId),
    );
    
    _debugLog('Started location tracking for user $userId');
  }
  
  /// Stop location tracking
  void stopLocationTracking() {
    if (!_isTracking) {
      return;
    }
    
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
    
    _debugLog('Stopped location tracking');
  }
  
  /// Update user location on backend
  Future<void> updateLocation(int userId) async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        _debugLog('Cannot update location: unable to get current position');
        return;
      }
      
      final locationCreate = LocationCreate((b) => b
        ..latitude = position.latitude
        ..longitude = position.longitude
        ..userId = userId);
      
      await _apiService.createLocation(locationCreate);
      _debugLog('Updated location for user $userId: ${position.latitude}, ${position.longitude}');
      
    } catch (e) {
      _debugLog('Error updating location for user $userId: $e');
    }
  }
  
  /// Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;
  
  /// Check if location tracking is active
  bool get isTracking => _isTracking;
  
  /// Calculate distance between two coordinates in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return _apiService.calculateDistance(lat1, lon1, lat2, lon2);
  }
  
  /// Check if app has location permissions
  Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
             permission == LocationPermission.whileInUse;
    } catch (e) {
      _debugLog('Error checking location permission: $e');
      // On macOS, assume permissions are handled by system
      return true;
    }
  }
  
  /// Manually trigger location permission dialog
  Future<void> triggerLocationPermissionDialog() async {
    try {
      _debugLog('Attempting to trigger location permission dialog');
      await Geolocator.requestPermission();
    } catch (e) {
      _debugLog('Error triggering permission dialog: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    stopLocationTracking();
    _debugLog('LocationService disposed');
  }
  
  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[LocationService] $message');
    }
  }
}