import 'package:flutter/foundation.dart';
import 'package:anyhow/rust.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

import '../models/activity.dart';
import '../models/connection.dart';
import '../models/meeting.dart';
import '../models/peer.dart';
import '../models/profile.dart';
import '../models/user_rating.dart';
import 'api_service.dart';
import 'location_service.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:built_collection/built_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage service with API-only integration (no local fallbacks)
class StorageService extends ChangeNotifier {
  static const String _keyApiUserId = 'api_user_id';

  final ApiService _apiService = ApiService();
  late LocationService _locationService;
  Timer? _invitationFetchTimer;
  Timer? _messageFetchTimer;
  Timer? _connectionSyncTimer; // Timer for connection synchronization
  Timer? _nearbyPeersTimer; // Timer for nearby peers polling
  Timer? _activitiesTimer; // Timer for activities polling
  Profile? _currentProfile;
  List<Connection> _connections = [];
  List<Peer> _nearbyPeers = [];
  List<Invitation> _invitations = [];
  List<ChatRoom> _chatRooms = [];
  List<Activity> _activities = [];
  final List<UserRating> _userRatings = [];
  Peer? _selectedPeer;
  String?
  _selectedActivityId; // Currently selected activity for viewing invitations
  String? _apiUserId; // Store API user ID for backend integration
  final Map<String, DateTime> _lastMessageFetch =
      {}; // Track last fetch time per chat room
  DateTime? _lastConnectionSync; // Track last connection sync time
  DateTime? _lastNearbyPeersSync; // Track last nearby peers sync time
  DateTime? _lastActivitiesSync; // Track last activities sync time

  Profile? get currentProfile => _currentProfile;
  List<Connection> get connections => _connections;
  List<Peer> get nearbyPeers => _nearbyPeers;
  List<Invitation> get invitations => _invitations;
  List<ChatRoom> get chatRooms => _chatRooms;
  List<Activity> get activities => _activities;
  List<UserRating> get userRatings => _userRatings;
  Peer? get selectedPeer => _selectedPeer;
  String? get selectedActivityId => _selectedActivityId;
  String? get apiUserId => _apiUserId;

  /// Check if user is logged in
  bool get hasUser => _currentProfile != null && _apiUserId != null;

  /// Get new friends (peers that connected to current user)
  List<Peer> get newFriends => _nearbyPeers.where((p) => 
    _connections.any((c) => 
      ((c.fromProfileId == _currentProfile?.id && c.toProfileId == p.id) ||
       (c.toProfileId == _currentProfile?.id && c.fromProfileId == p.id)) &&
      c.status == ConnectionStatus.accepted
    )
  ).toList();

  /// Get current user's connections as peers
  List<Peer> get yourConnections {
    final connectedIds = _connections
        .where((c) => 
            (c.fromProfileId == _currentProfile?.id || c.toProfileId == _currentProfile?.id) &&
            c.status == ConnectionStatus.accepted)
        .map((c) => c.fromProfileId == _currentProfile?.id ? c.toProfileId : c.fromProfileId)
        .toSet();
    
    return _nearbyPeers.where((p) => connectedIds.contains(p.id)).toList();
  }

  /// Get profiles that current user is connected to (async version)
  Future<List<Profile>> getConnectedProfiles() async {
    _debugLog('getConnectedProfiles called: _currentProfile=${_currentProfile?.id}, _connections=${_connections.length}');
    if (_currentProfile == null) {
      _debugLog('getConnectedProfiles: No current profile');
      return [];
    }
    
    // Get accepted connections for current user
    final currentUserId = _currentProfile!.id;
    final acceptedConnections = _connections.where((c) => c.status == ConnectionStatus.accepted).toList();
    final connectionIds = acceptedConnections
        .map((c) => c.fromProfileId == currentUserId ? c.toProfileId : c.fromProfileId)
        .toSet();
    
    _debugLog('getConnectedProfiles: Found ${acceptedConnections.length} accepted connections, connectionIds: $connectionIds');
    
    // Fetch profile data for each connected user from API
    final List<Profile> connectedProfiles = [];
    
    for (final connectionId in connectionIds) {
      try {
        // Get user data from API
        final userRead = await _apiService.getUser(int.parse(connectionId));
        final profile = _apiService.userReadToProfile(userRead);
        connectedProfiles.add(profile);
      } catch (e) {
        _debugLog('Failed to fetch profile for connection $connectionId: $e');
        // Continue with other profiles even if one fails
      }
    }
    
    _debugLog('getConnectedProfiles: Successfully fetched ${connectedProfiles.length} profiles from API');
    return connectedProfiles;
  }

  /// Get profiles that current user is connected to (sync version using nearby peers)
  List<Profile> get connectedProfiles {
    _debugLog('connectedProfiles called: _currentProfile=${_currentProfile?.id}, _connections=${_connections.length}, _nearbyPeers=${_nearbyPeers.length}');
    if (_currentProfile == null) {
      _debugLog('connectedProfiles: No current profile');
      return [];
    }
    
    // Get accepted connections for current user
    final currentUserId = _currentProfile!.id;
    final acceptedConnections = _connections.where((c) => c.status == ConnectionStatus.accepted).toList();
    final connectionIds = acceptedConnections
        .map((c) => c.fromProfileId == currentUserId ? c.toProfileId : c.fromProfileId)
        .toSet();
    
    _debugLog('connectedProfiles: Found ${acceptedConnections.length} accepted connections, connectionIds: $connectionIds');
    
    // Get profiles from nearby peers that match connection IDs
    final connectedPeers = _nearbyPeers
        .where((p) => connectionIds.contains(p.id))
        .toList();
    
    _debugLog('connectedProfiles: Found ${connectedPeers.length} matching peers from ${_nearbyPeers.length} nearby peers');
    
    // Convert Peer objects to Profile objects
    return connectedPeers.map((peer) => Profile(
      id: peer.id,
      userName: peer.name,
      school: peer.school,
      major: peer.major,
      interests: peer.interests,
      background: peer.background,
      profileImagePath: peer.profileImageUrl,
    )).toList();
  }

  /// Initialize services that depend on each other
  void _initializeServices() {
    _locationService = LocationService(_apiService);
    _startMessagePolling();
  }

  /// Start periodic message polling for real-time updates
  void _startMessagePolling() {
    _messageFetchTimer?.cancel();
    _messageFetchTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _fetchNewMessages();
    });
  }

  /// Stop message polling
  void _stopMessagePolling() {
    _messageFetchTimer?.cancel();
    _messageFetchTimer = null;
  }

  /// Start connection synchronization polling
  void _startConnectionSync() {
    _connectionSyncTimer?.cancel();
    _connectionSyncTimer = Timer.periodic(const Duration(seconds: 60), (
      _,
    ) async {
      await _syncConnections();
    });
  }

  /// Stop connection synchronization polling
  void _stopConnectionSync() {
    _connectionSyncTimer?.cancel();
    _connectionSyncTimer = null;
  }

  /// Start nearby peers polling
  void _startNearbyPeersPolling() {
    _nearbyPeersTimer?.cancel();
    _nearbyPeersTimer = Timer.periodic(const Duration(seconds: 45), (_) async {
      await _syncNearbyPeers();
    });
  }

  /// Stop nearby peers polling
  void _stopNearbyPeersPolling() {
    _nearbyPeersTimer?.cancel();
    _nearbyPeersTimer = null;
  }

  /// Start activities polling
  void _startActivitiesPolling() {
    _activitiesTimer?.cancel();
    _activitiesTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      await _syncActivities();
    });
  }

  /// Stop activities polling
  void _stopActivitiesPolling() {
    _activitiesTimer?.cancel();
    _activitiesTimer = null;
  }

  /// Refresh messages for a specific chat room
  Future<void> refreshChatRoomMessages(String chatRoomId) async {
    await _fetchMessagesForChatRoom(chatRoomId);
  }

  /// Fetch new messages for all chat rooms
  Future<void> _fetchNewMessages() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      for (final chatRoom in _chatRooms) {
        await _fetchMessagesForChatRoom(chatRoom.id);
      }
    } catch (e) {
      // Propagate errors to UI instead of silently handling them
      _debugLog('Error fetching messages: $e');
      rethrow;
    }
  }

  /// Synchronize connections with API
  Future<void> _syncConnections() async {
    _debugLog('_syncConnections called: _currentProfile=${_currentProfile?.id}, _apiUserId=$_apiUserId');
    if (_currentProfile == null || _apiUserId == null) {
      _debugLog('Skipping connection sync - missing profile or user ID');
      return;
    }

    try {
      _debugLog('Syncing connections with API...');

      // Fetch 1-hop connections for current user from API
      final currentUserId = int.tryParse(_apiUserId ?? '0') ?? 0;
      if (currentUserId == 0) {
        _debugLog('Invalid user ID for connection sync');
        return;
      }

      final apiConnections = await _apiService.getOneHopConnections(currentUserId);

      // Detect changes by comparing with previous state
      final hasChanges =
          _connections.length != apiConnections.length ||
          !_connections.every(
            (local) => apiConnections.any(
              (api) => api.id == local.id && api.status == local.status,
            ),
          );

      if (hasChanges) {
        _connections = apiConnections;
        notifyListeners();
        _debugLog(
          'Connections updated: ${_connections.length} user connections',
        );
      }

      _lastConnectionSync = DateTime.now();
    } catch (e) {
      _debugLog('Failed to sync connections: $e');
      rethrow; // Propagate errors instead of continuing with existing data
    }
  }

  /// Synchronize nearby peers with API
  Future<void> _syncNearbyPeers() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      _debugLog('Syncing nearby peers with API...');

      // Get current user location
      final currentPosition = await _locationService.getCurrentLocation();
      if (currentPosition == null) {
        _debugLog('Cannot sync nearby peers: unable to get current location');
        return;
      }

      // Update current user's location
      final userId = int.parse(_apiUserId!);
      await _locationService.updateLocation(userId);

      // Search for nearby users using API endpoint
      final nearbyUsersWithDistance = await _apiService.getNearbyUsers(
        currentPosition.latitude,
        currentPosition.longitude,
        radiusKm: 5.0,
        limit: 20,
      );

      // Convert UserReadWithDistance objects to Peer objects
      final peers = nearbyUsersWithDistance
          .where(
            (userWithDistance) => userWithDistance.id != userId,
          ) // Exclude self
          .map(
            (userWithDistance) =>
                _apiService.userReadWithDistanceToPeer(userWithDistance),
          )
          .map((peer) => _applyMatchScore(peer))
          .toList();

      // Sort by distance and match score
      peers.sort((a, b) {
        // Primary sort by distance
        final distanceCompare = a.distance.compareTo(b.distance);
        if (distanceCompare != 0) return distanceCompare;

        // Secondary sort by match score (descending)
        return b.matchScore.compareTo(a.matchScore);
      });

      // Detect changes by comparing with previous state
      final hasChanges =
          _nearbyPeers.length != peers.length ||
          !_nearbyPeers.every(
            (local) => peers.any((peer) => peer.id == local.id),
          );

      if (hasChanges) {
        _nearbyPeers = peers;
        notifyListeners();
        _debugLog('Nearby peers updated: ${_nearbyPeers.length} total peers');
      }

      _lastNearbyPeersSync = DateTime.now();
    } catch (e) {
      _debugLog('Failed to sync nearby peers: $e');
      rethrow; // Propagate errors instead of continuing with existing data
    }
  }

  /// Synchronize activities with API
  Future<void> _syncActivities() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      _debugLog('Syncing activities with API...');
      final apiActivities = await _apiService.getActivities();

      // Convert API activities to local Activity objects
      final activities = apiActivities.map((apiActivity) {
        return _apiService.activityReadToActivity(apiActivity);
      }).toList();

      // Detect changes by comparing with previous state
      final hasChanges =
          _activities.length != activities.length ||
          !_activities.every(
            (local) => activities.any((api) => api.id == local.id),
          );

      if (hasChanges) {
        _activities = activities;

        // Auto-select first activity if none is selected
        if (_selectedActivityId == null && _activities.isNotEmpty) {
          _selectedActivityId = _activities.first.id.toString();
          _debugLog(
            'Auto-selected activity: ${_activities.first.name} (ID: ${_activities.first.id})',
          );
        }

        notifyListeners();
        _debugLog('Activities updated: ${_activities.length} total activities');
      }

      _lastActivitiesSync = DateTime.now();
    } catch (e) {
      _debugLog('Failed to sync activities: $e');
      rethrow; // Propagate errors instead of continuing with existing data
    }
  }

  /// Force immediate connection sync
  Future<void> syncConnectionsNow() async {
    await _syncConnections();
  }

  /// Force immediate nearby peers sync
  Future<void> syncNearbyPeersNow() async {
    await _syncNearbyPeers();
  }

  /// Force immediate activities sync
  Future<void> syncActivitiesNow() async {
    await _syncActivities();
  }

  /// Fetch messages for a specific chat room
  Future<void> _fetchMessagesForChatRoom(String chatRoomId) async {
    try {
      _debugLog('=== FETCHING MESSAGES FOR CHAT ROOM $chatRoomId ===');
      final messages = await _apiService.getChatMessages(chatRoomId);
      final messageReads = messages.toList();

      _debugLog('Server returned ${messageReads.length} messages');
      for (int i = 0; i < messageReads.length; i++) {
        _debugLog(
          'Server message ${i + 1}: ID=${messageReads[i].id}, sender=${messageReads[i].senderId}, text="${messageReads[i].text}"',
        );
      }

      final chatRoomIndex = _chatRooms.indexWhere((cr) => cr.id == chatRoomId);
      if (chatRoomIndex == -1) {
        _debugLog('Chat room $chatRoomId not found locally');
        return;
      }

      final currentMessages = _chatRooms[chatRoomIndex].messages;
      _debugLog('Current local messages count: ${currentMessages.length}');
      for (int i = 0; i < currentMessages.length; i++) {
        _debugLog(
          'Local message ${i + 1}: ID=${currentMessages[i].id}, isMine=${currentMessages[i].isMine}, text="${currentMessages[i].text}"',
        );
      }

      final newMessages = <ChatMessage>[];

      for (final messageRead in messageReads) {
        // Check if message already exists by ID or by content+timestamp+sender (for temporary IDs)
        final existingMessage = currentMessages.firstWhere(
          (msg) => msg.id == messageRead.id,
          orElse: () {
            // Try to find a match by content, timestamp, and sender (for locally sent messages with temp IDs)
            final currentUserId = _currentProfile?.id ?? '';
            final isMine = messageRead.senderId.toString() == currentUserId;

            // Get the server timestamp in local format for comparison
            DateTime serverTimestampLocal;
            try {
              final parsedTimestamp = DateTime.parse(messageRead.timestamp);
              if (parsedTimestamp.isUtc) {
                // Convert UTC to local time
                serverTimestampLocal = parsedTimestamp.toLocal();
              } else {
                // Server is sending local-time formatted timestamps but they're actually UTC
                // Convert to UTC first, then to local time to get correct offset
                final utcTime = DateTime.utc(
                  parsedTimestamp.year,
                  parsedTimestamp.month,
                  parsedTimestamp.day,
                  parsedTimestamp.hour,
                  parsedTimestamp.minute,
                  parsedTimestamp.second,
                );
                serverTimestampLocal = utcTime.toLocal();
              }
            } catch (e) {
              // Fallback to current time if parsing fails
              serverTimestampLocal = DateTime.now();
            }

            final matchByContent = currentMessages.firstWhere(
              (msg) =>
                  msg.text.trim() == messageRead.text.trim() &&
                  msg.isMine == isMine &&
                  msg.timestamp
                          .difference(serverTimestampLocal)
                          .abs()
                          .inMinutes <
                      1, // Within 1 minute
              orElse: () => ChatMessage(
                id: 'dummy',
                text: '',
                isMine: false,
                timestamp: DateTime.now(),
              ),
            );

            return matchByContent;
          },
        );

        if (existingMessage.id == 'dummy') {
          // New message found
          final currentUserId = _currentProfile?.id ?? '';
          final isMine = messageRead.senderId.toString() == currentUserId;

          _debugLog('Adding new message: ID=${messageRead.id}, isMine=$isMine');
          newMessages.add(
            _apiService.chatMessageReadToChatMessage(messageRead, isMine),
          );
        } else if (existingMessage.id != messageRead.id) {
          // Found by content match but ID differs - update: local message with server ID and timestamp
          DateTime serverTimestampLocal;
          try {
            final parsedTimestamp = DateTime.parse(messageRead.timestamp);
            if (parsedTimestamp.isUtc) {
              // Convert UTC to local time
              serverTimestampLocal = parsedTimestamp.toLocal();
            } else {
              // Server is sending local-time formatted timestamps but they're actually UTC
              // Convert to UTC first, then to local time to get correct offset
              final utcTime = DateTime.utc(
                parsedTimestamp.year,
                parsedTimestamp.month,
                parsedTimestamp.day,
                parsedTimestamp.hour,
                parsedTimestamp.minute,
                parsedTimestamp.second,
              );
              serverTimestampLocal = utcTime.toLocal();
            }
          } catch (e) {
            // Fallback to current time if parsing fails
            serverTimestampLocal = DateTime.now();
          }

          _debugLog(
            'Updating temporary message ID: localID=${existingMessage.id} -> serverID=${messageRead.id}',
          );
          _debugLog(
            'Updating timestamp: local=${existingMessage.timestamp} -> server=$serverTimestampLocal',
          );
          final messageIndex = currentMessages.indexWhere(
            (msg) => msg.id == existingMessage.id,
          );
          if (messageIndex != -1) {
            currentMessages[messageIndex] = existingMessage.copyWith(
              id: messageRead.id,
              timestamp: serverTimestampLocal,
            );
          }
        }
      }

      // Load connections from API
      _debugLog('Attempting to sync connections...');
      await _syncConnections();

      // Start location tracking if user is logged in
      if (_currentProfile != null && _apiUserId != null) {
        _startLocationTracking();
      }

      // Load activities from API
      await _loadActivitiesFromApi();

      // Load chat rooms from API
      await _fetchChatRooms();

      // Start invitation polling if user is logged in
      if (_apiUserId != null) {
        startInvitationPolling();
      }

      // Start all periodic data fetching
      if (_apiUserId != null) {
        _startConnectionSync();
        _startNearbyPeersPolling();
        _startActivitiesPolling();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      rethrow;
    }
  }

  /// Load activities from API
  Future<void> _loadActivitiesFromApi() async {
    try {
      if (_apiUserId == null) {
        _debugLog('Cannot load activities from API: no API user ID');
        throw Exception('User not authenticated');
      }

      _debugLog('Loading activities from API...');
      final apiActivities = await _apiService.getActivities();

      _activities.clear();
      for (final apiActivity in apiActivities) {
        final activity = _apiService.activityReadToActivity(apiActivity);
        _activities.add(activity);
      }

      _debugLog('Loaded ${_activities.length} activities from API');

      // Select first activity if none is selected
      if (_selectedActivityId == null && _activities.isNotEmpty) {
        _selectedActivityId = _activities.first.id.toString();
        _debugLog(
          'Auto-selected activity: ${_activities.first.name} (ID: ${_activities.first.id}, type: ${_activities.first.id.runtimeType})',
        );
      }

      notifyListeners();
    } catch (e) {
      _debugLog('Error loading activities from API: $e');
      rethrow; // Propagate error instead of using local fallback
    }
  }

  /// Persist API user ID
  Future<void> _persistApiUserId() async {
    try {
      if (_apiUserId == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiUserId, _apiUserId!);
    } catch (e) {
      debugPrint('Error saving API user ID: $e');
      rethrow;
    }
  }

  /// Clear persisted data
  Future<void> _clearPersistedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyApiUserId);
    } catch (e) {
      debugPrint('Error clearing profile data: $e');
      rethrow;
    }
  }

  /// Save user name (registration step) - creates user in API
  Future<void> saveUserName(String userName) async {
    try {
      // Create a temporary profile for API call
      final tempProfile = Profile(
        id: '', // Will be replaced by API
        userName: userName,
      );

      // Create user in API first
      final userCreate = _apiService.profileToUserCreate(tempProfile);
      final apiUserRead = await _apiService.createUser(userCreate);
      final apiProfile = _apiService.userReadToProfile(apiUserRead);

      _currentProfile = apiProfile;
      _apiUserId = apiProfile.id;

      // Persist API user ID
      await _persistApiUserId();

      // Start location tracking for new user
      _startLocationTracking();

      // Start invitation polling for new user
      startInvitationPolling();

      // Start all periodic data fetching
      _startConnectionSync();
      _startNearbyPeersPolling();
      _startActivitiesPolling();

      notifyListeners();
    } catch (e) {
      debugPrint('Error creating user in API: $e');
      rethrow;
    }
  }

  /// Load user profile from storage and API
  Future<void> loadUserProfile() async {
    try {
      // Initialize services first
      _initializeServices();

      final prefs = await SharedPreferences.getInstance();

      // Load API user ID from storage
      _apiUserId = prefs.getString(_keyApiUserId);
      _debugLog('Loaded API user ID: $_apiUserId');

      if (_apiUserId != null) {
        try {
          final apiUserIdInt = int.parse(_apiUserId!);
          final apiUserRead = await _apiService.getUser(apiUserIdInt);
          final apiProfile = _apiService.userReadToProfile(apiUserRead);
          _currentProfile = apiProfile;
        } catch (e) {
          debugPrint('Error loading profile from API: $e');
          rethrow; // Propagate error instead of using local fallback
        }
      } else {
        _debugLog('No API user ID found in storage - user needs to register');
      }

      // Load connections from API
      _debugLog('Attempting to sync connections...');
      await _syncConnections();

      // Start location tracking if user is logged in
      if (_currentProfile != null && _apiUserId != null) {
        _startLocationTracking();
      }

      // Load activities from API
      await _loadActivitiesFromApi();

      // Load chat rooms from API
      await _fetchChatRooms();

      // Start invitation polling if user is logged in
      if (_apiUserId != null) {
        startInvitationPolling();
      }

      // Start all periodic data fetching
      if (_apiUserId != null) {
        _startConnectionSync();
        _startNearbyPeersPolling();
        _startActivitiesPolling();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      rethrow;
    }
  }

  /// Update current profile with additional information - syncs with API
  Future<void> updateProfile({
    String? school,
    String? major,
    String? interests,
    String? background,
    String? profileImagePath,
    bool skipApiSync = false,
  }) async {
    if (_currentProfile == null) return;

    debugPrint(
      'StorageService: updateProfile called with profileImagePath: $profileImagePath, skipApiSync: $skipApiSync',
    );
    debugPrint(
      'StorageService: Current profileImagePath before update: ${_currentProfile!.profileImagePath}',
    );

    // Update local profile first for immediate UI response
    _currentProfile = _currentProfile!.copyWith(
      school: school,
      major: major,
      interests: interests,
      background: background,
      profileImagePath: profileImagePath,
    );

    debugPrint(
      'StorageService: Profile updated locally, new profileImagePath: ${_currentProfile!.profileImagePath}',
    );

    // Sync with API if we have an API user ID and not skipping sync
    if (_apiUserId != null && !skipApiSync) {
      try {
        final apiUserIdInt = int.parse(_apiUserId!);
        final userUpdate = _apiService.profileToUserUpdate(_currentProfile!);
        final updatedUserRead = await _apiService.updateUser(
          apiUserIdInt,
          userUpdate,
        );
        final updatedProfile = _apiService.userReadToProfile(updatedUserRead);
        _currentProfile = updatedProfile;
      } catch (e) {
        debugPrint('Error updating profile in API: $e');
        rethrow; // Propagate error instead of continuing with local update
      }
    }

    notifyListeners();
  }

  /// Update only avatar URL without syncing other profile data
  Future<void> updateAvatarOnly(String? avatarUrl) async {
    if (_currentProfile == null) return;

    debugPrint(
      'StorageService: updateAvatarOnly called with avatarUrl: $avatarUrl',
    );

    // Update local profile immediately
    _currentProfile = _currentProfile!.copyWith(profileImagePath: avatarUrl);

    // Sync with API if we have an API user ID
    if (_apiUserId != null) {
      try {
        final apiUserIdInt = int.parse(_apiUserId!);
        // Create user update with only avatar URL changed
        final userUpdate = UserUpdate(
          (b) => b
            ..displayname = _currentProfile!.userName
            ..school = _currentProfile!.school ?? ''
            ..major = _currentProfile!.major ?? ''
            ..interests = _currentProfile!.interests ?? ''
            ..bio = _currentProfile!.background ?? ''
            ..avatarUrl = avatarUrl,
        ); // This will be null for deletion

        final updatedUserRead = await _apiService.updateUser(
          apiUserIdInt,
          userUpdate,
        );
        final updatedProfile = _apiService.userReadToProfile(updatedUserRead);
        _currentProfile = updatedProfile;

        debugPrint('StorageService: Avatar updated successfully in API');
      } catch (e) {
        debugPrint('Error updating avatar in API: $e');
        rethrow; // Propagate error instead of continuing with local update
      }
    }

    notifyListeners();
  }

  /// Clear all data (for logout)
  Future<void> clearProfile() async {
    _currentProfile = null;
    _connections = [];
    _nearbyPeers = [];
    _invitations = [];
    _chatRooms = [];
    _activities = [];
    _selectedPeer = null;
    _selectedActivityId = null;
    _apiUserId = null;

    // Stop all periodic timers when user logs out
    _stopLocationTracking();
    stopInvitationPolling();
    _stopMessagePolling();
    _stopConnectionSync();
    _stopNearbyPeersPolling();
    _stopActivitiesPolling();

    await _clearPersistedProfile();
    notifyListeners();
  }

  /// Logout user and clear all data
  Future<void> logout() async {
    await clearProfile();
  }

  /// Create a new activity via API
  Future<Activity> createActivity(String name, String description) async {
    final activityCreate = ActivityCreate(
      (b) => b
        ..name = name
        ..description = description,
    );

    final apiActivity = await _apiService.createActivity(activityCreate);
    final activity = _apiService.activityReadToActivity(apiActivity);

    _activities.add(activity);
    _selectedActivityId = activity.id.toString();
    _debugLog(
      'Created activity via API: ${activity.id} (type: ${activity.id.runtimeType})',
    );
    notifyListeners();

    return activity;
  }

  /// Delete an activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await _apiService.deleteActivity(activityId);
      _activities.removeWhere((a) => a.id == activityId);
      if (_selectedActivityId == activityId) {
        _selectedActivityId = null;
      }
      notifyListeners();
    } catch (e) {
      _debugLog('Error deleting activity: $e');
      rethrow;
    }
  }

  /// Select an activity to view its invitations
  void selectActivity(String activityId) {
    _selectedActivityId = activityId.toString();
    _debugLog(
      'Selected activity ID: $activityId (type: ${activityId.runtimeType})',
    );
    notifyListeners();
  }

  /// Clear selected activity
  void clearSelectedActivity() {
    _selectedActivityId = null;
    notifyListeners();
  }

  /// Create or get: search activity (removes duplicates)
  Future<Activity> createOrGetSearchActivity() async {
    const searchActivityName = 'Searching for peers to eat';

    // Check if we already have a search activity from server
    final existingSearchActivity = _activities
        .where((a) => a.name == searchActivityName)
        .firstOrNull;

    if (existingSearchActivity != null) {
      _selectedActivityId = existingSearchActivity.id.toString();
      _debugLog('Using existing search activity: ${existingSearchActivity.id}');
      notifyListeners();
      return existingSearchActivity;
    }

    // Create a new search activity via API
    final activityCreate = ActivityCreate(
      (b) => b
        ..name = searchActivityName
        ..description =
            'Looking for people nearby who want to grab food together',
    );

    final apiActivity = await _apiService.createActivity(activityCreate);
    final activity = _apiService.activityReadToActivity(apiActivity);

    _activities.add(activity);
    _selectedActivityId = activity.id.toString();
    _debugLog(
      'Created search activity via API: ${activity.id} (type: ${activity.id.runtimeType})',
    );
    notifyListeners();

    return activity;
  }

  /// Get activity by ID
  Activity? getActivityById(String activityId) {
    try {
      return _activities.firstWhere((a) => a.id == activityId);
    } catch (e) {
      return null;
    }
  }

  /// Search for nearby peers using real API and location services
  Future<List<Peer>> searchNearbyPeers() async {
    if (_currentProfile == null || _apiUserId == null) {
      _debugLog('Cannot search for peers: no current profile or API user ID');
      throw Exception('User not authenticated');
    }

    try {
      // Get current user location
      final currentPosition = await _locationService.getCurrentLocation();
      if (currentPosition == null) {
        _debugLog('Cannot search for peers: unable to get current location');
        throw Exception('Location services unavailable');
      }

      // Update current user's location
      final userId = int.parse(_apiUserId!);
      await _locationService.updateLocation(userId);

      // Search for nearby users using: new API endpoint
      final nearbyUsersWithDistance = await _apiService.getNearbyUsers(
        currentPosition.latitude,
        currentPosition.longitude,
        radiusKm: 5.0,
        limit: 20,
      );

      // Convert UserReadWithDistance objects to Peer objects
      final peers = nearbyUsersWithDistance
          .where(
            (userWithDistance) => userWithDistance.id != userId,
          ) // Exclude self
          .map(
            (userWithDistance) =>
                _apiService.userReadWithDistanceToPeer(userWithDistance),
          )
          .map((peer) => _applyMatchScore(peer))
          .toList();

      // Sort by distance and match score
      peers.sort((a, b) {
        // Primary sort by distance
        final distanceCompare = a.distance.compareTo(b.distance);
        if (distanceCompare != 0) return distanceCompare;

        // Secondary sort by match score (descending)
        return b.matchScore.compareTo(a.matchScore);
      });

      _nearbyPeers = peers;
      notifyListeners();
      _debugLog('Found ${peers.length} nearby peers');
      return peers;
    } catch (e) {
      _debugLog('Error searching for nearby peers: $e');
      rethrow; // Propagate error instead of falling back to mock data
    }
  }

  /// Apply match score to a peer based on current user profile
  Peer _applyMatchScore(Peer peer) {
    if (_currentProfile == null) return peer;

    final matchScore = Peer.calculateMatchScore(_currentProfile!, peer);
    return Peer(
      id: peer.id,
      name: peer.name,
      school: peer.school,
      major: peer.major,
      interests: peer.interests,
      background: peer.background,
      matchScore: matchScore,
      distance: peer.distance,
      wantsToEat: peer.wantsToEat,
      profileImageUrl: peer.profileImageUrl,
    );
  }

  /// Start location tracking for current user
  void _startLocationTracking() {
    if (_apiUserId != null && _currentProfile != null) {
      final userId = int.parse(_apiUserId!);
      _locationService.startLocationTracking(userId);
      _debugLog('Started location tracking for user $_apiUserId');
    }
  }

  /// Stop location tracking
  void _stopLocationTracking() {
    _locationService.stopLocationTracking();
    _debugLog('Stopped location tracking');
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[StorageService] $message');
    }
  }

  /// Select a peer to potentially meet
  void selectPeer(Peer peer) {
    _selectedPeer = peer;
    notifyListeners();
  }

  /// Send invitation for activity
  Future<Invitation> sendInvitation(Peer peer, String activityName) async {
    _debugLog(
      'sendInvitation called for peer: ${peer.name}, activity: $activityName',
    );

    // Require activity to be selected
    if (_selectedActivityId == null) {
      _debugLog('No activity selected - throwing exception');
      throw Exception('No activity selected. Please select an activity first.');
    }

    // Require API user ID for backend integration
    if (_apiUserId == null) {
      _debugLog('No API user ID - throwing exception');
      throw Exception('User not authenticated. Please log in first.');
    }

    _debugLog('Validation passed - proceeding with API call');
    _debugLog(
      'Creating invitation with senderId: $_apiUserId, receiverId: ${peer.id}, activityId: $_selectedActivityId (type: ${_selectedActivityId.runtimeType})',
    );

    // Generate ice-breaking questions
    final iceBreakers = _generateIceBreakers(peer);

    try {
      _debugLog('Creating invitation using new message-based system...');

      final currentUserId = int.parse(_apiUserId!);
      final activityId = _selectedActivityId!.toString();

      // Step 1: Get or create chat room between users
      _debugLog('Getting/creating chat room for invitation...');
      final chatRoomRead = await _apiService.findChatRoomBetweenUsers(
        currentUserId,
        int.parse(peer.id),
        activityName,
      );

      if (chatRoomRead == null) {
        throw Exception('Failed to create or get chat room');
      }

      final chatRoom = _apiService.chatRoomReadToChatRoom(chatRoomRead);
      _chatRooms.add(chatRoom);
      _debugLog('Chat room created/fetched: ${chatRoom.id}');

      // Step 2: Create invitation message in the chat room
      _debugLog('Creating invitation message...');
      final invitationId = 'inv_${DateTime.now().millisecondsSinceEpoch}';
      final iceBreakerStrings = iceBreakers.map((ib) => ib.question).toList();

      // Create local invitation object for compatibility first
      final invitation = Invitation(
        id: invitationId,
        peerId: peer.id,
        peerName: peer.name,
        restaurant: activityName,
        activityId: _selectedActivityId!,
        createdAt: DateTime.now(),
        sentByMe: true,
        status: InvitationStatus.pending,
        iceBreakers: iceBreakers,
        nameCardCollected: false,
        chatOpened: false,
      );

      final invitationMessage = await _apiService.createInvitationMessage(
        chatRoom.id,
        currentUserId,
        activityName,
        invitation.restaurant,
        BuiltList<String>(iceBreakerStrings),
        null, // responseDeadline - not set for now
      );

      _debugLog('Invitation message created: ${invitationMessage.id}');

      _invitations.add(invitation);
      notifyListeners();
      _debugLog('Invitation added to local list and notified listeners');

      return invitation;
    } catch (e) {
      _debugLog('Failed to send invitation: $e');
      _debugLog('Error type: ${e.runtimeType}');
      if (e is DioException) {
        _debugLog('Dio error: ${e.type} - ${e.message}');
        _debugLog('Response: ${e.response?.data}');
      }
      throw Exception('Failed to send invitation: ${e.toString()}');
    }
  }

  /// Start periodic invitation fetching
  void startInvitationPolling() {
    if (_apiUserId == null) {
      _debugLog('Cannot start invitation polling: API user ID not set');
      return;
    }

    // Stop existing timer if any
    stopInvitationPolling();

    _debugLog('Starting invitation polling every 30 seconds');

    // Fetch immediately
    fetchInvitations();

    // Then fetch every 30 seconds
    _invitationFetchTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) {
      _debugLog('Periodic invitation fetch...');
      fetchInvitations();
    });
  }

  /// Stop periodic invitation fetching
  void stopInvitationPolling() {
    _invitationFetchTimer?.cancel();
    _invitationFetchTimer = null;
    _debugLog('Stopped invitation polling');
  }

  /// Fetch invitations from server
  Future<void> fetchInvitations() async {
    if (_apiUserId == null) {
      _debugLog('Cannot fetch invitations: API user ID not set');
      return;
    }

    try {
      _debugLog('Fetching invitations for user $_apiUserId...');

      // TODO: Implement message-based invitation fetching
      // final invitationReads = await _apiService.getInvitations(int.parse(_apiUserId!));
      final invitationReads = <dynamic>[];
      _debugLog('Fetched ${invitationReads.length} invitations from server');

      // Convert API invitations to local Invitation objects
      final fetchedInvitations = <Invitation>[];

      for (final invitationRead in invitationReads) {
        try {
          // Get peer name from sender/receiver info
          String peerName = 'Unknown User';
          bool sentByMe = invitationRead.senderId.toString() == _apiUserId;

          // If we sent it, peer is the receiver, otherwise peer is the sender
          final peerId = sentByMe
              ? invitationRead.receiverId.toString()
              : invitationRead.senderId.toString();

          // Try to get peer name from profiles or nearby peers
          final profile = await getProfileById(peerId);
          if (profile != null) {
            peerName = profile.userName;
          } else {
            final peer = getPeerById(peerId);
            if (peer != null) {
              peerName = peer.name;
            } else {
              // Fallback to generic name if we can't find the user
              peerName = 'User $peerId';
            }
          }

          // Create invitation from message data (since we removed old invitation API)
          DateTime parsedCreatedAt;
          try {
            parsedCreatedAt = DateTime.parse(invitationRead.createdAt);
            if (parsedCreatedAt.isUtc) {
              parsedCreatedAt = parsedCreatedAt.toLocal();
            }
          } catch (e) {
            parsedCreatedAt = DateTime.now();
            _debugLog(
              'Failed to parse createdAt: ${invitationRead.createdAt}, using current time',
            );
          }

          final invitation = Invitation(
            id: invitationRead.id,
            peerId: peerId.toString(),
            peerName: peerName,
            restaurant: invitationRead.restaurant,
            activityId: invitationRead.activityId,
            createdAt: parsedCreatedAt,
            sentByMe: sentByMe,
            status: _parseInvitationStatus(invitationRead.status),
            iceBreakers: [], // Not available in new API
            nameCardCollected: false, // Not available in new API
            chatOpened: false, // Not available in new API
          );

          fetchedInvitations.add(invitation);
        } catch (e) {
          _debugLog('Error processing invitation ${invitationRead.id}: $e');
        }
      }

      // Update local invitations list
      _invitations = fetchedInvitations;
      _debugLog(
        'Updated local invitations list with ${_invitations.length} invitations',
      );
      notifyListeners();
    } catch (e) {
      _debugLog('Failed to fetch invitations: $e');
      rethrow; // Propagate errors instead of continuing with local data
    }
  }

  /// Serialize iceBreakers to JSON string for API
  String _serializeIceBreakers(List<IceBreaker> iceBreakers) {
    final iceBreakerMap = iceBreakers
        .map((ib) => {'question': ib.question, 'answer': ib.answer})
        .toList();
    return jsonEncode(iceBreakerMap);
  }

  // Helper method to parse timestamp strings to DateTime
  DateTime _parseTimestamp(String timestampString) {
    try {
      final parsedTimestamp = DateTime.parse(timestampString);
      // Convert to local time if it's UTC
      return parsedTimestamp.isUtc
          ? parsedTimestamp.toLocal()
          : parsedTimestamp;
    } catch (e) {
      _debugLog(
        'Failed to parse timestamp: $timestampString, using current time',
      );
      return DateTime.now();
    }
  }

  /// Parse invitation status from API string
  InvitationStatus _parseInvitationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'declined':
        return InvitationStatus.declined;
      default:
        return InvitationStatus.pending;
    }
  }

  /// Generate ice-breaking questions based on peer's profile
  List<IceBreaker> _generateIceBreakers(Peer peer) {
    // Common interests questions (always included)
    final commonInterestQuestions = [
      IceBreaker(
        question: 'What inspired you to study ${peer.major}?',
        answer: 'This helps you understand their passion and motivation',
      ),
      IceBreaker(
        question:
            'I see you\'re interested in ${peer.interests.split(',').first.trim()}. How did you get into that?',
        answer: 'Shows you read their profile and care about their interests',
      ),
      IceBreaker(
        question: 'What\'s your favorite thing about ${peer.school}?',
        answer: 'A great way to share common experiences',
      ),
    ];

    // Other diverse questions (for random selection)
    final otherQuestions = [
      // Values and personal philosophy
      IceBreaker(
        question:
            'What\'s a core value or principle that guides your decisions?',
        answer: 'Helps understand what matters most to them',
      ),
      IceBreaker(
        question: 'What does success mean to you personally?',
        answer: 'Reveals their priorities and aspirations',
      ),
      IceBreaker(
        question:
            'If you could change one thing about the world, what would it be?',
        answer: 'Shows their values and what they care about',
      ),
      IceBreaker(
        question:
            'What\'s something you believe that most people disagree with?',
        answer: 'Encourages authentic conversation and perspective sharing',
      ),
      // Background and experiences
      IceBreaker(
        question: 'What\'s a life experience that shaped who you are today?',
        answer: 'Invites deeper storytelling about their journey',
      ),
      IceBreaker(
        question:
            'How has your background influenced your career or life goals?',
        answer: 'Explores the connection between past and future',
      ),
      IceBreaker(
        question: 'What\'s a challenge you\'ve overcome that you\'re proud of?',
        answer: 'Highlights resilience and personal growth',
      ),
      IceBreaker(
        question:
            'Is there a family tradition or cultural practice that\'s meaningful to you?',
        answer: 'Opens discussion about heritage and identity',
      ),
      // Fun and personality
      IceBreaker(
        question:
            'What\'s a fun fact about yourself that most people don\'t know?',
        answer: 'Helps break the ice with something unexpected',
      ),
      IceBreaker(
        question:
            'If you could have dinner with anyone, dead or alive, who would it be?',
        answer: 'Reveals their inspirations and interests',
      ),
      IceBreaker(
        question:
            'What\'s something you\'re currently trying to learn or get better at?',
        answer: 'Shows growth mindset and current interests',
      ),
      IceBreaker(
        question:
            'If you had a free year to do anything, how would you spend it?',
        answer: 'Explores dreams and priorities',
      ),
    ];

    // Randomly select 2 questions from other questions
    final random = Random();
    final shuffledOther = List<IceBreaker>.from(otherQuestions)
      ..shuffle(random);
    final selectedOther = shuffledOther.take(2).toList();

    // Combine common interest questions with randomly selected questions
    return [...commonInterestQuestions, ...selectedOther];
  }

  /// Accept an invitation (max 1 per activity)
  Future<void> acceptInvitation(String invitationId) async {
    final index = _invitations.indexWhere((i) => i.id == invitationId);
    if (index == -1) return;

    final acceptedInvitation = _invitations[index];
    final activityId = acceptedInvitation.activityId;

    // Check if there's already an accepted invitation for this activity
    final hasAcceptedForActivity = _invitations.any(
      (i) => i.isAccepted && i.activityId == activityId && i.id != invitationId,
    );

    if (hasAcceptedForActivity) {
      // Already have an accepted invitation for this activity, can't accept another
      return;
    }

    try {
      // Use new message-based invitation response API
      final currentUserId = int.tryParse(currentProfile?.id ?? '0') ?? 0;
      await _apiService.respondToInvitationMessage(
        invitationId,
        'accept',
        currentUserId,
      );

      _debugLog('Invitation accepted via API: $invitationId');
    } catch (e) {
      _debugLog('Failed to accept invitation via API: $e');
      rethrow; // Propagate error instead of continuing with local update
    }

    // Accept this invitation locally
    _invitations[index] = _invitations[index].copyWith(
      status: InvitationStatus.accepted,
    );

    // Auto-decline all OTHER received invitations for same activity
    for (int i = 0; i < _invitations.length; i++) {
      if (i != index &&
          _invitations[i].activityId == activityId &&
          _invitations[i].isPending &&
          !_invitations[i].sentByMe) {
        _invitations[i] = _invitations[i].copyWith(
          status: InvitationStatus.declined,
        );
      }
    }

    // Delete all unanswered SENT invitations for same activity
    _invitations.removeWhere(
      (inv) => inv.activityId == activityId && inv.sentByMe && inv.isPending,
    );

    notifyListeners();

    // REMOVED: _createChatRoom(acceptedInvitation) - now handled by backend
  }

  /// Decline an invitation
  Future<void> declineInvitation(String invitationId) async {
    try {
      // Use new message-based invitation response API
      final currentUserId = int.tryParse(currentProfile?.id ?? '0') ?? 0;
      await _apiService.respondToInvitationMessage(
        invitationId,
        'decline',
        currentUserId,
      );

      _debugLog('Invitation declined via API: $invitationId');
    } catch (e) {
      _debugLog('Failed to decline invitation via API: $e');
      rethrow; // Propagate error instead of continuing with local update
    }

    final index = _invitations.indexWhere((i) => i.id == invitationId);
    if (index != -1) {
      _invitations[index] = _invitations[index].copyWith(
        status: InvitationStatus.declined,
      );
      notifyListeners();
    }
  }

  /// Respond to invitation (accept/decline) by message ID
  Future<void> respondToInvitationByMessageId(
    String messageId,
    String action, // "accept" or "decline"
  ) async {
    try {
      final currentUserId = int.tryParse(currentProfile?.id ?? '0') ?? 0;
      await _apiService.respondToInvitationMessage(
        messageId,
        action,
        currentUserId,
      );

      _debugLog('Invitation $action via API (message ID): $messageId');
    } catch (e) {
      _debugLog('Failed to $action invitation via API: $e');
      rethrow; // Propagate error so UI can handle
    }
  }

  /// Send message in chat room
  Future<void> sendMessage(String chatRoomId, String text) async {
    final index = _chatRooms.indexWhere((c) => c.id == chatRoomId);
    if (index != -1) {
      final localTimestamp = DateTime.now();
      final message = ChatMessage(
        id: localTimestamp.millisecondsSinceEpoch.toString(),
        text: text,
        isMine: true,
        timestamp: localTimestamp,
        messageType: MessageType.text,
      );

      // Add message locally immediately for instant UI feedback
      final updatedMessages = [..._chatRooms[index].messages, message];
      _chatRooms[index] = _chatRooms[index].copyWith(messages: updatedMessages);
      notifyListeners();

      _debugLog('=== SENDING MESSAGE ===');
      _debugLog('Chat Room ID: $chatRoomId');
      _debugLog('Local Message ID: ${message.id}');
      _debugLog('Message Text: ${message.text}');
      _debugLog(
        'Current messages count before send: ${_chatRooms[index].messages.length}',
      );

      try {
        // Send to backend
        final currentUserId = int.tryParse(_currentProfile?.id ?? '0') ?? 0;
        await _apiService.sendChatMessage(chatRoomId, currentUserId, text);

        // Don't refresh messages immediately to avoid duplication
        // The message is already added locally, and periodic polling will sync server-assigned ID
        _debugLog('Message sent successfully to chat room $chatRoomId');
      } catch (e) {
        // Handle send error - could remove message or mark as failed
        print('Error sending message: $e');
        // For now, we'll keep message locally and let polling sync it
      }
    }
  }

  /// Simulate peer sending a message
  Future<void> _simulatePeerMessage(String chatRoomId) async {
    await Future.delayed(const Duration(seconds: 2));

    final index = _chatRooms.indexWhere((c) => c.id == chatRoomId);
    if (index != -1) {
      final responses = [
        'Sounds great! What time works for you?',
        'Perfect! Looking forward to it!',
        'That works for me! See you there!',
        'Great idea! Let\'s meet around noon?',
        'Awesome! Can\'t wait to meet you!',
      ];

      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: responses[DateTime.now().millisecond % responses.length],
        isMine: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      );

      final updatedMessages = [..._chatRooms[index].messages, message];
      _chatRooms[index] = _chatRooms[index].copyWith(messages: updatedMessages);
      notifyListeners();
    }
  }

  /// Get chat room between two users
  ChatRoom? getChatRoomBetweenUsers(String user1Id, String user2Id) {
    try {
      return _chatRooms.firstWhere(
        (c) => c.containsUser(user1Id) && c.containsUser(user2Id),
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch chat rooms from API
  Future<void> _fetchChatRooms() async {
    if (_apiUserId == null) return;

    try {
      // Convert string API user ID to int for API call
      final apiUserIdInt = int.tryParse(_apiUserId!);
      if (apiUserIdInt == null) {
        print('Invalid API user ID format: $_apiUserId');
        return;
      }

      final response = await _apiService.getChatRooms(apiUserIdInt);

      // Convert ChatRoomRead objects to local ChatRoom objects
      _chatRooms = response.map((chatRoomRead) {
        return ChatRoom(
          id: chatRoomRead.id,
          user1Id: chatRoomRead.user1Id.toString(),
          user2Id: chatRoomRead.user2Id.toString(),
          restaurant: chatRoomRead.restaurant,
          createdAt: _parseTimestamp(chatRoomRead.createdAt),
          messages: [],
        );
      }).toList();

      // Fetch messages for each chat room
      for (final chatRoom in _chatRooms) {
        await _fetchMessagesForChatRoom(chatRoom.id);
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching chat rooms: $e');
      rethrow; // Propagate error instead of using local fallback
    }
  }

  /// Refresh all chat rooms and messages
  Future<void> refreshChatRooms() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      await _fetchChatRooms();
    } catch (e) {
      print('Error refreshing chat rooms: $e');
      rethrow; // Propagate error
    }
  }

  /// Refresh invitations from server
  Future<void> refreshInvitations() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      await fetchInvitations();
    } catch (e) {
      print('Error refreshing invitations: $e');
      rethrow; // Propagate error
    }
  }

  /// Refresh all data (comprehensive refresh)
  Future<void> refreshAllData() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      _debugLog('Starting comprehensive data refresh...');

      // Refresh all data sources
      await Future.wait([
        _syncConnections(),
        _syncNearbyPeers(),
        _syncActivities(),
        _fetchChatRooms(),
        fetchInvitations(),
      ]);

      _debugLog('Comprehensive data refresh completed');
    } catch (e) {
      _debugLog('Error during comprehensive refresh: $e');
      rethrow;
    }
  }

  /// Get peer by ID
  /// Returns null if not found locally
  /// Deprecated: Use getProfileById instead
  Peer? getPeerById(String peerId) {
    try {
      return _nearbyPeers.firstWhere((p) => p.id == peerId);
    } catch (e) {
      return null;
    }
  }

  /// Create a connection request to a peer
  Future<Map<String, dynamic>> createConnectionRequest(
    Peer peer,
    String chatRoomId,
  ) async {
    if (_currentProfile == null) {
      throw Exception('No current profile set');
    }

    try {
      final currentUserId = int.tryParse(_apiUserId ?? '0') ?? 0;
      final targetUserId = int.tryParse(peer.id) ?? 0;

      if (currentUserId == 0 || targetUserId == 0) {
        throw Exception('Invalid user IDs for connection request');
      }

      final result = await _apiService.createConnectionRequest(
        chatRoomId,
        currentUserId,
        targetUserId,
      );

      _debugLog('Connection request created: $result');
      return result;
    } catch (e) {
      _debugLog('Failed to create connection request: $e');
      rethrow;
    }
  }

  /// Respond to a connection request (accept/decline)
  Future<Map<String, dynamic>> respondToConnectionRequest(
    String messageId,
    String action, // "accept" or "decline"
  ) async {
    if (_currentProfile == null) {
      throw Exception('No current profile set');
    }

    try {
      final currentUserId = int.tryParse(_apiUserId ?? '0') ?? 0;

      if (currentUserId == 0) {
        throw Exception('Invalid user ID for connection response');
      }

      final result = await _apiService.respondToConnectionRequest(
        messageId,
        action,
        currentUserId,
      );

      _debugLog('Connection request response: $result');
      return result;
    } catch (e) {
      _debugLog('Failed to respond to connection request: $e');
      rethrow;
    }
  }

  /// Get all connections for current user
  Future<List<Connection>> getConnections() async {
    if (_currentProfile == null) return [];

    try {
      final connections = await _apiService.getConnections();
      _debugLog('Retrieved ${connections.length} connections');
      return connections;
    } catch (e) {
      _debugLog('Failed to get connections: $e');
      rethrow; // Propagate error instead of returning empty list
    }
  }

  /// Get pending connections for current user
  Future<Map<String, dynamic>> getPendingConnections() async {
    if (_currentProfile == null) return {'connections': <dynamic>[]};

    try {
      final currentUserId = int.tryParse(_apiUserId ?? '0') ?? 0;
      if (currentUserId == 0) {
        return {'connections': <dynamic>[]};
      }

      final connections = await _apiService.getPendingConnections();
      _debugLog('Retrieved pending connections: $connections');
      return {'connections': connections};
    } catch (e) {
      _debugLog('Failed to get pending connections: $e');
      rethrow; // Propagate error instead of returning empty list
    }
  }

  /// Create connection from peer
  Future<Result<void>> collectNameCard(String peerId) async {
    if (_currentProfile == null) {
      return bail('No current profile available');
    }

    final peerResult = await getProfileResultById(peerId);

    if (peerResult case Err()) {
      return peerResult;
    }

    final peer = peerResult.unwrap();

    if (_connections.any((c) => c.toProfileId == peer.id)) {
      return bail(
        'Either a request or connection already exists with this peer',
      );
    }

    final currentUserId = _currentProfile!.id;
    final chatRoom = getChatRoomBetweenUsers(currentUserId, peerId);
    if (chatRoom == null) {
      return bail('No chat room found between users for connection');
    }

    try {
      final apiUserIdInt = int.tryParse(_apiUserId ?? '0') ?? 0;
      final targetUserIdInt = int.tryParse(peerId) ?? 0;

      if (apiUserIdInt == 0 || targetUserIdInt == 0) {
        return bail('Invalid user IDs for connection request');
      }

      await _apiService.createConnectionRequest(
        chatRoom.id,
        apiUserIdInt,
        targetUserIdInt,
      );
      return Ok(null);
    } catch (e) {
      return bail(
        'Failed to send connection request: ${e.toString()}',
      ).context('Error occurred while collecting name card for peer $peerId');
    }
  }

  Future<Result<Profile>> getProfileResultById(String id) async {
    try {
      final profile = await getProfileById(id);
      if (profile == null) {
        return bail('Profile not found for ID: $id');
      }
      return Ok(profile);
    } catch (e) {
      return bail('Error fetching profile for ID $id: ${e.toString()}');
    }
  }

  /// Get profile by ID (fetches from API if not found locally)
  Future<Profile?> getProfileById(String id) async {
    if (id == _currentProfile?.id) return _currentProfile;

    // Fetch from API since we don't have local caching
    try {
      final userIdInt = int.tryParse(id);
      if (userIdInt == null) {
        _debugLog('Invalid user ID format: $id');
        return null;
      }

      final userRead = await _apiService.getUser(userIdInt);
      final profile = _apiService.userReadToProfile(userRead);

      return profile;
    } catch (e) {
      _debugLog('Error fetching profile for user $id: $e');
      rethrow; // Propagate error instead of returning null
    }
  }

  /// Mark chat as opened for invitation
  Future<void> markChatOpened(String invitationId) async {
    final invIndex = _invitations.indexWhere((i) => i.id == invitationId);
    if (invIndex != -1) {
      _invitations[invIndex] = _invitations[invIndex].copyWith(
        chatOpened: true,
      );
      notifyListeners();
    }
  }

  /// Mark match as not good and decline
  Future<void> markNotGoodMatch(String peerId) async {
    final peer = getPeerById(peerId);
    if (peer == null) {
      _debugLog('Peer not found for ID: $peerId');
      return;
    }

    // Find and decline any pending invitations with this peer
    final pendingInvitations = _invitations
        .where((i) => i.peerId == peerId && i.isPending)
        .toList();

    for (final invitation in pendingInvitations) {
      await declineInvitation(invitation.id);
    }

    // Remove from chat rooms
    final currentUserId = _currentProfile?.id ?? '';
    _chatRooms.removeWhere(
      (c) => c.containsUser(currentUserId) && c.containsUser(peerId),
    );

    notifyListeners();
  }

  /// Add a user rating
  Future<void> addUserRating({
    required String ratedUserId,
    required int rating,
    String? reason,
  }) async {
    if (_currentProfile == null) return;

    final userRating = UserRating(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ratedUserId: ratedUserId,
      ratedByUserId: _currentProfile!.id,
      rating: rating,
      reason: reason,
      createdAt: DateTime.now(),
    );

    _userRatings.add(userRating);
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    stopInvitationPolling();
    _stopMessagePolling();
    _stopConnectionSync();
    _stopNearbyPeersPolling();
    _stopActivitiesPolling();
    super.dispose();
    _debugLog('StorageService disposed');
  }
}
