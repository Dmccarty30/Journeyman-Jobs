# Phase 1 Implementation - Job Sharing Feature

## Week 1-2: Basic Share Functionality, User Detection & Tracking

---

## 📋 Phase 1 Overview

### Objectives

1. Implement basic share-to-email functionality
2. Build user detection system
3. Create share tracking infrastructure
4. Set up database schema

### Deliverables

- Share button on job details screen
- Email sharing with job details
- User detection algorithm
- Share tracking in Firestore
- Basic analytics

---

## 🗂️ File Structure

``` tree
lib/
├── features/
│   └── job_sharing/
│       ├── models/
│       │   ├── share_model.dart
│       │   ├── share_recipient.dart
│       │   └── share_analytics.dart
│       ├── services/
│       │   ├── share_service.dart
│       │   ├── user_detection_service.dart
│       │   └── email_service.dart
│       ├── widgets/
│       │   ├── share_button.dart
│       │   ├── share_modal.dart
│       │   └── recipient_selector.dart
│       └── screens/
│           └── share_screen.dart
└── core/
    └── utils/
        └── share_utils.dart
```

---

## 📝 Step-by-Step Implementation

### Step 1: Create Data Models

**File: `lib/features/job_sharing/models/share_model.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ShareModel {
  final String id;
  final String jobId;
  final String sharerId;
  final String sharerName;
  final List<ShareRecipient> recipients;
  final String? message;
  final DateTime createdAt;
  final Map<String, dynamic> jobSnapshot;

  ShareModel({
    required this.id,
    required this.jobId,
    required this.sharerId,
    required this.sharerName,
    required this.recipients,
    this.message,
    required this.createdAt,
    required this.jobSnapshot,
  });

  factory ShareModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShareModel(
      id: doc.id,
      jobId: data['jobId'],
      sharerId: data['sharerId'],
      sharerName: data['sharerName'],
      recipients: (data['recipients'] as List)
          .map((r) => ShareRecipient.fromMap(r))
          .toList(),
      message: data['message'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      jobSnapshot: data['jobSnapshot'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'sharerId': sharerId,
      'sharerName': sharerName,
      'recipients': recipients.map((r) => r.toMap()).toList(),
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'jobSnapshot': jobSnapshot,
    };
  }
}

class ShareRecipient {
  final String identifier; // Email or phone
  final RecipientType type;
  final String? userId; // If existing user
  final String? name;
  ShareStatus status;
  DateTime? viewedAt;
  DateTime? appliedAt;

  ShareRecipient({
    required this.identifier,
    required this.type,
    this.userId,
    this.name,
    this.status = ShareStatus.sent,
    this.viewedAt,
    this.appliedAt,
  });

  factory ShareRecipient.fromMap(Map<String, dynamic> map) {
    return ShareRecipient(
      identifier: map['identifier'],
      type: RecipientType.values.byName(map['type']),
      userId: map['userId'],
      name: map['name'],
      status: ShareStatus.values.byName(map['status']),
      viewedAt: map['viewedAt'] != null 
          ? (map['viewedAt'] as Timestamp).toDate() 
          : null,
      appliedAt: map['appliedAt'] != null 
          ? (map['appliedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'type': type.name,
      'userId': userId,
      'name': name,
      'status': status.name,
      'viewedAt': viewedAt != null 
          ? Timestamp.fromDate(viewedAt!) 
          : null,
      'appliedAt': appliedAt != null 
          ? Timestamp.fromDate(appliedAt!) 
          : null,
    };
  }
}

enum RecipientType { user, email, phone }
enum ShareStatus { sent, viewed, applied, expired }
```

---

### Step 2: Create User Detection Service

**File: `lib/features/job_sharing/services/user_detection_service.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/share_model.dart';

class UserDetectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Check if email/phone belongs to existing user
  Future<Map<String, dynamic>?> detectUser(String identifier) async {
    try {
      // Clean identifier
      final cleanId = identifier.trim().toLowerCase();
      
      // Check by email
      if (_isEmail(cleanId)) {
        final emailQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: cleanId)
            .limit(1)
            .get();
            
        if (emailQuery.docs.isNotEmpty) {
          final doc = emailQuery.docs.first;
          return {
            'userId': doc.id,
            'email': doc.data()['email'],
            'name': '${doc.data()['first_name']} ${doc.data()['last_name']}',
            'isUser': true,
            'type': RecipientType.user,
          };
        }
      }
      
      // Check by phone
      if (_isPhone(cleanId)) {
        final phoneQuery = await _firestore
            .collection('users')
            .where('phone_number', isEqualTo: cleanId)
            .limit(1)
            .get();
            
        if (phoneQuery.docs.isNotEmpty) {
          final doc = phoneQuery.docs.first;
          return {
            'userId': doc.id,
            'phone': doc.data()['phone_number'],
            'name': '${doc.data()['first_name']} ${doc.data()['last_name']}',
            'isUser': true,
            'type': RecipientType.user,
          };
        }
      }
      
      // Not a user
      return {
        'identifier': cleanId,
        'isUser': false,
        'type': _isEmail(cleanId) ? RecipientType.email : RecipientType.phone,
      };
      
    } catch (e) {
      print('Error detecting user: $e');
      return null;
    }
  }
  
  /// Batch check multiple identifiers
  Future<List<Map<String, dynamic>>> detectMultipleUsers(
    List<String> identifiers
  ) async {
    final results = <Map<String, dynamic>>[];
    
    for (final identifier in identifiers) {
      final result = await detectUser(identifier);
      if (result != null) {
        results.add(result);
      }
    }
    
    return results;
  }
  
  bool _isEmail(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }
  
  bool _isPhone(String value) {
    // Remove non-digits and check length
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 15;
  }
}
```

---

### Step 3: Create Share Service

**File: `lib/features/job_sharing/services/share_service.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/share_model.dart';
import 'user_detection_service.dart';
import 'email_service.dart';
import '../../jobs/models/job_model.dart';

class ShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserDetectionService _userDetection = UserDetectionService();
  final EmailService _emailService = EmailService();
  
  /// Share a job with multiple recipients
  Future<ShareModel> shareJob({
    required JobModel job,
    required List<String> recipientIdentifiers,
    String? personalMessage,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');
      
      // Get sharer's name
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final sharerName = '${userDoc.data()?['first_name']} ${userDoc.data()?['last_name']}';
      
      // Detect recipients (user vs non-user)
      final detectedRecipients = await _userDetection
          .detectMultipleUsers(recipientIdentifiers);
      
      // Create ShareRecipient objects
      final recipients = detectedRecipients.map((data) {
        return ShareRecipient(
          identifier: data['identifier'] ?? data['email'] ?? data['phone'],
          type: data['type'],
          userId: data['userId'],
          name: data['name'],
          status: ShareStatus.sent,
        );
      }).toList();
      
      // Create share record
      final share = ShareModel(
        id: '', // Will be set by Firestore
        jobId: job.id,
        sharerId: currentUser.uid,
        sharerName: sharerName,
        recipients: recipients,
        message: personalMessage,
        createdAt: DateTime.now(),
        jobSnapshot: job.toMap(),
      );
      
      // Save to Firestore
      final docRef = await _firestore
          .collection('shares')
          .add(share.toFirestore());
      
      // Send notifications
      await _sendShareNotifications(share, job);
      
      // Track analytics
      await _trackShareAnalytics(share);
      
      return ShareModel(
        id: docRef.id,
        jobId: share.jobId,
        sharerId: share.sharerId,
        sharerName: share.sharerName,
        recipients: share.recipients,
        message: share.message,
        createdAt: share.createdAt,
        jobSnapshot: share.jobSnapshot,
      );
      
    } catch (e) {
      print('Error sharing job: $e');
      rethrow;
    }
  }
  
  /// Send notifications based on recipient type
  Future<void> _sendShareNotifications(
    ShareModel share, 
    JobModel job
  ) async {
    for (final recipient in share.recipients) {
      if (recipient.type == RecipientType.user) {
        // Create in-app notification (Phase 2)
        await _createInAppNotification(
          userId: recipient.userId!,
          share: share,
          job: job,
        );
      } else if (recipient.type == RecipientType.email) {
        // Send email
        await _emailService.sendJobShareEmail(
          toEmail: recipient.identifier,
          sharerName: share.sharerName,
          job: job,
          personalMessage: share.message,
          shareId: share.id,
        );
      } else if (recipient.type == RecipientType.phone) {
        // Send SMS (Phase 3)
        // For now, log it
        print('SMS to ${recipient.identifier}: Job share from ${share.sharerName}');
      }
    }
  }
  
  /// Create in-app notification for existing users
  Future<void> _createInAppNotification({
    required String userId,
    required ShareModel share,
    required JobModel job,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'type': 'job_share',
      'title': '${share.sharerName} shared a job with you',
      'message': '${job.classification} at ${job.company} - \$${job.hourlyRate}/hr',
      'data': {
        'shareId': share.id,
        'jobId': job.id,
        'sharerId': share.sharerId,
      },
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Track share analytics
  Future<void> _trackShareAnalytics(ShareModel share) async {
    await _firestore.collection('analytics').add({
      'event': 'job_shared',
      'userId': share.sharerId,
      'jobId': share.jobId,
      'recipientCount': share.recipients.length,
      'recipientTypes': share.recipients
          .map((r) => r.type.name)
          .toSet()
          .toList(),
      'hasMessage': share.message != null,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  /// Update share status when viewed
  Future<void> markShareAsViewed(String shareId, String identifier) async {
    final shareDoc = await _firestore
        .collection('shares')
        .doc(shareId)
        .get();
        
    if (!shareDoc.exists) return;
    
    final share = ShareModel.fromFirestore(shareDoc);
    final recipientIndex = share.recipients
        .indexWhere((r) => r.identifier == identifier);
        
    if (recipientIndex != -1) {
      share.recipients[recipientIndex].status = ShareStatus.viewed;
      share.recipients[recipientIndex].viewedAt = DateTime.now();
      
      await _firestore
          .collection('shares')
          .doc(shareId)
          .update({
        'recipients': share.recipients.map((r) => r.toMap()).toList(),
      });
    }
  }
}
```

---

### Step 4: Create Email Service

**File: `lib/features/job_sharing/services/email_service.dart`**

```dart
import 'package:cloud_functions/cloud_functions.dart';
import '../../jobs/models/job_model.dart';

class EmailService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  /// Send job share email to non-users
  Future<bool> sendJobShareEmail({
    required String toEmail,
    required String sharerName,
    required JobModel job,
    String? personalMessage,
    required String shareId,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendJobShareEmail');
      
      final result = await callable.call({
        'to': toEmail,
        'sharerName': sharerName,
        'job': {
          'id': job.id,
          'title': job.classification,
          'company': job.company,
          'location': '${job.city}, ${job.state}',
          'hourlyRate': job.hourlyRate,
          'perDiem': job.perDiem,
          'duration': job.duration,
          'description': job.description,
        },
        'personalMessage': personalMessage,
        'shareId': shareId,
        'signupLink': 'https://journeymanjobs.com/signup?share=$shareId&job=${job.id}',
      });
      
      return result.data['success'] == true;
      
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
  
  /// Send batch emails
  Future<Map<String, bool>> sendBatchEmails(
    List<Map<String, dynamic>> emailData
  ) async {
    final results = <String, bool>{};
    
    for (final data in emailData) {
      final success = await sendJobShareEmail(
        toEmail: data['email'],
        sharerName: data['sharerName'],
        job: data['job'],
        personalMessage: data['message'],
        shareId: data['shareId'],
      );
      results[data['email']] = success;
    }
    
    return results;
  }
}
```

---

### Step 5: Create Share Button Widget

**File: `lib/features/job_sharing/widgets/share_button.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../jobs/models/job_model.dart';
import '../screens/share_screen.dart';

class ShareButton extends StatelessWidget {
  final JobModel job;
  final bool isIconOnly;
  final VoidCallback? onShareComplete;

  const ShareButton({
    super.key,
    required this.job,
    this.isIconOnly = false,
    this.onShareComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (isIconOnly) {
      return IconButton(
        icon: Icon(
          Icons.share_outlined,
          color: AppTheme.primaryNavy,
        ),
        onPressed: () => _openShareScreen(context),
        tooltip: 'Share Job',
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _openShareScreen(context),
      icon: Icon(Icons.share_outlined),
      label: Text('Share'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }

  void _openShareScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareScreen(
          job: job,
          onShareComplete: onShareComplete,
        ),
      ),
    );
  }
}
```

---

### Step 6: Create Share Modal

**File: `lib/features/job_sharing/widgets/share_modal.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../models/share_model.dart';

class ShareModal extends StatefulWidget {
  final List<Map<String, dynamic>> detectedRecipients;
  final Function(String) onAddRecipient;
  final Function(String) onRemoveRecipient;
  final VoidCallback onShare;

  const ShareModal({
    super.key,
    required this.detectedRecipients,
    required this.onAddRecipient,
    required this.onRemoveRecipient,
    required this.onShare,
  });

  @override
  State<ShareModal> createState() => _ShareModalState();
}

class _ShareModalState extends State<ShareModal> {
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  final List<String> _selectedRecipients = [];
  bool _isAddingRecipient = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingLg),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Share Job Opportunity',
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
          
          SizedBox(height: AppTheme.spacingMd),
          
          // Add recipient field
          Row(
            children: [
              Expanded(
                child: JJTextField(
                  controller: _recipientController,
                  label: 'Email or Phone',
                  hintText: 'Enter email or phone number',
                  prefixIcon: Icons.person_add_outlined,
                ),
              ),
              SizedBox(width: AppTheme.spacingMd),
              JJIconButton(
                icon: Icons.add,
                onPressed: _addRecipient,
                isLoading: _isAddingRecipient,
              ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacingLg),
          
          // Recipients list
          if (widget.detectedRecipients.isNotEmpty) ...[
            Text(
              'Recipients',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacingSm),
            
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.detectedRecipients.length,
                itemBuilder: (context, index) {
                  final recipient = widget.detectedRecipients[index];
                  final isUser = recipient['isUser'] == true;
                  final identifier = recipient['identifier'] ?? 
                                    recipient['email'] ?? 
                                    recipient['phone'];
                  final isSelected = _selectedRecipients.contains(identifier);
                  
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRecipients.add(identifier);
                        } else {
                          _selectedRecipients.remove(identifier);
                        }
                      });
                    },
                    title: Text(
                      recipient['name'] ?? identifier,
                      style: AppTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      identifier,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    secondary: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: isUser 
                            ? AppTheme.successGreen.withOpacity(0.1)
                            : AppTheme.warningAmber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        isUser ? 'User' : 'Invite',
                        style: AppTheme.bodySmall.copyWith(
                          color: isUser 
                              ? AppTheme.successGreen
                              : AppTheme.warningAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          SizedBox(height: AppTheme.spacingMd),
          
          // Personal message
          JJTextField(
            controller: _messageController,
            label: 'Add a message (optional)',
            hintText: 'Hey, thought you might be interested in this job...',
            maxLines: 3,
            prefixIcon: Icons.message_outlined,
          ),
          
          SizedBox(height: AppTheme.spacingLg),
          
          // Action buttons
          Row(
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
                  text: 'Share',
                  icon: Icons.send,
                  onPressed: _selectedRecipients.isEmpty 
                      ? null 
                      : () {
                          widget.onShare();
                          Navigator.pop(context);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _addRecipient() async {
    final value = _recipientController.text.trim();
    if (value.isEmpty) return;
    
    setState(() => _isAddingRecipient = true);
    
    // Add recipient logic
    widget.onAddRecipient(value);
    _recipientController.clear();
    
    setState(() => _isAddingRecipient = false);
  }
  
  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
```

---

### Step 7: Update Job Details Screen

**File: Update `lib/features/jobs/screens/job_details_screen.dart`**

```dart
// Add to existing imports
import '../../job_sharing/widgets/share_button.dart';

// Add share button to the job details screen
// In the build method, add this after the job details:

Container(
  padding: EdgeInsets.all(AppTheme.spacingMd),
  child: Row(
    children: [
      Expanded(
        child: JJPrimaryButton(
          text: 'Apply Now',
          icon: Icons.send,
          onPressed: _applyForJob,
        ),
      ),
      SizedBox(width: AppTheme.spacingMd),
      Expanded(
        child: ShareButton(
          job: widget.job,
          onShareComplete: () {
            JJSnackBar.showSuccess(
              context: context,
              message: 'Job shared successfully!',
            );
          },
        ),
      ),
    ],
  ),
),
```

---

## 🔥 Firebase Functions Setup

### Cloud Function for Email Sending

**File: `functions/src/index.ts`**

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';

admin.initializeApp();

// Configure email transporter (use SendGrid in production)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass,
  },
});

export const sendJobShareEmail = functions.https.onCall(async (data, context) => {
  const { to, sharerName, job, personalMessage, shareId, signupLink } = data;
  
  // Email template
  const htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #2C3E50; color: white; padding: 20px; text-align: center; }
        .job-card { background: #f4f4f4; padding: 20px; margin: 20px 0; border-radius: 8px; }
        .job-title { font-size: 24px; color: #2C3E50; margin-bottom: 10px; }
        .job-detail { margin: 8px 0; }
        .cta-button { 
          display: inline-block; 
          background: #F39C12; 
          color: white; 
          padding: 12px 30px; 
          text-decoration: none; 
          border-radius: 5px; 
          margin: 20px 0;
        }
        .message { background: #fff; padding: 15px; margin: 15px 0; border-left: 4px solid #F39C12; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>⚡ Journeyman Jobs</h1>
          <p>${sharerName} shared a job opportunity with you!</p>
        </div>
        
        ${personalMessage ? `
          <div class="message">
            <strong>Message from ${sharerName}:</strong><br>
            ${personalMessage}
          </div>
        ` : ''}
        
        <div class="job-card">
          <h2 class="job-title">${job.title}</h2>
          <div class="job-detail">📍 <strong>Location:</strong> ${job.location}</div>
          <div class="job-detail">🏢 <strong>Company:</strong> ${job.company}</div>
          <div class="job-detail">💰 <strong>Rate:</strong> $${job.hourlyRate}/hr</div>
          ${job.perDiem ? `<div class="job-detail">🏨 <strong>Per Diem:</strong> $${job.perDiem}/day</div>` : ''}
          <div class="job-detail">⏱️ <strong>Duration:</strong> ${job.duration}</div>
          
          <p>${job.description}</p>
        </div>
        
        <div style="text-align: center;">
          <a href="${signupLink}" class="cta-button">
            Join & Apply in 2 Minutes →
          </a>
          <p style="color: #666; font-size: 14px;">
            Join thousands of journeymen finding better opportunities
          </p>
        </div>
        
        <hr style="margin: 30px 0; border: none; border-top: 1px solid #ddd;">
        
        <p style="text-align: center; color: #999; font-size: 12px;">
          You received this email because ${sharerName} thought you'd be interested in this opportunity.<br>
          <a href="${signupLink}&unsubscribe=true" style="color: #999;">Unsubscribe</a>
        </p>
      </div>
    </body>
    </html>
  `;
  
  try {
    await transporter.sendMail({
      from: '"Journeyman Jobs" <noreply@journeymanjobs.com>',
      to: to,
      subject: `${sharerName} shared a $${job.hourlyRate}/hr ${job.title} opportunity with you`,
      html: htmlContent,
    });
    
    // Log email sent
    await admin.firestore().collection('email_logs').add({
      to,
      type: 'job_share',
      shareId,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'sent',
    });
    
    return { success: true };
    
  } catch (error) {
    console.error('Error sending email:', error);
    return { success: false, error: error.message };
  }
});
```

---

## 🗄️ Database Schema Updates

### Firestore Collections

**1. `shares` Collection**

```javascript
{
  jobId: string,
  sharerId: string,
  sharerName: string,
  recipients: [
    {
      identifier: string,
      type: 'user' | 'email' | 'phone',
      userId: string | null,
      name: string | null,
      status: 'sent' | 'viewed' | 'applied' | 'expired',
      viewedAt: timestamp | null,
      appliedAt: timestamp | null
    }
  ],
  message: string | null,
  createdAt: timestamp,
  jobSnapshot: {
    // Complete job data at time of share
  }
}
```

**2. `share_analytics` Collection**

```javascript
{
  event: string,
  userId: string,
  jobId: string,
  recipientCount: number,
  recipientTypes: string[],
  hasMessage: boolean,
  timestamp: timestamp
}
```

---

## 🧪 Testing Checklist

### Unit Tests

- [ ] User detection service tests
- [ ] Share model serialization tests
- [ ] Email validation tests
- [ ] Phone validation tests

### Integration Tests

- [ ] Share creation flow
- [ ] Email sending
- [ ] User detection accuracy
- [ ] Analytics tracking

### Manual Testing

- [ ] Share button appears on job details
- [ ] Can add email recipients
- [ ] Can add phone recipients
- [ ] Detects existing users correctly
- [ ] Email sends successfully
- [ ] Share tracking works
- [ ] Analytics events fire

---

## 📊 Success Metrics

### Week 1 Goals

- Share button functional
- Basic email sharing works
- User detection 90% accurate
- Share tracking implemented

### Week 2 Goals

- Email templates polished
- Analytics dashboard ready
- Error handling robust
- Performance optimized

---

## 🚀 Deployment Steps

1. **Deploy Cloud Functions**

```bash
firebase deploy --only functions:sendJobShareEmail
```

2.0 **Update Firestore Rules**

```javascript
// Add to firestore.rules
match /shares/{shareId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update: if request.auth != null && 
    request.auth.uid == resource.data.sharerId;
}
```

3.0 **Update App Bundle**

```bash
flutter build apk --release
flutter build ios --release
```

---

## ⚠️ Rollback Plan

If issues arise:

1. Feature flag to disable share button
2. Revert Cloud Functions
3. Clear share collection if needed
4. Restore previous app version

---
