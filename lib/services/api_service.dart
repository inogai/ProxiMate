import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';
import '../models/profile.dart';
import '../models/peer.dart';
import '../models/meeting.dart';
import '../models/activity.dart';

class ApiService {
  late UsersApi _usersApi;
  late LocationsApi _locationsApi;
  late ActivitiesApi _activitiesApi;
  late ChatroomsApi _chatroomsApi;
  late MessagesApi _messagesApi;
  late DefaultApi _defaultApi;
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
      _usersApi = openapi.getUsersApi();
      _locationsApi = openapi.getLocationsApi();
      _activitiesApi = openapi.getActivitiesApi();
      _chatroomsApi = openapi.getChatroomsApi();
      _messagesApi = openapi.getMessagesApi();
      _defaultApi = openapi.getDefaultApi();
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
      () => _usersApi.createUserApiV1UsersPost(userCreate: user),
      'Create User',
    );
    return response.data!;
  }

  Future<UserRead> getOrCreateUser(UserCreate user) async {
    final response = await _executeWithRetry(
      () =>
          _usersApi.getOrCreateUserApiV1UsersGetOrCreatePost(userCreate: user),
      'Get or Create User',
    );
    return response.data!;
  }

  Future<UserRead> updateUser(int userId, UserUpdate userUpdate) async {
    final response = await _executeWithRetry(
      () => _usersApi.updateUserApiV1UsersUserIdPut(
        userId: userId,
        userUpdate: userUpdate,
      ),
      'Update User',
    );
    return response.data!;
  }

  Future<UserRead> getUser(int userId) async {
    final response = await _executeWithRetry(
      () => _usersApi.getUserApiV1UsersUserIdGet(userId: userId),
      'Get User',
    );
    return response.data!;
  }

  Future<UserRead> getUserByUsername(String username) async {
    final response = await _executeWithRetry(
      () => _usersApi.getUserByUsernameApiV1UsersUsernameUsernameGet(
        username: username,
      ),
      'Get User by Username',
    );
    return response.data!;
  }

  Future<LocationRead> createLocation(LocationCreate location) async {
    final response = await _executeWithRetry(
      () => _locationsApi.createLocationApiV1LocationsPost(
        locationCreate: location,
      ),
      'Create Location',
    );
    return response.data!;
  }

  Future<BuiltList<LocationRead>> getUserLocations(int userId) async {
    final response = await _executeWithRetry(
      () => _locationsApi.getUserLocationHistoryApiV1LocationsUsersUserIdGet(
        userId: userId,
      ),
      'Get User Locations',
    );
    return response.data!;
  }

  Future<bool> checkHealth() async {
    try {
      await _executeWithRetry(
        () => _defaultApi.healthCheckApiV1HealthGet(),
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
      () => _usersApi.getUsersApiV1UsersGet(
        skip: offset ?? 0,
        limit: limit ?? 100,
      ),
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
      () => _locationsApi.findNearbyUsersApiV1LocationsNearbyUsersGet(
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
      () => _locationsApi.getBatchLocationsApiV1LocationsBatchGet(
        userIds: userIds.join(','),
      ),
      'Get Batch Locations',
    );
    return response.data!;
  }

  Profile userReadToProfile(UserRead user) {
    return Profile(
      id: user.id.toString(),
      userName: user.displayname,
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
        ..displayname = profile.userName
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
        ..displayname = profile.userName
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
      name: user.displayname,
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
      name: userWithDistance.displayname,
      school: userWithDistance.school ?? '',
      major: userWithDistance.major ?? '',
      interests: userWithDistance.interests ?? '',
      background: userWithDistance.bio ?? '',
      profileImageUrl: userWithDistance.avatarUrl,
      distance: userWithDistance.distanceKm?.toDouble() ?? 0.0,
    );
  }

  // Chat model converters
  ChatRoomCreateRequest chatRoomToChatRoomCreateRequest(ChatRoom chatRoom) {
    return ChatRoomCreateRequest(
      (b) => b
        ..user1Id = int.tryParse(chatRoom.user1Id) ?? 0
        ..user2Id = int.tryParse(chatRoom.user2Id) ?? 0
        ..restaurant = chatRoom.restaurant,
    );
  }

  ChatRoom chatRoomReadToChatRoom(ChatRoomRead chatRoomRead) {
    // Parse createdAt string to DateTime
    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(chatRoomRead.createdAt);
      // Assume the timestamp is in UTC and convert to local
      if (parsedCreatedAt.isUtc) {
        parsedCreatedAt = parsedCreatedAt.toLocal();
      }
    } catch (e) {
      // Fallback to current time if parsing fails
      parsedCreatedAt = DateTime.now();
      _debugLog(
        'Failed to parse createdAt: ${chatRoomRead.createdAt}, using current time',
      );
    }

    return ChatRoom(
      id: chatRoomRead.id,
      user1Id: chatRoomRead.user1Id.toString(),
      user2Id: chatRoomRead.user2Id.toString(),
      restaurant: chatRoomRead.restaurant,
      createdAt: parsedCreatedAt,
    );
  }

  // Chat message creation is now handled directly in sendChatMessage method

  ChatMessage chatMessageReadToChatMessage(
    ChatMessageRead messageRead,
    bool isMine,
  ) {
    // Parse timestamp string to DateTime
    DateTime parsedTimestamp;
    try {
      parsedTimestamp = DateTime.parse(messageRead.timestamp);
      // Assume the timestamp is in UTC and convert to local
      if (parsedTimestamp.isUtc) {
        parsedTimestamp = parsedTimestamp.toLocal();
      }
    } catch (e) {
      // Fallback to current time if parsing fails
      parsedTimestamp = DateTime.now();
      _debugLog(
        'Failed to parse timestamp: ${messageRead.timestamp}, using current time',
      );
    }

    Map<String, dynamic>? invitationData = messageRead.invitationData != null
        ? json.decode(messageRead.invitationData!) as Map<String, dynamic>
        : null;

    // Normalize invitation status values from server to client expectations
    if (invitationData != null && invitationData.containsKey('status')) {
      final status = invitationData['status'] as String?;
      if (status == 'accept') {
        invitationData['status'] = 'accepted';
      } else if (status == 'decline') {
        invitationData['status'] = 'declined';
      }
    }

    return ChatMessage(
      id: messageRead.id,
      text: messageRead.text,
      isMine: isMine,
      timestamp: parsedTimestamp,
      messageType: _parseMessageType(messageRead.messageType),
      invitationId: messageRead.invitationId,
      invitationData: invitationData,
    );
  }

  // Activity model converters
  ActivityCreate activityToActivityCreate(Activity activity) {
    return ActivityCreate(
      (b) => b
        ..name = activity.name
        ..description = activity.description,
    );
  }

  Activity activityReadToActivity(ActivityRead activityRead) {
    // Parse createdAt string to DateTime
    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(activityRead.createdAt);
      // Assume the timestamp is in UTC and convert to local
      if (parsedCreatedAt.isUtc) {
        parsedCreatedAt = parsedCreatedAt.toLocal();
      }
    } catch (e) {
      // Fallback to current time if parsing fails
      parsedCreatedAt = DateTime.now();
      _debugLog(
        'Failed to parse createdAt: ${activityRead.createdAt}, using current time',
      );
    }

    return Activity(
      id: activityRead.id,
      name: activityRead.name,
      description: activityRead.description,
      createdAt: parsedCreatedAt,
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
    final multipartFile = await _createMultipartFile(imageFile);
    if (multipartFile == null) {
      throw Exception('Failed to create multipart file from image');
    }

    final response = await _executeWithRetry(
      () => _usersApi.uploadAvatarApiV1UsersUserIdAvatarPost(
        userId: userId,
        file: multipartFile,
      ),
      'Upload Avatar',
    );

    return response.data?.avatarUrl;
  }

  /// Delete avatar for a user
  Future<bool> deleteAvatar(int userId) async {
    await _executeWithRetry(
      () => _usersApi.removeAvatarApiV1UsersUserIdAvatarDelete(userId: userId),
      'Delete Avatar',
    );
    return true;
  }

  // Chat endpoints

  /// Create chat room
  Future<ChatRoomRead> createChatRoom(ChatRoomCreateRequest chatRoom) async {
    final response = await _executeWithRetry(
      () => _chatroomsApi.createChatroomWithInvitationApiV1ChatroomsPost(
        chatRoomCreateRequest: chatRoom,
      ),
      'Create Chat Room',
    );
    return response.data!;
  }

  /// Find chat room between two users
  Future<ChatRoomRead?> findChatRoomBetweenUsers(
    int user1Id,
    int user2Id,
    String restaurant,
  ) async {
    try {
      final response = await _executeWithRetry(
        () => _chatroomsApi.getOrCreateChatRoomApiV1ChatroomsGetOrCreatePost(
          user1Id: user1Id,
          user2Id: user2Id,
          restaurant: restaurant,
        ),
        'Find Chat Room Between Users',
      );
      return response.data;
    } catch (e) {
      // Return null if no chat room found
      return null;
    }
  }

  /// Get chat rooms for user
  Future<BuiltList<ChatRoomRead>> getChatRooms(int userId) async {
    final response = await _executeWithRetry(
      () => _chatroomsApi.getUserChatRoomsApiV1ChatroomsUsersUserIdGet(
        userId: userId,
      ),
      'Get Chat Rooms',
    );
    return response.data!;
  }

  /// Get chat room by ID
  Future<ChatRoomRead> getChatRoom(String chatroomId) async {
    final response = await _executeWithRetry(
      () => _chatroomsApi.getChatRoomApiV1ChatroomsChatRoomIdGet(
        chatRoomId: chatroomId,
      ),
      'Get Chat Room',
    );
    return response.data!;
  }

  /// Send chat message
  Future<ChatMessageRead> sendChatMessage(
    String chatroomId,
    int senderId,
    String text,
  ) async {
    final response = await _executeWithRetry(
      () => _messagesApi.sendMessageApiV1MessagesSendPost(
        chatRoomId: chatroomId,
        senderId: senderId,
        text: text,
      ),
      'Send Chat Message',
    );
    return response.data!;
  }

  /// Get chat messages
  Future<BuiltList<ChatMessageRead>> getChatMessages(String chatroomId) async {
    final response = await _executeWithRetry(
      () => _messagesApi.getChatRoomMessagesApiV1MessagesChatroomsChatRoomIdGet(
        chatRoomId: chatroomId,
      ),
      'Get Chat Messages',
    );
    return response.data!;
  }

  /// Create invitation message using proper backend endpoint
  Future<ChatMessageRead> createInvitationMessage(
    String chatroomId,
    int senderId,
    String activityName,
    String restaurant,
    BuiltList<String> iceBreakers,
    String? responseDeadline,
  ) async {
    // Generate unique invitation ID
    final invitationId = 'inv_${DateTime.now().millisecondsSinceEpoch}';

    final response = await _executeWithRetry(
      () => _messagesApi.createInvitationMessageApiV1MessagesInvitationPost(
        chatRoomId: chatroomId,
        senderId: senderId,
        invitationId: invitationId,
        activityId: activityName, // Using activity name as ID for now
        restaurant: restaurant,
        requestBody: iceBreakers, // Pass ice breakers as request body
      ),
      'Create Invitation Message',
    );
    return response.data!;
  }

  /// Respond to invitation message (accept/decline)
  Future<Map<String, dynamic>> respondToInvitationMessage(
    String messageId,
    String action, // "accept" or "decline"
    int responderId,
  ) async {
    final invitationRespondRequest = InvitationRespondRequest(
      (b) => b
        ..action = action
        ..responderId = responderId,
    );

    final response = await _executeWithRetry(
      () => _messagesApi
          .respondToInvitationApiV1MessagesMessageIdInvitationRespondPut(
            messageId: messageId,
            invitationRespondRequest: invitationRespondRequest,
          ),
      'Respond to Invitation Message',
    );
    // For now, return a simple success response
    // TODO: Parse JsonObject response properly when needed
    return {'status': 'success', 'action': action};
  }

  /// Collect name card from invitation message
  Future<Map<String, dynamic>> collectNameCardFromMessage(
    String messageId,
  ) async {
    final response = await _executeWithRetry(
      () => _messagesApi
          .collectNameCardFromMessageApiV1MessagesMessageIdCollectCardPut(
            messageId: messageId,
          ),
      'Collect Name Card From Message',
    );
    // For now, return a simple success response
    // TODO: Parse JsonObject response properly when needed
    return {'status': 'success', 'collected': true};
  }

  // Activity endpoints

  /// Create activity
  Future<ActivityRead> createActivity(ActivityCreate activity) async {
    final response = await _executeWithRetry(
      () => _activitiesApi.createActivityApiV1ActivitiesPost(
        activityCreate: activity,
      ),
      'Create Activity',
    );
    return response.data!;
  }

  /// Get activities
  Future<BuiltList<ActivityRead>> getActivities() async {
    final response = await _executeWithRetry(
      () => _activitiesApi.getActivitiesApiV1ActivitiesGet(),
      'Get Activities',
    );
    return response.data!;
  }

  /// Delete activity
  Future<void> deleteActivity(String activityId) async {
    await _executeWithRetry(
      () => _activitiesApi.deleteActivityApiV1ActivitiesActivityIdDelete(
        activityId: activityId,
      ),
      'Delete Activity',
    );
  }

  /// Create a MultipartFile from various image input types
  Future<MultipartFile?> _createMultipartFile(dynamic imageFile) async {
    try {
      if (imageFile is File) {
        // Mobile: File from file system
        return await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      } else if (imageFile is Uint8List) {
        // Web: Raw bytes from image cropping
        return MultipartFile.fromBytes(
          imageFile,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.png',
        );
      } else if (imageFile is String && imageFile.startsWith('/')) {
        // File path as string
        return await MultipartFile.fromFile(
          imageFile,
          filename: imageFile.split('/').last,
        );
      }
    } catch (e) {
      _debugLog('Error creating multipart file: $e');
    }
    return null;
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[ApiService] $message');
    }
  }

  void dispose() {
    _debugLog('API Service disposed');
  }

  /// Parse message type from API string to enum
  MessageType _parseMessageType(String? messageType) {
    switch (messageType?.toLowerCase()) {
      case 'invitation':
        return MessageType.invitation;
      case 'invitation_response':
        return MessageType.invitationResponse;
      case 'system':
        return MessageType.system;
      case 'text':
      default:
        return MessageType.text;
    }
  }
}

extension on double {
  double toRadians() => this * (3.14159265359 / 180);
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}
