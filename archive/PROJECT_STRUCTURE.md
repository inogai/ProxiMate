# Peer Networking App

A modular and maintainable Flutter mobile application for connecting with nearby peers, getting restaurant recommendations, and building your network through in-person meetups.

## Complete User Flow

1. **Registration** → Enter your name
2. **Profile Setup** → Add school, major, interests, and background
3. **Main Screen** → Navigate between Home and Profile tabs
4. **Search Peers** → Find nearby peers with similar interests
5. **View Peer Profile** → See detailed information and match score
6. **Restaurant Recommendation** → Get suggestions for where to meet
7. **Chat & Decide** → Chat with peer and decide whether to meet
8. **Meeting Confirmation** → Wait for peer acceptance
9. **Meet Up** → Exchange name cards like Pokémon Go!

## Project Structure

```
lib/
├── main.dart                              # App entry point with provider setup
├── models/                                # Data models
│   ├── user_profile.dart                 # User profile data model
│   ├── peer.dart                         # Peer/match data model with match scoring
│   └── meeting.dart                      # Meeting/chat session model
├── services/                              # Business logic and data management
│   └── storage_service.dart              # Storage service managing users, peers, meetings
├── screens/                               # Full-screen pages
│   ├── register_screen.dart              # User registration (username only)
│   ├── profile_setup_screen.dart         # Profile setup (school, major, interests, background)
│   ├── main_screen.dart                  # Main app screen with tab navigation
│   ├── search_peers_screen.dart          # Search and browse nearby peers
│   ├── peer_detail_screen.dart           # Detailed peer profile view
│   ├── restaurant_recommendation_screen.dart # Restaurant suggestion
│   ├── chat_decision_screen.dart         # Chat and decide to meet
│   └── meeting_confirmation_screen.dart  # Meeting status and confirmation
└── widgets/                               # Reusable UI components
    ├── profile_tab.dart                  # Profile display tab
    └── home_tab.dart                     # Home tab with search entry point
```

## Features

### 1. Registration Screen
- Simple username input with validation
- Clean, modern UI with Material Design 3
- Smooth navigation to profile setup

### 2. Profile Setup Screen
- Collects additional user information:
  - School name
  - Major/field of study
  - Interests (used for matching)
  - Background
- Form validation for all fields
- Multi-line text input for longer responses

### 3. Main Screen with Navigation
- Tab-based navigation using NavigationBar
- **Home Tab**: Entry point for peer search and feature overview
- **Profile Tab**: User profile display
- Easily extensible for additional tabs

### 4. Peer Search & Matching
- Search for nearby peers based on profile
- **Smart matching algorithm** that considers:
  - Same school (30% weight)
  - Same major (30% weight)
  - Common interests (40% weight)
- Visual match percentage badges
- Sorted by match score (highest first)
- Mock data generation based on user profile

### 5. Peer Profile View
- Detailed peer information display
- Match score prominently shown
- "Connect & Chat" action button
- Visual hierarchy with cards and icons

### 6. Restaurant Recommendations
- AI-powered restaurant suggestions (mock)
- "Try Another" option to get different suggestions
- Context-aware based on peer selection
- Smooth transition to chat

### 7. Chat & Decision Interface
- Simple chat interface with the peer
- Mock conversation with automatic responses
- Two decision options:
  - "Not interested" - politely decline
  - "Let's meet!" - proceed with meeting
- Restaurant info banner

### 8. Meeting Confirmation
- Meeting details card with:
  - Peer name
  - Restaurant location
  - Scheduled time
- Real-time status updates
- Simulated peer acceptance (3-second delay)
- **Pokémon Go-style concept**: Exchange name cards when meeting

### 9. Profile Management
- View complete user profile
- Logout functionality with confirmation
- Clean card-based layout

## Architecture Highlights

### State Management
- Uses **Provider** package for simple and effective state management
- `StorageService` extends `ChangeNotifier` for reactive updates
- Clean separation between UI and business logic
- Centralized state management for users, peers, and meetings

### Modularity
- **Models**: Separate data structures with proper encapsulation
  - `UserProfile`: User data with copyWith pattern
  - `Peer`: Peer data with match scoring algorithm
  - `Meeting`: Meeting/session data with status tracking
- **Services**: Centralized business logic and data management
  - Mock API calls with realistic delays
  - Simulated peer responses
  - Restaurant recommendation system
- **Screens**: Individual full-screen pages with single responsibility
- **Widgets**: Reusable UI components

### Code Quality
- Proper null safety implementation
- Form validation throughout
- Resource cleanup (TextEditingController disposal)
- Proper use of const constructors for performance
- Async/await patterns for simulated API calls
- Proper navigation stack management

### Smart Features
- **Match Score Algorithm**: Calculates compatibility based on:
  - School affinity
  - Major similarity
  - Interest overlap using text analysis
- **Mock Data Generation**: Creates realistic peers based on user profile
- **Simulated Networking**: Realistic async behavior with delays
- **State Persistence**: In-memory storage across screens

## Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## Flow Diagram Implementation

The app implements the complete flow shown in the diagram:

```
Open App → Register → Profile Setup → Main Screen (Home Tab)
    ↓
Search Peers (with matching algorithm)
    ↓
View Peer Profiles (with match scores)
    ↓
Restaurant Recommendation
    ↓
Chat & Decide (accept/decline)
    ↓
Meeting Confirmation (waiting for peer)
    ↓
Meet Up & Exchange Name Cards (Pokémon Go style)
```

## Future Enhancements

### Backend Integration
- Real API calls to backend services
- Persistent storage using shared_preferences or local database
- Real-time chat using WebSockets or Firebase
- Actual geolocation for finding nearby peers
- Push notifications for meeting confirmations

### Features
- Name card collection system (like Pokémon Go)
- View collected name cards in Profile
- Meeting history and statistics
- Profile editing functionality
- Image upload for profile picture
- Real restaurant recommendations via Google Places API
- Calendar integration for meeting scheduling
- In-app navigation to restaurant
- Rating system after meetings

### UI/UX
- Animations and transitions
- Custom themes and dark mode
- Onboarding tutorial
- Achievement system
- Social sharing features

## Dependencies

- `flutter`: SDK
- `provider`: ^6.1.2 - State management
- `cupertino_icons`: ^1.0.8 - iOS-style icons

## Notes

- Currently uses in-memory storage (data is lost on app restart)
- Ready for persistent storage integration
- Follows Flutter best practices and Material Design guidelines
