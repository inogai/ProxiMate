import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Storage service with persistent data using shared_preferences and API integration
class StorageService extends ChangeNotifier {
  static const String _keyCurrentProfile = 'current_profile';
  static const String _keyConnections = 'connections';
  static const String _keyProfiles = 'profiles';
  static const String _keyApiUserId = 'api_user_id';

  final ApiService _apiService = ApiService();
  late LocationService _locationService;
  Timer? _invitationFetchTimer;
  Timer? _messageFetchTimer;
  Profile? _currentProfile;
  Map<String, Profile> _profiles = {};
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

  /// Fetch new messages for all chat rooms
  Future<void> _fetchNewMessages() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      for (final chatRoom in _chatRooms) {
        await _fetchMessagesForChatRoom(chatRoom.id);
      }
    } catch (e) {
      // Silently handle errors to avoid disrupting UI
      print('Error fetching messages: $e');
    }
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
          // Found by content match but ID differs - update the local message with server ID and timestamp
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
        } else {
          _debugLog('Message already exists locally: ID=${messageRead.id}');
        }
      }

      // Process invitation response messages to update invitation statuses
      if (newMessages.isNotEmpty) {
        for (final newMessage in newMessages) {
          if (newMessage.messageType == MessageType.invitationResponse &&
              newMessage.invitationId != null) {
            // This is a response to an invitation
            final invitationId = newMessage.invitationId!;
            final responseStatus = newMessage.text.contains('accepted')
                ? 'accepted'
                : newMessage.text.contains('declined')
                ? 'declined'
                : 'pending';

            _debugLog(
              'Processing invitation response: invitationId=$invitationId, status=$responseStatus',
            );

            // Find all messages in chat room (current + new)
            final allMessages = [...currentMessages, ...newMessages];

            // Find the invitation message with matching invitationId
            for (int i = 0; i < allMessages.length; i++) {
              final message = allMessages[i];
              if (message.messageType == MessageType.invitation &&
                  message.invitationId == invitationId) {
                // Update the invitation message's status
                if (message.invitationData != null) {
                  final updatedInvitationMessage = message.copyWith(
                    invitationData: {
                      ...message.invitationData!,
                      'status': responseStatus,
                    },
                  );

                  // Update in the appropriate list (currentMessages or newMessages)
                  if (i < currentMessages.length) {
                    currentMessages[i] = updatedInvitationMessage;
                  } else {
                    newMessages[i - currentMessages.length] =
                        updatedInvitationMessage;
                  }

                  _debugLog(
                    'Updated invitation message ${message.id} status to $responseStatus',
                  );
                }
                break; // Found and updated the matching invitation
              }
            }
          }
        }
      }

      if (newMessages.isNotEmpty) {
        // Sort all messages by timestamp
        final allMessages = [...currentMessages, ...newMessages];
        allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        _chatRooms[chatRoomIndex] = _chatRooms[chatRoomIndex].copyWith(
          messages: allMessages,
        );

        _lastMessageFetch[chatRoomId] = DateTime.now();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching messages for chat room $chatRoomId: $e');
    }
  }

  // Get connected profiles
  List<Profile> get connectedProfiles {
    return _connections
        .map((conn) => _profiles[conn.toProfileId])
        .whereType<Profile>()
        .toList();
  }

  bool get hasUser => _currentProfile != null;

  // Get new friends (nearby peers who are not yet connections)
  List<Peer> get newFriends {
    final connectionIds = _connections.map((c) => c.toProfileId).toSet();
    final filtered = _nearbyPeers
        .where((p) => !connectionIds.contains(p.id))
        .toList();
    // Sort by match score (highest first)
    filtered.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return filtered;
  }

  // Get your connections as peers
  List<Peer> get yourConnections {
    final connectionIds = _connections.map((c) => c.toProfileId).toSet();
    final filtered = _nearbyPeers
        .where((p) => connectionIds.contains(p.id))
        .toList();
    // Sort by match score (highest first)
    filtered.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return filtered;
  }

  // Deprecated - kept for backward compatibility
  List<Peer> get peersWantToEat =>
      _nearbyPeers.where((p) => p.wantsToEat).toList();

  // Deprecated - kept for backward compatibility
  List<Peer> get peersNotWantToEat =>
      _nearbyPeers.where((p) => !p.wantsToEat).toList();

  // Get sent invitations
  List<Invitation> get sentInvitations =>
      _invitations.where((i) => i.sentByMe).toList();

  // Get received invitations (only pending)
  List<Invitation> get receivedInvitations =>
      _invitations.where((i) => !i.sentByMe && i.isPending).toList();

  // Get accepted invitations (not yet name card collected)
  List<Invitation> get acceptedInvitations =>
      _invitations.where((i) => i.isAccepted && !i.nameCardCollected).toList();

  // Get pending invitations
  List<Invitation> get pendingInvitations =>
      _invitations.where((i) => i.isPending).toList();

  /// Get chat room by peer ID
  ChatRoom? getChatRoomByPeerId(String peerId) {
    final currentUserId = _currentProfile?.id ?? '';
    if (currentUserId.isEmpty) return null;

    try {
      return _chatRooms.firstWhere(
        (cr) => cr.containsUser(currentUserId) && cr.containsUser(peerId),
      );
    } catch (e) {
      return null;
    }
  }

  /// Refresh messages for a specific chat room
  Future<void> refreshChatRoomMessages(String chatRoomId) async {
    await _fetchMessagesForChatRoom(chatRoomId);
  }

  /// Load current profile from persistent storage and sync with API
  Future<void> loadUserProfile() async {
    try {
      // Initialize services first
      _initializeServices();

      final prefs = await SharedPreferences.getInstance();

      // Load API user ID first
      _apiUserId = prefs.getString(_keyApiUserId);

      final profileJson = prefs.getString(_keyCurrentProfile);

      if (profileJson != null) {
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        _currentProfile = Profile.fromJson(profileMap);

        // If we have an API user ID, try to sync the latest profile from backend
        if (_apiUserId != null) {
          try {
            final apiUserIdInt = int.parse(_apiUserId!);
            final apiUserRead = await _apiService.getUser(apiUserIdInt);
            final apiProfile = _apiService.userReadToProfile(apiUserRead);
            _currentProfile = apiProfile;
            // Update local cache with latest data
            await _persistCurrentProfile();
          } catch (e) {
            debugPrint('Error syncing profile from API: $e');
            // Continue with local cached profile if API fails
          }
        }
      }

      // Load connections
      final connectionsJson = prefs.getString(_keyConnections);
      if (connectionsJson != null) {
        final connectionsList = jsonDecode(connectionsJson) as List;
        _connections = connectionsList
            .map((json) => Connection.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Load profiles
      final profilesJson = prefs.getString(_keyProfiles);
      if (profilesJson != null) {
        final profilesMap = jsonDecode(profilesJson) as Map<String, dynamic>;
        _profiles = profilesMap.map(
          (key, value) =>
              MapEntry(key, Profile.fromJson(value as Map<String, dynamic>)),
        );
      }

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

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  /// Load activities from API
  Future<void> _loadActivitiesFromApi() async {
    try {
      if (_apiUserId == null) {
        _debugLog('Cannot load activities from API: no API user ID');
        return;
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
      // Continue with local activities if API fails
    }
  }

  /// Save current profile to persistent storage
  Future<void> _persistCurrentProfile() async {
    try {
      if (_currentProfile == null) return;

      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(_currentProfile!.toJson());
      await prefs.setString(_keyCurrentProfile, profileJson);
    } catch (e) {
      debugPrint('Error saving current profile: $e');
    }
  }

  /// Persist connections
  Future<void> _persistConnections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final connectionsJson = jsonEncode(
        _connections.map((c) => c.toJson()).toList(),
      );
      await prefs.setString(_keyConnections, connectionsJson);
    } catch (e) {
      debugPrint('Error saving connections: $e');
    }
  }

  /// Persist profiles cache
  Future<void> _persistProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = jsonEncode(
        _profiles.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(_keyProfiles, profilesJson);
    } catch (e) {
      debugPrint('Error saving profiles: $e');
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
    }
  }

  /// Clear persisted data
  Future<void> _clearPersistedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCurrentProfile);
      await prefs.remove(_keyConnections);
      await prefs.remove(_keyProfiles);
      await prefs.remove(_keyApiUserId);
    } catch (e) {
      debugPrint('Error clearing profile data: $e');
    }
  }

  /// Save user name (registration step) - creates user in API
  Future<void> saveUserName(String userName) async {
    try {
      // Create a temporary profile for the API call
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

      // Persist both profile and API user ID
      await _persistCurrentProfile();
      await _persistApiUserId();

      // Start location tracking for the new user
      _startLocationTracking();

      // Start invitation polling for the new user
      startInvitationPolling();

      notifyListeners();
    } catch (e) {
      debugPrint('Error creating user in API: $e');
      throw Exception('Failed to create user: $e');
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

    // Try to sync with API if we have an API user ID and not skipping sync
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
        // Continue with local update if API fails
      }
    }

    await _persistCurrentProfile();
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
        // Continue with local update if API fails
      }
    }

    await _persistCurrentProfile();
    notifyListeners();
  }

  /// Clear all data (for logout)
  Future<void> clearProfile() async {
    _currentProfile = null;
    _profiles = {};
    _connections = [];
    _nearbyPeers = [];
    _invitations = [];
    _chatRooms = [];
    _activities = [];
    _selectedPeer = null;
    _selectedActivityId = null;
    _apiUserId = null;

    // Stop location tracking when user logs out
    _locationService.stopLocationTracking();

    // Stop invitation polling when user logs out
    stopInvitationPolling();

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
  void deleteActivity(String activityId) {
    _activities.removeWhere((a) => a.id == activityId);
    if (_selectedActivityId == activityId) {
      _selectedActivityId = null;
    }
    notifyListeners();
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

  /// Create or get the search activity (removes duplicates)
  Future<Activity> createOrGetSearchActivity() async {
    const searchActivityName = 'Searching for peers to eat';

    // Check if we already have a search activity from the server
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
      return [];
    }

    try {
      // Get current user location
      final currentPosition = await _locationService.getCurrentLocation();
      if (currentPosition == null) {
        _debugLog('Cannot search for peers: unable to get current location');
        // Fall back to mock data if location unavailable
        return await _fallbackToMockPeers();
      }

      // Update current user's location
      final userId = int.parse(_apiUserId!);
      await _locationService.updateLocation(userId);

      // Search for nearby users using the new API endpoint
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
      // Fall back to mock data on API failure
      return await _fallbackToMockPeers();
    }
  }

  /// Fallback to mock peers when API/location services fail
  Future<List<Peer>> _fallbackToMockPeers() async {
    _debugLog('Falling back to mock peers');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final mockPeers = _generateMockPeers();
    _nearbyPeers = mockPeers;
    notifyListeners();
    return mockPeers;
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

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[StorageService] $message');
    }
  }

  /// Generate mock peers for demonstration
  List<Peer> _generateMockPeers() {
    if (_currentProfile == null) return [];

    final peers = [
      Peer(
        id: '1',
        name: 'Alex Johnson',
        school: _currentProfile!.school ?? 'MIT',
        major: _currentProfile!.major ?? 'Computer Science',
        interests: 'Machine Learning, Hiking, Photography',
        background: 'Worked at Google for 2 years, now pursuing Masters',
        distance: 0.5,
        wantsToEat: true,
        profileImageUrl: 'https://picsum.photos/seed/alex/200',
      ),
      Peer(
        id: '2',
        name: 'Sarah Chen',
        school: _currentProfile!.school ?? 'Stanford',
        major: 'Electrical Engineering',
        interests: 'Robotics, Music, Cooking',
        background: 'Undergraduate student interested in AI research',
        distance: 1.2,
        wantsToEat: true,
        profileImageUrl: 'https://picsum.photos/seed/sarah/200',
      ),
      Peer(
        id: '3',
        name: 'Michael Brown',
        school: 'UC Berkeley',
        major: _currentProfile!.major ?? 'Computer Science',
        interests: 'Web Development, Gaming, Basketball',
        background: 'Full-stack developer, love building apps',
        distance: 0.8,
        wantsToEat: false,
        profileImageUrl: 'https://picsum.photos/seed/michael/200',
      ),
      Peer(
        id: '4',
        name: 'Emily Davis',
        school: _currentProfile!.school ?? 'Harvard',
        major: 'Data Science',
        interests: 'Data Analysis, Running, Reading',
        background: 'Data analyst looking to network with tech professionals',
        distance: 2.1,
        wantsToEat: true,
        profileImageUrl: 'https://picsum.photos/seed/emily/200',
      ),
      Peer(
        id: '5',
        name: 'David Wilson',
        school: _currentProfile!.school ?? 'MIT',
        major: 'Business',
        interests: 'Entrepreneurship, Travel, Coffee',
        background: 'MBA student, formerly worked at startup',
        distance: 1.5,
        wantsToEat: false,
        profileImageUrl: 'https://picsum.photos/seed/david/200',
      ),
      Peer(
        id: '6',
        name: 'Lisa Martinez',
        school: 'Stanford',
        major: _currentProfile!.major ?? 'Computer Science',
        interests: 'UI/UX Design, Art, Yoga',
        background: 'Product designer passionate about user experience',
        distance: 0.3,
        wantsToEat: true,
        profileImageUrl: 'https://picsum.photos/seed/lisa/200',
      ),
    ];

    // Calculate match scores and sort by distance
    return peers
        .map(
          (peer) => peer.copyWith(
            matchScore: Peer.calculateMatchScore(_currentProfile!, peer),
          ),
        )
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  /// Generate mock network profiles database with connections
  Map<String, dynamic> generateMockNetworkDatabase() {
    // Define mock profiles with varied friend counts (1-6 friends per person)
    final mockProfiles = {
      'mock_0': {
        'id': 'mock_0',
        'name': 'Alex Chen',
        'school': 'MIT',
        'major': 'Computer Science',
        'interests': 'AI, Hiking',
        'imageUrl': 'https://picsum.photos/seed/alexchen/200',
      },
      'mock_1': {
        'id': 'mock_1',
        'name': 'Sarah Kim',
        'school': 'Stanford',
        'major': 'Engineering',
        'interests': 'Robotics, Music',
        'imageUrl': 'https://picsum.photos/seed/sarahkim/200',
      },
      'mock_2': {
        'id': 'mock_2',
        'name': 'Mike Johnson',
        'school': 'Berkeley',
        'major': 'Business',
        'interests': 'Startups, Sports',
        'imageUrl': 'https://picsum.photos/seed/mikej/200',
      },
      'mock_3': {
        'id': 'mock_3',
        'name': 'Emma Davis',
        'school': 'Harvard',
        'major': 'Biology',
        'interests': 'Research, Art',
        'imageUrl': 'https://picsum.photos/seed/emmad/200',
      },
      'mock_4': {
        'id': 'mock_4',
        'name': 'James Wilson',
        'school': 'Yale',
        'major': 'Economics',
        'interests': 'Finance, Travel',
        'imageUrl': 'https://picsum.photos/seed/jamesw/200',
      },
      'mock_5': {
        'id': 'mock_5',
        'name': 'Lisa Martinez',
        'school': 'Princeton',
        'major': 'Psychology',
        'interests': 'Social Science, Photography',
        'imageUrl': 'https://picsum.photos/seed/lisam/200',
      },
      'mock_6': {
        'id': 'mock_6',
        'name': 'Tom Anderson',
        'school': 'Columbia',
        'major': 'Physics',
        'interests': 'Space, Gaming',
        'imageUrl': 'https://picsum.photos/seed/toma/200',
      },
      'mock_7': {
        'id': 'mock_7',
        'name': 'Nina Patel',
        'school': 'Cornell',
        'major': 'Architecture',
        'interests': 'Design, Cooking',
        'imageUrl': 'https://picsum.photos/seed/ninap/200',
      },
      'mock_8': {
        'id': 'mock_8',
        'name': 'David Lee',
        'school': 'Duke',
        'major': 'Mathematics',
        'interests': 'Chess, Programming',
        'imageUrl': 'https://picsum.photos/seed/davidl/200',
      },
      'mock_9': {
        'id': 'mock_9',
        'name': 'Rachel Green',
        'school': 'Brown',
        'major': 'Literature',
        'interests': 'Writing, Theatre',
        'imageUrl': 'https://picsum.photos/seed/rachelg/200',
      },
      'mock_10': {
        'id': 'mock_10',
        'name': 'Kevin Wang',
        'school': 'Caltech',
        'major': 'Chemistry',
        'interests': 'Lab Work, Soccer',
        'imageUrl': 'https://picsum.photos/seed/kevinw/200',
      },
      'mock_11': {
        'id': 'mock_11',
        'name': 'Sophia Torres',
        'school': 'Northwestern',
        'major': 'Journalism',
        'interests': 'Media, Film',
        'imageUrl': 'https://picsum.photos/seed/sophiat/200',
      },
      'mock_12': {
        'id': 'mock_12',
        'name': 'Ryan Cooper',
        'school': 'UPenn',
        'major': 'Medicine',
        'interests': 'Healthcare, Running',
        'imageUrl': 'https://picsum.photos/seed/ryanc/200',
      },
      'mock_13': {
        'id': 'mock_13',
        'name': 'Maya Patel',
        'school': 'Dartmouth',
        'major': 'Environmental Science',
        'interests': 'Sustainability, Yoga',
        'imageUrl': 'https://picsum.photos/seed/mayap/200',
      },
      'mock_14': {
        'id': 'mock_14',
        'name': 'Chris Martin',
        'school': 'Rice',
        'major': 'Philosophy',
        'interests': 'Ethics, Reading',
        'imageUrl': 'https://picsum.photos/seed/chrism/200',
      },
    };

    // Define connections based on the friend lists
    // Helper to avoid duplicate connections
    final addedConnections = <String>{};
    final mockConnections = <Map<String, String>>[];

    void addConnection(String from, String to) {
      final key1 = '$from-$to';
      final key2 = '$to-$from';
      if (!addedConnections.contains(key1) &&
          !addedConnections.contains(key2)) {
        mockConnections.add({'from': from, 'to': to});
        addedConnections.add(key1);
      }
    }

    // mock_0 (Alex Chen): friends with you, mock_1, mock_2, mock_5, mock_8 (5 friends)
    addConnection('mock_0', 'mock_1');
    addConnection('mock_0', 'mock_2');
    addConnection('mock_0', 'mock_5');
    addConnection('mock_0', 'mock_8');

    // mock_1 (Sarah Kim): friends with you, mock_0, mock_3, mock_9 (4 friends)
    addConnection('mock_1', 'mock_3');
    addConnection('mock_1', 'mock_9');

    // mock_2 (Mike Johnson): friends with mock_0, mock_4, mock_11 (3 friends)
    addConnection('mock_2', 'mock_4');
    addConnection('mock_2', 'mock_11');

    // mock_3 (Emma Davis): friends with you, mock_1, mock_5, mock_6, mock_10 (5 friends)
    addConnection('mock_3', 'mock_5');
    addConnection('mock_3', 'mock_6');
    addConnection('mock_3', 'mock_10');

    // mock_4 (James Wilson): friends with mock_2, mock_6, mock_12 (3 friends)
    addConnection('mock_4', 'mock_6');
    addConnection('mock_4', 'mock_12');

    // mock_5 (Lisa Martinez): friends with you, mock_0, mock_3, mock_7, mock_9, mock_13 (6 friends - popular!)
    addConnection('mock_5', 'mock_7');
    addConnection('mock_5', 'mock_9');
    addConnection('mock_5', 'mock_13');

    // mock_6 (Tom Anderson): friends with mock_3, mock_4 (2 friends)
    // Already connected above

    // mock_7 (Nina Patel): friends with you, mock_5, mock_11 (3 friends)
    addConnection('mock_7', 'mock_11');

    // mock_8 (David Lee): friends with mock_0, mock_10 (2 friends)
    addConnection('mock_8', 'mock_10');

    // mock_9 (Rachel Green): friends with mock_1, mock_5, mock_12, mock_13 (4 friends)
    addConnection('mock_9', 'mock_12');
    addConnection('mock_9', 'mock_13');

    // mock_10 (Kevin Wang): friends with mock_3, mock_8 (2 friends)
    // Already connected above

    // mock_11 (Sophia Torres): friends with mock_2, mock_7, mock_13 (3 friends)
    addConnection('mock_11', 'mock_13');

    // mock_12 (Ryan Cooper): friends with mock_4, mock_9 (2 friends)
    // Already connected above

    // mock_13 (Maya Patel): friends with you, mock_5, mock_9, mock_11 (4 friends)
    // Already connected above

    // mock_14 (Chris Martin): friends with mock_0 (1 friend - introvert!)
    addConnection('mock_14', 'mock_0');

    return {'profiles': mockProfiles, 'connections': mockConnections};
  }

  /// Get mock network nodes for a given connection profile ID
  Map<String, dynamic> getMockNetworkForConnection(String connectionProfileId) {
    final database = generateMockNetworkDatabase();
    final profiles = database['profiles'] as Map<String, dynamic>;
    final connections = database['connections'] as List<Map<String, String>>;

    // Find the key for this connection in our mock database
    String? connectionKey;
    for (final entry in profiles.entries) {
      if (entry.value['id'] == connectionProfileId) {
        connectionKey = entry.key;
        break;
      }
    }

    if (connectionKey == null) {
      return {'directProfiles': [], 'indirectProfiles': []};
    }

    // Get direct connections
    final directConnectionKeys = <String>{};
    for (final conn in connections) {
      if (conn['from'] == connectionKey) {
        directConnectionKeys.add(conn['to']!);
      } else if (conn['to'] == connectionKey) {
        directConnectionKeys.add(conn['from']!);
      }
    }

    // Get indirect connections (friends of friends)
    final indirectConnectionKeys = <String>{};
    for (final directKey in directConnectionKeys) {
      for (final conn in connections) {
        if (conn['from'] == directKey && conn['to'] != connectionKey) {
          indirectConnectionKeys.add(conn['to']!);
        } else if (conn['to'] == directKey && conn['from'] != connectionKey) {
          indirectConnectionKeys.add(conn['from']!);
        }
      }
    }

    // Remove direct connections from indirect
    indirectConnectionKeys.removeAll(directConnectionKeys);

    // Build result
    final directProfiles = directConnectionKeys
        .map((key) => profiles[key] as Map<String, dynamic>)
        .toList();

    final indirectProfiles = indirectConnectionKeys
        .map(
          (key) => {
            ...profiles[key] as Map<String, dynamic>,
            'connectedThrough': directConnectionKeys.firstWhere(
              (directKey) => connections.any(
                (c) =>
                    (c['from'] == directKey && c['to'] == key) ||
                    (c['to'] == directKey && c['from'] == key),
              ),
            ),
          },
        )
        .toList();

    return {
      'directProfiles': directProfiles,
      'indirectProfiles': indirectProfiles,
      'allConnections': connections,
    };
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
      // Don't throw - keep existing local invitations if fetch fails
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
      // Continue with local update even if API fails
    }

    // Accept this invitation locally
    _invitations[index] = _invitations[index].copyWith(
      status: InvitationStatus.accepted,
    );

    // Auto-decline all OTHER received invitations for the same activity
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

    // Delete all unanswered SENT invitations for the same activity
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
      // Continue with local update even if API fails
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
      throw e; // Re-throw so UI can handle
    }
  }

  /// Mock: Accept a sent invitation (simulate peer accepting)
  Future<void> mockAcceptSentInvitation(String invitationId) async {
    final index = _invitations.indexWhere((i) => i.id == invitationId);
    if (index == -1 || !_invitations[index].sentByMe) return;

    final acceptedInvitation = _invitations[index];
    final activityId = acceptedInvitation.activityId;

    // Mark this invitation as accepted
    _invitations[index] = _invitations[index].copyWith(
      status: InvitationStatus.accepted,
    );

    // Auto-decline all OTHER received invitations for the same activity
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

    // Delete all other unanswered SENT invitations for the same activity
    _invitations.removeWhere(
      (inv) =>
          inv.activityId == activityId &&
          inv.sentByMe &&
          inv.isPending &&
          inv.id != invitationId,
    );

    notifyListeners();

    // REMOVED: _createChatRoom(acceptedInvitation) - now handled by backend
  }

  /// Mock: Decline a sent invitation (simulate peer declining)
  Future<void> mockDeclineSentInvitation(String invitationId) async {
    final index = _invitations.indexWhere((i) => i.id == invitationId);
    if (index == -1 || !_invitations[index].sentByMe) return;

    _invitations[index] = _invitations[index].copyWith(
      status: InvitationStatus.declined,
    );
    notifyListeners();
  }

  /// Mock: Simulate receiving an invitation from a peer
  Future<void> mockReceiveInvitation() async {
    // Require activity to be selected
    if (_selectedActivityId == null) {
      throw Exception('No activity selected. Please select an activity first.');
    }

    // Get a random peer from nearby peers, or create a full mock peer
    Peer mockPeer;

    if (_nearbyPeers.isNotEmpty) {
      mockPeer = _nearbyPeers[DateTime.now().millisecond % _nearbyPeers.length];
    } else {
      // Create a full mock peer with complete profile
      final mockNames = [
        'Jessica Lee',
        'Ryan Martinez',
        'Olivia Taylor',
        'James Anderson',
        'Emma White',
      ];
      final mockSchools = ['MIT', 'Stanford', 'Harvard', 'UC Berkeley', 'Yale'];
      final mockMajors = [
        'Computer Science',
        'Engineering',
        'Business',
        'Biology',
        'Psychology',
      ];
      final mockInterestsOptions = [
        'Coding, Gaming, Music',
        'Sports, Travel, Photography',
        'Reading, Art, Cooking',
        'Hiking, Yoga, Coffee',
        'Movies, Dancing, Food',
      ];
      final mockBackgrounds = [
        'Senior looking to expand my network before graduation',
        'Transfer student interested in meeting new people',
        'Graduate student passionate about collaboration',
        'Undergrad exploring different career paths',
        'International student wanting to connect with locals',
      ];

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomIndex = timestamp % mockNames.length;

      mockPeer = Peer(
        id: 'mock_$timestamp',
        name: mockNames[randomIndex],
        school: mockSchools[randomIndex],
        major: mockMajors[randomIndex],
        interests: mockInterestsOptions[randomIndex],
        background: mockBackgrounds[randomIndex],
        distance: 0.5 + (randomIndex * 0.3),
        wantsToEat: true,
        matchScore: 0.6 + (randomIndex * 0.05),
      );

      // Add the mock peer to nearby peers so they appear in the network
      _nearbyPeers.add(mockPeer);
    }

    final restaurants = [
      'The Corner Bistro',
      'Sushi Paradise',
      'Pizza Heaven',
      'Burger Joint',
      'Taco Fiesta',
      'Thai Garden',
      'Mediterranean Grill',
    ];

    final restaurant =
        restaurants[DateTime.now().millisecond % restaurants.length];

    // Generate ice breakers for the mock peer (as if they sent them)
    final iceBreakers = _generateIceBreakers(mockPeer);

    final invitation = Invitation(
      id: 'received_${DateTime.now().millisecondsSinceEpoch}',
      peerId: mockPeer.id,
      peerName: mockPeer.name,
      restaurant: restaurant,
      activityId: _selectedActivityId!,
      createdAt: DateTime.now(),
      sentByMe: false, // This is a received invitation
      status: InvitationStatus.pending,
      iceBreakers: iceBreakers, // Include ice breakers from the mock peer
    );

    _invitations.add(invitation);
    notifyListeners();
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
        // Handle send error - could remove the message or mark as failed
        print('Error sending message: $e');
        // For now, we'll keep the message locally and let polling sync it
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
    }
  }

  /// Refresh all chat rooms and messages
  Future<void> refreshChatRooms() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      await _fetchChatRooms();
    } catch (e) {
      print('Error refreshing chat rooms: $e');
    }
  }

  /// Refresh invitations from server
  Future<void> refreshInvitations() async {
    if (_currentProfile == null || _apiUserId == null) return;

    try {
      await fetchInvitations();
    } catch (e) {
      print('Error refreshing invitations: $e');
    }
  }

  /// Get peer by ID
  Peer? getPeerById(String peerId) {
    try {
      return _nearbyPeers.firstWhere((p) => p.id == peerId);
    } catch (e) {
      return null;
    }
  }

  /// Create connection from peer
  Future<void> collectNameCard(String invitationId) async {
    if (_currentProfile == null) return;

    try {
      // Use new message-based name card collection API
      final result = await _apiService.collectNameCardFromMessage(invitationId);
      _debugLog('Name card collected via API: $result');
    } catch (e) {
      _debugLog('Failed to collect name card via API: $e');
      // Continue with local implementation even if API fails
    }

    final invitation = _invitations.firstWhere((i) => i.id == invitationId);
    final peer = getPeerById(invitation.peerId);

    if (peer == null) return;

    // Check if already connected
    final alreadyConnected = _connections.any((c) => c.toProfileId == peer.id);
    if (alreadyConnected) return;

    // Create or get profile for the peer
    if (!_profiles.containsKey(peer.id)) {
      _profiles[peer.id] = Profile(
        id: peer.id,
        userName: peer.name,
        school: peer.school,
        major: peer.major,
        interests: peer.interests,
        background: peer.background,
        profileImagePath: null,
      );
    }

    // Create connection
    final connection = Connection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromProfileId: _currentProfile!.id,
      toProfileId: peer.id,
      restaurant: invitation.restaurant,
      collectedAt: DateTime.now(),
      status: ConnectionStatus.accepted,
    );

    _connections.add(connection);

    // Mark invitation as name card collected
    final invIndex = _invitations.indexWhere((i) => i.id == invitationId);
    if (invIndex != -1) {
      _invitations[invIndex] = _invitations[invIndex].copyWith(
        nameCardCollected: true,
      );
    }

    await _persistConnections();
    await _persistProfiles();
    notifyListeners();
  }

  /// Get profile by ID (fetches from API if not found locally)
  Future<Profile?> getProfileById(String id) async {
    if (id == _currentProfile?.id) return _currentProfile;

    // Check local cache first
    if (_profiles.containsKey(id)) {
      return _profiles[id];
    }

    // Fetch from API if not found locally
    try {
      final userIdInt = int.tryParse(id);
      if (userIdInt == null) {
        _debugLog('Invalid user ID format: $id');
        return null;
      }

      final userRead = await _apiService.getUser(userIdInt);
      final profile = _apiService.userReadToProfile(userRead);

      // Cache the profile locally
      _profiles[id] = profile;
      await _persistProfiles();
      notifyListeners();

      return profile;
    } catch (e) {
      _debugLog('Error fetching profile for user $id: $e');
      return null;
    }
  }

  /// Mark chat as opened for the invitation
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
  Future<void> markNotGoodMatch(String invitationId) async {
    await declineInvitation(invitationId);

    // Remove from chat rooms
    final invitation = _invitations.firstWhere((i) => i.id == invitationId);
    final currentUserId = _currentProfile?.id ?? '';
    _chatRooms.removeWhere(
      (c) => c.containsUser(currentUserId) && c.containsUser(invitation.peerId),
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
    super.dispose();
    _debugLog('StorageService disposed');
  }
}
