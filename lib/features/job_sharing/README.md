# Contact Picker Feature

A comprehensive native contact integration system for job sharing in the Journeyman Jobs app. This feature allows IBEW members to easily share job opportunities with their contacts while providing special highlighting for existing platform users.

## Features

### Core Functionality
- 📱 **Native Contacts Integration** - Direct access to device contacts
- 🔍 **Smart Search & Filtering** - Search contacts by name, email, or phone
- 👥 **Multi-Select Support** - Select multiple contacts with configurable limits
- ⚡ **IBEW Member Highlighting** - Special badges for existing platform users
- 🎨 **Electrical Theme** - Consistent with app's electrical design system
- 🔒 **Permission Handling** - Graceful permission requests and error handling
- ⚡ **Performance Optimized** - Efficient loading and filtering for large contact lists

### Technical Features
- 🧪 **Riverpod State Management** - Modern reactive state management
- 🔄 **Real-time Updates** - Live search with debouncing
- 📱 **Platform-Specific** - iOS and Android optimized implementations
- 🎯 **Type Safety** - Full null-safety and strong typing
- 🧩 **Modular Design** - Reusable components and services
- ✅ **Comprehensive Testing** - Unit and widget tests included

## Architecture

```
lib/features/job_sharing/
├── widgets/
│   ├── contact_picker.dart              # Standard contact picker widget
│   └── riverpod_contact_picker.dart     # Riverpod-powered version
├── services/
│   └── contact_service.dart             # Contact operations and utilities
├── providers/
│   └── contact_provider.dart            # Riverpod state management
├── screens/
│   └── contact_picker_demo_screen.dart  # Demo and testing screen
├── examples/
│   └── contact_picker_usage.dart        # Integration examples
└── README.md                            # This file
```

## Setup & Installation

### 1. Dependencies
The following dependencies are required and have been added to `pubspec.yaml`:

```yaml
dependencies:
  contacts_service: ^0.6.3
  permission_handler: ^12.0.1  # Already included
  flutter_riverpod: ^3.0.0-dev.17  # Already included
```

### 2. Platform Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Contacts permissions for job sharing -->
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<!-- Contacts permissions for job sharing -->
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts to easily share job opportunities with your fellow IBEW brothers and sisters</string>
```

### 3. Run Dependencies Installation
```bash
flutter pub get
```

## Usage

### Basic Implementation

```dart
import 'package:journeyman_jobs/features/job_sharing/widgets/riverpod_contact_picker.dart';

// Open contact picker
final selectedContacts = await Navigator.of(context).push<List<ContactInfo>>(
  MaterialPageRoute(
    builder: (context) => JJRiverpodContactPicker(
      onContactsSelected: (contacts) {
        // Called as contacts are selected
        print('Selected: ${contacts.length} contacts');
      },
      existingPlatformUsers: ['member1@ibew123.org', 'member2@ibew456.org'],
      allowMultiSelect: true,
      maxSelection: 10,
      highlightExistingUsers: true,
    ),
  ),
);

// Process selected contacts
if (selectedContacts != null && selectedContacts.isNotEmpty) {
  for (final contact in selectedContacts) {
    print('Contact: ${contact.displayName}');
    print('Email: ${contact.primaryEmail}');
    print('Phone: ${contact.primaryPhoneNumber}');
  }
}
```

### Advanced Usage with Job Sharing

```dart
// Share a specific job with selected contacts
Future<void> shareJobWithContacts(String jobId) async {
  final contacts = await Navigator.push<List<ContactInfo>>(
    context,
    MaterialPageRoute(
      builder: (context) => JJRiverpodContactPicker(
        onContactsSelected: (contacts) {},
        existingPlatformUsers: await getExistingIBEWMembers(),
        allowMultiSelect: true,
        maxSelection: 15,
      ),
    ),
  );

  if (contacts != null) {
    await sendJobInvitations(jobId, contacts);
  }
}
```

## Widget Configuration

### JJRiverpodContactPicker Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onContactsSelected` | `Function(List<ContactInfo>)` | **Required** | Callback when contacts are selected |
| `existingPlatformUsers` | `List<String>?` | `null` | List of existing user emails/phones for highlighting |
| `allowMultiSelect` | `bool` | `true` | Whether to allow multiple contact selection |
| `maxSelection` | `int` | `10` | Maximum number of contacts that can be selected |
| `highlightExistingUsers` | `bool` | `true` | Whether to show special badges for existing users |

### ContactInfo Model

```dart
class ContactInfo {
  final String displayName;
  final List<String> emails;
  final List<String> phoneNumbers;
  final List<int>? avatar;

  // Computed properties
  String? get primaryEmail => emails.isNotEmpty ? emails.first : null;
  String? get primaryPhoneNumber => phoneNumbers.isNotEmpty ? phoneNumbers.first : null;
  bool get hasContactMethod => emails.isNotEmpty || phoneNumbers.isNotEmpty;
}
```

## Service Layer

### ContactService Methods

```dart
// Check permission status
bool hasPermission = await ContactService.instance.hasContactsPermission();

// Request permission
ContactPermissionResult result = await ContactService.instance.requestContactsPermission();

// Load contacts with filtering
ContactLoadResult contacts = await ContactService.instance.loadContacts(
  requireEmailOrPhone: true,
  searchQuery: 'john',
);

// Utility methods
String initials = ContactService.instance.getContactInitials(contact);
String formatted = ContactService.instance.formatPhoneNumber('+1234567890');
bool isExisting = ContactService.instance.isExistingPlatformUser(contact, existingUsers);
```

## State Management

### Using Riverpod Providers

```dart
// Initialize contact state
ref.read(contactProvider.notifier).initialize(
  existingPlatformUsers: ['user1@example.com'],
);

// Watch contact state
final contactState = ref.watch(contactProvider);

// Access specific state
final selectedCount = ref.watch(selectedContactCountProvider);
final hasPermission = ref.watch(contactPermissionProvider);
```

## Testing

Run the comprehensive test suite:

```bash
# Run all tests
flutter test

# Run specific contact picker tests
flutter test test/features/job_sharing/widgets/contact_picker_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage

The test suite covers:
- Widget rendering and interaction
- Permission handling flows
- Contact selection logic
- Search and filtering functionality
- Service layer methods
- State management with providers
- Error handling scenarios

## Demo Screen

A demo screen is included to showcase functionality:

```dart
import 'package:journeyman_jobs/features/job_sharing/screens/contact_picker_demo_screen.dart';

// Navigate to demo
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ContactPickerDemoScreen()),
);
```

## Performance Considerations

### Optimizations Implemented
- **Lazy Loading** - Contacts loaded only when needed
- **Search Debouncing** - 300ms delay to prevent excessive filtering
- **Image Optimization** - Low-resolution avatars for performance
- **Memory Management** - Proper disposal of controllers and timers
- **Efficient Filtering** - Optimized string matching algorithms

### Large Contact Lists
The picker is optimized to handle:
- 1000+ contacts with smooth scrolling
- Real-time search across all contact fields
- Efficient memory usage for contact avatars
- Pagination support for extremely large lists (if needed)

## Error Handling

### Permission Scenarios
- ✅ **Granted** - Full functionality
- ❌ **Denied** - Graceful fallback with retry option
- 🚫 **Permanently Denied** - Settings link with clear instructions
- ⚠️ **Error** - User-friendly error messages

### Contact Loading Errors
- Network connectivity issues
- Corrupted contact data
- Platform-specific errors
- Memory constraints

## Accessibility

### Features Implemented
- ♿ **Screen Reader Support** - Semantic labels and descriptions
- 🔤 **High Contrast** - Proper color contrast ratios
- 📱 **Large Text** - Scalable typography
- ⌨️ **Keyboard Navigation** - Full keyboard accessibility
- 🎯 **Focus Management** - Logical tab order

## Security & Privacy

### Data Protection
- 🔐 **Permission-Based Access** - Explicit user consent required
- 🚫 **No Data Storage** - Contacts never stored locally or transmitted
- 📱 **Platform Security** - Uses native platform contact APIs
- 🔒 **Encrypted Communication** - All network requests encrypted

### Privacy Compliance
- **GDPR Compliant** - No personal data collection
- **CCPA Compliant** - Transparent data usage
- **Platform Guidelines** - Follows iOS/Android privacy policies

## Integration Examples

### Job Sharing Integration
```dart
// In job details screen
ElevatedButton.icon(
  onPressed: () => shareJobWithContacts(job.id),
  icon: const Icon(Icons.share),
  label: const Text('Share with Brothers'),
)
```

### Storm Roster Integration
```dart
// Emergency contact selection
JJRiverpodContactPicker(
  onContactsSelected: (contacts) => setEmergencyContacts(contacts),
  allowMultiSelect: true,
  maxSelection: 3,
  highlightExistingUsers: false,
)
```

### Mentorship Assignment
```dart
// Single contact selection for mentor
JJRiverpodContactPicker(
  onContactsSelected: (contacts) => assignMentor(contacts.first),
  allowMultiSelect: false,
  maxSelection: 1,
  existingPlatformUsers: certifiedMentors,
)
```

## Troubleshooting

### Common Issues

#### Permission Denied
```dart
// Check permission status
final hasPermission = await ContactService.instance.hasContactsPermission();
if (!hasPermission) {
  // Guide user to settings
  await openAppSettings();
}
```

#### No Contacts Found
- Verify contacts exist with email/phone
- Check device contact app functionality
- Ensure proper permission granted

#### Performance Issues
- Enable contact thumbnail loading only if needed
- Implement pagination for very large lists
- Use search debouncing appropriately

## Roadmap

### Planned Enhancements
- 📧 **Smart Grouping** - Group contacts by company/organization
- 🔄 **Sync Integration** - Real-time contact updates
- 📊 **Analytics** - Sharing success metrics
- 🌐 **Web Support** - Progressive web app compatibility
- 🤖 **AI Suggestions** - Smart contact recommendations

### Future Features
- **Bulk Actions** - Select all/none functionality
- **Custom Tags** - User-defined contact categories
- **Sharing History** - Track previous sharing activities
- **Integration APIs** - Third-party contact sources

## Contributing

When contributing to the contact picker feature:

1. **Follow Design System** - Use AppTheme constants
2. **Add Tests** - Include widget and unit tests
3. **Update Documentation** - Keep README current
4. **Performance Testing** - Test with large contact lists
5. **Accessibility Testing** - Verify screen reader compatibility

## Support

For issues or questions regarding the contact picker feature:

- 📧 Create an issue in the project repository
- 🔧 Check existing test cases for usage examples
- 📚 Review the demo screen implementation
- 💬 Consult the integration examples

---

**Built with ⚡ for IBEW members by IBEW members**