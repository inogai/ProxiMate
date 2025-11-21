import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/openapi.dart';
import '../models/profile.dart';
import '../models/peer.dart';

class ApiService {
  late DefaultApi _api;
  String _baseUrl;
  final int _maxRetries;
  final Duration _timeout;
  
  ApiService({
    String baseUrl = 'http://localhost:8000',
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  }) : _baseUrl = baseUrl, 
       _maxRetries = maxRetries,
       _timeout = timeout {
    _initializeApi();
  }

  void _initializeApi() {
    try {
      final openapi = Openapi(basePathOverride: _baseUrl);
      _api = openapi.getDefaultApi();
      _debugLog('API Service initialized with base URL: $_baseUrl');
    } catch (e) {
      _debugLog('Failed to initialize API client: $e');
      rethrow;
    }
  }

  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    _initializeApi();
    _debugLog('API base URL updated to: $_baseUrl');
  }

  Future<T> _executeWithRetry<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < _maxRetries) {
      try {
        _debugLog('Executing $operationName (attempt ${attempts + 1})');
        final result = await operation().timeout(_timeout);
        _debugLog('$operationName succeeded');
        return result;
      } on SocketException catch (e) {
        lastException = Exception('Network error: ${e.message}');
        _debugLog('Network error in $operationName: ${e.message}');
      } on TimeoutException catch (e) {
        lastException = Exception('Request timeout: ${e.message}');
        _debugLog('Timeout in $operationName: ${e.message}');
      } catch (e) {
        lastException = Exception('Unexpected error: $e');
        _debugLog('Unexpected error in $operationName: $e');
      }

      attempts++;
      if (attempts < _maxRetries) {
        final delay = Duration(seconds: 2 * attempts);
        _debugLog('Retrying $operationName in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }

    _debugLog('$operationName failed after $_maxRetries attempts');
    throw lastException ?? Exception('Operation failed after $_maxRetries attempts');
  }

  Future<UserRead> createUser(UserCreate user) async {
    final response = await _executeWithRetry(
      () => _api.createUserUsersPost(userCreate: user),
      'Create User',
    );
    return response.data!;
  }

  Future<UserRead> updateUser(int userId, Map<String, dynamic> userData) async {
    // Note: updateUser endpoint not available in current API
    // This is a placeholder for future implementation
    _debugLog('Update user endpoint not available - using placeholder');
    throw UnimplementedError('Update user endpoint not yet implemented in backend');
  }

  Future<UserRead> getUser(int userId) async {
    // Note: getUser endpoint not available in current API
    // We'll use getUsersUsersGet and filter by ID for now
    final response = await _executeWithRetry(
      () => _api.getUsersUsersGet(),
      'Get All Users',
    );
    final users = response.data!;
    final user = users.where((u) => u.id == userId).firstOrNull;
    if (user == null) {
      throw Exception('User with ID $userId not found');
    }
    return user;
  }

  Future<LocationRead> createLocation(LocationCreate location) async {
    final response = await _executeWithRetry(
      () => _api.createLocationLocationsPost(locationCreate: location),
      'Create Location',
    );
    return response.data!;
  }

  Future<BuiltList<LocationRead>> getUserLocations(int userId) async {
    final response = await _executeWithRetry(
      () => _api.getUserLocationsLocationsUserIdGet(userId: userId),
      'Get User Locations',
    );
    return response.data!;
  }

  Future<bool> checkHealth() async {
    try {
      await _executeWithRetry(
        () => _api.healthCheckHealthGet(),
        'Health Check',
      );
      return true;
    } catch (e) {
      _debugLog('Health check failed: $e');
      return false;
    }
  }

  // Phase 3: Location-based peer discovery endpoints

  /// Get all users with optional filtering
  Future<BuiltList<UserRead>> getAllUsers({
    String? school,
    String? major,
    String? interests,
    int? limit,
    int? offset,
  }) async {
    final response = await _executeWithRetry(
      () => _api.getUsersUsersGet(),
      'Get All Users',
    );
    
    // Apply filtering client-side for now (backend filtering not available)
    var users = response.data!;
    
    if (school != null && school.isNotEmpty) {
      users = users.rebuild((b) => b.clear());
      final filtered = response.data!.where((u) => 
        u.school?.toLowerCase().contains(school.toLowerCase()) == true
      ).toList();
      users = BuiltList<UserRead>(filtered);
    }
    
    if (major != null && major.isNotEmpty) {
      users = users.rebuild((b) => b.clear());
      final filtered = response.data!.where((u) => 
        u.major?.toLowerCase().contains(major.toLowerCase()) == true
      ).toList();
      users = BuiltList<UserRead>(filtered);
    }
    
    if (interests != null && interests.isNotEmpty) {
      users = users.rebuild((b) => b.clear());
      final filtered = response.data!.where((u) => 
        u.interests?.toLowerCase().contains(interests.toLowerCase()) == true
      ).toList();
      users = BuiltList<UserRead>(filtered);
    }
    
    return users;
  }

  /// Get nearby users based on location
  Future<BuiltList<UserReadWithDistance>> getNearbyUsers(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
    int? limit,
  }) async {
    final response = await _executeWithRetry(
      () => _api.getNearbyUsersUsersNearbyGet(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: limit,
      ),
      'Get Nearby Users',
    );
    return response.data!;
  }

  /// Get locations for multiple users in batch
  Future<BuiltList<LocationRead>> getBatchLocations(List<int> userIds) async {
    final response = await _executeWithRetry(
      () => _api.getBatchLocationsLocationsBatchGet(
        userIds: userIds.join(','),
      ),
      'Get Batch Locations',
    );
    return response.data!;
  }

  Profile userReadToProfile(UserRead user) {
    return Profile(
      id: user.id.toString(),
      userName: user.username,
      school: (user.school?.isEmpty ?? true) ? null : user.school,
      major: (user.major?.isEmpty ?? true) ? null : user.major,
      interests: (user.interests?.isEmpty ?? true) ? null : user.interests,
      background: (user.bio?.isEmpty ?? true) ? null : user.bio,
      profileImagePath: (user.avatarUrl?.isEmpty ?? true) ? null : user.avatarUrl,
    );
  }

  UserCreate profileToUserCreate(Profile profile) {
    return UserCreate((b) => b
      ..username = profile.userName
      ..school = profile.school ?? ''
      ..major = profile.major ?? ''
      ..interests = profile.interests ?? ''
      ..bio = profile.background ?? ''
      ..avatarUrl = profile.profileImagePath ?? '');
  }

  Map<String, dynamic> profileToUserUpdate(Profile profile) {
    return {
      'username': profile.userName,
      'school': profile.school,
      'major': profile.major,
      'interests': profile.interests,
      'bio': profile.background,
      'avatarUrl': profile.profileImagePath,
    };
  }

  Peer userReadToPeer(UserRead user, LocationRead? location, {double? distance}) {
    return Peer(
      id: user.id.toString(),
      name: user.username,
      school: user.school ?? '',
      major: user.major ?? '',
      interests: user.interests ?? '',
      background: user.bio ?? '',
      profileImageUrl: user.avatarUrl,
      distance: distance ?? 0.0,
    );
  }

  Peer userReadWithDistanceToPeer(UserReadWithDistance userWithDistance) {
    return Peer(
      id: userWithDistance.id.toString(),
      name: userWithDistance.username,
      school: userWithDistance.school ?? '',
      major: userWithDistance.major ?? '',
      interests: userWithDistance.interests ?? '',
      background: userWithDistance.bio ?? '',
      profileImageUrl: userWithDistance.avatarUrl,
      distance: userWithDistance.distanceKm?.toDouble() ?? 0.0,
    );
  }

  double calculateDistance(
    double lat1, 
    double lon1, 
    double lat2, 
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() * lat2.toRadians().cos() *
        (dLon / 2).sin() * (dLon / 2).sin();

    final double c = 2 * a.sqrt().asin();

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[ApiService] $message');
    }
  }

  void dispose() {
    _debugLog('API Service disposed');
  }
}

extension on double {
  double toRadians() => this * (3.14159265359 / 180);
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}