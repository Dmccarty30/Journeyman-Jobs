# Phase 2 Implementation - Advanced Job Sharing Features

## Week 3-4: In-App Notifications, Quick Signup & Contact Integration

---

## 📋 Phase 2 Overview

### Objectives

1. Implement in-app notifications for platform users
2. Create quick signup flow for non-users
3. Integrate phone contacts
4. Build crew groups feature
5. Enhance share tracking

### Deliverables

- Real-time in-app notifications
- Quick signup with pre-filled job interest
- Native contact picker integration
- Crew management system
- Share conversion tracking

---

## 🗂️ Additional File Structure

``` tree
lib/
├── features/
│   └── job_sharing/
│       ├── providers/
│       │   ├── share_provider.dart
│       │   └── crew_provider.dart
│       ├── screens/
│       │   ├── quick_signup_screen.dart
│       │   ├── crew_management_screen.dart
│       │   └── share_tracking_screen.dart
│       └── widgets/
│           ├── notification_card.dart
│           ├── contact_picker.dart
│           └── crew_selector.dart
└── core/
    └── services/
        ├── notification_service.dart
        └── deep_link_service.dart
```

---

## 📝 Step-by-Step Implementation

### Step 1: Create Notification Service

**File: `lib/core/services/notification_service.dart`**

```dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Stream controllers
  final _notificationStreamController = BehaviorSubject<List<NotificationModel>>();
  final _unreadCountController = BehaviorSubject<int>.seeded(0);
  
  // Streams
  Stream<List<NotificationModel>> get notificationStream => 
      _notificationStreamController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  
  StreamSubscription? _notificationSubscription;
  
  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission
    await _requestPermission();
    
    // Configure local notifications
    await _configureLocalNotifications();
    
    // Configure FCM
    await _configureFCM();
    
    // Start listening to notifications
    _startNotificationListener();
    
    // Handle initial message if app opened from notification
    RemoteMessage? initialMessage = 
        await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }
  }
  
  /// Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Notification permission status: ${settings.authorizationStatus}');
  }
  
  /// Configure local notifications
  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );
  }
  
  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }
    
    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_saveTokenToDatabase);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
    
    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });
  }
  
  /// Save FCM token to database
  Future<void> _saveTokenToDatabase(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  /// Start listening to user notifications
  void _startNotificationListener() {
    final user = _auth.currentUser;
    if (user == null) return;
    
    _notificationSubscription?.cancel();
    _notificationSubscription = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
          
          _notificationStreamController.add(notifications);
          
          // Update unread count
          final unreadCount = notifications
              .where((n) => !n.isRead)
              .length;
          _unreadCountController.add(unreadCount);
        });
  }
  
  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'job_shares',
      'Job Shares',
      channelDescription: 'Notifications for shared job opportunities',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Job Share',
      message.notification?.body ?? 'Someone shared a job with you',
      details,
      payload: message.data.toString(),
    );
  }
  
  /// Handle notification tap
  void _handleNotificationTap(dynamic payload) {
    // Parse payload and navigate
    if (payload is String) {
      try {
        final data = Map<String, dynamic>.from(payload as Map);
        if (data['type'] == 'job_share') {
          // Navigate to job details
          _navigateToJobDetails(data['jobId']);
        }
      } catch (e) {
        print('Error handling notification tap: $e');
      }
    }
  }
  
  /// Navigate to job details
  void _navigateToJobDetails(String jobId) {
    // This would use your navigation service
    // NavigationService.navigateTo('/job/$jobId');
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final batch = _firestore.batch();
    final unreadNotifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();
    
    for (final doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }
  
  /// Create notification for job share
  static Future<void> createJobShareNotification({
    required String recipientId,
    required String sharerName,
    required String jobTitle,
    required String jobId,
    required String shareId,
    String? message,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': recipientId,
      'type': 'job_share',
      'title': '$sharerName shared a job with you',
      'body': '$jobTitle opportunity - Tap to view',
      'data': {
        'jobId': jobId,
        'shareId': shareId,
        'sharerName': sharerName,
        'personalMessage': message,
      },
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Dispose resources
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationStreamController.close();
    _unreadCountController.close();
  }
}

/// Notification Model
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'],
      type: data['type'],
      title: data['title'],
      body: data['body'],
      data: data['data'] ?? {},
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
```

---

### Step 2: Create Quick Signup Screen

**File: `lib/features/job_sharing/screens/quick_signup_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/screens/job_details_screen.dart';

class QuickSignupScreen extends StatefulWidget {
  final String shareId;
  final String jobId;
  final JobModel? preloadedJob;

  const QuickSignupScreen({
    super.key,
    required this.shareId,
    required this.jobId,
    this.preloadedJob,
  });

  @override
  State<QuickSignupScreen> createState() => _QuickSignupScreenState();
}

class _QuickSignupScreenState extends State<QuickSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  JobModel? _job;
  Map<String, dynamic>? _shareData;

  @override
  void initState() {
    super.initState();
    _loadShareAndJobData();
  }

  Future<void> _loadShareAndJobData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load share data
      final shareDoc = await FirebaseFirestore.instance
          .collection('shares')
          .doc(widget.shareId)
          .get();
      
      if (shareDoc.exists) {
        _shareData = shareDoc.data();
      }
      
      // Load job data if not preloaded
      if (widget.preloadedJob != null) {
        _job = widget.preloadedJob;
      } else {
        final jobDoc = await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .get();
        
        if (jobDoc.exists) {
          _job = JobModel.fromFirestore(jobDoc);
        }
      }
      
      // Pre-fill email if available from share link
      final uri = Uri.base;
      final email = uri.queryParameters['email'];
      if (email != null) {
        _emailController.text = email;
      }
      
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with job preview
                    _buildHeader(),
                    
                    SizedBox(height: AppTheme.spacingXl),
                    
                    // Quick signup form
                    _buildSignupForm(),
                    
                    SizedBox(height: AppTheme.spacingXl),
                    
                    // Already have account link
                    _buildLoginLink(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          padding: EdgeInsets.zero,
        ),
        
        SizedBox(height: AppTheme.spacingMd),
        
        // Title
        Text(
          'Quick Signup',
          style: AppTheme.headlineLarge.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        
        SizedBox(height: AppTheme.spacingSm),
        
        // Subtitle with sharer info
        if (_shareData != null) ...[
          Text(
            '${_shareData!['sharerName']} shared this opportunity with you',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
        
        SizedBox(height: AppTheme.spacingLg),
        
        // Job preview card
        if (_job != null) _buildJobPreview(),
      ],
    );
  }

  Widget _buildJobPreview() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: AppTheme.accentCopper,
                size: AppTheme.iconMd,
              ),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  _job!.classification,
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacingSm),
          
          Text(
            '${_job!.company} • ${_job!.city}, ${_job!.state}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          
          SizedBox(height: AppTheme.spacingSm),
          
          Row(
            children: [
              Chip(
                label: Text(
                  '\$${_job!.hourlyRate}/hr',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: AppTheme.successGreen.withOpacity(0.1),
              ),
              
              if (_job!.perDiem != null) ...[
                SizedBox(width: AppTheme.spacingSm),
                Chip(
                  label: Text(
                    '\$${_job!.perDiem} per diem',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.infoBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppTheme.infoBlue.withOpacity(0.1),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Your Account',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          
          SizedBox(height: AppTheme.spacingMd),
          
          // Name fields
          Row(
            children: [
              Expanded(
                child: JJTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Required';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: JJTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Required';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacingMd),
          
          // Email field
          JJTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          
          SizedBox(height: AppTheme.spacingMd),
          
          // Phone field (optional)
          JJTextField(
            controller: _phoneController,
            label: 'Phone (Optional)',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          
          SizedBox(height: AppTheme.spacingMd),
          
          // Password field
          JJTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: _obscurePassword,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Password is required';
              }
              if (value!.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword 
                    ? Icons.visibility_outlined 
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSignup(),
          ),
          
          SizedBox(height: AppTheme.spacingXl),
          
          // Submit button
          JJPrimaryButton(
            text: 'Create Account & Apply',
            icon: Icons.rocket_launch_outlined,
            onPressed: _handleSignup,
            isLoading: _isLoading,
            isFullWidth: true,
          ),
          
          SizedBox(height: AppTheme.spacingMd),
          
          // Terms text
          Text(
            'By creating an account, you agree to our Terms of Service and Privacy Policy',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Navigate to login screen
          Navigator.pushReplacementNamed(
            context,
            '/login',
            arguments: {
              'shareId': widget.shareId,
              'jobId': widget.jobId,
            },
          );
        },
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            children: [
              TextSpan(
                text: 'Sign In',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Create Firebase Auth account
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(
        '${_firstNameController.text} ${_lastNameController.text}',
      );
      
      // Create user profile with job interest
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'signupSource': 'job_share',
        'shareId': widget.shareId,
        'initialJobInterest': widget.jobId,
        'onboardingStatus': 'quick_signup',
      });
      
      // Track share conversion
      await _trackShareConversion();
      
      // Auto-apply to job
      await _autoApplyToJob(credential.user!.uid);
      
      // Navigate to job details
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: _job!),
          ),
        );
        
        JJSnackBar.showSuccess(
          context: context,
          message: 'Account created! You\'ve been automatically applied to this job.',
        );
      }
      
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please sign in instead.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak. Please use a stronger password.';
      }
      
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: message,
        );
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'An error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _trackShareConversion() async {
    // Update share status
    final shareRef = FirebaseFirestore.instance
        .collection('shares')
        .doc(widget.shareId);
    
    final shareDoc = await shareRef.get();
    if (shareDoc.exists) {
      final recipients = List<Map<String, dynamic>>.from(
        shareDoc.data()!['recipients'],
      );
      
      // Find and update recipient status
      for (var recipient in recipients) {
        if (recipient['identifier'] == _emailController.text.trim()) {
          recipient['status'] = 'applied';
          recipient['appliedAt'] = Timestamp.now();
          recipient['userId'] = FirebaseAuth.instance.currentUser?.uid;
          break;
        }
      }
      
      await shareRef.update({'recipients': recipients});
    }
    
    // Track analytics
    await FirebaseFirestore.instance.collection('analytics').add({
      'event': 'share_conversion',
      'shareId': widget.shareId,
      'jobId': widget.jobId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _autoApplyToJob(String userId) async {
    // Create job application
    await FirebaseFirestore.instance.collection('applications').add({
      'userId': userId,
      'jobId': widget.jobId,
      'status': 'pending',
      'appliedAt': FieldValue.serverTimestamp(),
      'source': 'job_share',
      'shareId': widget.shareId,
      'autoApplied': true,
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

### Step 3: Create Contact Picker Integration

**File: `lib/features/job_sharing/widgets/contact_picker.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';

class ContactPicker extends StatefulWidget {
  final Function(List<String>) onContactsSelected;
  final List<String> selectedContacts;

  const ContactPicker({
    super.key,
    required this.onContactsSelected,
    this.selectedContacts = const [],
  });

  @override
  State<ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  Set<String> _selectedIdentifiers = {};
  bool _isLoading = false;
  bool _hasPermission = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIdentifiers = Set.from(widget.selectedContacts);
    _checkPermissionAndLoadContacts();
  }

  Future<void> _checkPermissionAndLoadContacts() async {
    setState(() => _isLoading = true);
    
    // Check permission
    final status = await Permission.contacts.status;
    
    if (status.isGranted) {
      await _loadContacts();
    } else if (status.isDenied) {
      final result = await Permission.contacts.request();
      if (result.isGranted) {
        await _loadContacts();
      } else {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await ContactsService.getContacts();
      
      // Filter contacts with email or phone
      final validContacts = contacts.where((contact) {
        return (contact.emails?.isNotEmpty ?? false) ||
               (contact.phones?.isNotEmpty ?? false);
      }).toList();
      
      // Sort alphabetically
      validContacts.sort((a, b) {
        final aName = a.displayName ?? '';
        final bName = b.displayName ?? '';
        return aName.compareTo(bName);
      });
      
      setState(() {
        _contacts = validContacts;
        _filteredContacts = validContacts;
        _hasPermission = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading contacts: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _contacts;
      });
      return;
    }
    
    final filtered = _contacts.where((contact) {
      final name = contact.displayName?.toLowerCase() ?? '';
      final email = contact.emails?.first?.value?.toLowerCase() ?? '';
      final phone = contact.phones?.first?.value ?? '';
      final searchQuery = query.toLowerCase();
      
      return name.contains(searchQuery) ||
             email.contains(searchQuery) ||
             phone.contains(searchQuery);
    }).toList();
    
    setState(() {
      _filteredContacts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderLight,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Contacts',
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                
                if (_hasPermission) ...[
                  SizedBox(height: AppTheme.spacingMd),
                  
                  // Search field
                  TextField(
                    controller: _searchController,
                    onChanged: _filterContacts,
                    decoration: InputDecoration(
                      hintText: 'Search contacts...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.spacingSm),
                  
                  Text(
                    '${_selectedIdentifiers.length} contacts selected',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
          
          // Actions
          if (_hasPermission) ...[
            Container(
              padding: EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                border: Border(
                  top: BorderSide(color: AppTheme.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: JJSecondaryButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: JJPrimaryButton(
                      text: 'Add Selected',
                      onPressed: _selectedIdentifiers.isEmpty
                          ? null
                          : () {
                              widget.onContactsSelected(
                                _selectedIdentifiers.toList(),
                              );
                              Navigator.pop(context);
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (!_hasPermission) {
      return _buildPermissionRequest();
    }
    
    if (_filteredContacts.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final email = contact.emails?.firstOrNull?.value;
        final phone = contact.phones?.firstOrNull?.value;
        final identifier = email ?? phone ?? '';
        final isSelected = _selectedIdentifiers.contains(identifier);
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryNavy.withOpacity(0.1),
            child: Text(
              (contact.displayName?.isNotEmpty ?? false)
                  ? contact.displayName![0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          title: Text(
            contact.displayName ?? 'Unknown',
            style: AppTheme.bodyLarge,
          ),
          subtitle: Text(
            identifier,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedIdentifiers.add(identifier);
                } else {
                  _selectedIdentifiers.remove(identifier);
                }
              });
            },
            activeColor: AppTheme.accentCopper,
          ),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIdentifiers.remove(identifier);
              } else {
                _selectedIdentifiers.add(identifier);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: AppTheme.spacingLg),
            Text(
              'Contact Access Required',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text(
              'To share jobs with your contacts, we need permission to access your contact list.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacingXl),
            JJPrimaryButton(
              text: 'Grant Permission',
              icon: Icons.check,
              onPressed: () async {
                await openAppSettings();
                _checkPermissionAndLoadContacts();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: AppTheme.spacingLg),
            Text(
              'No Contacts Found',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try a different search term'
                  : 'No contacts with email or phone numbers found',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

---

### Step 4: Create Crew Management

**File: `lib/features/job_sharing/models/crew_model.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CrewModel {
  final String id;
  final String name;
  final String ownerId;
  final List<CrewMember> members;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final String? description;
  final String? imageUrl;

  CrewModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    this.lastUsed,
    this.description,
    this.imageUrl,
  });

  factory CrewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrewModel(
      id: doc.id,
      name: data['name'],
      ownerId: data['ownerId'],
      members: (data['members'] as List)
          .map((m) => CrewMember.fromMap(m))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUsed: data['lastUsed'] != null
          ? (data['lastUsed'] as Timestamp).toDate()
          : null,
      description: data['description'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'members': members.map((m) => m.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'lastUsed': lastUsed != null 
          ? Timestamp.fromDate(lastUsed!) 
          : null,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

class CrewMember {
  final String identifier; // Email or phone
  final String? userId; // If platform user
  final String name;
  final String? role; // e.g., "Foreman", "Journeyman"
  final bool isUser;

  CrewMember({
    required this.identifier,
    this.userId,
    required this.name,
    this.role,
    required this.isUser,
  });

  factory CrewMember.fromMap(Map<String, dynamic> map) {
    return CrewMember(
      identifier: map['identifier'],
      userId: map['userId'],
      name: map['name'],
      role: map['role'],
      isUser: map['isUser'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'userId': userId,
      'name': name,
      'role': role,
      'isUser': isUser,
    };
  }
}
```

---

## 📦 Package Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies...
  
  # Phase 2 additions
  flutter_local_notifications: ^17.0.0
  firebase_messaging: ^14.7.0
  permission_handler: ^11.3.0
  contacts_service: ^0.6.3
  share_plus: ^7.2.2
  uni_links: ^0.5.1
  rxdart: ^0.28.0
```

---

## 🔥 Firebase Setup

### Firestore Security Rules Update

```javascript
// Add to firestore.rules
match /notifications/{notificationId} {
  allow read: if request.auth != null && 
    request.auth.uid == resource.data.userId;
  allow write: if false; // Only server can write
}

match /crews/{crewId} {
  allow read: if request.auth != null && 
    (request.auth.uid == resource.data.ownerId ||
     request.auth.uid in resource.data.members[*].userId);
  allow create: if request.auth != null;
  allow update, delete: if request.auth != null && 
    request.auth.uid == resource.data.ownerId;
}
```

### Cloud Messaging Setup

```typescript
// functions/src/notifications.ts
import * as admin from 'firebase-admin';

export const sendPushNotification = async (
  token: string,
  title: string,
  body: string,
  data?: any
) => {
  const message = {
    notification: {
      title,
      body,
    },
    data: data || {},
    token,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.error('Error sending message:', error);
    throw error;
  }
};

// Trigger on notification creation
export const onNotificationCreated = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    // Get user's FCM token
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(notification.userId)
      .get();
    
    const fcmToken = userDoc.data()?.fcmToken;
    
    if (fcmToken) {
      await sendPushNotification(
        fcmToken,
        notification.title,
        notification.body,
        notification.data
      );
    }
  });
```

---

## 🧪 Testing Plan

### Integration Tests

```dart
// test/integration/share_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Job Sharing Flow', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    test('User can share job to email', () async {
      // Test implementation
    });

    test('Quick signup creates account', () async {
      // Test implementation
    });

    test('Notifications are received', () async {
      // Test implementation
    });

    test('Contact picker loads contacts', () async {
      // Test implementation
    });
  });
}
```

---

## 📊 Analytics Implementation

```dart
// lib/core/services/analytics_service.dart
class ShareAnalytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logShareInitiated({
    required String jobId,
    required int recipientCount,
  }) async {
    await _analytics.logEvent(
      name: 'share_initiated',
      parameters: {
        'job_id': jobId,
        'recipient_count': recipientCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logShareConversion({
    required String shareId,
    required String conversionType,
  }) async {
    await _analytics.logEvent(
      name: 'share_conversion',
      parameters: {
        'share_id': shareId,
        'conversion_type': conversionType, // 'signup', 'apply', 'view'
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logCrewCreated({
    required String crewId,
    required int memberCount,
  }) async {
    await _analytics.logEvent(
      name: 'crew_created',
      parameters: {
        'crew_id': crewId,
        'member_count': memberCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

---

## 🚀 Deployment Checklist

### Phase 2 Week 3 (Days 1-7)

- [ ] Implement notification service
- [ ] Create quick signup screen
- [ ] Build contact picker
- [ ] Test push notifications
- [ ] Deploy notification cloud functions

### Phase 2 Week 4 (Days 8-14)

- [ ] Create crew management
- [ ] Implement deep linking
- [ ] Add share tracking dashboard
- [ ] Performance optimization
- [ ] Final testing and QA

---

## 📈 Success Metrics

### Week 3 Targets

- Push notification delivery rate >95%
- Quick signup conversion >40%
- Contact picker usage >30%

### Week 4 Targets

- Crew feature adoption >20%
- Share-to-apply time <3 minutes
- Deep link success rate >90%

---

## 🔐 Security Considerations

1. **Contact Data Protection**
   - Never store raw contacts on server
   - Hash identifiers for matching
   - Implement rate limiting

2. **Quick Signup Security**
   - Validate share links
   - Prevent automated signups
   - Implement CAPTCHA if needed

3. **Notification Security**
   - Validate FCM tokens
   - Sanitize notification content
   - Implement notification preferences

---

## 🎯 Next Steps (Phase 3 Preview)

1. **SMS Integration**
   - Twilio setup
   - SMS templates
   - Cost management

2. **Advanced Analytics**
   - Conversion funnels
   - A/B testing
   - ROI tracking

3. **Group Applications**
   - Bulk apply feature
   - Contractor dashboard
   - Crew availability tracking

---

- ***End of Phase 2 Implementation Plan***
