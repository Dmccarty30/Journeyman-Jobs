# Frontend Design Specification

## Project Overview
Journeyman Jobs is an electrical-themed Flutter application designed for IBEW workers, including journeymen, linemen, wiremen, operators, and tree trimmers. The app features comprehensive crew management functionality with real-time messaging, user discovery, and team collaboration tools.

This design specification covers the crew feature UI/UX design system, ensuring consistent electrical theming, accessibility compliance, and exceptional user experience across all crew-related interfaces.

## Technology Stack
- **Framework**: Flutter 3.6.0+ with null safety
- **State Management**: Flutter Riverpod with code generation
- **Navigation**: go_router for type-safe routing
- **Styling**: Custom design system with shadcn_ui components
- **Backend**: Firebase (Authentication, Firestore, Cloud Storage)

## Design System Foundation

### Color Palette
```dart
// Primary Electrical Theme
static const Color primaryNavy = Color(0xFF1A202C);    // Deep navy blue
static const Color accentCopper = Color(0xFFB45309);   // Copper accent

// Secondary Colors
static const Color secondaryNavy = Color(0xFF2D3748);  // Lighter navy
static const Color secondaryCopper = Color(0xFFD69E2E); // Lighter copper

// Status Colors
static const Color successGreen = Color(0xFF38A169);   // Power indicator
static const Color warningYellow = Color(0xFFD69E2E);  // Caution indicator
static const Color errorRed = Color(0xFFE53E3E);       // Danger indicator
static const Color infoBlue = Color(0xFF3182CE);       // Information flow
```

### Typography Scale
```dart
// Display Styles (for headers and hero sections)
displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700)
displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600)
displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600)

// Body Text (optimized for readability)
bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)
bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400)
bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400)

// Button Text (optimized for touch targets)
buttonLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)
buttonMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)
buttonSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)
```

### Spacing System
```dart
static const double spacingXs = 4.0;   // Micro spacing
static const double spacingSm = 8.0;   // Small spacing
static const double spacingMd = 16.0;  // Medium spacing
static const double spacingLg = 24.0;  // Large spacing
static const double spacingXl = 32.0;  // Extra large spacing
```

### Border Radius System
```dart
static const double radiusXs = 4.0;    // Small elements
static const double radiusSm = 8.0;    // Cards, buttons
static const double radiusMd = 12.0;   // Input fields, dialogs
static const double radiusLg = 16.0;   // Large cards
static const double radiusRound = 50.0; // Avatars, circular elements
```

## Component Architecture

### CrewCard Component

**Purpose**: Display crew information in lists and grids with electrical theme integration

**Props Interface**:
```dart
class CrewCard {
  final Crew crew;                    // Crew data model
  final VoidCallback? onTap;          // Navigation callback
  final VoidCallback? onLongPress;    // Context menu callback
  final bool showMemberAvatars;       // Display member thumbnails
  final bool showOnlineStatus;        // Show activity indicator
  final bool isSelected;              // Selection state for multi-select
  final CardVariant variant;          // Card style variant
}
```

**Visual Specifications**:

- [x] Base card with navy background and copper border (1.5px)
- [x] Crew logo/initial avatar with electrical gradient background
- [x] Crew name with bold white typography (titleLarge)
- [x] Member count with electrical bolt icon
- [x] Online status indicator with green glow effect
- [x] Last activity timestamp (relative time format)
- [x] Electrical circuit pattern background (subtle, 10% opacity)
- [x] Hover state with copper glow effect
- [x] Pressed state with scale animation (0.98x)
- [x] Selection state with copper outline and check badge

**Implementation Example**:

```dart
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: AppTheme.primaryNavy,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      border: Border.all(
        color: isSelected ? AppTheme.accentCopper : AppTheme.borderCopper,
        width: isSelected ? AppTheme.borderWidthThick : AppTheme.borderWidthMedium,
      ),
      boxShadow: isSelected ? [AppTheme.shadowElectricalSuccess] : AppTheme.shadowCard,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            // Circuit pattern background
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: CircuitPatternPainter(density: ComponentDensity.medium),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                  _buildCrewAvatar(),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(child: _buildCrewInfo()),
                  _buildStatusIndicator(),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppTheme.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
```

**Accessibility Requirements**:

- [x] Semantic labeling for screen readers
- [x] 48x48px minimum touch targets
- [x] High contrast text (≥4.5:1 ratio)
- [x] Focus indicators with copper outline
- [x] Support for TalkBack and VoiceOver
- [x] Reduced motion support for accessibility preferences

### UserSearchDialog Component

**Purpose**: Search and discover users for crew invitations with real-time filtering

**Props Interface**:
```dart
class UserSearchDialog {
  final String crewId;              // Current crew context
  final Function(UsersRecord) onUserSelected;  // Selection callback
  final String? title;              // Custom dialog title
  final int maxResults;             // Maximum search results
  final List<String> excludeUserIds; // Users to exclude from results
}
```

**Visual Specifications**:

- [x] Full-screen modal dialog on mobile, 80% height on tablet
- [x] Navy background with copper gradient header
- [x] Real-time search with debouncing (300ms delay)
- [x] Search field with copper focus state and icon
- [x] Suggested users section with lightbulb indicator
- [x] User cards with avatar, name, local, and certifications
- [x] Electrical skeleton loaders during search
- [x] Empty states with contextual messaging
- [x] Error states with retry functionality

**Implementation Example**:

```dart
Widget _buildSearchField() {
  return Container(
    padding: const EdgeInsets.all(AppTheme.spacingMd),
    child: TextField(
      controller: _searchController,
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
      decoration: InputDecoration(
        hintText: 'Search by name, email, or IBEW local...',
        hintStyle: AppTheme.bodyMedium.copyWith(
          color: AppTheme.white.withValues(alpha: 0.6),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppTheme.accentCopper,
        ),
        filled: true,
        fillColor: AppTheme.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: AppTheme.accentCopper.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(
            color: AppTheme.accentCopper,
            width: AppTheme.borderWidthThick,
          ),
        ),
      ),
    ),
  );
}
```

### CrewMessageBubble Component

**Purpose**: Display chat messages with electrical theming and interaction support

**Props Interface**:
```dart
class CrewMessageBubble {
  final CrewMessage message;         // Message data
  final bool isFromCurrentUser;     // Message origin
  final VoidCallback? onTap;        // Tap callback
  final VoidCallback? onLongPress;  // Context menu callback
  final Function(String)? onReactionTap; // Reaction callback
  final MessageVariant variant;     // Message style variant
}
```

**Visual Specifications**:

- [x] Different styling for sent vs received messages
- [x] Copper gradient for sent messages (right-aligned)
- [x] Navy background for received messages (left-aligned)
- [x] Electrical message status indicators (sent, delivered, read)
- [x] Timestamp display with relative formatting
- [x] Reaction bar with emoji support
- [x] Reply threading visual hierarchy
- [x] Message type indicators (text, image, file, location)

**Implementation Example**:

```dart
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: isFromCurrentUser
        ? MainAxisAlignment.end
        : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: isFromCurrentUser
              ? AppTheme.electricalGradient
              : LinearGradient(colors: [AppTheme.secondaryNavy]),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppTheme.radiusLg),
              topRight: const Radius.circular(AppTheme.radiusLg),
              bottomLeft: Radius.circular(
                isFromCurrentUser ? AppTheme.radiusLg : AppTheme.radiusSm,
              ),
              bottomRight: Radius.circular(
                isFromCurrentUser ? AppTheme.radiusSm : AppTheme.radiusLg,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply indicator
              if (message.replyToMessageId != null) _buildReplyIndicator(),

              // Message content
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: _buildMessageContent(),
              ),

              // Message footer
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingSm,
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                ),
                child: _buildMessageFooter(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

### CrewInvitationCard Component

**Purpose**: Display crew invitation requests with electrical theming

**Props Interface**:
```dart
class CrewInvitationCard {
  final CrewInvitation invitation;   // Invitation data
  final VoidCallback? onAccept;     // Accept callback
  final VoidCallback? onDecline;    // Decline callback
  final VoidCallback? onViewProfile; // Profile view callback
  final InvitationStatus status;    // Current invitation status
}
```

**Visual Specifications**:

- [x] Card with navy background and copper accent border
- [x] Inviter avatar with electrical badge
- [x] Crew name and member count
- [x] Invitation message with character limit
- [x] Action buttons with electrical styling
- [x] Status indicators (pending, accepted, declined)
- [x] Timestamp with relative formatting
- [x] Electrical glow effects for new invitations

## Layout Patterns

### Crew List Layout
```dart
// Main crew list with electrical theme
class CrewListView extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.offWhite,
            AppTheme.offWhite.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          // Electrical header
          SliverAppBar(
            backgroundColor: AppTheme.primaryNavy,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Circuit pattern background
                  CustomPaint(
                    painter: CircuitPatternPainter(
                      density: ComponentDensity.high,
                      opacity: 0.1,
                    ),
                  ),
                  // Header content
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Crews',
                            style: AppTheme.displayLarge.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            'Connect with your electrical team',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Crew list
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => CrewCard(crew: crews[index]),
                childCount: crews.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Crew Chat Layout
```dart
// Chat interface with electrical theming
class CrewChatLayout extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Row(
          children: [
            // Crew avatar
            CircleAvatar(
              backgroundColor: AppTheme.accentCopper,
              child: Text(
                crew.name[0].toUpperCase(),
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // Crew info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crew.name,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                  Text(
                    '${crew.memberCount} members',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group, color: AppTheme.white),
            onPressed: () => _showCrewMembers(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.offWhite,
                    AppTheme.offWhite.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: MessagesList(crewId: crew.id),
            ),
          ),

          // Message input
          MessageInputField(
            crewId: crew.id,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}
```

## Interaction Patterns

### Navigation Patterns
- **Bottom Navigation**: 4-tab navigation with electrical icons
- **Hierarchical Navigation**: Deep linking support for crew screens
- **Modal Dialogs**: Full-screen on mobile, floating on tablet
- **Gesture Navigation**: Swipe-to-reply, pull-to-refresh, long-press menus

### Button Interactions
```dart
// Primary electrical button with theme integration
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.accentCopper,
    foregroundColor: AppTheme.white,
    padding: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingLg,
      vertical: AppTheme.spacingMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    ),
    elevation: 2,
    shadowColor: AppTheme.electricalGlowInfo.withValues(alpha: 0.3),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Electrical icon
      Icon(
        Icons.bolt,
        size: AppTheme.iconSm,
        color: AppTheme.white,
      ),
      const SizedBox(width: AppTheme.spacingSm),
      Text(
        label,
        style: AppTheme.buttonMedium.copyWith(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
)
```

### Search Interactions
- **Real-time Search**: 300ms debouncing for performance
- **Progressive Loading**: Skeleton states during search
- **Search Suggestions**: Intelligent user recommendations
- **Empty States**: Contextual guidance for search actions
- **Error Recovery**: Retry mechanisms with clear messaging

### Chat Interactions
- **Message Composition**: Multi-line input with character limit
- **Message Types**: Text, images, files, location sharing
- **Reply Threading**: Visual hierarchy for message replies
- **Reaction System**: Emoji reactions with electrical animations
- **Message Status**: Sent, delivered, read indicators

## Implementation Roadmap

### Phase 1: Foundation Components
1. [ ] Set up electrical theme tokens and constants
2. [ ] Create base crew card component with electrical styling
3. [ ] Implement user search dialog with real-time filtering
4. [ ] Build message bubble component with variant support
5. [ ] Create invitation card component with action buttons

### Phase 2: Layout and Navigation
1. [ ] Implement crew list screen with electrical header
2. [ ] Create crew chat screen with message input
3. [ ] Build crew invitation management interface
4. [ ] Add crew member management screens
5. [ ] Implement crew settings and preferences

### Phase 3: Interactions and Animations
1. [ ] Add electrical animations and transitions
2. [ ] Implement gesture-based interactions
3. [ ] Create loading states with electrical theming
4. [ ] Add micro-interactions for user feedback
5. [ ] Implement error handling with recovery patterns

### Phase 4: Accessibility and Performance
1. [ ] Add semantic labels and screen reader support
2. [ ] Implement focus management and keyboard navigation
3. [ ] Optimize for performance with lazy loading
4. [ ] Add reduced motion support
5. [ ] Implement accessibility testing suite

### Phase 5: Polish and Refinement
1. [ ] Comprehensive testing across device sizes
2. [ ] Performance optimization and memory management
3. [ ] User testing and feedback integration
4. [ ] Final visual polish and animation refinement
5. [ ] Documentation and design system handoff

## Accessibility Requirements

### Visual Accessibility
- **Color Contrast**: Minimum 4.5:1 ratio for normal text, 3:1 for large text
- **Touch Targets**: Minimum 48x48px for all interactive elements
- **Spacing**: Adequate spacing between interactive elements
- **Typography**: Scalable fonts supporting system preferences

### Screen Reader Support
- **Semantic Labels**: Proper labeling for all UI elements
- **Navigation**: Logical reading order and focus management
- **States**: Announcing dynamic content changes
- **Context**: Providing context for interactive elements

### Motor Accessibility
- **Gesture Alternatives**: Button alternatives for swipe gestures
- **Focus Management**: Visible focus indicators and logical tab order
- **Error Recovery**: Clear error messages and recovery paths
- **Timing**: Adjustable or dismissible time-based content

## Responsive Design

### Mobile Layout (320-768px)
- **Single Column**: Full-width cards and lists
- **Bottom Navigation**: Primary navigation pattern
- **Modal Dialogs**: Full-screen overlay presentation
- **Touch Optimized**: Large touch targets and spacing

### Tablet Layout (768-1024px)
- **Two Column**: Master-detail layout for crew management
- **Floating Dialogs**: Modal presentation with proper sizing
- **Keyboard Support**: Enhanced input methods and shortcuts
- **Multi-window**: Split-screen compatibility

### Desktop Layout (1024px+)
- **Three Column**: Expanded layout with persistent navigation
- **Hover States**: Mouse-specific interactions and tooltips
- **Keyboard Navigation**: Full keyboard accessibility
- **Window Management**: Resizable panels and flexible layouts

## Performance Considerations

### Rendering Performance
- **60 FPS Target**: Smooth animations and transitions
- **Lazy Loading**: Progressive content loading for large lists
- **Image Optimization**: WebP format with proper sizing
- **Memory Management**: Proper widget disposal and state management

### Network Optimization
- **Caching Strategy**: Intelligent data caching and invalidation
- **Request Optimization**: Batch operations and efficient queries
- **Offline Support**: Core functionality without network connectivity
- **Data Compression**: Efficient data transfer and storage

### Battery Optimization
- **Background Tasks**: Minimal background processing
- **Location Services**: Efficient location tracking with proper timeouts
- **Push Notifications**: Optimized notification delivery
- **Animation Performance**: Hardware-accelerated animations

This design specification provides a comprehensive foundation for implementing exceptional crew features with consistent electrical theming, accessibility compliance, and outstanding user experience. The component architecture ensures maintainability and scalability while preserving the unique electrical identity of the Journeyman Jobs application.