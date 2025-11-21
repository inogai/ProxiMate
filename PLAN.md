# Backend Integration Plan - Replace Mock Invite & Chat with Real Backend

## Current State Analysis

### Available Backend Endpoints ✅
- `POST /users/` - Create User
- `GET /users/` - Get Users (with filtering)
- `GET /users/nearby` - Get Nearby Users
- `POST /locations/` - Create Location
- `GET /locations/{user_id}` - Get User Locations
- `GET /locations/batch` - Get Batch Locations
- `GET /health` - Health Check

### Current Mock Implementations ❌
- **Invitation System**: Auto-response timers, local storage only
- **Chat System**: Simulated responses, no real-time messaging
- **Activity Management**: Local state management
- **Connections**: Name card collection stored locally

## Required Backend Endpoints

### 1. Invitation Management (High Priority)

#### Core Invitation Endpoints
```
POST   /invitations/              # Send invitation
GET    /invitations/              # Get user's invitations (sent & received)
GET    /invitations/{id}          # Get invitation details
PUT    /invitations/{id}/accept   # Accept invitation
PUT    /invitations/{id}/decline  # Decline invitation
```

#### Required Data Models
```dart
class InvitationCreate {
  int senderId;
  int receiverId;
  int activityId;
  String? message;
  String? iceBreakerQuestion;
}

class InvitationRead {
  int id;
  int senderId;
  int receiverId;
  int activityId;
  String status; // PENDING, ACCEPTED, DECLINED
  DateTime createdAt;
  DateTime? respondedAt;
  String? message;
  String? iceBreakerQuestion;
}
```

### 2. Chat System (High Priority)

#### Chat Endpoints
```
POST   /chat/rooms/               # Create chat room
GET    /chat/rooms/               # Get user's chat rooms
GET    /chat/rooms/{id}           # Get chat room details
POST   /chat/messages/            # Send message
GET    /chat/rooms/{id}/messages  # Get chat history
```

#### Required Data Models
```dart
class ChatRoomCreate {
  int participant1Id;
  int participant2Id;
  int? invitationId; // Link to invitation that created this room
}

class ChatRoomRead {
  int id;
  int participant1Id;
  int participant2Id;
  int? invitationId;
  DateTime createdAt;
  DateTime? lastMessageAt;
}

class ChatMessageCreate {
  int chatRoomId;
  int senderId;
  String content;
  String messageType; // TEXT, IMAGE, etc.
}

class ChatMessageRead {
  int id;
  int chatRoomId;
  int senderId;
  String content;
  String messageType;
  DateTime createdAt;
  bool isRead;
}
```

### 3. Activity Management (Medium Priority)

#### Activity Endpoints
```
POST   /activities/               # Create activity
GET    /activities/               # Get user's activities
GET    /activities/{id}           # Get activity details
PUT    /activities/{id}           # Update activity
DELETE /activities/{id}           # Delete activity
```

#### Required Data Models
```dart
class ActivityCreate {
  int creatorId;
  String title;
  String description;
  String location;
  DateTime startTime;
  DateTime endTime;
  int maxParticipants;
  List<String> tags;
}

class ActivityRead {
  int id;
  int creatorId;
  String title;
  String description;
  String location;
  DateTime startTime;
  DateTime endTime;
  int maxParticipants;
  int currentParticipants;
  List<String> tags;
  DateTime createdAt;
  bool isActive;
}
```

### 4. Connections & Ratings (Medium Priority)

#### Connection Endpoints
```
POST   /connections/              # Collect name card
GET    /connections/              # Get user's connections
GET    /connections/{id}          # Get connection details
```

#### Rating Endpoints
```
POST   /ratings/                  # Rate user after meeting
GET    /ratings/user/{userId}     # Get user's ratings
```

#### Required Data Models
```dart
class ConnectionCreate {
  int collectorId;
  int collectedId;
  int? meetingId; // Link to meeting/activity
}

class ConnectionRead {
  int id;
  int collectorId;
  int collectedId;
  int? meetingId;
  DateTime collectedAt;
}

class RatingCreate {
  int raterId;
  int ratedId;
  int meetingId;
  int rating; // 1-5 stars
  String? comment;
}

class RatingRead {
  int id;
  int raterId;
  int ratedId;
  int meetingId;
  int rating;
  String? comment;
  DateTime createdAt;
}
```

## Implementation Plan

### Phase 1: Core Backend Integration (High Priority)

#### 1.1 Add Missing API Endpoints
- [ ] Implement invitation endpoints in backend
- [ ] Implement chat endpoints in backend
- [ ] Add WebSocket support for real-time chat
- [ ] Update OpenAPI specification
- [ ] Regenerate Flutter API client

#### 1.2 Replace Mock Functions in Flutter
- [ ] Update `storage_service.dart` invitation functions:
  - `sendInvitation()` → API call
  - `acceptInvitation()` → API call
  - `declineInvitation()` → API call
  - Remove mock functions (`mockReceiveInvitation`, etc.)
- [ ] Update `storage_service.dart` chat functions:
  - `sendMessage()` → API call + WebSocket
  - Remove `_simulatePeerMessage()`
  - `getChatRoomByPeerId()` → API call

#### 1.3 Remove Auto-Response System
- [ ] Remove timer logic from `activity_invitations_screen.dart:31-82`
- [ ] Remove mock acceptance/decline logic
- [ ] Update UI to handle real-time invitation status

### Phase 2: UI Updates & Real-time Features (Medium Priority)

#### 2.1 Update Invitation UI
- [ ] Add real-time invitation status updates
- [ ] Show "pending" state while waiting for response
- [ ] Handle invitation expiration
- [ ] Update invitation list UI with backend data

#### 2.2 Update Chat UI
- [ ] Implement real-time message delivery
- [ ] Add "read" receipts
- [ ] Handle connection status indicators
- [ ] Add typing indicators (optional)

#### 2.3 Error Handling & Offline Support
- [ ] Add proper error handling for API failures
- [ ] Implement offline message queuing
- [ ] Add retry mechanisms for failed requests
- [ ] Show connection status to users

### Phase 3: Additional Features (Low Priority)

#### 3.1 Activity Management
- [ ] Replace local activity management with backend
- [ ] Add activity creation/editing UI
- [ ] Implement activity participant management
- [ ] Add activity search and filtering

#### 3.2 Connections & Ratings
- [ ] Implement name card collection via API
- [ ] Add post-meeting rating system
- [ ] Display user ratings and reviews
- [ ] Add connection management UI

#### 3.3 Testing & Optimization
- [ ] End-to-end testing of invite/chat flow
- [ ] Performance optimization for real-time features
- [ ] Add comprehensive error logging
- [ ] Load testing for concurrent users

## Files to Modify

### Backend (New Files)
- `invitations.py` - Invitation endpoints and models
- `chat.py` - Chat endpoints and WebSocket handling
- `activities.py` - Activity management endpoints
- `connections.py` - Connection and rating endpoints
- `database/migrations/` - Database schema updates

### Flutter (Modified Files)
- `lib/services/api_service.dart` - Add new endpoint methods
- `lib/services/storage_service.dart` - Replace mock functions with API calls
- `lib/screens/activity_invitations_screen.dart` - Remove auto-response timer
- `lib/screens/chat_room_screen.dart` - Add real-time messaging
- `lib/screens/peer_detail_screen.dart` - Update invitation sending
- `lib/models/meeting.dart` - Update models for backend integration

## Success Criteria

### Phase 1 Success
- [ ] Invitations can be sent and received via backend
- [ ] Chat messages are sent and received in real-time
- [ ] No more mock data or auto-response timers
- [ ] All invitation and chat data persists in backend

### Phase 2 Success
- [ ] Real-time updates work smoothly in UI
- [ ] Error handling is comprehensive and user-friendly
- [ ] Offline functionality works correctly
- [ ] Performance is acceptable for real-time features

### Phase 3 Success
- [ ] All features work with backend (no local storage)
- [ ] Complete end-to-end flow tested and working
- [ ] System can handle multiple concurrent users
- [ ] Code is production-ready with proper error handling

## Notes

1. **WebSocket Implementation**: Chat will require WebSocket support for real-time messaging
2. **Database Schema**: Backend database will need new tables for invitations, chat rooms, messages, activities, connections, and ratings
3. **Authentication**: Current API has no authentication - consider adding JWT tokens for security
4. **Scalability**: Consider Redis for real-time features and message queuing
5. **Testing**: Each phase should include comprehensive testing before proceeding to the next