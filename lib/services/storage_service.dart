import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/profile.dart';
import '../models/peer.dart';
import '../models/meeting.dart';
import '../models/connection.dart';
import '../models/activity.dart';
import '../models/user_rating.dart';

/// Storage service with persistent data using shared_preferences
class StorageService extends ChangeNotifier {
  static const String _keyCurrentProfile = 'current_profile';
  static const String _keyConnections = 'connections';
  static const String _keyProfiles = 'profiles';
  Profile? _currentProfile;
  Map<String, Profile> _profiles = {};
  List<Connection> _connections = [];
  List<Peer> _nearbyPeers = [];
  List<Invitation> _invitations = [];
  List<ChatRoom> _chatRooms = [];
  List<Activity> _activities = [];
  List<UserRating> _userRatings = [];
  Peer? _selectedPeer;
  String? _selectedActivityId; // Currently selected activity for viewing invitations

  Profile? get currentProfile => _currentProfile;
  List<Connection> get connections => _connections;
  List<Peer> get nearbyPeers => _nearbyPeers;
  List<Invitation> get invitations => _invitations;
  List<ChatRoom> get chatRooms => _chatRooms;
  List<Activity> get activities => _activities;
  List<UserRating> get userRatings => _userRatings;
  Peer? get selectedPeer => _selectedPeer;
  String? get selectedActivityId => _selectedActivityId;

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
    final filtered = _nearbyPeers.where((p) => !connectionIds.contains(p.id)).toList();
    // Sort by match score (highest first)
    filtered.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return filtered;
  }

  // Get your connections as peers
  List<Peer> get yourConnections {
    final connectionIds = _connections.map((c) => c.toProfileId).toSet();
    final filtered = _nearbyPeers.where((p) => connectionIds.contains(p.id)).toList();
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

  /// Load current profile from persistent storage
  Future<void> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_keyCurrentProfile);
      
      if (profileJson != null) {
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        _currentProfile = Profile.fromJson(profileMap);
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
          (key, value) => MapEntry(key, Profile.fromJson(value as Map<String, dynamic>)),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile data: $e');
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
      final connectionsJson = jsonEncode(_connections.map((c) => c.toJson()).toList());
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

  /// Clear persisted data
  Future<void> _clearPersistedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCurrentProfile);
      await prefs.remove(_keyConnections);
      await prefs.remove(_keyProfiles);
    } catch (e) {
      debugPrint('Error clearing profile data: $e');
    }
  }

  /// Save user name (registration step)
  Future<void> saveUserName(String userName) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _currentProfile = Profile(id: id, userName: userName);
    await _persistCurrentProfile();
    notifyListeners();
  }

  /// Update current profile with additional information
  Future<void> updateProfile({
    String? school,
    String? major,
    String? interests,
    String? background,
    String? profileImagePath,
  }) async {
    if (_currentProfile == null) return;

    _currentProfile = _currentProfile!.copyWith(
      school: school,
      major: major,
      interests: interests,
      background: background,
      profileImagePath: profileImagePath,
    );
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
    await _clearPersistedProfile();
    notifyListeners();
  }

  /// Logout user and clear all data
  Future<void> logout() async {
    await clearProfile();
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
        .map((peer) => peer.copyWith(
              matchScore: Peer.calculateMatchScore(_currentProfile!, peer),
            ))
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
      if (!addedConnections.contains(key1) && !addedConnections.contains(key2)) {
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

    return {
      'profiles': mockProfiles,
      'connections': mockConnections,
    };
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
        .map((key) => {
          ...profiles[key] as Map<String, dynamic>,
          'connectedThrough': directConnectionKeys.firstWhere(
            (directKey) => connections.any((c) =>
              (c['from'] == directKey && c['to'] == key) ||
              (c['to'] == directKey && c['from'] == key)
            ),
          ),
        })
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
    final allQuestions = [
      // Interest-based questions
      IceBreaker(
        question: 'What inspired you to study ${peer.major}?',
        answer: 'This helps you understand their passion and motivation',
      ),
      IceBreaker(
        question: 'I see you\'re interested in ${peer.interests.split(',').first.trim()}. How did you get into that?',
        answer: 'Shows you read their profile and care about their interests',
      ),
      IceBreaker(
        question: 'What\'s your favorite thing about ${peer.school}?',
        answer: 'A great way to share common experiences',
      ),
      // Values and personal philosophy
      IceBreaker(
        question: 'What\'s a core value or principle that guides your decisions?',
        answer: 'Helps understand what matters most to them',
      ),
      IceBreaker(
        question: 'What does success mean to you personally?',
        answer: 'Reveals their priorities and aspirations',
      ),
      IceBreaker(
        question: 'If you could change one thing about the world, what would it be?',
        answer: 'Shows their values and what they care about',
      ),
      IceBreaker(
        question: 'What\'s something you believe that most people disagree with?',
        answer: 'Encourages authentic conversation and perspective sharing',
      ),
      // Background and experiences
      IceBreaker(
        question: 'What\'s a life experience that shaped who you are today?',
        answer: 'Invites deeper storytelling about their journey',
      ),
      IceBreaker(
        question: 'How has your background influenced your career or life goals?',
        answer: 'Explores the connection between past and future',
      ),
      IceBreaker(
        question: 'What\'s a challenge you\'ve overcome that you\'re proud of?',
        answer: 'Highlights resilience and personal growth',
      ),
      IceBreaker(
        question: 'Is there a family tradition or cultural practice that\'s meaningful to you?',
        answer: 'Opens discussion about heritage and identity',
      ),
      // Fun and personality
      IceBreaker(
        question: 'What\'s a fun fact about yourself that most people don\'t know?',
        answer: 'Helps break the ice with something unexpected',
      ),
      IceBreaker(
        question: 'If you could have dinner with anyone, dead or alive, who would it be?',
        answer: 'Reveals their inspirations and interests',
      ),
      IceBreaker(
        question: 'What\'s something you\'re currently trying to learn or get better at?',
        answer: 'Shows growth mindset and current interests',
      ),
      IceBreaker(
        question: 'If you had a free year to do anything, how would you spend it?',
        answer: 'Explores dreams and priorities',
      ),
    ];

    // Randomly select 2 questions
    final random = Random();
    final shuffled = List<IceBreaker>.from(allQuestions)..shuffle(random);
    return shuffled.take(2).toList();
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

  /// Create connection from peer
  Future<void> collectNameCard(String invitationId) async {
    if (_currentProfile == null) return;

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

  /// Get profile by ID
  Profile? getProfileById(String id) {
    if (id == _currentProfile?.id) return _currentProfile;
    return _profiles[id];
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
}
