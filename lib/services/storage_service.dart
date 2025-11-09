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

  /// Clear selected activity
  void clearSelectedActivity() {
    _selectedActivityId = null;
    notifyListeners();
  }

  /// Create or get the search activity (removes duplicates)
  Activity createOrGetSearchActivity() {
    const searchActivityName = 'Searching for peers to eat';
    
    // Find and remove any existing search activities (clean up duplicates)
    final oldSearchActivities = _activities
        .where((a) => a.name == searchActivityName)
        .map((a) => a.id)
        .toList();
    
    // Remove old search activities
    _activities.removeWhere((a) => a.name == searchActivityName);
    
    // Also remove invitations associated with old search activities
    _invitations.removeWhere((inv) => oldSearchActivities.contains(inv.activityId));
    
    // Create a new search activity
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: searchActivityName,
      description: 'Looking for people nearby who want to grab food together',
      createdAt: DateTime.now(),
    );
    
    _activities.add(activity);
    _selectedActivityId = activity.id;
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

  /// Search for nearby peers (mock implementation)
  Future<List<Peer>> searchNearbyPeers() async {
    // Don't create a new activity here - it's already created by createOrGetSearchActivity()
    
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
    // Require activity to be selected
    if (_selectedActivityId == null) {
      throw Exception('No activity selected. Please select an activity first.');
    }

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate ice-breaking questions
    final iceBreakers = _generateIceBreakers(peer);

    final invitation = Invitation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      peerId: peer.id,
      peerName: peer.name,
      restaurant: restaurant,
      activityId: _selectedActivityId!,
      createdAt: DateTime.now(),
      sentByMe: true,
      status: InvitationStatus.pending,
      iceBreakers: iceBreakers,
    );

    _invitations.add(invitation);
    notifyListeners();

    // Don't simulate peer response - let user use mock buttons instead
    // Don't auto-simulate received invitations - causes duplicate activities
    // _simulateReceivedInvitations();

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

    // Accept this invitation
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
      (inv) => inv.activityId == activityId && 
               inv.sentByMe && 
               inv.isPending,
    );

    notifyListeners();

    // Create chat room
    _createChatRoom(acceptedInvitation);
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
      (inv) => inv.activityId == activityId && 
               inv.sentByMe && 
               inv.isPending &&
               inv.id != invitationId,
    );

    notifyListeners();

    // Create chat room
    _createChatRoom(acceptedInvitation);
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
      final mockNames = ['Jessica Lee', 'Ryan Martinez', 'Olivia Taylor', 'James Anderson', 'Emma White'];
      final mockSchools = ['MIT', 'Stanford', 'Harvard', 'UC Berkeley', 'Yale'];
      final mockMajors = ['Computer Science', 'Engineering', 'Business', 'Biology', 'Psychology'];
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
    
    final restaurant = restaurants[DateTime.now().millisecond % restaurants.length];

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
    _chatRooms.removeWhere((c) => c.peerId == invitation.peerId);
    
    notifyListeners();
  }
}
