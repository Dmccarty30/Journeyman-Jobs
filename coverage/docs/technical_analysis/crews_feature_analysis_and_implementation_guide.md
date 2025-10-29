# Crews Feature Technical Analysis & Implementation Guide

## Executive Summary

The Crews feature in Journeyman Jobs is **70% complete** with excellent architecture, comprehensive models, and robust real-time capabilities. However, several critical gaps prevent full functionality:

- **Security**: Firebase rules in development mode (all authenticated users have full access)
- **Invitation System**: Service exists but providers return empty lists
- **User Discovery**: No way to search for or invite users
- **Crew Authentication**: No dedicated crew-specific authentication service

This document provides a complete technical analysis and implementation guide to restore full functionality.

---

## 1. Current State Analysis

### 1.1 What's Implemented ✅

#### **Core Models (Complete)**

- `CrewModel` - Basic crew structure with foreman, members, job preferences
- `CrewInvitationModel` - Comprehensive invitation system with 5 status types
- `CrewMessageModel` - Rich messaging with multiple types, reactions, read status
- `CrewPreferences` - Job preference configuration
- `PostModel` - Feed posts with reactions and comments

#### **Services (Mostly Complete)**

- `CrewService` - Full CRUD operations for crews
- `CrewMessagingService` - Real-time messaging with Firestore
- `CrewInvitationService` - Complete implementation (494 lines)
- `FeedService` - Post creation and feed functionality

#### **UI Components (Complete)**

- `CreateCrewScreen` - Full-featured crew creation with preferences dialog
- `CrewChatScreen` - Complete chat interface
- `CrewInvitationsScreen` - Two versions (basic and advanced)
- `CrewInvitationCard` - Beautiful animated card with electrical theme
- `TailboardScreen` - Main crew dashboard

#### **State Management (Complete)**

- `CrewsRiverpodProvider` - Comprehensive state management
- `FeedProvider` - Post and feed state
- `CrewJobsRiverpodProvider` - Job-related crew state
- `CrewSelectionProvider` - Crew selection state

#### **Authentication (Robust)**

- Multi-provider auth (email, Google, Apple)
- Session timeout with grace periods
- Rate limiting and input validation
- 24-hour session validity
- Automatic token refresh

### 1.2 Critical Gaps ❌

#### **1. Firebase Security Rules (DEV MODE)**

```javascript
// Current: All authenticated users have full access
match /crews/{crewId} {
  allow read, write: if isAuthenticated(); // 🚨 SECURITY RISK
}
```

#### **2. Riverpod Providers (Empty)**

```dart
@riverpod
List<CrewInvitation> pendingInvitations(Ref ref) {
  // TODO: Implement actual invitation fetching from Firestore
  return []; // 🚨 Returns empty list
}
```

#### **3. User Discovery (Missing)**

- No user search functionality
- No way to find users to invite
- No crew browsing for public crews

#### **4. Permission System (Bypassed)**

```dart
// DEV MODE: Permission check bypassed
/* PRODUCTION CODE:
if (!await hasPermission(crewId: crewId, userId: inviterId, permission: Permission.inviteMember)) {
  throw CrewException('Insufficient permissions', code: 'permission-denied');
}
*/
```

---

## 2. Detailed Component Analysis

### 2.1 Authentication & Session Management

#### **Current Implementation**

- Strong foundation with Firebase Auth
- Multiple timeout systems (2-min + 5-min grace, 20-min + 15-min grace)
- Comprehensive input validation and rate limiting
- Role-based access control enums defined

#### **Missing Components**

1. **Crew-Specific Authentication Service**

   ```dart
   class CrewAuthService {
     Future<bool> verifyCrewPermission(String userId, String crewId, Permission permission);
     Future<void> authenticateForCrew(String crewId);
     Future<String> generateCrewSessionToken(String crewId, String userId);
   }
   ```

2. **Multi-Factor Authentication (MFA)**
   - Phone verification for sensitive operations
   - TOTP support for crew administrators
   - Device trust scoring

3. **Session Isolation per Crew**
   - Separate session management for each crew
   - Crew-specific activity tracking
   - Permission-based session validity

### 2.2 Crew Creation Flow

#### **Current Flow**

1. User fills crew creation form (name, description, job type)
2. Preferences dialog opens for job preferences
3. `CrewService.createCrew()` called with preferences
4. Document created in `crews` collection
5. User becomes foreman automatically

#### **Dependencies**

- User must be authenticated
- CrewPreferences dialog must complete
- Firestore write permissions needed
- Navigation to TailboardScreen after creation

#### **Missing Validations**

- Crew name uniqueness check
- Foreman eligibility verification
- Crew size limits
- Subscription tier validation

### 2.3 Invitation System Architecture

#### **Data Models**

```dart
class CrewInvitationModel {
  final String id;
  final String crewId;
  final String inviterId;
  final String inviteeId;
  final String inviteeEmail;
  final CrewInvitationStatus status; // pending, accepted, declined, cancelled, expired
  final Timestamp createdAt;
  final Timestamp expiresAt; // 7 days
  final String? message;
  final Map<String, dynamic>? metadata;
}
```

#### **Service Implementation**

The `CrewInvitationService` is complete with:

- CRUD operations for invitations
- Real-time streaming
- Notification integration
- Batch cleanup operations
- Expiration handling

#### **Critical Gap: Provider Implementation**

The UI screens depend on providers that return empty lists:

```dart
// lib/features/crews/providers/crews_riverpod_provider.dart

@riverpod
List<CrewInvitation> pendingInvitations(Ref ref) {
  // TODO: Implement actual invitation fetching from Firestore
  return [];
}

@riverpod
List<CrewInvitation> sentInvitations(Ref ref) {
  // TODO: Implement actual invitation fetching from Firestore
  return [];
}
```

### 2.4 Chat/Messaging System

#### **Architecture**

- Messages stored in `crewMessages` collection
- Conversations tracked in `crewConversations` collection
- Real-time updates via Firestore streams
- Support for multiple message types (text, image, location, job share)

#### **Features**

- Message reactions and read status
- Reply threading
- Message editing and deletion
- Media sharing
- Push notifications

#### **Missing Components**

1. **Message Encryption**

   ```dart
   class MessageEncryption {
     Future<String> encryptMessage(String content, List<String> recipientIds);
     Future<String> decryptMessage(String encryptedContent, String userId);
   }
   ```

2. **Message Moderation**
   - Automated content filtering
   - Report system for inappropriate messages
   - Admin moderation tools

3. **Advanced Search**
   - Full-text search across messages
   - Filter by date, sender, or type
   - Export conversation history

### 2.5 Feed/Posting System

#### **Implementation**

- Posts stored in `posts` collection with crew association
- Support for text and media posts
- Reaction system (likes, emojis)
- Comment threading
- Pin important posts

#### **Public Feed Requirements**

The feed needs to support:

1. **Global Feed**: All posts from all crews
2. **Crew-Specific Feed**: Posts from user's crews only
3. **Filtered Feed**: Based on user preferences

#### **Missing Features**

1. **Content Moderation**
   - Automated content filtering
   - Report system
   - Admin review queue

2. **Feed Algorithm**
   - Relevance scoring
   - Engagement-based sorting
   - Personalized content ranking

---

## 3. Firebase Security Rules Analysis

### 3.1 Current State (Development Mode)

```javascript
// firebase/firestore.rules - CURRENT IMPLEMENTATION

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // DEV MODE: All authenticated users have full access
    match /crews/{crewId} {
      allow read, write: if isAuthenticated(); // 🚨 SECURITY RISK
    }
  }
}
```

### 3.2 Required Production Rules

```javascript
// REQUIRED PRODUCTION SECURITY RULES

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isCrewMember(crewId) {
      return exists(/databases/$(database)/documents/crews/$(crewId)) &&
             request.auth.uid in resource.data.memberIds;
    }

    function isCrewForeman(crewId) {
      return exists(/databases/$(database)/documents/crews/$(crewId)) &&
             request.auth.uid == resource.data.foremanId;
    }

    function hasPermission(crewId, permission) {
      // Check user role and permissions
      return isCrewMember(crewId) ||
             (permission == 'read' && resource.data.visibility == 'public');
    }

    // Users collection
    match /users/{userId} {
      allow read, write: if isAuthenticated() && request.auth.uid == userId;
    }

    // Crews collection
    match /crews/{crewId} {
      // Read access for members and public crews
      allow read: if isCrewMember(crewId) ||
                    (resource.data.visibility == 'public');

      // Create: Any authenticated user can create a crew
      allow create: if isAuthenticated() &&
                     request.resource.data.foremanId == request.auth.uid;

      // Update: Only foreman can update crew details
      allow update: if isCrewForeman(crewId);

      // Delete: Only foreman can delete crew
      allow delete: if isCrewForeman(crewId);

      // Members subcollection
      match /members/{memberId} {
        allow read: if isCrewMember(crewId);
        allow write: if isCrewForeman(crewId);
        allow create: if isCrewForeman(crewId);
        allow delete: if isCrewForeman(crewId);
      }

      // Invitations subcollection
      match /invitations/{invitationId} {
        allow read: if isCrewMember(crewId) ||
                      resource.data.inviteeId == request.auth.uid ||
                      resource.data.inviterId == request.auth.uid;

        allow create: if isCrewForeman(crewId) ||
                      (resource.data.inviterId == request.auth.uid &&
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.permissions.contains('inviteMember'));

        allow update: if (resource.data.inviteeId == request.auth.uid &&
                         request.resource.data.status in ['accepted', 'declined']) ||
                        (resource.data.inviterId == request.auth.uid &&
                         request.resource.data.status == 'cancelled');

        allow delete: if isCrewForeman(crewId) ||
                      resource.data.inviterId == request.auth.uid;
      }

      // Feed posts subcollection
      match /feedPosts/{postId} {
        allow read: if isCrewMember(crewId) ||
                      (resource.data.isPublic == true);

        allow create: if isCrewMember(crewId) &&
                      request.resource.data.authorId == request.auth.uid;

        allow update: if resource.data.authorId == request.auth.uid ||
                      isCrewForeman(crewId);

        allow delete: if resource.data.authorId == request.auth.uid ||
                      isCrewForeman(crewId);
      }
    }

    // Crew messages collection
    match /crewMessages/{messageId} {
      allow read: if isAuthenticated() &&
                    exists(/databases/$(database)/documents/crews/$(resource.data.crewId)) &&
                    (request.auth.uid in get(/databases/$(database)/documents/crews/$(resource.data.crewId)).data.memberIds);

      allow create: if isAuthenticated() &&
                      request.resource.data.senderId == request.auth.uid &&
                      exists(/databases/$(database)/documents/crews/$(request.resource.data.crewId)) &&
                      (request.auth.uid in get(/databases/$(database)/documents/crews/$(request.resource.data.crewId)).data.memberIds);

      allow update: if resource.data.senderId == request.auth.uid;
      allow delete: if resource.data.senderId == request.auth.uid;
    }

    // Crew conversations collection
    match /crewConversations/{convId} {
      allow read, write: if isAuthenticated() &&
                          exists(/databases/$(database)/documents/crews/$(resource.data.crewId)) &&
                          (request.auth.uid in get(/databases/$(database)/documents/crews/$(resource.data.crewId)).data.memberIds);
    }

    // Posts collection (global feed)
    match /posts/{postId} {
      allow read: if isAuthenticated() &&
                    (resource.data.isPublic == true ||
                     (exists(/databases/$(database)/documents/crews/$(resource.data.crewId)) &&
                      request.auth.uid in get(/databases/$(database)/documents/crews/$(resource.data.crewId)).data.memberIds));

      allow create: if isAuthenticated() &&
                      request.resource.data.authorId == request.auth.uid &&
                      exists(/databases/$(database)/documents/crews/$(request.resource.data.crewId)) &&
                      (request.auth.uid in get(/databases/$(database)/documents/crews/$(request.resource.data.crewId)).data.memberIds);

      allow update: if resource.data.authorId == request.auth.uid;
      allow delete: if resource.data.authorId == request.auth.uid;
    }

    // Jobs collection
    match /jobs/{jobId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated(); // TODO: Add proper job creation permissions
    }
  }
}
```

---

## 4. Implementation Guide

### 4.1 Phase 1: Critical Security Fixes (Week 1)

#### **Task 1: Implement Production Security Rules**

1. Update `firebase/firestore.rules` with production rules
2. Test all crew operations with new rules
3. Enable security in production environment

```bash
# Deploy security rules
firebase deploy --only firestore:rules
```

#### **Task 2: Complete Riverpod Providers**

```dart
// lib/features/crews/providers/crews_riverpod_provider.dart

@riverpod
class PendingInvitationsNotifier extends AsyncNotifier<List<CrewInvitation>> {
  @override
  Future<List<CrewInvitation>> build() async {
    final userId = ref.watch(authRiverpodProvider)?.uid;
    if (userId == null) return [];

    final service = ref.watch(crewInvitationServiceProvider);
    return service.getPendingInvitationsForUser(userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(authRiverpodProvider)?.uid;
      if (userId == null) return [];

      final service = ref.read(crewInvitationServiceProvider);
      return service.getPendingInvitationsForUser(userId);
    });
  }
}

@riverpod
List<CrewInvitation> pendingInvitations(PendingInvitationsNotifierRef ref) {
  return ref.watch(pendingInvitationsNotifierProvider).maybeWhen(
    data: (invitations) => invitations,
    orElse: () => [],
  );
}
```

#### **Task 3: Enable Permission Checks**

```dart
// lib/services/crew_invitation_service.dart

Future<String> createInvitation({
  required String crewId,
  required String inviterId,
  required String inviteeEmail,
  String? message,
}) async {
  // PRODUCTION: Verify inviter has permission
  final crewDoc = await _firestore.collection('crews').doc(crewId).get();
  final crewData = crewDoc.data()!;

  // Check if inviter is foreman or has invite permission
  if (crewData['foremanId'] != inviterId) {
    // Check user permissions
    final userDoc = await _firestore.collection('users').doc(inviterId).get();
    final permissions = List<String>.from(userDoc.data()?['permissions'] ?? []);

    if (!permissions.contains('inviteMember')) {
      throw CrewException('Insufficient permissions to invite members',
                        code: 'permission-denied');
    }
  }

  // Continue with invitation creation...
}
```

### 4.2 Phase 2: User Discovery System (Week 2)

#### **Task 1: Create User Search Service**

```dart
// lib/services/user_discovery_service.dart

class UserDiscoveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search for users by name, email, or IBEW local
  Future<List<UserModel>> searchUsers({
    required String query,
    int limit = 20,
    String? excludeUserId,
  }) async {
    final lowercaseQuery = query.toLowerCase();

    // Search by display name
    final nameSnapshot = await _firestore
        .collection('users')
        .where('displayNameLowerCase', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('displayNameLowerCase', isLessThanOrEqualTo: lowercaseQuery + '\uf8ff')
        .limit(limit)
        .get();

    // Search by email if query contains @
    List<DocumentSnapshot> emailResults = [];
    if (query.contains('@')) {
      final emailSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: query.toLowerCase())
          .limit(1)
          .get();
      emailResults = emailSnapshot.docs;
    }

    // Combine and deduplicate results
    final allDocs = {...nameSnapshot.docs, ...emailResults}
        .where((doc) => doc.id != excludeUserId)
        .toList();

    return allDocs
        .map((doc) => UserModel.fromFirestore(doc))
        .take(limit)
        .toList();
  }

  /// Get suggested users based on skills and location
  Future<List<UserModel>> getSuggestedUsers({
    required String userId,
    int limit = 10,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null) return [];

    final userLocal = userData['ibewLocal'] as String?;
    final userSkills = List<String>.from(userData['skills'] ?? []);

    Query query = _firestore.collection('users');

    // Prioritize same local
    if (userLocal != null) {
      query = query.where('ibewLocal', isEqualTo: userLocal);
    }

    final snapshot = await query.limit(limit * 2).get();

    // Score and rank users
    final users = snapshot.docs
        .where((doc) => doc.id != userId)
        .map((doc) => MapEntry(doc, UserModel.fromFirestore(doc)))
        .toList();

    // Sort by relevance (same local, shared skills)
    users.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a.value, userLocal, userSkills);
      final scoreB = _calculateRelevanceScore(b.value, userLocal, userSkills);
      return scoreB.compareTo(scoreA);
    });

    return users.map((e) => e.value).take(limit).toList();
  }

  int _calculateRelevanceScore(UserModel user, String? userLocal, List<String> userSkills) {
    int score = 0;

    // Same local = high priority
    if (user.ibewLocal == userLocal) {
      score += 100;
    }

    // Shared skills
    final sharedSkills = user.skills.where((skill) => userSkills.contains(skill)).length;
    score += sharedSkills * 10;

    return score;
  }
}
```

#### **Task 2: Create User Search UI**

```dart
// lib/features/crews/widgets/user_search_dialog.dart

class UserSearchDialog extends StatefulWidget {
  final String crewId;
  final Function(UserModel) onUserSelected;

  const UserSearchDialog({
    Key? key,
    required this.crewId,
    required this.onUserSelected,
  }) : super(key: key);

  @override
  State<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  List<UserModel> _suggestedUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestedUsers();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadSuggestedUsers() async {
    final currentUser = ref.read(authRiverpodProvider);
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final discoveryService = ref.read(userDiscoveryServiceProvider);
      final suggested = await discoveryService.getSuggestedUsers(
        userId: currentUser.uid,
        limit: 5,
      );

      if (mounted) {
        setState(() {
          _suggestedUsers = suggested;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text;

    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final discoveryService = ref.read(userDiscoveryServiceProvider);
      final results = await discoveryService.searchUsers(
        query: query,
        excludeUserId: ref.read(authRiverpodProvider)?.uid,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.person_add),
                const SizedBox(width: 8),
                Text(
                  'Invite to Crew',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            // Search field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_searchController.text.isEmpty) {
      // Show suggested users
      if (_suggestedUsers.isEmpty) {
        return const Center(child: Text('No suggested users'));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _suggestedUsers.length,
              itemBuilder: (context, index) {
                final user = _suggestedUsers[index];
                return _buildUserTile(user);
              },
            ),
          ),
        ],
      );
    }

    // Show search results
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null ? Text(user.displayNameStr[0]) : null,
      ),
      title: Text(user.displayNameStr),
      subtitle: user.ibewLocal != null ? Text('IBEW Local ${user.ibewLocal}') : null,
      onTap: () {
        widget.onUserSelected(user);
        Navigator.of(context).pop();
      },
    );
  }
}
```

### 4.3 Phase 3: Crew Authentication Service (Week 3)

#### **Task 1: Create Crew Authentication Service**

```dart
// lib/services/crew_auth_service.dart

class CrewAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Verify user has permission for specific crew operation
  Future<bool> verifyCrewPermission({
    required String userId,
    required String crewId,
    required Permission permission,
  }) async {
    try {
      // Get crew document
      final crewDoc = await _firestore.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) return false;

      final crewData = crewDoc.data()!;
      final memberIds = List<String>.from(crewData['memberIds'] ?? []);

      // Check if user is member
      if (!memberIds.contains(userId)) {
        return false;
      }

      // Get user role
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data()!;

      // Foreman has all permissions
      if (crewData['foremanId'] == userId) {
        return true;
      }

      // Check specific permissions
      final userPermissions = List<String>.from(userData['permissions'] ?? []);

      switch (permission) {
        case Permission.readCrew:
          return true; // All members can read

        case Permission.updateCrew:
        case Permission.deleteCrew:
          return crewData['foremanId'] == userId;

        case Permission.inviteMember:
        case Permission.removeMember:
          return userPermissions.contains('manageMembers') ||
                 crewData['foremanId'] == userId;

        case Permission.postMessage:
          return true; // All members can post

        case Permission.deletePost:
          return userPermissions.contains('moderateContent') ||
                 crewData['foremanId'] == userId;

        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Generate crew session token for enhanced security
  Future<String> generateCrewSessionToken({
    required String crewId,
    required String userId,
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    // Verify user is crew member
    final hasPermission = await verifyCrewPermission(
      userId: userId,
      crewId: crewId,
      permission: Permission.readCrew,
    );

    if (!hasPermission) {
      throw CrewAuthException('User is not a member of this crew');
    }

    // Create custom token with crew context
    final customToken = await _auth.createCustomToken(userId, {
      'crewId': crewId,
      'crewAccess': true,
      'expiresAt': DateTime.now().add(expiresIn).toIso8601String(),
    });

    return customToken;
  }

  /// Authenticate user for specific crew operations
  Future<void> authenticateForCrew({
    required String crewId,
    required Permission operation,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw CrewAuthException('User not authenticated');
    }

    final hasPermission = await verifyCrewPermission(
      userId: currentUser.uid,
      crewId: crewId,
      permission: operation,
    );

    if (!hasPermission) {
      throw CrewAuthException('Insufficient permissions for this operation');
    }

    // Log authentication event
    await _logAuthEvent(
      userId: currentUser.uid,
      crewId: crewId,
      operation: operation.toString(),
      success: true,
    );
  }

  Future<void> _logAuthEvent({
    required String userId,
    required String crewId,
    required String operation,
    required bool success,
  }) async {
    await _firestore.collection('crewAuthLogs').add({
      'userId': userId,
      'crewId': crewId,
      'operation': operation,
      'success': success,
      'timestamp': FieldValue.serverTimestamp(),
      'ipAddress': 'TODO: Get IP address',
    });
  }
}

class CrewAuthException implements Exception {
  final String message;
  final String? code;

  CrewAuthException(this.message, {this.code});

  @override
  String toString() => message;
}
```

### 4.4 Phase 4: Enhanced Features (Week 4)

#### **Task 1: Implement MFA for Crew Admins**

```dart
// lib/services/mfa_service.dart

class MFAService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Enable phone verification for crew admin
  Future<void> enablePhoneVerification(String phoneNumber) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await user.linkWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Failed to verify phone: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Store verificationId for input
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout
      },
    );
  }

  /// Verify TOTP for admin operations
  Future<bool> verifyTOTP(String code) async {
    // Implement TOTP verification
    // Use a library like 'otp' for generating/verifying codes
    return true; // Placeholder
  }
}
```

#### **Task 2: Add Message Encryption**

```dart
// lib/services/message_encryption_service.dart

class MessageEncryptionService {
  static final MessageEncryptionService _instance = MessageEncryptionService._internal();
  factory MessageEncryptionService() => _instance;
  MessageEncryptionService._internal();

  /// Encrypt message content for crew members
  Future<String> encryptMessage({
    required String content,
    required List<String> recipientIds,
  }) async {
    // For now, return content as-is
    // In production, implement end-to-end encryption
    // Each crew member would have a public key
    return content;
  }

  /// Decrypt message for specific user
  Future<String> decryptMessage({
    required String encryptedContent,
    required String userId,
  }) async {
    // For now, return content as-is
    // In production, decrypt with user's private key
    return encryptedContent;
  }
}
```

---

## 5. Testing Strategy

### 5.1 Unit Tests

```dart
// test/services/crew_auth_service_test.dart

void main() {
  group('CrewAuthService', () {
    late CrewAuthService service;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      service = CrewAuthService();
    });

    test('should verify foreman permissions', () async {
      // Arrange
      final crewId = 'crew-123';
      final foremanId = 'user-123';

      when(mockFirestore.collection('crews').doc(crewId).get())
          .thenAnswer((_) async => MockDocumentSnapshot({
            'foremanId': foremanId,
            'memberIds': [foremanId, 'user-456'],
          }));

      // Act
      final result = await service.verifyCrewPermission(
        userId: foremanId,
        crewId: crewId,
        permission: Permission.deleteCrew,
      );

      // Assert
      expect(result, isTrue);
    });

    test('should deny non-member permissions', () async {
      // Arrange
      final crewId = 'crew-123';
      final userId = 'user-789'; // Not a member

      when(mockFirestore.collection('crews').doc(crewId).get())
          .thenAnswer((_) async => MockDocumentSnapshot({
            'foremanId': 'user-123',
            'memberIds': ['user-123', 'user-456'],
          }));

      // Act
      final result = await service.verifyCrewPermission(
        userId: userId,
        crewId: crewId,
        permission: Permission.readCrew,
      );

      // Assert
      expect(result, isFalse);
    });
  });
}
```

### 5.2 Integration Tests

```dart
// test/integration/crew_creation_test.dart

void main() {
  group('Crew Creation Integration', () {
    late FirebaseFirestore firestore;
    late FirebaseAuth auth;

    setUpAll(() async {
      // Initialize Firebase emulators
      await Firebase.initializeApp();
      firestore = FirebaseFirestore.instance;
      auth = FirebaseAuth.instance;

      // Use emulator
      firestore.useFirestoreEmulator('localhost', 8080);
      auth.useAuthEmulator('localhost', 9099);
    });

    test('should create crew with valid data', () async {
      // Arrange
      final user = await auth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      final crewService = CrewService();

      // Act
      final crewId = await crewService.createCrew(
        name: 'Test Crew',
        foremanId: user.uid,
        preferences: CrewPreferences(
          jobTypes: ['Inside Wireman'],
          constructionTypes: ['Commercial'],
          autoShareEnabled: false,
        ),
      );

      // Assert
      final crewDoc = await firestore.collection('crews').doc(crewId).get();
      expect(crewDoc.exists, isTrue);
      expect(crewDoc.data()!['name'], equals('Test Crew'));
      expect(crewDoc.data()!['foremanId'], equals(user.uid));
    });
  });
}
```

---

## 6. Deployment Checklist

### 6.1 Pre-Deployment

- [ ] All tests passing (>90% coverage)
- [ ] Security rules deployed to production
- [ ] API rate limits configured
- [ ] Error monitoring implemented
- [ ] Performance benchmarks met
- [ ] Security audit completed

### 6.2 Deployment Steps

1. **Deploy Security Rules**

   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Deploy Functions (if any)**

   ```bash
   firebase deploy --only functions
   ```

3. **Update App Configuration**
   - Update API endpoints
   - Configure production Firebase project
   - Set correct app version

4. **Enable Features**
   - Remove DEV_MODE flags
   - Enable permission checks
   - Activate rate limiting

### 6.3 Post-Deployment

- [ ] Monitor error rates
- [ ] Check authentication flows
- [ ] Verify invitation system
- [ ] Test crew creation
- [ ] Validate messaging functionality

---

## 7. Monitoring & Maintenance

### 7.1 Key Metrics

- Crew creation rate
- Invitation acceptance rate
- Message volume
- User engagement
- Authentication success/failure rates

### 7.2 Alerting

- High authentication failure rates
- Permission denied errors
- Database operation timeouts
- Unusual activity patterns

### 7.3 Regular Tasks

- Review security logs
- Update user permissions
- Clean up expired invitations
- Monitor storage usage
- Performance optimization

---

## 8. Success Criteria

### 8.1 Functional Requirements

- [ ] Users can create crews with preferences
- [ ] Crew invitations work end-to-end
- [ ] Real-time messaging functions properly
- [ ] Feed posts appear correctly
- [ ] Permissions are enforced

### 8.2 Non-Functional Requirements

- [ ] Response time < 500ms for operations
- [ ] 99.9% uptime
- [ ] Zero security vulnerabilities
- [ ] All data encrypted in transit
- [ ] GDPR compliant

### 8.3 User Experience

- [ ] Intuitive crew creation flow
- [ ] Easy member invitation process
- [ ] Seamless real-time updates
- [ ] Clear permission indicators
- [ ] Helpful error messages

---

## 9. Conclusion

The Crews feature has a solid foundation with excellent architecture. The primary blockers are:

1. **Security Rules**: Currently in development mode
2. **Provider Implementation**: Empty providers prevent data flow
3. **User Discovery**: Missing search functionality

With the implementation guide provided, these gaps can be resolved within 2-3 weeks, resulting in a fully functional crew management system ready for production deployment.

The existing code quality is high, with comprehensive models, services, and UI components. The electrical theme is well-implemented throughout, and the real-time capabilities using Firestore are robust.

---

## 10. Appendix

### 10.1 Firebase Collection Structure

```
crews/
  {crewId}/
    - name: String
    - description: String
    - foremanId: String
    - memberIds: Array<String>
    - jobPreferences: Object
    - visibility: String (public/private)
    - createdAt: Timestamp
    - updatedAt: Timestamp

    members/{memberId}/
      - userId: String
      - role: String
      - joinedAt: Timestamp

    invitations/{invitationId}/
      - inviterId: String
      - inviteeId: String
      - inviteeEmail: String
      - status: String
      - createdAt: Timestamp
      - expiresAt: Timestamp

    feedPosts/{postId}/
      - authorId: String
      - content: String
      - mediaUrls: Array<String>
      - likes: Array<String>
      - reactions: Object
      - createdAt: Timestamp

crewMessages/
  {messageId}/
    - crewId: String
    - senderId: String
    - content: String
    - type: String
    - createdAt: Timestamp
    - readStatus: Array<Object>
    - replyToMessageId: String

crewConversations/
  {convId}/
    - crewId: String
    - participantIds: Array<String>
    - lastMessage: Object
    - updatedAt: Timestamp

posts/
  {postId}/
    - crewId: String
    - authorId: String
    - content: String
    - isPublic: Boolean
    - likes: Array<String>
    - reactions: Object
    - createdAt: Timestamp
```

### 10.2 Common Error Codes

| Error Code | Description | Resolution |
|------------|-------------|------------|
| permission-denied | User lacks required permission | Check user role and permissions |
| crew-not-found | Crew does not exist | Verify crew ID |
| not-crew-member | User is not a crew member | Ensure user is added to crew |
| invitation-expired | Invitation has expired | Create new invitation |
| rate-limit-exceeded | Too many requests | Wait and retry |
| invalid-crew-data | Crew data validation failed | Check required fields |

### 10.3 API Rate Limits

| Operation | Limit | Period |
|-----------|-------|--------|
| Create Crew | 5 per user | 1 hour |
| Send Invitation | 20 per user | 1 hour |
| Send Message | 100 per user | 1 hour |
| Create Post | 20 per user | 1 hour |
| Search Users | 50 per user | 1 hour |

---

**Document Version**: 1.0
**Last Updated**: October 28, 2024
**Next Review**: November 28, 2024
