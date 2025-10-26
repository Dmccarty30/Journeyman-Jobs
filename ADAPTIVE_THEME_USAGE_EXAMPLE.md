# Adaptive Theme Usage Example

## How to Use the Adaptive Theme in TailboardScreen

### 1. Import the adaptive theme

```dart
import '../../../design_system/adaptive_tailboard_theme.dart';
import '../../../design_system/adaptive_tailboard_components.dart';
```

### 2. Replace background decoration

**Before:**

```dart
TailboardComponents.circuitBackground(context, 
  child: Scaffold(
    backgroundColor: Colors.transparent,
    body: // content
  ),
)
```

**After:**

```dart
AdaptiveTailboardComponents.circuitBackground(context, 
  child: Scaffold(
    backgroundColor: Colors.transparent,
    body: // content
  ),
)
```

### 3. Replace header component

**Before:**

```dart
TailboardComponents.simplifiedHeader(context, 
  crewName: crew.name,
  memberCount: crew.memberIds.length,
  userRole: 'Journeyman',
)
```

**After:**

```dart
AdaptiveTailboardComponents.header(context, 
  crewName: crew.name,
  memberCount: crew.memberIds.length,
  userRole: 'Journeyman',
)
```

### 4. Replace job cards

**Before:**

```dart
TailboardComponents.jobCard(context, 
  company: job.company,
  location: job.location,
  wage: job.wage,
  status: job.status,
  onTap: () => _handleJobTap(job),
)
```

**After:**

```dart
AdaptiveTailboardComponents.jobCard(context, 
  company: job.company,
  location: job.location,
  wage: job.wage,
  status: job.status,
  onTap: () => _handleJobTap(job),
)
```

### 5. Replace tab bar

**Before:**

```dart
TailboardComponents.optimizedTabBar(context, 
  controller: _tabController,
  tabs: const ['Feed', 'Jobs', 'Chat', 'Members'],
  icons: const [
    Icons.feed_outlined,
    Icons.work_outline,
    Icons.chat_bubble_outline,
    Icons.group_outlined,
  ],
)
```

**After:**

```dart
AdaptiveTailboardComponents.tabBar(context, 
  controller: _tabController,
  tabs: const ['Feed', 'Jobs', 'Chat', 'Members'],
  icons: const [
    Icons.feed_outlined,
    Icons.work_outline,
    Icons.chat_bubble_outline,
    Icons.group_outlined,
  ],
)
```

### 6. Custom adaptive widgets

You can also create your own adaptive widgets using the theme:

```dart
Container(
  decoration: AdaptiveTailboardTheme.getCardDecoration(context),
  child: Text(
    'Adaptive Content',
    style: AdaptiveTailboardTheme.getHeadingStyle(context),
  ),
)

// Custom text field
Container(
  decoration: BoxDecoration(
    color: AdaptiveTailboardTheme.getSurface(context),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AdaptiveTailboardTheme.getBorder(context)),
  ),
  child: TextField(
    style: AdaptiveTailboardTheme.getBodyStyle(context),
    decoration: InputDecoration(
      hintText: 'Enter text...',
      hintStyle: AdaptiveTailboardTheme.getBodyStyle(context),
      border: InputBorder.none,
      contentPadding: EdgeInsets.all(16),
    ),
  ),
)
```

## Theme Characteristics

### Light Mode

- **Background**: Light gray (#F8FAFC) with subtle gradients
- **Surfaces**: White cards with light borders
- **Text**: Dark navy for primary, medium gray for secondary
- **Copper Accents**: Standard copper (#F59E0B)
- **Shadows**: Light shadows (10% opacity)
- **Circuit Patterns**: Subtle visibility

### Dark Mode

- **Background**: Deep navy (#0F1419) with graduated gradients
- **Surfaces**: Navy cards with darker borders
- **Text**: White for primary, gray for secondary
- **Copper Accents**: Brighter copper (#FCD34D) for visibility
- **Shadows**: Darker shadows (30% opacity)
- **Circuit Patterns**: More visible

## Benefits

1. **Automatic Detection**: No manual theme switching required
2. **System Integration**: Responds to system light/dark mode settings
3. **Professional Appearance**: Maintains electrical worker aesthetic
4. **Good Contrast**: Readable in both light and dark modes
5. **Moderate Gradients**: Visual depth without overwhelming effects
6. **Electrical Theme**: Copper accents and circuit patterns maintained
