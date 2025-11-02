import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/peer.dart';
import '../models/meeting.dart';
import '../models/name_card.dart';
import '../models/activity.dart';

/// Simple in-memory storage service for user profile
/// In production, this would use shared_preferences or a database
class StorageService extends ChangeNotifier {
  UserProfile? _userProfile;
  List<Peer> _nearbyPeers = [];
  List<Invitation> _invitations = [];
  List<ChatRoom> _chatRooms = [];
  List<NameCard> _nameCards = [];
  List<Activity> _activities = [];
  Peer? _selectedPeer;
  String? _selectedActivityId; // Currently selected activity for viewing invitations

  UserProfile? get userProfile => _userProfile;
  List<Peer> get nearbyPeers => _nearbyPeers;
  List<Invitation> get invitations => _invitations;
  List<ChatRoom> get chatRooms => _chatRooms;
  List<NameCard> get nameCards => _nameCards;
  List<Activity> get activities => _activities;
  Peer? get selectedPeer => _selectedPeer;
  String? get selectedActivityId => _selectedActivityId;

  bool get hasUser => _userProfile != null;

  // Get peers who want to eat
  List<Peer> get peersWantToEat =>
      _nearbyPeers.where((p) => p.wantsToEat).toList();

  // Get peers who don't want to eat
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

  /// Save user name (registration step)
  Future<void> saveUserName(String userName) async {
    _userProfile = UserProfile(userName: userName);
    notifyListeners();
  }

  /// Update user profile with additional information
  Future<void> updateProfile({
    String? school,
    String? major,
    String? interests,
    String? background,
  }) async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(
      school: school,
      major: major,
      interests: interests,
      background: background,
    );
    notifyListeners();
  }

  /// Clear all data
  void clearProfile() {
    _userProfile = null;
    _nearbyPeers = [];
    _invitations = [];
    _chatRooms = [];
    _nameCards = [];
    _activities = [];
    _selectedPeer = null;
    _selectedActivityId = null;
    notifyListeners();
  }

  /// Create a new activity
  Activity createActivity(String name, String description) {
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    _activities.add(activity);
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
    _selectedActivityId = activityId;
    notifyListeners();
  }

  /// Get activity by ID
  Activity? getActivityById(String activityId) {
    try {
      return _activities.firstWhere((a) => a.id == activityId);
    } catch (e) {
      return null;
    }
  }

  /// Search for nearby peers (mock implementation)
  Future<List<Peer>> searchNearbyPeers() async {
    // Create activity first
    createActivity(
      'Searching for peers to eat',
      'Looking for people nearby who want to grab food together',
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock peers based on user profile
    final mockPeers = _generateMockPeers();
    _nearbyPeers = mockPeers;
    notifyListeners();
    return mockPeers;
  }

  /// Generate mock peers for demonstration
  List<Peer> _generateMockPeers() {
    if (_userProfile == null) return [];

    final peers = [
      Peer(
        id: '1',
        name: 'Alex Johnson',
        school: _userProfile!.school ?? 'MIT',
        major: _userProfile!.major ?? 'Computer Science',
        interests: 'Machine Learning, Hiking, Photography',
        background: 'Worked at Google for 2 years, now pursuing Masters',
        distance: 0.5,
        wantsToEat: true,
      ),
      Peer(
        id: '2',
        name: 'Sarah Chen',
        school: _userProfile!.school ?? 'Stanford',
        major: 'Electrical Engineering',
        interests: 'Robotics, Music, Cooking',
        background: 'Undergraduate student interested in AI research',
        distance: 1.2,
        wantsToEat: true,
      ),
      Peer(
        id: '3',
        name: 'Michael Brown',
        school: 'UC Berkeley',
        major: _userProfile!.major ?? 'Computer Science',
        interests: 'Web Development, Gaming, Basketball',
        background: 'Full-stack developer, love building apps',
        distance: 0.8,
        wantsToEat: false,
      ),
      Peer(
        id: '4',
        name: 'Emily Davis',
        school: _userProfile!.school ?? 'Harvard',
        major: 'Data Science',
        interests: 'Data Analysis, Running, Reading',
        background: 'Data analyst looking to network with tech professionals',
        distance: 2.1,
        wantsToEat: true,
      ),
      Peer(
        id: '5',
        name: 'David Wilson',
        school: _userProfile!.school ?? 'MIT',
        major: 'Business',
        interests: 'Entrepreneurship, Travel, Coffee',
        background: 'MBA student, formerly worked at startup',
        distance: 1.5,
        wantsToEat: false,
      ),
      Peer(
        id: '6',
        name: 'Lisa Martinez',
        school: 'Stanford',
        major: _userProfile!.major ?? 'Computer Science',
        interests: 'UI/UX Design, Art, Yoga',
        background: 'Product designer passionate about user experience',
        distance: 0.3,
        wantsToEat: true,
      ),
    ];

    // Calculate match scores and sort by distance
    return peers
        .map((peer) => peer.copyWith(
              matchScore: Peer.calculateMatchScore(_userProfile!, peer),
            ))
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  /// Select a peer to potentially meet
  void selectPeer(Peer peer) {
    _selectedPeer = peer;
    notifyListeners();
  }

  /// Send invitation to eat
  Future<Invitation> sendInvitation(Peer peer, String restaurant) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate ice-breaking questions
    final iceBreakers = _generateIceBreakers(peer);

    final invitation = Invitation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      peerId: peer.id,
      peerName: peer.name,
      restaurant: restaurant,
      createdAt: DateTime.now(),
      sentByMe: true,
      status: InvitationStatus.pending,
      iceBreakers: iceBreakers,
    );

    _invitations.add(invitation);
    notifyListeners();

    // Simulate peer response after delay
    _simulatePeerResponse(invitation.id);

    // Also simulate some received invitations
    _simulateReceivedInvitations();

    return invitation;
  }

  /// Generate ice-breaking questions based on peer's profile
  List<IceBreaker> _generateIceBreakers(Peer peer) {
    return [
      IceBreaker(
        question: 'What inspired you to study ${peer.major}?',
        answer: 'This helps you understand their passion and motivation',
      ),
      IceBreaker(
        question: 'What\'s your favorite thing about ${peer.school}?',
        answer: 'A great way to share common experiences',
      ),
      IceBreaker(
        question: 'I see you\'re interested in ${peer.interests.split(',').first.trim()}. How did you get into that?',
        answer: 'Shows you read their profile and care about their interests',
      ),
      IceBreaker(
        question: 'What\'s a fun fact about yourself that most people don\'t know?',
        answer: 'Helps break the ice with something unexpected',
      ),
      IceBreaker(
        question: 'If you could have dinner with anyone, dead or alive, who would it be?',
        answer: 'Reveals their values and inspirations',
      ),
    ];
  }

  /// Simulate peer accepting/declining (for demo purposes)
  Future<void> _simulatePeerResponse(String invitationId) async {
    await Future.delayed(const Duration(seconds: 3));

    final index = _invitations.indexWhere((i) => i.id == invitationId);
    if (index != -1) {
      // 70% chance of acceptance for demo
      final accepted = DateTime.now().millisecond % 10 < 7;

      _invitations[index] = _invitations[index].copyWith(
        status: accepted
            ? InvitationStatus.accepted
            : InvitationStatus.declined,
      );
      notifyListeners();

      // If accepted, create a chat room
      if (accepted) {
        _createChatRoom(_invitations[index]);
      }
    }
  }

  /// Simulate receiving invitations from others
  Future<void> _simulateReceivedInvitations() async {
    // Only add if we don't have any received invitations yet
    if (receivedInvitations.isEmpty && _nearbyPeers.length >= 2) {
      await Future.delayed(const Duration(seconds: 5));

      final peer = _nearbyPeers[1];
      final iceBreakers = _generateIceBreakers(peer);
      
      final invitation = Invitation(
        id: 'received_${DateTime.now().millisecondsSinceEpoch}',
        peerId: peer.id,
        peerName: peer.name,
        restaurant: 'Green Garden Cafe',
        createdAt: DateTime.now(),
        sentByMe: false,
        status: InvitationStatus.pending,
        iceBreakers: iceBreakers,
      );

      _invitations.add(invitation);
      notifyListeners();
    }
  }

  /// Accept an invitation (max 1 allowed)
  Future<void> acceptInvitation(String invitationId) async {
    // Check if there's already an accepted invitation
    final hasAccepted = _invitations.any((i) => i.isAccepted);
    
    if (hasAccepted) {
      // Auto-decline all other pending invitations
      for (int i = 0; i < _invitations.length; i++) {
        if (_invitations[i].isPending && _invitations[i].id != invitationId) {
          _invitations[i] = _invitations[i].copyWith(
            status: InvitationStatus.declined,
          );
        }
      }
    }

    final index = _invitations.indexWhere((i) => i.id == invitationId);
    if (index != -1) {
      // Decline all other invitations if we're accepting this one
      for (int i = 0; i < _invitations.length; i++) {
        if (i != index && _invitations[i].isPending) {
          _invitations[i] = _invitations[i].copyWith(
            status: InvitationStatus.declined,
          );
        }
      }

      _invitations[index] = _invitations[index].copyWith(
        status: InvitationStatus.accepted,
      );
      notifyListeners();

      // Create chat room
      _createChatRoom(_invitations[index]);
    }
  }

  /// Decline an invitation
  Future<void> declineInvitation(String invitationId) async {
    final index = _invitations.indexWhere((i) => i.id == invitationId);
    if (index != -1) {
      _invitations[index] = _invitations[index].copyWith(
        status: InvitationStatus.declined,
      );
      notifyListeners();
    }
  }

  /// Create a chat room for accepted invitation
  void _createChatRoom(Invitation invitation) {
    // Check if chat room already exists
    final exists = _chatRooms.any((c) => c.peerId == invitation.peerId);
    if (exists) return;

    final chatRoom = ChatRoom(
      id: 'chat_${invitation.id}',
      peerId: invitation.peerId,
      peerName: invitation.peerName,
      restaurant: invitation.restaurant,
      createdAt: DateTime.now(),
    );

    _chatRooms.add(chatRoom);
    notifyListeners();
  }

  /// Send message in chat room
  void sendMessage(String chatRoomId, String text) {
    final index = _chatRooms.indexWhere((c) => c.id == chatRoomId);
    if (index != -1) {
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isMine: true,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [..._chatRooms[index].messages, message];
      _chatRooms[index] = _chatRooms[index].copyWith(messages: updatedMessages);
      notifyListeners();

      // Simulate peer response
      _simulatePeerMessage(chatRoomId);
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
      );

      final updatedMessages = [..._chatRooms[index].messages, message];
      _chatRooms[index] = _chatRooms[index].copyWith(messages: updatedMessages);
      notifyListeners();
    }
  }

  /// Get chat room by peer ID
  ChatRoom? getChatRoomByPeerId(String peerId) {
    try {
      return _chatRooms.firstWhere((c) => c.peerId == peerId);
    } catch (e) {
      return null;
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

  /// Collect name card from peer
  Future<void> collectNameCard(String invitationId) async {
    final invitation = _invitations.firstWhere((i) => i.id == invitationId);
    final peer = getPeerById(invitation.peerId);
    
    if (peer == null) return;

    // Check if already collected
    final alreadyCollected = _nameCards.any((nc) => nc.peerId == peer.id);
    if (alreadyCollected) return;

    final nameCard = NameCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      peerId: peer.id,
      name: peer.name,
      school: peer.school,
      major: peer.major,
      interests: peer.interests,
      background: peer.background,
      restaurant: invitation.restaurant,
      collectedAt: DateTime.now(),
    );

    _nameCards.add(nameCard);
    
    // Mark invitation as name card collected
    final invIndex = _invitations.indexWhere((i) => i.id == invitationId);
    if (invIndex != -1) {
      _invitations[invIndex] = _invitations[invIndex].copyWith(
        nameCardCollected: true,
      );
    }
    
    notifyListeners();
  }

  /// Mark match as not good and decline
  Future<void> markNotGoodMatch(String invitationId) async {
    await declineInvitation(invitationId);
    
    // Remove from chat rooms
    final invitation = _invitations.firstWhere((i) => i.id == invitationId);
    _chatRooms.removeWhere((c) => c.peerId == invitation.peerId);
    
    notifyListeners();
  }
}
