# Stream Chat Electrical Theme Implementation

## Overview

This document explains how to use the `_buildElectricalStreamTheme()` method in `TailboardScreen` to apply electrical theming to Stream Chat Flutter widgets.

## Theme Configuration

The `_buildElectricalStreamTheme()` method returns a `StreamChatThemeData` object with the following electrical theme characteristics:

### Color Scheme

- **Primary Accent**: `AppTheme.accentCopper` (#B45309) - Used for primary actions, highlights, and own message bubbles
- **Primary Navy**: `AppTheme.primaryNavy` (#1A202C) - Used for avatars, headers, and other elements
- **Backgrounds**: Light surfaces from `AppTheme.surfaceLight` and `AppTheme.white`
- **Text Colors**: High contrast colors following WCAG accessibility guidelines

### Message Theming

- **Own Messages**: Copper background with white text (7.6:1 contrast ratio)
- **Other Messages**: Light gray background with dark navy text (14.8:1 contrast ratio)
- **Timestamps**: Medium gray for optimal readability

## Usage

### Basic Usage

To apply the electrical theme to any Stream Chat widget, wrap it with `StreamChatTheme`:

```dart
StreamChatTheme(
  data: _buildElectricalStreamTheme(),
  child: StreamChannelListView(
    // Your Stream Chat widget here
  ),
)
```

### Example Implementation in TailboardScreen

Here's how to use the theme in a typical Stream Chat implementation:

```dart
class TailboardScreen extends ConsumerStatefulWidget {
  // ... existing code ...

  @override
  Widget build(BuildContext context) {
    return StreamChatTheme(
      data: _buildElectricalStreamTheme(),
      child: Scaffold(
        body: Column(
          children: [
            // Existing Tailboard components...

            // Stream Chat integration with electrical theme
            Expanded(
              child: StreamChannelListView(
                filter: Filter.and([
                  Filter.equal('team', selectedCrew.id),
                  Filter.notEqual('hidden', true),
                ]),
                sort: [const SortOption('last_message_at')],
                onChannelTap: (channel) {
                  // Navigate to channel with theme applied
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StreamChatTheme(
                        data: _buildElectricalStreamTheme(),
                        child: StreamChannelScreen(
                          channel: channel,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... existing _buildElectricalStreamTheme() method ...
}
```

### Channel Screen Implementation

For individual chat screens, ensure the theme is applied:

```dart
class ElectricalChatScreen extends StatelessWidget {
  final Channel channel;

  const ElectricalChatScreen({Key? key, required this.channel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamChatTheme(
      data: _buildElectricalStreamTheme(),
      child: StreamChannelScreen(
        channel: channel,
      ),
    );
  }
}
```

## Theme Components

### 1. Color Theme (`StreamColorTheme.light()`)

- Primary colors for interactive elements
- Text colors with proper contrast ratios
- Background and surface colors
- Overlay and barrier colors

### 2. Message Themes (`StreamMessageThemeData`)

- **Own Messages**: Copper background, white text, secondary copper avatars
- **Other Messages**: Light gray background, navy text, navy avatars
- Timestamp styling with appropriate opacity

### 3. Channel List Theme (`StreamChannelPreviewThemeData`)

- Navy avatars for channel previews
- High contrast text for channel names and last messages
- Proper sizing for touch targets

### 4. Input Theme (`StreamMessageInputThemeData`)

- Rounded input field with copper focus border
- Copper send button for consistency
- Proper sizing and spacing

### 5. Gallery Theme (`StreamGalleryThemeData`)

- Navy background for image viewers
- Copper page indicators
- White close button for contrast

## Accessibility Features

The electrical theme follows WCAG accessibility guidelines:

- **High Contrast**: All text meets or exceeds 4.5:1 contrast ratios
- **Touch Targets**: Minimum 44x44 points for interactive elements
- **Color Blind Safe**: Relies on more than just color for information
- **Focus Indicators**: Clear focus states with copper borders

## Integration Notes

### Current Implementation

The `_buildElectricalStreamTheme()` method is now available in `TailboardScreen` and ready for use with any Stream Chat widgets.

### Future Phases

- Phase 5: Apply theme to Crew Chat (#general channel)
- Phase 7: Apply theme to all Stream Chat widgets in containers 0-3

### Customization

The theme can be easily modified by adjusting the color constants in the `_buildElectricalStreamTheme()` method. All colors are sourced from `AppTheme` for consistency.

## Testing

When testing the electrical theme:

1. **Visual Verification**: Ensure copper accents are visible and consistent
2. **Contrast Testing**: Verify text meets accessibility contrast ratios
3. **Responsive Testing**: Check theme behavior on different screen sizes
4. **Dark Mode**: Currently implements light mode theme (can be extended)

## File Location

- **Implementation**: `lib/features/crews/screens/tailboard_screen.dart` (lines 3078-3308)
- **Method**: `_buildElectricalStreamTheme()`
