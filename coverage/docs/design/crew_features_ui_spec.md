# Crew Features UI Design Specification

## 🎨 Design Overview

This document outlines the comprehensive UI/UX design for crew-related features in Journeyman Jobs, focusing on user discovery, crew management, and permission-based interfaces while maintaining the established electrical theme.

## 🧭 Design Philosophy

**Core Principles:**
- **Electrical Consistency**: All components maintain the Navy (#1A202C) and Copper (#B45309) color scheme
- **Accessibility First**: WCAG 2.1 AA compliance minimum with high contrast ratios
- **Mobile-First Design**: Responsive layouts optimized for phone screens first
- **Electrical Motifs**: Circuit patterns, lightning animations, and industrial aesthetics
- **Intuitive Workflows**: Streamlined user journeys with clear CTAs and feedback

## 📱 Layout Architecture

### Responsive Breakpoints
```yaml
breakpoints:
  mobile: "320px - 768px"     # Primary focus
  tablet: "768px - 1024px"    # Secondary adaptation
  desktop: "1024px+"          # Enhanced layouts
```

### Container Standards
```yaml
container:
  mobile_padding: "16px"
  tablet_padding: "24px"
  desktop_padding: "32px"
  max_content_width: "1200px"
```

## 👥 User Search Interface

### UserSearchDialog Specifications

**Dimensions & Layout:**
- Width: 90% of screen width (mobile), 600px max (tablet+)
- Height: 80% of screen height with scrollable content
- Border radius: 16px with copper accent border
- Background: Navy with electrical circuit pattern overlay

**Header Section:**
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppTheme.primaryNavy, AppTheme.primaryNavy.withOpacity(0.8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
  ),
  child: Row(
    children: [
      Icon(Icons.group_add, color: AppTheme.accentCopper, size: 24),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          'Invite Crew Members',
          style: AppTheme.headingLarge.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.close, color: AppTheme.accentCopper),
      ),
    ],
  ),
)
```

**Search Field Design:**
```dart
TextField(
  style: AppTheme.bodyText.copyWith(color: Colors.white),
  decoration: InputDecoration(
    hintText: 'Search by name, email, or IBEW local...',
    hintStyle: AppTheme.bodyText.copyWith(
      color: Colors.white.withOpacity(0.6),
    ),
    prefixIcon: Icon(Icons.search, color: AppTheme.accentCopper),
    suffixIcon: _searchController.text.isNotEmpty
        ? IconButton(
            onPressed: () {
              _searchController.clear();
              _clearSearchResults();
            },
            icon: Icon(Icons.clear, color: AppTheme.accentCopper),
          )
        : null,
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppTheme.accentCopper.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
    ),
  ),
)
```

### UserResultCard Component

**Card Structure:**
```dart
Container(
  margin: EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isSuggested
          ? AppTheme.accentCopper.withOpacity(0.3)
          : Colors.white.withOpacity(0.1),
    ),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAvatar(),
            SizedBox(width: 16),
            Expanded(child: _buildUserInfo()),
            _buildActionIndicator(),
          ],
        ),
      ),
    ),
  ),
)
```

**Avatar with Electrical Theme:**
```dart
Container(
  width: 48,
  height: 48,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppTheme.accentCopper, AppTheme.accentCopper.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 2,
    ),
  ),
  child: Stack(
    children: [
      Center(
        child: Text(
          user.displayName.isNotEmpty
              ? user.displayName[0].toUpperCase()
              : 'U',
          style: AppTheme.headingLarge.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      if (isSuggested)
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.accentCopper,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryNavy, width: 2),
            ),
            child: Icon(Icons.lightbulb, color: Colors.white, size: 12),
          ),
        ),
    ],
  ),
)
```

## 🔐 Permission-Based UI Components

### PermissionIndicatorWidget

**Purpose**: Visual indicators for user permissions within crew management

```dart
class PermissionIndicatorWidget extends StatelessWidget {
  final MemberPermissions permissions;
  final MemberRole role;

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentCopper.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: AppTheme.accentCopper, size: 20),
              SizedBox(width: 8),
              Text(
                '${role.name.capitalize()} Permissions',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ..._buildPermissionItems(),
        ],
      ),
    );
  }

  List<Widget> _buildPermissionItems() {
    final permissions = [
      {'name': 'Invite Members', 'value': permissions.canInviteMembers},
      {'name': 'Remove Members', 'value': permissions.canRemoveMembers},
      {'name': 'Share Jobs', 'value': permissions.canShareJobs},
      {'name': 'Post Announcements', 'value': permissions.canPostAnnouncements},
      {'name': 'Edit Crew Info', 'value': permissions.canEditCrewInfo},
      {'name': 'View Analytics', 'value': permissions.canViewAnalytics},
    ];

    return permissions.map((perm) => _buildPermissionItem(
      perm['name'] as String,
      perm['value'] as bool,
    )).toList();
  }

  Widget _buildPermissionItem(String name, bool hasPermission) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: hasPermission ? AppTheme.successGreen : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasPermission ? Icons.check : Icons.close,
              color: Colors.white,
              size: 14,
            ),
          ),
          SizedBox(width: 12),
          Text(
            name,
            style: AppTheme.bodyMedium.copyWith(
              color: hasPermission ? AppTheme.textPrimary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
```

### CrewRoleSelector

**Purpose**: Interactive role selection interface for crew management

```dart
class CrewRoleSelector extends StatefulWidget {
  final MemberRole currentRole;
  final Function(MemberRole) onRoleChanged;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    if (!canEdit) {
      return _buildRoleDisplay();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentCopper, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Crew Role',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...MemberRole.values.map((role) => _buildRoleOption(role)),
        ],
      ),
    );
  }

  Widget _buildRoleOption(MemberRole role) {
    final isSelected = currentRole == role;
    final roleInfo = _getRoleInfo(role);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onRoleChanged(role),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentCopper.withOpacity(0.1) : Colors.transparent,
            border: Border(
              top: BorderSide(color: AppTheme.lightGray),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentCopper : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.accentCopper : AppTheme.mediumGray,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleInfo['title'] as String,
                      style: AppTheme.titleSmall.copyWith(
                        color: isSelected ? AppTheme.accentCopper : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      roleInfo['description'] as String,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                roleInfo['icon'] as IconData,
                color: isSelected ? AppTheme.accentCopper : AppTheme.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getRoleInfo(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return {
          'title': 'Administrator',
          'description': 'Full control over crew and members',
          'icon': Icons.admin_panel_settings,
        };
      case MemberRole.foreman:
        return {
          'title': 'Foreman',
          'description': 'Manage crew operations and members',
          'icon': Icons.engineering,
        };
      case MemberRole.lead:
        return {
          'title': 'Lead Hand',
          'description': 'Coordinate work and share jobs',
          'icon': Icons.people,
        };
      case MemberRole.member:
        return {
          'title': 'Member',
          'description': 'Participate in crew activities',
          'icon': Icons.person,
        };
    }
  }
}
```

## 📊 Crew Management Interface

### CrewDashboardScreen

**Layout Structure:**
```dart
Scaffold(
  backgroundColor: AppTheme.primaryNavy,
  body: CustomScrollView(
    slivers: [
      SliverAppBar(
        expandedHeight: 200,
        floating: false,
        pinned: true,
        backgroundColor: AppTheme.primaryNavy,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            crew.name,
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          background: Stack(
            fit: StackFit.expand,
            children: [
              CircuitPatternBackground(opacity: 0.1),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryNavy,
                      AppTheme.primaryNavy.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showInviteDialog(),
            icon: Icon(Icons.group_add, color: AppTheme.accentCopper),
          ),
          IconButton(
            onPressed: () => _showCrewSettings(),
            icon: Icon(Icons.settings, color: AppTheme.accentCopper),
          ),
        ],
      ),
      SliverToBoxAdapter(
        child: _buildCrewStatsCard(),
      ),
      SliverToBoxAdapter(
        child: _buildActionButtons(),
      ),
      SliverFillRemaining(
        child: _buildMembersList(),
      ),
    ],
  ),
)
```

### CrewStatsCard

**Visual Statistics Display:**
```dart
Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: AppTheme.cardGradient,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppTheme.accentCopper, width: 1.5),
    boxShadow: [AppTheme.shadowMd],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Crew Overview',
        style: AppTheme.headlineSmall.copyWith(
          color: AppTheme.primaryNavy,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Members',
              '${crew.memberCount}',
              Icons.people,
              AppTheme.accentCopper,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Active Jobs',
              '${crew.stats.activeJobs}',
              Icons.work,
              AppTheme.successGreen,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Completed',
              '${crew.stats.completedJobs}',
              Icons.check_circle,
              AppTheme.infoBlue,
            ),
          ),
        ],
      ),
    ],
  ),
)

Widget _buildStatItem(String label, String value, IconData icon, Color color) {
  return Column(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      SizedBox(height: 8),
      Text(
        value,
        style: AppTheme.headlineMedium.copyWith(
          color: AppTheme.primaryNavy,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
    ],
  );
}
```

## 🎯 Loading States & Error Handling

### Electrical Loading States

**JJElectricalLoader Integration:**
```dart
// Full screen loading
JJElectricalLoader(
  width: 200,
  height: 60,
  message: 'Discovering users...',
)

// Inline loading
JJPowerLineLoader(
  width: 300,
  height: 80,
  message: 'Sending invitations...',
)

// Skeleton loading
JJSkeletonLoader(
  width: double.infinity,
  height: 80,
  borderRadius: 12,
  showCircuitPattern: true,
)
```

### Error State Design

**Consistent Error Feedback:**
```dart
Container(
  padding: EdgeInsets.all(20),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ElectricalIllustrationWidget(
        illustration: ElectricalIllustration.powerOutage,
        width: 120,
        height: 120,
        animate: true,
      ),
      SizedBox(height: 16),
      Text(
        'Connection Lost',
        style: AppTheme.headlineMedium.copyWith(
          color: Colors.white,
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Unable to connect to the network. Please check your connection.',
        style: AppTheme.bodyMedium.copyWith(
          color: Colors.white.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 20),
      JJButton(
        text: 'Try Again',
        icon: Icons.refresh,
        onPressed: _retryOperation,
        variant: JJButtonVariant.primary,
      ),
    ],
  ),
)
```

## 📱 Responsive Behavior

### Mobile Adaptations
- **Touch Targets**: Minimum 44px tap areas
- **Thumb Zones**: Important actions placed in bottom 75% of screen
- **Single Hand Use**: Critical functions accessible within thumb reach
- **Gesture Support**: Swipe-to-refresh, pull-to-refresh

### Tablet Enhancements
- **Multi-Column Layouts**: Side-by-side user lists and details
- **Hover States**: Desktop-like interactions with touch support
- **Larger Targets**: Expanded touch areas for better usability

## 🎨 Animation Specifications

### Micro-interactions
```dart
// Button press animation
scale: 0.95 → 1.0 (100ms easeOut)

// Card hover/lift animation
elevation: 2 → 8 (200ms easeInOut)
scale: 1.0 → 1.02 (200ms easeInOut)

// Lightning pulse effect
opacity: 0.3 → 0.8 → 0.3 (1500ms infinite easeInOut)

// Circuit pattern animation
strokeDashOffset: 0 → 100 (2000ms linear infinite)
```

### Page Transitions
```dart
// Slide transition
offset: Offset(1.0, 0) → Offset(0, 0) (300ms easeOutCubic)

// Fade transition
opacity: 0.0 → 1.0 (250ms easeInOut)

// Scale transition
scale: 0.8 → 1.0 (200ms easeOutBack)
```

## ♿ Accessibility Compliance

### Contrast Ratios
- **Text on Background**: Minimum 4.5:1 (AA), 7:1 preferred (AAA)
- **Interactive Elements**: Minimum 3:1
- **Large Text**: Minimum 3:1

### Screen Reader Support
- **Semantic Labels**: All interactive elements properly labeled
- **Live Regions**: Dynamic content announcements
- **Focus Management**: Logical tab order and focus indicators

### Keyboard Navigation
- **Tab Order**: Logical navigation through all interactive elements
- **Skip Links**: Quick navigation to main content
- **Keyboard Shortcuts**: Common actions accessible via keyboard

## 🔧 Component Library Integration

### Recommended Components
- **Buttons**: Use `JJButton` for all primary actions
- **Text Fields**: Use `JJTextField` for form inputs
- **Cards**: Use `JJCard` for content containers
- **Loaders**: Use `JJElectricalLoader` for full-screen loading
- **Toasts**: Use `JJElectricalToast` for notifications

### Electrical Theme Elements
- **Circuit Patterns**: Background patterns for visual interest
- **Lightning Effects**: Accent animations for emphasis
- **Electrical Icons**: Industry-specific iconography
- **Color Scheme**: Navy (#1A202C) and Copper (#B45309) throughout

## 📐 Spacing & Typography

### Spacing Scale
```yaml
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
  xxxl: 64px
```

### Typography Hierarchy
```yaml
typography:
  display_large: 32px / 700 weight
  headline_large: 22px / 600 weight
  title_medium: 14px / 600 weight
  body_medium: 14px / 400 weight
  label_medium: 12px / 500 weight
```

## 🚀 Implementation Guidelines

### Code Structure
```dart
// File organization
lib/
├── features/
│   └── crews/
│       ├── screens/
│       │   ├── crew_dashboard_screen.dart
│       │   ├── user_search_dialog.dart
│       │   └── crew_settings_screen.dart
│       ├── widgets/
│       │   ├── user_result_card.dart
│       │   ├── permission_indicator.dart
│       │   └── crew_stats_card.dart
│       └── models/
│           ├── crew.dart
│           └── crew_member.dart
```

### Performance Considerations
- **Lazy Loading**: User lists load incrementally
- **Image Caching**: Profile images cached for performance
- **Debounced Search**: Search requests debounced to reduce API calls
- **Memory Management**: Proper disposal of controllers and listeners

### Testing Requirements
- **Widget Tests**: All components have corresponding widget tests
- **Integration Tests**: User flows tested end-to-end
- **Accessibility Tests**: Screen reader compatibility verified
- **Performance Tests**: Loading times and memory usage monitored

## 📚 Documentation & Maintenance

### Component Documentation
- **Usage Examples**: Clear examples for each component
- **Props Documentation**: All props documented with types and descriptions
- **Theme Integration**: Instructions for customizing appearance
- **Accessibility Notes**: A11y considerations and requirements

### Update Guidelines
- **Breaking Changes**: Documented with migration guides
- **Deprecation Notices**: Clear timeline for component updates
- **Version Compatibility**: Flutter version requirements specified
- **Testing Coverage**: Maintain >80% test coverage

---

This UI specification provides a comprehensive foundation for implementing crew-related features with consistent electrical theming, accessibility compliance, and responsive design. All components should be implemented following these guidelines to ensure a cohesive and professional user experience.