# Electrical Components Library

A comprehensive collection of electrical-themed Flutter components designed for industrial, electrical, and engineering applications.

## Components Overview

### 🔄 Loading Components (Use These)

#### JJElectricalLoader ⭐ Recommended

Primary full-screen loader with 3-phase sine wave animation.

- **Purpose**: General loading states, full-screen loading, feature initialization
- **Features**: Three sine waves with 120° phase difference, AppTheme styling, optional message
- **Customization**: Width, height, message text
- **Location**: `design_system/components/reusable_components.dart`

#### JJPowerLineLoader ⭐ Recommended

Power line transmission animation loader.

- **Purpose**: Inline loading, contextual loading indicators
- **Features**: Transmission towers, animated energy pulses, AppTheme styling
- **Customization**: Width, height, message text
- **Location**: `design_system/components/reusable_components.dart`

#### JJSkeletonLoader

Content placeholder shimmer loader.

- **Purpose**: Content skeleton screens, list placeholders, image loading
- **Features**: Shimmer gradient animation, optional circuit pattern overlay
- **Customization**: Width, height, border radius, show circuit pattern
- **Location**: `widgets/jj_skeleton_loader.dart`

#### ElectricalRotationMeter

Gauge-style loading indicator resembling electrical meters.

- **Purpose**: Professional loading indicator for industrial applications
- **Features**: Analog meter with needle animation, tick marks, optional label
- **Customization**: Size, colors, label text, animation duration

### 🔧 Base Components (Internal Use - Do Not Use Directly)

> **Note**: These components are maintained for internal use by the wrapper components above. Use `JJElectricalLoader` or `JJPowerLineLoader` instead.

- **ThreePhaseSineWaveLoader**: Base component for JJElectricalLoader
- **PowerLineLoader**: Base component for JJPowerLineLoader

### 🔧 Interactive Components

#### CircuitBreakerToggle

Interactive switch styled as an electrical circuit breaker.

- **Purpose**: Professional-looking toggle switch for electrical contexts
- **Features**: Smooth animation, electrical symbols (| for ON, O for OFF)
- **Customization**: Colors, size, state management

### 🏗️ Static Icons

#### HardHatIcon

Safety-themed icon representing protective equipment.

- **Purpose**: Safety indicators for electrical/construction contexts
- **Features**: Realistic hard hat design with safety stripe
- **Customization**: Size, colors

#### TransmissionTowerIcon

Electrical infrastructure icon.

- **Purpose**: Represent electrical transmission infrastructure
- **Features**: Detailed tower structure with power lines and warning signs
- **Customization**: Size, color

## Color Scheme

All components use a consistent electrical industry color palette:

- **Primary Navy**: `#1A202C` - Structural elements
- **Accent Copper**: `#B45309` - Active/energized elements
- **Success Green**: `#38A169` - ON states
- **Info Blue**: `#3182CE` - Secondary phases
- **Gray tones**: Various shades for inactive/background elements

## Usage Examples

```dart
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/widgets/jj_skeleton_loader.dart';

// ⭐ JJElectricalLoader (Recommended for full-screen loading)
JJElectricalLoader(
  width: 200,
  height: 60,
  message: 'Loading...',
)

// ⭐ JJPowerLineLoader (Recommended for inline/contextual loading)
JJPowerLineLoader(
  width: 300,
  height: 80,
  message: 'Processing data...',
)

// JJSkeletonLoader (for content placeholders)
JJSkeletonLoader(
  width: double.infinity,
  height: 100,
  borderRadius: 8,
  showCircuitPattern: true,
)

// Electrical Rotation Meter
ElectricalRotationMeter(
  size: 120,
  label: 'Loading Power Systems...',
  duration: Duration(milliseconds: 3000),
)

// Circuit Breaker Toggle
CircuitBreakerToggle(
  isOn: _isSystemOn,
  onChanged: (value) {
    setState(() => _isSystemOn = value);
  },
  width: 80,
  height: 40,
)

// Hard Hat Icon
HardHatIcon(
  size: 48,
  color: Colors.orange,
)

// Transmission Tower Icon
TransmissionTowerIcon(
  size: 64,
  color: Colors.navy,
)
```

## Design Principles

1. **Industrial Aesthetics**: Clean, professional designs suitable for electrical/industrial contexts
2. **Realistic Animations**: Physics-based animations that mirror real electrical phenomena
3. **Accessibility**: High contrast colors and clear visual indicators
4. **Customization**: Flexible color schemes and sizing options
5. **Performance**: Efficient CustomPainter implementations for smooth animations

## Technical Details

- **Animation**: Uses `AnimationController` with `SingleTickerProviderStateMixin`
- **Rendering**: Custom `CustomPainter` classes for efficient drawing
- **Math**: Utilizes trigonometric functions for realistic wave patterns
- **Colors**: Consistent color interpolation and opacity effects
- **Performance**: Optimized `shouldRepaint` methods to minimize unnecessary redraws

## Dependencies

- Flutter SDK
- `dart:math` (for mathematical calculations)

## Integration

1. Copy the `electrical_components` folder to your project
2. Import the library: `import 'package:your_app/electrical_components/electrical_components.dart';`
3. Use any component in your widget tree
4. Customize colors and sizing as needed

## Customization Tips

- **Colors**: Use your brand colors while maintaining sufficient contrast
- **Sizing**: Test components at different sizes to ensure proper scaling
- **Animation**: Adjust duration based on your application's needs
- **Context**: Consider the electrical context when choosing component combinations
