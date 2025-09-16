# CRITICAL MEMORY LEAK FIXES - P1 Priority

**Impact**: IBEW electrical workers experiencing battery drain during 12+ hour shifts

## Files Identified for Memory Leak Analysis

Based on git status and project structure, these StatefulWidget files need investigation:

### High Priority - Emergency/Storm Screens

1. **lib/widgets/storm/roster_signup_carousel.dart** - Storm roster functionality
2. **lib/widgets/storm/contractor_card.dart** - Storm contractor displays
3. **lib/widgets/rich_text_job_card.dart** - Job card displays

### High Priority - Communication Screens

4. **lib/features/crews/screens/crew_communication_screen.dart** - Real-time messaging
5. **lib/features/crews/screens/crew_detail_screen.dart** - Crew management
6. **lib/features/job_sharing/screens/quick_signup_screen.dart** - Viral signup flow

### Medium Priority - Core Navigation

7. **lib/screens/nav_bar_page.dart** (and backup) - Main navigation
8. **lib/features/crews/widgets/crew_member_card.dart** - Member displays

### Contact/Communication Widgets

9. **lib/features/job_sharing/widgets/contact_picker.dart** - Contact selection
10. **lib/features/job_sharing/widgets/riverpod_contact_picker.dart** - Riverpod contact picker

## Common Memory Leak Patterns to Check For

### Controllers That Need Disposal

- `TextEditingController` - Text input fields
- `ScrollController` - Scrollable lists/pages
- `PageController` - Page view navigation
- `AnimationController` - Animations
- `TabController` - Tab navigation

### Stream Subscriptions to Cancel

- Firebase listeners
- Provider change notifications
- Timer subscriptions
- Location services
- Network connectivity

### Missing dispose() Patterns

```dart
@override
void dispose() {
  _textController?.dispose();
  _scrollController?.dispose();
  _pageController?.dispose();
  _animationController?.dispose();
  _streamSubscription?.cancel();
  _timer?.cancel();
  super.dispose();
}
```

## Investigation Results

*To be filled during analysis*

## Fixes Applied

*To be documented as fixes are implemented*

---
**Target**: 70-90% reduction in memory growth during extended usage
**Timeline**: Critical fix for field workers
