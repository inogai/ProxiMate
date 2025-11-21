# ProxiMate API Integration Plan

## Overview
This document outlines the plan to integrate real backend API data into the ProxiMate Flutter app, replacing the current mock data implementation with live data from the REST API.

## API Analysis

### Available Endpoints
The backend provides the following key endpoints:

#### User Management
- `POST /users/` - Create new user
- `GET /users/{user_id}` - Get user details
- `PUT /users/{user_id}` - Update user information

#### Location Services
- `POST /locations/` - Create/update user location
- `GET /locations/{user_id}` - Get user locations

#### System
- `GET /health` - Health check
- `GET /` - Root endpoint

### Data Models

#### User Models
**UserCreate** (Request):
- `username` (String, required)
- `school` (String, optional, default: '')
- `major` (String, optional, default: '')
- `interests` (String, optional, default: '')
- `bio` (String, optional, default: '')
- `avatarUrl` (String, optional, default: '')

**UserRead** (Response):
- All UserCreate fields plus:
- `id` (int)
- `createdAt` (DateTime)

#### Location Models
**LocationCreate** (Request):
- `latitude` (num, required)
- `longitude` (num, required)
- `userId` (int, required)

**LocationRead** (Response):
- All LocationCreate fields plus:
- `id` (int)
- `timestamp` (DateTime)

## Integration Plan

### Phase 1: API Service Layer
**Objective**: Create a robust API service to handle all backend communications.

**Tasks**:
1. **Create API Service** (`lib/services/api_service.dart`)
   - Initialize OpenAPI client with configurable base URL
   - Implement authentication headers (if needed)
   - Add comprehensive error handling and retry logic
   - Create model converters between API models and app models
   - Add logging for debugging

**Implementation Details**:
```dart
class ApiService {
  late DefaultApi _api;
  String _baseUrl;
  
  ApiService({String baseUrl = 'http://localhost'}) : _baseUrl = baseUrl {
    _api = Openapi(baseUrl: _baseUrl).getDefaultApi();
  }
  
  // User operations
  Future<UserRead> createUser(UserCreate user);
  Future<UserRead> updateUser(int userId, UserUpdate user);
  Future<UserRead> getUser(int userId);
  
  // Location operations
  Future<LocationRead> createLocation(LocationCreate location);
  Future<BuiltList<LocationRead>> getUserLocations(int userId);
  
  // Model converters
  Profile userReadToProfile(UserRead user);
  UserCreate profileToUserCreate(Profile profile);
  Peer userReadToPeer(UserRead user, LocationRead? location);
}
```

### Phase 2: User Management Integration
**Objective**: Replace mock user creation and management with real API calls.

**Tasks**:
1. **Update Storage Service** (`lib/services/storage_service.dart`)
   - Replace `saveUserName()` with API user creation
   - Replace `updateProfile()` with API user updates
   - Implement local caching for offline support
   - Add sync mechanisms for data consistency
   - Handle ID conversion (API uses int, app uses String)

**Implementation Details**:
```dart
// In StorageService
Future<void> saveUserName(String userName) async {
  try {
    final userCreate = UserCreate((b) => b..username = userName);
    final userRead = await _apiService.createUser(userCreate);
    
    _currentProfile = _apiService.userReadToProfile(userRead);
    await _persistCurrentProfile();
    notifyListeners();
  } catch (e) {
    // Handle error, maybe fallback to local storage
    debugPrint('Error creating user: $e');
  }
}
```

### Phase 3: Location Services
**Objective**: Implement real-time location tracking and proximity-based user discovery.

**Tasks**:
1. **Create Location Service** (`lib/services/location_service.dart`)
   - Request location permissions from user
   - Implement periodic location updates
   - Post location data to backend
   - Fetch nearby users' locations
   - Calculate distances between users
   - Handle location privacy settings

**Implementation Details**:
```dart
class LocationService {
  final ApiService _apiService;
  Timer? _locationTimer;
  
  Future<void> startLocationTracking(int userId) async {
    // Request permissions
    // Start periodic updates
    _locationTimer = Timer.periodic(Duration(minutes: 5), (_) {
      _updateLocation(userId);
    });
  }
  
  Future<void> _updateLocation(int userId) async {
    final position = await Geolocator.getCurrentPosition();
    final locationCreate = LocationCreate((b) => b
      ..latitude = position.latitude
      ..longitude = position.longitude
      ..userId = userId);
    
    await _apiService.createLocation(locationCreate);
  }
}
```

### Phase 4: Real-time Peer Discovery
**Objective**: Replace mock peer generation with real user discovery based on location.

**Tasks**:
1. **Enhance Peer Search** (`lib/services/storage_service.dart`)
   - Replace `_generateMockPeers()` with API calls
   - Implement location-based filtering
   - Maintain existing match scoring algorithm
   - Add real-time updates when new users are nearby
   - Handle user online/offline status

**Implementation Details**:
```dart
Future<List<Peer>> searchNearbyPeers() async {
  if (_currentProfile == null) return [];
  
  try {
    // Get current user's ID (convert from String to int)
    final userId = int.parse(_currentProfile!.id);
    
    // Get all users (this might need a new endpoint in the backend)
    // For now, we'll work with existing endpoints
    final allUsers = await _apiService.getAllUsers(); // Might need to implement
    
    // Get locations for all users
    final nearbyPeers = <Peer>[];
    
    for (final user in allUsers) {
      if (user.id == userId) continue; // Skip self
      
      final locations = await _apiService.getUserLocations(user.id);
      if (locations.isNotEmpty) {
        final latestLocation = locations.last;
        final distance = _calculateDistance(
          _currentLocation!, 
          latestLocation
        );
        
        if (distance <= 5.0) { // Within 5km
          final peer = _apiService.userReadToPeer(user, latestLocation);
          nearbyPeers.add(peer);
        }
      }
    }
    
    _nearbyPeers = nearbyPeers;
    notifyListeners();
    return nearbyPeers;
  } catch (e) {
    debugPrint('Error searching nearby peers: $e');
    return [];
  }
}
```

### Phase 5: Data Synchronization
**Objective**: Ensure data consistency between local cache and remote API.

**Tasks**:
1. **Implement Sync Strategy**
   - Cache all API responses locally using SharedPreferences
   - Implement background sync when network is available
   - Add conflict resolution for concurrent updates
   - Use progressive loading for better UX
   - Implement data versioning to handle schema changes

**Implementation Details**:
```dart
class SyncService {
  final ApiService _apiService;
  final StorageService _storageService;
  
  Future<void> syncUserData() async {
    try {
      // Sync current user profile
      if (_storageService.currentProfile != null) {
        final userId = int.parse(_storageService.currentProfile!.id);
        final apiUser = await _apiService.getUser(userId);
        final localProfile = _storageService.currentProfile!;
        
        // Compare timestamps and sync if needed
        if (apiUser.createdAt.isAfter(localProfile.lastUpdated)) {
          final updatedProfile = _apiService.userReadToProfile(apiUser);
          await _storageService.updateProfileFromSync(updatedProfile);
        }
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }
}
```

### Phase 6: Error Handling & UX
**Objective**: Provide robust error handling and maintain good user experience.

**Tasks**:
1. **Implement Comprehensive Error Management**
   - Add network connectivity checks
   - Implement graceful fallbacks to cached data
   - Show user-friendly error messages
   - Add loading states during API calls
   - Implement retry mechanisms with exponential backoff

**Implementation Details**:
```dart
class NetworkAwareService {
  Future<T> withNetworkFallback<T>(
    Future<T> Function() networkCall,
    T Function() fallbackCall,
  ) async {
    try {
      final hasNetwork = await Connectivity().checkConnectivity();
      if (hasNetwork != ConnectivityResult.none) {
        return await networkCall();
      }
    } catch (e) {
      debugPrint('Network call failed: $e');
    }
    
    return fallbackCall();
  }
}
```

### Phase 7: Testing & Optimization
**Objective**: Ensure reliability and performance of the integrated system.

**Tasks**:
1. **Testing Strategy**
   - Create mock API responses for unit testing
   - Write integration tests for all API flows
   - Add performance benchmarks for API calls
   - Optimize battery usage for location tracking
   - Test offline functionality thoroughly

2. **Performance Optimization**
   - Implement request batching where possible
   - Add response caching with TTL
   - Optimize image loading for avatar URLs
   - Use pagination for large datasets

## Key Implementation Details

### Model Mapping
| API Field | App Field | Notes |
|-----------|-----------|-------|
| `UserRead.bio` | `Profile.background` | Semantic name change |
| `UserRead.avatarUrl` | `Profile.profileImagePath` | Handle both local and remote URLs |
| `UserRead.id` (int) | `Profile.id` (String) | Convert int to string for consistency |
| `UserRead.createdAt` | `Profile.lastUpdated` | Track sync timestamps |

### Location Integration
- Request location permissions on app startup
- Update location every 5 minutes (configurable)
- Use location data for distance-based filtering
- Respect user privacy settings and battery life
- Implement geofencing for automatic check-ins

### Offline Support
- Cache all API responses locally
- Allow full functionality with cached data
- Sync changes when network is restored
- Handle conflicts using last-write-wins strategy
- Provide visual indicators for offline mode

### Security Considerations
- Validate all user inputs before sending to API
- Sanitize data received from backend
- Implement rate limiting for API calls
- Handle authentication tokens securely
- Log security events appropriately

## Migration Strategy

### Gradual Rollout
1. **Phase 1-2**: Implement user management with feature flag
2. **Phase 3-4**: Add location services to beta users
3. **Phase 5-6**: Full rollout with sync and error handling
4. **Phase 7**: Performance optimization and testing

### Backward Compatibility
- Maintain existing mock data as fallback
- Allow users to continue using app offline
- Provide migration path for existing local data
- Ensure smooth transition without data loss

### Monitoring & Analytics
- Track API call success/failure rates
- Monitor user engagement with real features
- Measure performance impact vs mock data
- Collect user feedback on new functionality

## Success Metrics

### Technical Metrics
- API response time < 500ms
- 99.9% uptime for critical features
- < 5% battery drain from location tracking
- 100% data consistency between client and server

### User Experience Metrics
- Seamless transition from mock to real data
- Improved match quality with real location data
- Higher engagement with real user interactions
- Positive user feedback on new features

## Conclusion

This integration plan provides a comprehensive roadmap for replacing mock data with real API integration while maintaining the excellent user experience of the ProxiMate app. The phased approach allows for careful testing and gradual rollout, ensuring reliability and performance at each stage.

The implementation focuses on:
- **Robust error handling** for network issues
- **Offline support** for uninterrupted usage
- **Performance optimization** for battery and data usage
- **Seamless user experience** throughout the transition
- **Scalable architecture** for future enhancements

By following this plan, ProxiMate will evolve from a prototype with mock data to a production-ready social networking application with real-time location-based user discovery.