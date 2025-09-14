# Job Sharing Widgets

This directory contains the UI components for the job sharing feature in the Journeyman Jobs app.

## Components

### 1. JJShareButton (`share_button.dart`)
A customizable share button with electrical theme and lightning animations.

**Features:**
- Multiple size variants (small, medium, large)
- Primary and secondary style variants
- Electrical pulse animation on tap
- Circuit pattern overlay
- Loading state support
- Customizable tooltip

**Usage:**
```dart
JJShareButton(
  size: JJShareButtonSize.medium,
  variant: JJShareButtonVariant.primary,
  onPressed: () => shareJob(),
  tooltip: 'Share this job',
)
```

### 2. JJShareModal (`share_modal.dart`)
A full-featured modal for selecting recipients and sharing jobs.

**Features:**
- Job preview with key details
- Recipient selection with search
- Personal message input
- Share progress indication
- Electrical-themed design
- Responsive layout

**Usage:**
```dart
showDialog(
  context: context,
  builder: (context) => JJShareModal(
    job: selectedJob,
    contacts: userContacts,
    onShare: (recipients, message) {
      // Handle share action
    },
  ),
);
```

### 3. JJRecipientSelector (`recipient_selector.dart`)
Widget for selecting and managing recipients for job sharing.

**Features:**
- Search functionality
- Selected recipients display with removal
- Add new contact capability
- Electrical animations
- Maximum recipient limits

**Usage:**
```dart
JJRecipientSelector(
  contacts: availableContacts,
  selectedRecipients: selectedList,
  onRecipientsChanged: (recipients) {
    setState(() => selectedList = recipients);
  },
  maxRecipients: 10,
)
```

### 4. JJNotificationCard (`notification_card.dart`)
Card component for displaying job share notifications.

**Features:**
- Different styles for notification types
- Swipe-to-dismiss functionality
- Interactive actions (view job, mark as read)
- Status indicators and timestamps
- Electrical theme with pulse effects

**Usage:**
```dart
JJNotificationCard(
  notification: shareNotification,
  onTap: () => handleNotificationTap(),
  onViewJob: () => viewJobDetails(),
  onMarkAsRead: () => markAsRead(),
  onDismiss: () => dismissNotification(),
)
```

## Design System Integration

All widgets follow the electrical theme design system:

- **Colors**: Navy (`#1A202C`) and Copper (`#B45309`)
- **Components**: Use `JJ` prefix for consistency
- **Animations**: Lightning bolts and electrical effects
- **Typography**: Inter font with defined text styles
- **Spacing**: Consistent spacing constants from `AppTheme`

## Models

### ShareNotificationModel (`../models/share_notification_model.dart`)
Data model for share notifications with the following types:
- `jobShared`: User shared a job with others
- `shareReceived`: User received a job share
- `shareViewed`: Someone viewed a shared job
- `shareExpired`: A share has expired

## Demo

See `share_widgets_demo.dart` for a comprehensive demonstration of all components with mock data and interactions.

## Dependencies

- `flutter_animate`: For electrical animations
- Existing app models: `Job`, `UserModel`
- App theme: `AppTheme` from design system

## Testing

Widget tests should be created in `/test/features/job_sharing/widgets/` following the existing test patterns.

## Integration

These widgets integrate with:
- Job sharing service for backend operations
- User contacts and profile management
- Push notification system
- App navigation and routing
