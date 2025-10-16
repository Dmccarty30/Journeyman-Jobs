# **🔐 AUTHENTICATION SYSTEM OVERVIEW**

## **Authentication Methods Supported**

- **Firebase Authentication** (primary auth provider)
- **Email/Password** - Email/PW sign up & sign in
- **Google Sign In** - OAuth via Google account
- **Apple Sign In** (iOS only) - Apple ID OAuth
- **Additional Methods Prep** - Infrastructure for future providers

---

## **📝 USER DOCUMENT CREATION & LIFECYCLE**

### **Phase 1: Initial Account Creation**

#### **Email/Password Registration Flow**

**User Action Sequence:**

1. User opens app → SplashScreen
2. Navigates to WelcomeScreen → taps "Get Started"
3. Routes to `/auth` AuthScreen with Sign Up tab
4. User enters:
   - Email (validated regex + unique)
   - Password (6+ chars)
   - Confirm password
5. User taps "Create Account"

**System Response Sequence:**

1. `AuthScreen._signUpWithEmail()` method called
2. **Firebase Auth Account Creation:**

   ```dart
   final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
     email: _signUpEmailController.text.trim(),
     password: _signUpPasswordController.text,
   );
   ```

3. **Initial Firestore User Document Creation:**

   ```dart
   await firestoreService.createUser(
     uid: user.uid,
     userData: {
       'email': user.email,
       'createdTime': FieldValue.serverTimestamp(),
       'onboardingStatus': 'incomplete',
     },
   );
   ```

#### **Social Login Flow (Google/Apple)**

**Process:**

1. User taps Google/Apple sign in button
2. OAuth flow completes, Firebase Auth account created
3. App checks if Firestore user document exists
4. If not, minimal document created:

   ```dart
   await firestoreService.createUser(
     uid: user.uid,
     userData: {'email': user.email},
   );
   ```

5. All social logins route to onboarding (profile complete process)

### **Phase 2: Document Validation & Completion**

#### **Onboarding Status Management**

- **Document Field:** `onboardingStatus`
- **States:** `'incomplete'` → `'complete'`
- **Default:** When document created, set to `'incomplete'`

#### **Email/Password Sign In Validation**

1. User enters `/auth` screen, selects Sign In tab
2. Returns existing user + Firebase Auth validation
3. **Critical Document Check:**

   ```dart
   final DocumentSnapshot userDoc = await firestoreService.getUser(user.uid);
   if (!userDoc.exists) {
     // Create minimal document if missing
     await firestoreService.createUser(uid: user.uid, userData: {'email': user.email});
     navigateToOnboarding();
   } else {
     final String? onboardingStatus = userDoc.get('onboardingStatus');
     if (onboardingStatus == 'incomplete' || onboardingStatus == null) {
       navigateToOnboarding();
     } else if (onboardingStatus == 'complete') {
       context.go(AppRouter.home);
     }
   }
   ```

---

## **📊 USER DOCUMENT STRUCTURE**

### **Core UserModel Properties**

```dart
class UserModel {
  // Identification
  final String uid;                    // Firebase Auth UID
  final String username;               // Optional username
  final String email;                  // Primary email
  
  // Professional Info
  final String classification;         // IBEW classification
  final int homeLocal;                 // Home union local #
  final String role;                   // Job role
  
  // Social & Grouping
  final List<String> crewIds;          // Crew memberships
  
  // Personal Info
  final String firstName;              // First name
  final String lastName;               // Last name
  final String phoneNumber;            // Phone #
  final String address1;               // Address
  final String? address2;
  final String city;
  final String state;
  final int zipcode;
  final String ticketNumber;           // Union ticket #
  
  // Professional Details
  final bool isWorking;                // Current employment status
  final List<String> constructionTypes;// Work specialties
  final String? booksOn;               // Work booking method
  
  // Notifications
  final String? fcmToken;              // FCM push token
  
  // System Fields
  final Timestamp lastActive;          // Last activity
  final DateTime? createdTime;         // Account creation
  final OnboardingStatus? onboardingStatus; // 'complete'/'incomplete'
  final bool hasSetJobPreferences;     // Profile completeness flag
}
```

### **Document Permissions**

**Owner:** User document belongs to authenticated user (via `uid`)
**Access:** Read/write own document only (enforced by Firestore security rules)
**Validation:** All users have required field validation

---

## **🔒 AUTHENTICATION VALIDATION PATTERNS**

### **Route Protection System**

#### **Public Routes** (No auth required)

- `/` - SplashScreen
- `/welcome` - WelcomeScreen  
- `/auth` - AuthScreen
- `/forgot-password` - ForgotPasswordScreen

#### **Protected Routes** (Auth required)

- `/home`, `/jobs`, `/storm`, `/locals`, `/crews`, `/settings` - Main navigation
- `/profile`, `/help`, `/resources`, `/training`, `/feedback` - User features
- `/electrical-calculators`, `/transformer-*` - Tools
- `/notifications`, `/notification-settings` - Communications

#### **Router Guard Logic:**

```dart
static String? _redirect(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  final isAuthenticated = user != null;
  final location = state.matchedLocation;
  
  final publicRoutes = [splash, welcome, auth, forgotPassword];
  
  // Redirect unauthenticated users to welcome
  if (!isAuthenticated && !publicRoutes.contains(location)) {
    return welcome;
  }
  
  return null; // Screen handles onboarding status checks
}
```

### **Riverpod State Management**

#### **Auth State Provider:**

- **Source:** Firestore auth state changes stream
- **State:** Loading → authenticated or null
- **Reactive:** Providers rebuild on auth changes
- **Error Handling:** Network/auth error states

#### **Authentication Checks:**

- `isAuthenticated` provider: `user != null`
- `isRouteProtected` provider: Route protection boolean
- Automatic app data loading on auth state changes

### **Operation-Level Authentication**

**All authenticated operations require valid user session:**

1. **Firestore Operations:**
   - User document read/write
   - Job posting, searching
   - Crew management
   - Local union queries

2. **Service Operations:**
   - FCM token management
   - Notification subscriptions
   - Avatar upload/management
   - Location services

3. **Feature Access:**
   - Job bookmarking/favorites
   - Crew participation
   - Profile management
   - Settings configuration

---

## **🔄 USER DOCUMENT LIFECYCLE ACTIONS**

### **Document Updates & Permissions**

#### **Who Can Modify User Documents:**

1. **User Themselves** - Own profile updates
2. **System Services** - Onboarding completion, avatar updates
3. **Auth Flow Handlers** - FCM token updates

#### **Automatic Updates:**

- **Auth Creation:** Initial document with `'onboardingStatus': 'incomplete'`
- **Onboarding Completion:** `'onboardingStatus': 'complete'`
- **FCM Token Store:** `'fcmToken': token, lastActive: timestamp`
- **Activity Tracking:** `lastActive` timestamp on operations
- **Profile Completion:** `hasSetJobPreferences: true` flag

### **Deletion & Cleanup**

- **Account Deletion:** via `FirebaseAuth.user?.delete()`
- **Document Cleanup:** Manual Firestore document deletion
- **Cascade Deletions:** Crew memberships, job bookmarks cleanup

---

## **©️ BACKEND COLLECTIONS RELATIONSHIPS**

### **Primary Collections:**

1. **`users`** - Core user profiles
   - **Relationship:** Contains full user data, primary document
   - **Access:** Owner-only read/write
   - **Indexing:** UID, email, location fields

2. **`jobs`** - Job postings & opportunities
   - **Relationship:** User can post/read jobs, authorId references users.uid
   - **Access:** Authenticated read, author write
   - **Filtering:** By classification, location, construction type

3. **`locals`** - Union local information
   - **Relationship:** Static reference data, authenticated read only
   - **Access:** Read-only for authenticated users

4. **`crews`** - Work crew groups
   - **Dependency:** User crewIds reference crews documents
   - **Access:** Owner (foreman) full control, members read/write
   - **Subcollections:** `members`, `feedPosts`, `messages`

### **User Document References:**

**Outgoing References:**

- `crewIds: List<String>` → `/crews/{crewId}` documents
- `homeLocal: int` → `/locals/{localId}` geographic reference

**Incoming References:**

- Job documents reference `authorId: String` → user.uid
- Crew documents reference `foremanId: String` → user.uid  
- Message/feed posts reference `authorId: String` → user.uid
- Notifications reference `targetUserId: String` → user.uid

### **Relationship Integrity:**

- **No Foreign Keys:** Firestore denormalized, references by string ID
- **Access Control:** Security rules enforce relationship permissions
- **Cascade Effects:** User deletion should clean up references but not currently implemented

---

## **🔄 LOGIN FLOW STATE MANAGEMENT**

### **State Changes on Authentication:**

#### **Sign In Flow:**

1. **Firebase Auth Success** → User object available
2. **Document Existence Check** → Create if missing
3. **Onboarding Status Check** → Route to onboarding or home
4. **App State Update** → Load jobs, locals, user preferences
5. **FCM Token Storage** → Update notification tokens
6. **Analytics Tracking** → Log authentication event

#### **Sign Out Flow:**

1. **Firebase Auth Sign Out**
2. **Google Sign In Clean Up**
3. **Provider Clearing** → Reset app state providers
4. **Route Reset** → Clear navigation, return to welcome
5. **Analytics Tracking** → Log sign out event

#### **Session Management:**

- **Persistence:** Firebase Auth automatic session persistence
- **Timeout:** No explicit session timeout (Firebase default)
- **Background:** Auth state monitored continuously
- **Offline:** Cached user data available when offline

This comprehensive system provides robust user authentication, document management, and operation-level security throughout the Journeyman Jobs application. The Firebase backend, Riverpod state management, and protected routing work together to ensure users have appropriate access to features while maintaining data integrity and privacy.
