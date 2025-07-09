# IBEW Locals Screen Implementation Guide

## Problem Analysis & Solutions

### Identified Issues

1. **Data not displaying on cards**: Missing null checks and improper data binding
2. **Inconsistent styling**: Not following app's design system
3. **Non-clickable elements**: Missing URL launcher implementation
4. **Poor visual hierarchy**: Labels and values not distinguished
5. **Unnecessary elements**: "Active" status and member count fields

### Solution Implementation

## Complete locals_screen.dart

Place this file in: `lib/screens/jobs/locals_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '/backend/schema/locals_record.dart';
import '/design_system/app_theme.dart';
import 'dart:io' show Platform;

class LocalsScreen extends StatefulWidget {
  const LocalsScreen({Key? key}) : super(key: key);

  @override
  State<LocalsScreen> createState() => _LocalsScreenState();
}

class _LocalsScreenState extends State<LocalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('IBEW Locals Directory'),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: TextField(
              controller: _searchController,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'Search by local number, city, or state...',
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.white.withOpacity(0.7)
                ),
                prefixIcon: const Icon(Icons.search, color: AppTheme.white),
                filled: true,
                fillColor: AppTheme.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(
                    color: AppTheme.accentCopper, 
                    width: 2
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<LocalsRecord>>(
        stream: FirebaseFirestore.instance
            .collection('locals')
            .orderBy('local_union')
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => LocalsRecord.fromSnapshot(doc))
                .where((local) {
                  if (_searchQuery.isEmpty) return true;
                  return local.localUnion.toLowerCase().contains(_searchQuery) ||
                      local.city.toLowerCase().contains(_searchQuery) ||
                      local.state.toLowerCase().contains(_searchQuery) ||
                      local.classification.toLowerCase().contains(_searchQuery);
                })
                .toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.accentCopper
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppTheme.iconXxl,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Error loading locals',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.error
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Please try again later',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textLight
                    ),
                  ),
                ],
              ),
            );
          }

          final locals = snapshot.data ?? [];

          if (locals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_city,
                    size: AppTheme.iconXxl,
                    color: AppTheme.mediumGray,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    _searchQuery.isEmpty 
                        ? 'No locals found' 
                        : 'No results found',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.textLight
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Try adjusting your search',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textLight
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: locals.length,
            itemBuilder: (context, index) {
              final local = locals[index];
              return LocalCard(
                local: local,
                onTap: () => _showLocalDetails(context, local),
              );
            },
          );
        },
      ),
    );
  }

  void _showLocalDetails(BuildContext context, LocalsRecord local) {
    showDialog(
      context: context,
      builder: (context) => LocalDetailsDialog(local: local),
    );
  }
}
```

## Key Fixes Implemented

### 1. Data Display Fix

```dart
// BEFORE: Data might not show if null
Text(local.address)  // Could throw error or show nothing

// AFTER: Safe data access with fallback
if (local.address.isNotEmpty) ...[
  _buildInfoRow(
    context,
    'Address',
    local.address,
    Icons.location_on_outlined,
    canTap: true,
    onTap: () => _launchMaps(local.address, local.city, local.state),
  ),
]
```

### 2. RichText Implementation

```dart
// Proper key-value display with RichText
RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: '$label: ',  // Key in lighter color
        style: AppTheme.labelMedium.copyWith(
          color: AppTheme.textLight,
        ),
      ),
      TextSpan(
        text: value,  // Value in darker color
        style: AppTheme.bodyMedium.copyWith(
          color: canTap ? AppTheme.accentCopper : AppTheme.textDark,
          decoration: canTap ? TextDecoration.underline : null,
        ),
      ),
    ],
  ),
)
```

### 3. Clickable Elements

```dart
// Phone launcher with number cleaning
Future<void> _launchPhone(String phone) async {
  final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
  final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);
  
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  }
}

// Platform-specific map launching
Future<void> _launchMaps(String address, String city, String state) async {
  final fullAddress = '$address, $city, $state';
  final encodedAddress = Uri.encodeComponent(fullAddress);
  
  Uri mapsUri;
  if (Platform.isIOS) {
    mapsUri = Uri.parse('maps://?q=$encodedAddress');
    if (!await canLaunchUrl(mapsUri)) {
      mapsUri = Uri.parse('https://maps.apple.com/?q=$encodedAddress');
    }
  } else {
    mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress'
    );
  }
  
  if (await canLaunchUrl(mapsUri)) {
    await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
  }
}
```

### 4. Visual Hierarchy

```dart
// Card header with proper styling
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local ${local.localUnion}',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            '${local.city}, ${local.state}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    ),
    // Visual indicator for more details
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        size: AppTheme.iconSm,
        color: AppTheme.accentCopper,
      ),
    ),
  ],
),
```

## Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.2.1
```

## Usage Instructions

1. **Import the screen** in your navigation:

```dart
import '/screens/jobs/locals_screen.dart';
```

2. **Add to navigation**:

```dart
// In your bottom navigation or drawer
ListTile(
  leading: Icon(Icons.location_city),
  title: Text('IBEW Locals'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocalsScreen(),
      ),
    );
  },
)
```

3. **Ensure Firestore security rules** allow read access:

```javascript
match /locals/{document=**} {
  allow read: if true;
}
```

## Testing Checklist

- [ ] All local cards display complete information
- [ ] Search filters work across all fields
- [ ] Phone numbers launch dialer
- [ ] Addresses open maps
- [ ] Websites open in browser
- [ ] Email addresses open mail client
- [ ] Dialog shows all additional information
- [ ] No "Active" status shown anywhere
- [ ] No member count displayed
- [ ] All text uses RichText format
- [ ] Proper error handling for missing data
- [ ] Responsive on different screen sizes
- [ ] Smooth scrolling performance

## Common Issues & Solutions

### Issue: Data not showing on cards

**Solution**: Check Firestore field names match schema exactly

### Issue: URLs not launching

**Solution**: Add url_launcher configuration to platform files

### Issue: Search not working

**Solution**: Ensure all fields being searched are strings

### Issue: Dialog overflow on small screens

**Solution**: SingleChildScrollView implemented with proper constraints
