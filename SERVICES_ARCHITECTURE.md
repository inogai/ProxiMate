# ProxiMate Services Architecture Documentation

## Overview

The ProxiMate application implements a service-oriented architecture with four main service classes that handle different aspects of the application's functionality. These services work together to provide a seamless social networking experience focused on location-based connections and activities.

## Service Components

### 1. ApiService (`lib/services/api_service.dart`)

**Purpose**: Handles all HTTP communication with the backend REST API server.

**Key Features**:

- **API Client Management**: Initializes and manages multiple API endpoints (Users, Locations, Activities, Chatrooms, Messages, Connections)
- **Retry Mechanism**: Implements exponential backoff retry logic for failed requests
- **Error Handling**: Comprehensive error handling for network issues, timeouts, and API errors
- **Base URL Configuration**: Dynamic base URL configuration for different environments

**Core Methods**:

- `createUser()`: Creates new user accounts
- `getOrCreateUser()`: Retrieves existing user or creates new one
- `updateUser()`: Updates user profile information
- `getUser()`: Retrieves user by ID
- `getUserByUsername()`: Retrieves user by username
- `createLocation()`: Stores location data
- `getUserLocations()`: Retrieves location history
- `checkHealth()`: Verifies API server availability
- `getTwoHopConnections()`: Retrieves friends-of-friends connections

**Configuration**:

```dart
ApiService({
  String baseUrl = 'http://localhost:8000', // Default local development
  int maxRetries = 3,
  Duration timeout = const Duration(seconds: 30),
})
```

### 2. LocationService (`lib/services/location_service.dart`)

**Purpose**: Manages GPS location tracking, permissions, and location updates.

**Key Features**:

- **Permission Management**: Handles location permission requests and status checks
- **Location Accuracy Fallback**: Attempts multiple accuracy levels (high → medium → low)
- **Background Tracking**: Supports continuous location updates via streaming
- **Location Services Integration**: Integrates with device location services

### Core Methods

**Permission Flow**:

1. Check if location services are enabled
2. Verify current permission status
3. Request permissions if denied
4. Handle permanent denial scenarios
5. Fetch location with progressive accuracy fallback

### 3. StorageService (`lib/services/storage_service.dart`)

**Purpose**: Central data management service that coordinates between API and local state.

**Key Features**:

- **State Management**: Implements ChangeNotifier for reactive UI updates
- **Data Synchronization**: Manages periodic synchronization with backend
- **Timer-based Polling**: Implements multiple timers for different data types
- **Connection Management**: Handles user connections and relationship mapping
- **Activity Management**: Coordinates activity-related operations

**Core Data Properties**:

- `_currentProfile`: Currently logged-in user profile
- `_connections`: User's connection list
- `_nearbyPeers`: Proximity-based peer discovery
- `_invitations`: Pending connection invitations
- `_chatRooms`: User's chat rooms
- `_activities`: Available activities
- `_userRatings`: User rating information

**Timers for Synchronization**:

- `_invitationFetchTimer`: Periodic invitation updates
- `_messageFetchTimer`: Chat message polling
- `_connectionSyncTimer`: Connection synchronization
- `_nearbyPeersTimer`: Nearby peers updates
- `_activitiesTimer`: Activity updates

**Key Methods**:

- `saveUserName()`: Creates new user profile
- `updateProfile()`: Updates existing profile
- `getConnectedProfiles()`: Retrieves user's connections
- `getTwoHopConnectionsWithMapping()`: Friends-of-friends with relationship mapping
- `clearProfile()`: Logs out user and clears data

### 4. StorageServiceWrapper (`lib/services/storage_service_wrapper.dart`)

**Purpose**: Provides a user-friendly wrapper around StorageService with error handling and UI notifications.

**Key Features**:

- **Error Handling**: Wraps storage operations with try-catch blocks
- **Toast Notifications**: Provides user feedback for operations
- **Context Integration**: Integrates with Flutter's BuildContext for UI operations
- **Simplified Interface**: Offers simplified methods for common operations

**Core Methods**:

- `saveUserName()`: Creates profile with success/error notifications
- `updateProfile()`: Updates profile with user feedback
- `testApiConnection()`: Tests API connectivity
- `clearProfile()`: Logs out user with confirmation

## Service Interactions

### Data Flow Architecture

```text
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UI Components │───▶│StorageService    │───▶│   ApiService    │
│                 │◀───│                  │◀───│                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │ LocationService  │
                       │                  │
                       └──────────────────┘
```

### Service Dependencies

1. **StorageService** depends on:
   - ApiService for backend communication
   - LocationService for location tracking

2. **LocationService** depends on:
   - ApiService for location data transmission

3. **StorageServiceWrapper** depends on:
   - StorageService for core operations
   - ApiService for direct API calls

4. **ApiService** is independent and serves as the foundation

## Data Models

The services work with several key data models:

### Profile (`lib/models/profile.dart`)

Represents user profiles with:

- Basic information (id, userName)
- Academic details (school, major)
- Personal details (interests, background)
- Profile image path

### Connection (`lib/models/connection.dart`)

Represents relationships between users with:

- Connection participants (fromProfileId, toProfileId)
- Connection metadata (restaurant, collectedAt)
- Status tracking (pending, accepted, declined)
- Optional notes

### Other Models

- **Activity**: Represents social activities
- **Meeting**: Handles meeting arrangements
- **Peer**: Represents nearby users
- **UserRating**: Stores user ratings

## Error Handling Strategy

### ApiService Error Handling

- Implements retry mechanism with exponential backoff
- Handles network errors, timeouts, and API errors
- Provides detailed error logging

### StorageService Error Handling

- Uses ChangeNotifier for reactive error state
- Graceful degradation when API is unavailable
- Comprehensive logging for debugging

### StorageServiceWrapper Error Handling

- User-friendly error messages via toast notifications
- Context-aware error handling
- Prevents UI crashes from service errors

## Synchronization Strategy

The application uses a multi-timer approach for data synchronization:

1. **Invitation Updates**: Periodic polling for new invitations
2. **Message Updates**: Real-time message synchronization
3. **Connection Sync**: Regular connection status updates
4. **Nearby Peers**: Location-based peer discovery updates
5. **Activity Updates**: Activity list synchronization

## Security Considerations

1. **API Communication**: All API calls should use HTTPS in production
2. **Location Data**: Location permissions are properly requested and handled
3. **User Data**: Profile data is validated before transmission
4. **Error Information**: Sensitive information is not exposed in error messages

## Performance Optimizations

1. **Retry Logic**: Prevents unnecessary repeated requests
2. **Timer Management**: Proper cleanup of timers to prevent memory leaks
3. **State Management**: Efficient state updates using ChangeNotifier
4. **Data Caching**: Last known positions and data are cached for offline scenarios

## Usage Examples

### Creating a New User Profile

```dart
// Using StorageServiceWrapper
final wrapper = StorageServiceWrapper(context);
await wrapper.saveUserName("new_username");

// Using StorageService directly
await storageService.saveUserName("new_username");
```

### Getting Current Location

```dart
final locationService = LocationService(apiService);
final position = await locationService.getCurrentLocation();
if (position != null) {
  print("Location: ${position.latitude}, ${position.longitude}");
}
```

### Testing API Connectivity

```dart
final wrapper = StorageServiceWrapper(context);
bool isHealthy = await wrapper.testApiConnection();
```

## Future Enhancements

1. **Offline Support**: Add local storage fallbacks
2. **Real-time Updates**: Implement WebSocket connections
3. **Caching Strategy**: Implement intelligent data caching
4. **Background Processing**: Optimize background synchronization
5. **Security**: Add authentication token management

## Conclusion

The services architecture in ProxiMate provides a robust foundation for building a location-based social networking application. The separation of concerns between API communication, location tracking, data management, and user interface handling creates a maintainable and scalable codebase.

The use of Flutter's ChangeNotifier pattern enables reactive UI updates, while the retry mechanisms and error handling ensure a reliable user experience even in challenging network conditions.

This architecture is designed to support future enhancements such as offline capabilities, real-time updates, and improved caching strategies, making it well-suited for the evolving needs of a social networking platform.
