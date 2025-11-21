# Data Model Refactoring Plan

## Executive Summary
Consolidate duplicate data models (`UserProfile` and `NameCard`) into a unified `Profile` model and create a `Connection` model to represent relationships. Update network graph to show real data instead of mock nodes.

---

## Current State Analysis

### Models
1. **UserProfile** (`lib/models/user_profile.dart`)
   - Fields: `userName`, `school`, `major`, `interests`, `background`, `profileImagePath`
   - Methods: `copyWith()`, `toJson()`, `fromJson()`
   - Purpose: Represents the current user's profile
   - Used by: StorageService, profile screens, peer match calculation

2. **NameCard** (`lib/models/name_card.dart`)
   - Fields: `id`, `peerId`, `name`, `school`, `major`, `interests`, `background`, `restaurant`, `collectedAt`
   - Methods: None (no serialization)
   - Purpose: Represents collected peer profiles
   - Used by: StorageService, network tab
   - **Problem**: Duplicates 5 fields from UserProfile, missing `profileImagePath`

3. **Peer** (`lib/models/peer.dart`)
   - Fields: `id`, `name`, `school`, `major`, `interests`, `background`, `matchScore`, `distance`, `wantsToEat`
   - Methods: `calculateMatchScore()` (static)
   - Purpose: Represents nearby potential connections during discovery
   - **Note**: Also duplicates profile fields but serves different purpose (temporary discovery state)

### Storage Service Usage

**UserProfile Usage:**
1. `_userProfile` - Current user's profile (nullable)
2. `loadUserProfile()` - Load from SharedPreferences
3. `_persistUserProfile()` - Save to SharedPreferences
4. `saveUserName()` - Initialize profile with username
5. `updateProfile()` - Update profile fields including `profileImagePath`
6. `clearProfile()` - Logout, clear all data
7. `hasUser` getter - Check if user exists

**NameCard Usage:**
1. `_nameCards` - List of collected connections
2. `nameCards` getter - Expose to UI
3. `collectNameCard()` - Create NameCard from Peer after invitation acceptance
   - Copies: `name`, `school`, `major`, `interests`, `background` from Peer
   - Adds: `restaurant` from Invitation, `collectedAt` timestamp
   - Missing: `profileImagePath` (Peer doesn't have it either)
4. Network tab uses for display (grid view and graph view)

### UI Usage

**Profile Screens:**
- `ProfileSetupScreen` - Initial profile creation, sets `profileImagePath`
- `EditProfileScreen` - Update profile, modify `profileImagePath`
- `ProfileTab` - Display current user profile with image

**Network Tab:**
- Displays NameCard count in badge
- Grid view: Shows list of collected NameCards with CircleAvatar (no profile image)
- Graph view: Mock data (15 hardcoded nodes), ignores real NameCards
- `_showNameCardDetails()` - Modal showing NameCard details (no profile image)

**Invitation Flow:**
1. User discovers Peers (temporary objects)
2. User sends/receives Invitation
3. After meeting, user collects NameCard from Peer
4. NameCard stored permanently in `_nameCards` list

---

## Refactoring Goals

1. **Unify Profile Data**: Single `Profile` model for all users (self and connections)
2. **Relationship Model**: `Connection` model to represent relationships with metadata
3. **Real Network Graph**: Use actual connection data instead of mock nodes
4. **Empty Network State**: Show only current user when no connections exist
5. **Profile Images Everywhere**: Add profile images to network nodes and NameCard displays
6. **Maintain Features**: Keep all existing functionality (match scores, invitations, chat)

---

## Proposed Architecture

### New Models

#### 1. Profile Model (`lib/models/profile.dart`)
```dart
class Profile {
  final String id;           // Unique identifier
  final String userName;     // Display name
  final String? school;
  final String? major;
  final String? interests;
  final String? background;
  final String? profileImagePath; // Can be: data URL (web), blob URL (web), or file path (mobile)
  
  // Methods
  Profile copyWith({...})
  Map<String, dynamic> toJson()
  factory Profile.fromJson(Map<String, dynamic> json)
}
```

**Key Design Decisions:**
- `id` is required - for current user, generate unique ID on first creation
- `userName` is required (matches current UserProfile)
- All other fields optional (matches current pattern)
- `profileImagePath` handles all image storage types (base64 data URLs, blob URLs, file paths)

#### 2. Connection Model (`lib/models/connection.dart`)
```dart
class Connection {
  final String id;                  // Unique connection identifier
  final String profileId;           // The connected profile's ID
  final String restaurant;          // Where they met
  final DateTime collectedAt;       // When connection was made
  final String? notes;              // Optional user notes
  
  // Methods
  Connection copyWith({...})
  Map<String, dynamic> toJson()
  factory Connection.fromJson(Map<String, dynamic> json)
}
```

**Key Design Decisions:**
- Stores relationship metadata, not profile data
- References Profile by ID (separation of concerns)
- Keeps meeting context (`restaurant`, `collectedAt`)
- One-directional: Only current user's connections are stored

### Updated Storage Service

```dart
class StorageService extends ChangeNotifier {
  Profile? _currentProfile;              // Current user (previously _userProfile)
  Map<String, Profile> _profiles;        // Cache of all known profiles (by ID)
  List<Connection> _connections;         // Current user's connections (previously _nameCards)
  
  // Existing lists (unchanged)
  List<Peer> _nearbyPeers;
  List<Invitation> _invitations;
  List<ChatRoom> _chatRooms;
  List<Activity> _activities;
  
  // New getters
  Profile? get currentProfile => _currentProfile;
  List<Connection> get connections => _connections;
  
  // Derived data
  List<Profile> get connectedProfiles {
    return _connections
        .map((conn) => _profiles[conn.profileId])
        .whereType<Profile>()
        .toList();
  }
  
  // New methods
  Future<void> saveProfile(Profile profile)
  Future<void> updateCurrentProfile({...})
  Profile? getProfileById(String id)
  Future<void> createConnection({
    required String profileId,
    required String restaurant,
    String? notes,
  })
}
```

**Migration Strategy:**
- `_userProfile` → `_currentProfile` (Profile with generated ID)
- `_nameCards` → `_connections` + `_profiles` map
- `saveUserName()` → `saveProfile()` / `updateCurrentProfile()`
- `updateProfile()` → `updateCurrentProfile()`
- `collectNameCard()` → `createConnection()` + store Profile in `_profiles`

---

## Implementation Steps

### Step 1: Create Profile Model
**Files to create:** `lib/models/profile.dart`

**Implementation:**
```dart
import 'package:flutter/foundation.dart';

@immutable
class Profile {
  final String id;
  final String userName;
  final String? school;
  final String? major;
  final String? interests;
  final String? background;
  final String? profileImagePath;

  const Profile({
    required this.id,
    required this.userName,
    this.school,
    this.major,
    this.interests,
    this.background,
    this.profileImagePath,
  });

  Profile copyWith({
    String? id,
    String? userName,
    String? school,
    String? major,
    String? interests,
    String? background,
    String? profileImagePath,
  }) {
    return Profile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      school: school ?? this.school,
      major: major ?? this.major,
      interests: interests ?? this.interests,
      background: background ?? this.background,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      if (school != null) 'school': school,
      if (major != null) 'major': major,
      if (interests != null) 'interests': interests,
      if (background != null) 'background': background,
      if (profileImagePath != null) 'profileImagePath': profileImagePath,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      userName: json['userName'] as String,
      school: json['school'] as String?,
      major: json['major'] as String?,
      interests: json['interests'] as String?,
      background: json['background'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

---

### Step 2: Create Connection Model
**Files to create:** `lib/models/connection.dart`

**Implementation:**
```dart
@immutable
class Connection {
  final String id;
  final String profileId;
  final String restaurant;
  final DateTime collectedAt;
  final String? notes;

  const Connection({
    required this.id,
    required this.profileId,
    required this.restaurant,
    required this.collectedAt,
    this.notes,
  });

  Connection copyWith({
    String? id,
    String? profileId,
    String? restaurant,
    DateTime? collectedAt,
    String? notes,
  }) {
    return Connection(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      restaurant: restaurant ?? this.restaurant,
      collectedAt: collectedAt ?? this.collectedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'restaurant': restaurant,
      'collectedAt': collectedAt.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      restaurant: json['restaurant'] as String,
      collectedAt: DateTime.parse(json['collectedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Connection &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

---

### Step 3: Update StorageService
**Files to modify:** `lib/services/storage_service.dart`

**Changes:**
1. Replace imports: `user_profile.dart` → `profile.dart`, `name_card.dart` → `connection.dart`
2. Replace fields:
   ```dart
   Profile? _currentProfile;           // was: UserProfile? _userProfile
   Map<String, Profile> _profiles = {}; // NEW: Cache of all profiles
   List<Connection> _connections = [];  // was: List<NameCard> _nameCards
   ```
3. Update persistence keys:
   ```dart
   static const String _keyCurrentProfile = 'current_profile';  // was: _keyUserProfile
   static const String _keyConnections = 'connections';         // NEW
   static const String _keyProfiles = 'profiles';               // NEW
   ```
4. Update getters:
   ```dart
   Profile? get currentProfile => _currentProfile;
   List<Connection> get connections => _connections;
   
   // Derived getter
   List<Profile> get connectedProfiles {
     return _connections
         .map((conn) => _profiles[conn.profileId])
         .whereType<Profile>()
         .toList();
   }
   
   bool get hasUser => _currentProfile != null;
   ```

5. Update methods:
   - `loadUserProfile()` → `loadCurrentProfile()` - load from new key
   - `_persistUserProfile()` → `_persistCurrentProfile()` - save to new key
   - Add `_persistConnections()` - save connections list
   - Add `_persistProfiles()` - save profiles map
   - `saveUserName()` → generate ID, create Profile, persist
   - `updateProfile()` → `updateCurrentProfile()` - update fields
   - `collectNameCard()` → `createConnection()`:
     ```dart
     Future<void> createConnection(String invitationId) async {
       final invitation = _invitations.firstWhere((i) => i.id == invitationId);
       final peer = getPeerById(invitation.peerId);
       
       if (peer == null) return;
       
       // Check if already connected
       if (_connections.any((c) => c.profileId == peer.id)) return;
       
       // Create Profile from Peer (if not exists)
       if (!_profiles.containsKey(peer.id)) {
         _profiles[peer.id] = Profile(
           id: peer.id,
           userName: peer.name,
           school: peer.school,
           major: peer.major,
           interests: peer.interests,
           background: peer.background,
           profileImagePath: null, // TODO: Get from peer if available
         );
       }
       
       // Create Connection
       final connection = Connection(
         id: DateTime.now().millisecondsSinceEpoch.toString(),
         profileId: peer.id,
         restaurant: invitation.restaurant,
         collectedAt: DateTime.now(),
       );
       
       _connections.add(connection);
       
       // Mark invitation
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
     ```

6. Add helper method:
   ```dart
   Profile? getProfileById(String id) {
     if (id == _currentProfile?.id) return _currentProfile;
     return _profiles[id];
   }
   ```

---

### Step 4: Update Peer Model
**Files to modify:** `lib/models/peer.dart`

**Changes:**
1. Update `calculateMatchScore()` to accept `Profile` instead of `UserProfile`:
   ```dart
   static double calculateMatchScore(Profile user, Peer peer) {
     // Implementation stays the same, just type change
   }
   ```

---

### Step 5: Update Profile Screens
**Files to modify:**
- `lib/screens/profile_setup_screen.dart`
- `lib/screens/edit_profile_screen.dart`
- `lib/widgets/profile_tab.dart`

**Changes:**
1. Replace `context.read<StorageService>().userProfile` with `.currentProfile`
2. Replace `context.watch<StorageService>().userProfile` with `.currentProfile`
3. In ProfileSetupScreen: Generate ID on first save
4. Update all method calls: `updateProfile()` → `updateCurrentProfile()`

**Example (ProfileTab):**
```dart
// Before
final profile = storageService.userProfile;

// After
final profile = storageService.currentProfile;
```

---

### Step 6: Update Network Tab - Show Real Data
**Files to modify:** `lib/widgets/network_tab.dart`

**Major Changes:**

1. **Replace mock data with real connections:**
   ```dart
   Widget _buildNetworkGraph(BuildContext context) {
     final storage = context.watch<StorageService>();
     final currentProfile = storage.currentProfile;
     final connections = storage.connections;
     final connectedProfiles = storage.connectedProfiles;
     
     if (currentProfile == null) {
       return Center(child: Text('No profile'));
     }
     
     // Build nodes from real data
     final List<NetworkNode> nodes = [];
     
     // Always add current user as center node
     nodes.add(NetworkNode(
       id: currentProfile.id,
       name: currentProfile.userName,
       school: currentProfile.school ?? '',
       color: Colors.blue,
       position: const Offset(0.5, 0.5), // Center
       connections: connections.map((c) => c.profileId).toList(),
     ));
     
     // Add connected profiles if any exist
     if (connectedProfiles.isEmpty) {
       // Empty state: Only show current user
       return NetworkGraphWidget(
         nodes: nodes,
         onNodeTap: (node) => _showCurrentUserProfile(context),
       );
     }
     
     // Position connected profiles around current user
     for (int i = 0; i < connectedProfiles.length; i++) {
       final profile = connectedProfiles[i];
       final angle = (i / connectedProfiles.length) * 2 * 3.14159;
       final radius = 0.3;
       
       nodes.add(NetworkNode(
         id: profile.id,
         name: profile.userName,
         school: profile.school ?? '',
         color: Colors.orange,
         position: Offset(
           0.5 + cos(angle) * radius,
           0.5 + sin(angle) * radius,
         ),
         connections: [currentProfile.id], // Connected to center
       ));
     }
     
     return NetworkGraphWidget(
       nodes: nodes,
       onNodeTap: (node) {
         if (node.id == currentProfile.id) {
           _showCurrentUserProfile(context);
         } else {
           final profile = connectedProfiles.firstWhere((p) => p.id == node.id);
           final connection = connections.firstWhere((c) => c.profileId == node.id);
           _showConnectionDetails(context, profile, connection);
         }
       },
     );
   }
   ```

2. **Add profile images to network nodes:**
   - Modify NetworkNode class to include `profileImagePath`:
     ```dart
     class NetworkNode {
       final String id;
       final String name;
       final String school;
       final Color color;
       final Offset position;
       final List<String> connections;
       final String? profileImagePath; // NEW
     }
     ```
   - Update NetworkGraphWidget to render CircleAvatar with images
   - Use platform detection for image type (base64 data URL vs file path)

3. **Update grid view:**
   ```dart
   Widget _buildNetworkGrid(BuildContext context) {
     final storage = context.watch<StorageService>();
     final connectedProfiles = storage.connectedProfiles;
     final connections = storage.connections;
     
     return CustomScrollView(
       slivers: [
         SliverPadding(
           padding: const EdgeInsets.all(16),
           sliver: SliverList(
             delegate: SliverChildBuilderDelegate(
               (context, index) {
                 final profile = connectedProfiles[index];
                 final connection = connections[index];
                 return _buildConnectionCard(context, profile, connection);
               },
               childCount: connectedProfiles.length,
             ),
           ),
         ),
       ],
     );
   }
   ```

4. **Update card display with profile image:**
   ```dart
   Widget _buildConnectionCard(BuildContext context, Profile profile, Connection connection) {
     return Card(
       child: InkWell(
         onTap: () => _showConnectionDetails(context, profile, connection),
         child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
             children: [
               Row(
                 children: [
                   CircleAvatar(
                     radius: 32,
                     backgroundColor: Theme.of(context).colorScheme.primary,
                     backgroundImage: profile.profileImagePath != null
                         ? (kIsWeb
                             ? (profile.profileImagePath!.startsWith('data:')
                                 ? MemoryImage(base64Decode(profile.profileImagePath!.split(',')[1]))
                                 : NetworkImage(profile.profileImagePath!))
                             : FileImage(File(profile.profileImagePath!)))
                         : null,
                     child: profile.profileImagePath == null
                         ? Text(
                             profile.userName[0].toUpperCase(),
                             style: const TextStyle(
                               color: Colors.white,
                               fontWeight: FontWeight.bold,
                               fontSize: 24,
                             ),
                           )
                         : null,
                   ),
                   // ... rest of the card
                 ],
               ),
               // ... interests, restaurant, date
             ],
           ),
         ),
       ),
     );
   }
   ```

5. **Update detail modal:**
   ```dart
   void _showConnectionDetails(BuildContext context, Profile profile, Connection connection) {
     showModalBottomSheet(
       // Similar to _showNameCardDetails but using Profile + Connection
       // Add CircleAvatar with profile.profileImagePath
       // Show connection.restaurant and connection.collectedAt
     );
   }
   ```

---

### Step 7: Update Main Screen Badge
**Files to modify:** `lib/screens/main_screen.dart`

**Changes:**
```dart
// Before
final nameCardCount = storage.nameCards.length;

// After
final connectionCount = storage.connections.length;

// Update badge label
label: Text('$connectionCount'),
isLabelVisible: connectionCount > 0,
```

---

### Step 8: Clean Up Old Models
**Files to delete:**
- `lib/models/user_profile.dart`
- `lib/models/name_card.dart`

**Verification:**
- Run global search for `UserProfile` and `NameCard` references
- Ensure all replaced
- Delete files

---

## Data Migration Considerations

### Migration Strategy for Existing Users

**Option A: One-time migration on app startup**
```dart
Future<void> migrateOldData() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Check if old data exists
  final oldProfileJson = prefs.getString('user_profile');
  if (oldProfileJson != null && !prefs.containsKey('current_profile')) {
    // Parse old UserProfile
    final oldProfile = UserProfile.fromJson(jsonDecode(oldProfileJson));
    
    // Create new Profile with generated ID
    final newProfile = Profile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: oldProfile.userName,
      school: oldProfile.school,
      major: oldProfile.major,
      interests: oldProfile.interests,
      background: oldProfile.background,
      profileImagePath: oldProfile.profileImagePath,
    );
    
    // Save as new format
    await prefs.setString('current_profile', jsonEncode(newProfile.toJson()));
    
    // Clean up old key
    await prefs.remove('user_profile');
  }
  
  // Note: Old nameCards cannot be migrated because we don't have profile images
  // User will need to re-collect connections (acceptable for beta/development)
}
```

**Option B: Fresh start**
- Since app appears to be in development (no persistence of nameCards currently)
- Simply clear all old data on first launch with new version
- Users re-create profiles and reconnect

**Recommendation**: Use Option A to preserve user profiles, accept loss of old connections (since they lack images anyway).

---

## Testing Checklist

### Unit Tests
- [ ] Profile model serialization (toJson/fromJson)
- [ ] Connection model serialization
- [ ] Profile equality (by ID)
- [ ] Connection equality (by ID)

### Integration Tests
- [ ] StorageService: Save and load current profile
- [ ] StorageService: Create connection
- [ ] StorageService: Get profile by ID
- [ ] StorageService: Get connected profiles list

### UI Tests
- [ ] Profile setup flow with new Profile model
- [ ] Edit profile updates currentProfile correctly
- [ ] Profile tab displays profile with image
- [ ] Network graph shows only current user when connections.isEmpty
- [ ] Network graph shows real connections (not mock data)
- [ ] Network nodes display profile images
- [ ] Grid view shows connections with images
- [ ] Connection detail modal shows profile + meeting info
- [ ] Badge shows correct connection count

### Platform Tests
- [ ] Web: Profile images work (base64 data URLs)
- [ ] Mobile: Profile images work (file paths)
- [ ] Web: Network nodes render with images
- [ ] Mobile: Network nodes render with images

---

## Risks & Mitigations

### Risk 1: Profile Image Storage for Peers
**Problem**: When collecting NameCard from Peer, how do we get their profile image?

**Options:**
1. **Store image URL in Peer model** (requires backend/P2P exchange)
2. **Default to avatar with initials** (current behavior, acceptable)
3. **Allow user to manually add photo later** (future enhancement)

**Recommendation**: Use option 2 initially (initials), plan for option 1 with backend.

### Risk 2: Network Graph Performance
**Problem**: Rendering many profile images in graph could be slow

**Mitigations:**
- Use CircleAvatar caching
- Limit visible nodes (show top N connections)
- Add pagination/filtering for large networks

### Risk 3: Data Migration
**Problem**: Existing users lose their NameCards

**Mitigation:**
- Clear communication to users about reset
- Only affects development/beta users
- Implement Option A migration to preserve profiles

---

## Future Enhancements

1. **Bidirectional Connections**: Track if connection is mutual
2. **Connection Notes**: Allow user to add notes to connections
3. **Profile Image Exchange**: P2P or backend image sharing during invitation
4. **Connection Strength**: Track interaction frequency, last contact
5. **Search/Filter**: Search connections by name, school, interests
6. **Export/Import**: Backup and restore connections
7. **Privacy**: Allow users to hide/show certain profile fields per connection

---

## Summary

This refactoring consolidates duplicate code, improves data architecture, and enables new features (profile images in network, empty state handling). The change is significant but well-scoped:

- **New files**: 2 (profile.dart, connection.dart)
- **Modified files**: ~8 (storage_service, network_tab, profile screens, main_screen, peer)
- **Deleted files**: 2 (user_profile.dart, name_card.dart)
- **Breaking change**: Yes (data structure changes require migration)
- **User impact**: Minimal if migration handled properly

**Estimated effort**: 4-6 hours for implementation + testing
