import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import '../models/profile.dart';
import '../models/peer.dart';
import '../models/meeting.dart';
import '../models/activity.dart';

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
    throw lastException ??
        Exception('Operation failed after $_maxRetries attempts');
  }

  Future<UserRead> createUser(UserCreate user) async {
    final response = await _executeWithRetry(
      () => _api.createUserUsersPost(userCreate: user),
      'Create User',
    );
    return response.data!;
  }

  Future<UserRead> updateUser(int userId, UserUpdate userUpdate) async {
    final response = await _executeWithRetry(
      () =>
          _api.updateUserUsersUserIdPut(userId: userId, userUpdate: userUpdate),
      'Update User',
    );
    return response.data!;
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
      final filtered = response.data!
          .where(
            (u) =>
                u.school?.toLowerCase().contains(school.toLowerCase()) == true,
          )
          .toList();
      users = BuiltList<UserRead>(filtered);
    }

    if (major != null && major.isNotEmpty) {
      users = users.rebuild((b) => b.clear());
      final filtered = response.data!
          .where(
            (u) => u.major?.toLowerCase().contains(major.toLowerCase()) == true,
          )
          .toList();
      users = BuiltList<UserRead>(filtered);
    }

    if (interests != null && interests.isNotEmpty) {
      users = users.rebuild((b) => b.clear());
      final filtered = response.data!
          .where(
            (u) =>
                u.interests?.toLowerCase().contains(interests.toLowerCase()) ==
                true,
          )
          .toList();
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
      () => _api.getBatchLocationsLocationsBatchGet(userIds: userIds.join(',')),
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
      profileImagePath: (user.avatarUrl?.isEmpty ?? true)
          ? null
          : user.avatarUrl,
    );
  }

  UserCreate profileToUserCreate(Profile profile) {
    return UserCreate(
      (b) => b
        ..username = profile.userName
        ..school = profile.school ?? ''
        ..major = profile.major ?? ''
        ..interests = profile.interests ?? ''
        ..bio = profile.background ?? ''
        ..avatarUrl = profile.profileImagePath ?? '',
    );
  }

  UserUpdate profileToUserUpdate(Profile profile) {
    return UserUpdate(
      (b) => b
        ..username = profile.userName
        ..school = profile.school ?? ''
        ..major = profile.major ?? ''
        ..interests = profile.interests ?? ''
        ..bio = profile.background ?? ''
        ..avatarUrl = profile.profileImagePath,
    );
  }

  Peer userReadToPeer(
    UserRead user,
    LocationRead? location, {
    double? distance,
  }) {
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

  // Invitation model converters
  InvitationCreate invitationToInvitationCreate(Invitation invitation, int senderId, int receiverId) {
    return InvitationCreate((b) => b
      ..senderId = senderId
      ..receiverId = receiverId
      ..activityId = invitation.activityId
      ..restaurant = invitation.restaurant
      ..status = invitation.status.name
      ..iceBreakers = invitation.iceBreakers.map((ib) => ib.question).join('|')
      ..sentByMe = invitation.sentByMe
      ..nameCardCollected = invitation.nameCardCollected
      ..chatOpened = invitation.chatOpened);
  }

  Invitation invitationReadToInvitation(InvitationRead invitationRead) {
    return Invitation(
      id: invitationRead.id,
      peerId: invitationRead.senderId.toString(),
      peerName: '', // Will be filled by caller
      restaurant: invitationRead.restaurant,
      activityId: invitationRead.activityId,
      createdAt: invitationRead.createdAt,
      sentByMe: invitationRead.sentByMe ?? false,
      status: _parseInvitationStatus(invitationRead.status),
      iceBreakers: _parseIceBreakers(invitationRead.iceBreakers),
      nameCardCollected: invitationRead.nameCardCollected ?? false,
      chatOpened: invitationRead.chatOpened ?? false,
    );
  }

  InvitationStatus _parseInvitationStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return InvitationStatus.accepted;
      case 'declined':
        return InvitationStatus.declined;
      case 'pending':
      default:
        return InvitationStatus.pending;
    }
  }

  List<IceBreaker> _parseIceBreakers(String? iceBreakersStr) {
    if (iceBreakersStr == null || iceBreakersStr.isEmpty) {
      return [];
    }
    
    final questions = iceBreakersStr.split('|');
    return questions.map((question) => IceBreaker(
      question: question,
      answer: 'Ice breaker question',
    )).toList();
  }

  // Chat model converters
  ChatRoomBase chatRoomToChatRoomBase(ChatRoom chatRoom) {
    return ChatRoomBase((b) => b
      ..peerId = int.tryParse(chatRoom.peerId) ?? 0
      ..peerName = chatRoom.peerName
      ..restaurant = chatRoom.restaurant);
  }

  ChatRoom chatRoomReadToChatRoom(ChatRoomRead chatRoomRead) {
    return ChatRoom(
      id: chatRoomRead.id,
      peerId: chatRoomRead.peerId.toString(),
      peerName: chatRoomRead.peerName,
      restaurant: chatRoomRead.restaurant,
      createdAt: chatRoomRead.createdAt,
    );
  }

  ChatMessageCreateRequest chatMessageToCreateRequest(String text, int senderId) {
    return ChatMessageCreateRequest((b) => b
      ..senderId = senderId
      ..text = text
      ..isMine = true);
  }

  ChatMessage chatMessageReadToChatMessage(ChatMessageRead messageRead, bool isMine) {
    return ChatMessage(
      id: messageRead.id,
      text: messageRead.text,
      isMine: isMine,
      timestamp: messageRead.timestamp,
    );
  }

  // Activity model converters
  ActivityCreate activityToActivityCreate(Activity activity) {
    return ActivityCreate((b) => b
      ..name = activity.name
      ..description = activity.description);
  }

  Activity activityReadToActivity(ActivityRead activityRead) {
    return Activity(
      id: activityRead.id,
      name: activityRead.name,
      description: activityRead.description,
      createdAt: activityRead.createdAt,
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() *
            lat2.toRadians().cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();

    final double c = 2 * a.sqrt().asin();

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Upload avatar image for a user
  Future<String?> uploadAvatar(int userId, dynamic imageFile) async {
    try {
      _debugLog('Starting avatar upload for user $userId');

      MultipartFile multipartFile;

      if (kIsWeb) {
        // Handle web platform - expect Uint8List
        if (imageFile is Uint8List) {
          multipartFile = MultipartFile.fromBytes(
            imageFile,
            filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.png',
          );
        } else {
          throw Exception('Invalid image file type for web platform');
        }
      } else {
        // Handle mobile platform - expect File
        if (imageFile is File) {
          multipartFile = await MultipartFile.fromFile(
            imageFile.path,
            filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.png',
          );
        } else {
          throw Exception('Invalid image file type for mobile platform');
        }
      }

      final response = await _executeWithRetry(
        () => _api.uploadAvatarUsersUserIdAvatarPost(
          userId: userId,
          file: multipartFile,
        ),
        'Upload Avatar',
      );

      // Extract avatar URL from response
      final responseData = response.data;
      _debugLog('Avatar upload response type: ${responseData.runtimeType}');
      _debugLog('Avatar upload response data: $responseData');

      if (responseData != null && responseData.containsKey('avatar_url')) {
        final avatarUrlValue = responseData['avatar_url'];
        _debugLog('Avatar URL value type: ${avatarUrlValue.runtimeType}');
        _debugLog('Avatar URL value: $avatarUrlValue');

        String? avatarUrl;

        // Handle different response types
        if (avatarUrlValue.runtimeType == String) {
          avatarUrl = avatarUrlValue.toString();
        } else if (avatarUrlValue != null) {
          // Convert JsonObject to String
          avatarUrl = avatarUrlValue.toString();
        }

        _debugLog('Avatar uploaded successfully: $avatarUrl');
        return avatarUrl;
      }

      _debugLog('Avatar upload response missing avatar_url field');
      return null;
    } catch (e) {
      _debugLog('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Delete avatar for a user
  Future<bool> deleteAvatar(int userId) async {
    try {
      _debugLog('Deleting avatar for user $userId');

      final response = await _executeWithRetry(
        () => _api.deleteAvatarUsersUserIdAvatarDelete(userId: userId),
        'Delete Avatar',
      );

      // Check response for success indication
      if (response.data != null) {
        _debugLog('Avatar deleted successfully: ${response.data}');
        return true;
      } else {
        _debugLog('Avatar delete response was null or empty');
        return false;
      }
    } catch (e) {
      _debugLog('Error deleting avatar: $e');
      return false;
    }
  }

  // Invitation endpoints

  /// Create invitation
  Future<InvitationRead> createInvitation(InvitationCreate invitation) async {
    final response = await _executeWithRetry(
      () => _api.createInvitationInvitationsPost(invitationCreate: invitation),
      'Create Invitation',
    );
    return response.data!;
  }

  /// Get invitations for user
  Future<BuiltList<InvitationRead>> getInvitations(int userId) async {
    final response = await _executeWithRetry(
      () => _api.getInvitationsInvitationsGet(userId: userId),
      'Get Invitations',
    );
    return response.data!;
  }

  /// Accept invitation
  Future<InvitationRead> acceptInvitation(String invitationId) async {
    final response = await _executeWithRetry(
      () => _api.acceptInvitationInvitationsInvitationIdAcceptPut(invitationId: invitationId),
      'Accept Invitation',
    );
    return response.data!;
  }

  /// Decline invitation
  Future<InvitationRead> declineInvitation(String invitationId) async {
    final response = await _executeWithRetry(
      () => _api.declineInvitationInvitationsInvitationIdDeclinePut(invitationId: invitationId),
      'Decline Invitation',
    );
    return response.data!;
  }

  /// Collect name card
  Future<InvitationRead> collectNameCard(String invitationId) async {
    final response = await _executeWithRetry(
      () => _api.collectNameCardInvitationsInvitationIdCollectNameCardPut(invitationId: invitationId),
      'Collect Name Card',
    );
    return response.data!;
  }

  /// Mark chat opened
  Future<InvitationRead> markChatOpened(String invitationId) async {
    final response = await _executeWithRetry(
      () => _api.markChatOpenedInvitationsInvitationIdChatOpenedPut(invitationId: invitationId),
      'Mark Chat Opened',
    );
    return response.data!;
  }

  /// Mark not good match
  Future<InvitationRead> markNotGoodMatch(String invitationId) async {
    final response = await _executeWithRetry(
      () => _api.markNotGoodMatchInvitationsInvitationIdNotGoodMatchPut(invitationId: invitationId),
      'Mark Not Good Match',
    );
    return response.data!;
  }

  // Chat endpoints

  /// Create chat room
  Future<ChatRoomRead> createChatRoom(ChatRoomBase chatRoom) async {
    final response = await _executeWithRetry(
      () => _api.createChatroomChatroomsPost(chatRoomBase: chatRoom),
      'Create Chat Room',
    );
    return response.data!;
  }

  /// Get chat rooms for user
  Future<BuiltList<ChatRoomRead>> getChatRooms(int userId) async {
    final response = await _executeWithRetry(
      () => _api.getChatroomsChatroomsGet(userId: userId),
      'Get Chat Rooms',
    );
    return response.data!;
  }

  /// Get chat room by ID
  Future<ChatRoomRead> getChatRoom(String chatroomId) async {
    final response = await _executeWithRetry(
      () => _api.getChatroomChatroomsChatroomIdGet(chatroomId: chatroomId),
      'Get Chat Room',
    );
    return response.data!;
  }

  /// Send chat message
  Future<ChatMessageRead> sendChatMessage(String chatroomId, ChatMessageCreateRequest message) async {
    final response = await _executeWithRetry(
      () => _api.sendChatMessageChatroomsChatroomIdMessagesPost(chatroomId: chatroomId, chatMessageCreateRequest: message),
      'Send Chat Message',
    );
    return response.data!;
  }

  /// Get chat messages
  Future<BuiltList<ChatMessageRead>> getChatMessages(String chatroomId) async {
    final response = await _executeWithRetry(
      () => _api.getChatMessagesChatroomsChatroomIdMessagesGet(chatroomId: chatroomId),
      'Get Chat Messages',
    );
    return response.data!;
  }

  // Activity endpoints

  /// Create activity
  Future<ActivityRead> createActivity(ActivityCreate activity) async {
    final response = await _executeWithRetry(
      () => _api.createActivityActivitiesPost(activityCreate: activity),
      'Create Activity',
    );
    return response.data!;
  }

  /// Get activities
  Future<BuiltList<ActivityRead>> getActivities() async {
    final response = await _executeWithRetry(
      () => _api.getActivitiesActivitiesGet(),
      'Get Activities',
    );
    return response.data!;
  }

  /// Delete activity
  Future<void> deleteActivity(String activityId) async {
    await _executeWithRetry(
      () => _api.deleteActivityActivitiesActivityIdDelete(activityId: activityId),
      'Delete Activity',
    );
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
