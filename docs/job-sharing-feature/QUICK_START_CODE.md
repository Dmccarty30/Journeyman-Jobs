# Job Sharing Feature - Quick Start Code Reference

## Copy-Paste Ready Implementation

---

## 🚀 Quick Setup Commands

```bash
# Add dependencies to pubspec.yaml
flutter pub add cloud_firestore firebase_auth firebase_messaging flutter_local_notifications permission_handler contacts_service share_plus uni_links rxdart

# iOS setup
cd ios && pod install

# Create feature folder structure
mkdir -p lib/features/job_sharing/{models,services,screens,widgets,providers}
```

---

## 📦 Essential Package Imports

```dart
// Core imports for any share-related file
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

// Service imports
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uni_links/uni_links.dart';
```

---

## 🎯 Quick Share Button Implementation

### Add to Any Job Card/Details

```dart
// Simple share button to add anywhere
class QuickShareButton extends StatelessWidget {
  final String jobId;
  final String jobTitle;
  final String company;
  final double hourlyRate;

  const QuickShareButton({
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.hourlyRate,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.share),
      onPressed: () => _shareJob(context),
    );
  }

  void _shareJob(BuildContext context) async {
    // Quick share via system share sheet
    final text = '🔥 Check out this job opportunity!\n\n'
        '$jobTitle at $company\n'
        '💰 \$$hourlyRate/hr\n\n'
        'Apply here: https://journeymanjobs.com/job/$jobId';
    
    await Share.share(text);
    
    // Track share
    FirebaseFirestore.instance.collection('analytics').add({
      'event': 'job_shared_quick',
      'jobId': jobId,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
```

---

## 💾 Firestore Quick Setup

### Create Collections (Run Once)

```dart
// Run this in your initialization code
Future<void> setupShareCollections() async {
  final firestore = FirebaseFirestore.instance;
  
  // Create indexes
  await firestore.collection('shares').doc('_setup').set({
    'created': true,
    'timestamp': FieldValue.serverTimestamp(),
  });
  
  await firestore.collection('crews').doc('_setup').set({
    'created': true,
    'timestamp': FieldValue.serverTimestamp(),
  });
  
  print('Collections initialized');
}
```

### Security Rules (firestore.rules)

```javascript
// Add to your existing rules
match /shares/{shareId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update: if request.auth.uid == resource.data.sharerId;
}

match /crews/{crewId} {
  allow read: if request.auth != null && 
    (request.auth.uid == resource.data.ownerId ||
     request.auth.uid in resource.data.members[*].userId);
  allow create: if request.auth != null;
  allow update, delete: if request.auth.uid == resource.data.ownerId;
}

match /notifications/{notificationId} {
  allow read: if request.auth.uid == resource.data.userId;
  allow write: if false; // Server only
}
```

---

## 📧 Quick Email Share Function

```dart
// Simple email share without Cloud Functions
Future<void> shareJobViaEmail({
  required String recipientEmail,
  required Map<String, dynamic> job,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  
  // Create share record
  final shareRef = await FirebaseFirestore.instance.collection('shares').add({
    'jobId': job['id'],
    'sharerId': user.uid,
    'sharerName': user.displayName ?? 'A friend',
    'recipients': [{
      'identifier': recipientEmail,
      'type': 'email',
      'status': 'sent',
      'sentAt': FieldValue.serverTimestamp(),
    }],
    'jobSnapshot': job,
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // Open email client
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: recipientEmail,
    queryParameters: {
      'subject': '${user.displayName} shared a \$${job['hourlyRate']}/hr job with you',
      'body': '''
Hey!

I thought you might be interested in this opportunity:

${job['title']} at ${job['company']}
Location: ${job['location']}
Rate: \$${job['hourlyRate']}/hr
${job['perDiem'] != null ? 'Per Diem: \$${job['perDiem']}/day' : ''}

Sign up and apply here:
https://journeymanjobs.com/signup?share=${shareRef.id}&job=${job['id']}

Best,
${user.displayName}
      ''',
    },
  );
  
  await launchUrl(emailUri);
}
```

---

## 🔔 Quick Notification Setup

```dart
// Initialize in main.dart
Future<void> setupNotifications() async {
  final messaging = FirebaseMessaging.instance;
  
  // Request permission
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // Get token
  final token = await messaging.getToken();
  if (token != null) {
    // Save to user profile
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'fcmToken': token});
  }
  
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Show local notification or update UI
    print('Got message: ${message.notification?.title}');
  });
}
```

---

## 👥 Quick Contact Access

```dart
// Simple contact picker
Future<List<String>> pickContacts(BuildContext context) async {
  final List<String> selectedEmails = [];
  
  // Check permission
  final status = await Permission.contacts.request();
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact permission required')),
    );
    return [];
  }
  
  // Get contacts
  final contacts = await ContactsService.getContacts();
  
  // Show picker dialog
  final selected = await showDialog<List<String>>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Select Contacts'),
      children: contacts
          .where((c) => c.emails?.isNotEmpty ?? false)
          .map((contact) => SimpleDialogOption(
                child: Text('${contact.displayName}: ${contact.emails?.first.value}'),
                onPressed: () {
                  Navigator.pop(context, [contact.emails!.first.value!]);
                },
              ))
          .toList(),
    ),
  );
  
  return selected ?? [];
}
```

---

## 🚀 Quick Signup Handler

```dart
// Handle quick signup from share link
class QuickSignupHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Parse URL parameters
    final uri = Uri.base;
    final shareId = uri.queryParameters['share'];
    final jobId = uri.queryParameters['job'];
    
    if (shareId == null || jobId == null) {
      return Scaffold(
        body: Center(child: Text('Invalid share link')),
      );
    }
    
    return QuickSignupForm(shareId: shareId, jobId: jobId);
  }
}

class QuickSignupForm extends StatefulWidget {
  final String shareId;
  final String jobId;
  
  QuickSignupForm({required this.shareId, required this.jobId});
  
  @override
  _QuickSignupFormState createState() => _QuickSignupFormState();
}

class _QuickSignupFormState extends State<QuickSignupForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  Future<void> _signupAndApply() async {
    try {
      // Create account
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Create profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'email': _emailController.text,
        'name': _nameController.text,
        'signupSource': 'share',
        'shareId': widget.shareId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Auto-apply to job
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': cred.user!.uid,
        'jobId': widget.jobId,
        'appliedAt': FieldValue.serverTimestamp(),
        'source': 'share',
      });
      
      // Navigate to success
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick Signup')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signupAndApply,
              child: Text('Create Account & Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📊 Quick Analytics

```dart
// Track all share events
class ShareAnalytics {
  static void track(String event, Map<String, dynamic> params) {
    FirebaseFirestore.instance.collection('analytics').add({
      'event': event,
      'params': params,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  // Common events
  static void trackShareInitiated(String jobId) {
    track('share_initiated', {'jobId': jobId});
  }
  
  static void trackShareSent(String shareId, int recipientCount) {
    track('share_sent', {
      'shareId': shareId,
      'recipientCount': recipientCount,
    });
  }
  
  static void trackShareConversion(String shareId) {
    track('share_conversion', {'shareId': shareId});
  }
}
```

---

## 🎨 Quick UI Components

### Share Success Dialog

```dart
void showShareSuccess(BuildContext context, int recipientCount) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Shared Successfully!'),
        ],
      ),
      content: Text('Job shared with $recipientCount ${recipientCount == 1 ? 'person' : 'people'}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

### Share Loading Indicator

```dart
class ShareLoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Sharing job...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🔧 Utility Functions

```dart
// Validation helpers
class ShareUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 15;
  }
  
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }
  
  static String generateShareLink(String shareId, String jobId) {
    return 'https://journeymanjobs.com/share?id=$shareId&job=$jobId';
  }
  
  static String getShareMessage(Map<String, dynamic> job, String link) {
    return '''
Check out this opportunity!

${job['title']} at ${job['company']}
\$${job['hourlyRate']}/hr

Apply here: $link
    ''';
  }
}
```

---

## 🚨 Error Handling

```dart
// Wrap all share operations
Future<T?> safeShareOperation<T>(
  Future<T> Function() operation,
  BuildContext context,
) async {
  try {
    return await operation();
  } on FirebaseException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Network error: ${e.message}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Something went wrong. Please try again.')),
    );
  }
  return null;
}

// Usage
await safeShareOperation(
  () => shareJobViaEmail(email: 'test@example.com', job: jobData),
  context,
);
```

---

## 🎯 Testing Quick Start

```dart
// Basic widget test
testWidgets('Share button shows and responds', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: QuickShareButton(
        jobId: 'test123',
        jobTitle: 'Journeyman Lineman',
        company: 'Duke Energy',
        hourlyRate: 48.50,
      ),
    ),
  );
  
  expect(find.byIcon(Icons.share), findsOneWidget);
  
  await tester.tap(find.byIcon(Icons.share));
  await tester.pumpAndSettle();
  
  // Verify share was triggered
});
```

---

## 🚀 Deploy Commands

```bash
# Deploy Firebase Functions
cd functions
npm install
firebase deploy --only functions

# Deploy Firestore Rules
firebase deploy --only firestore:rules

# Build and deploy app
flutter build apk --release
flutter build ios --release

# Or for web
flutter build web
firebase deploy --only hosting
```

---

## 📝 Environment Variables (.env)

```env
# Firebase Config
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-auth-domain
FIREBASE_PROJECT_ID=your-project-id

# Email Service
SENDGRID_API_KEY=your-sendgrid-key
EMAIL_FROM=noreply@journeymanjobs.com

# Deep Links
APP_DOMAIN=https://journeymanjobs.com
IOS_BUNDLE_ID=com.journeymanjobs.app
ANDROID_PACKAGE=com.journeymanjobs.app
```

---

## ✅ Minimal MVP Checklist

If you need to ship quickly, implement just these:

```dart
1. ☐ QuickShareButton widget (5 min)
2. ☐ shareJobViaEmail function (10 min)
3. ☐ Basic Firestore collection (5 min)
4. ☐ Share tracking (5 min)
5. ☐ Success feedback (5 min)

Total: 30 minutes to basic sharing!
```

---

*This quick reference provides copy-paste ready code to get the job sharing feature up and running quickly. Start with the MVP checklist for the fastest implementation.*
