# Circuit Animation Skill

**Domain**: Frontend
**Category**: Visual Effects & Animations
**Used By**: Electrical UI Specialist, Widget Specialist

## Skill Description
Creating electrical-themed animations including circuit flow, spark effects, power indicators, and connection visualizations for an engaging trade-specific UI.

## Core Animations

### Circuit Flow Animation
```dart
class CircuitFlowAnimation extends StatefulWidget {
  @override
  _CircuitFlowAnimationState createState() => _CircuitFlowAnimationState();
}

class _CircuitFlowAnimationState extends State<CircuitFlowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _flowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flowAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: CircuitPainter(
            progress: _flowAnimation.value,
            color: Colors.cyan.shade400,
          ),
        );
      },
    );
  }
}
```

### Electrical Spark Effect
```dart
class SparkEffect extends StatelessWidget {
  final Duration duration;
  final Color color;

  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      builder: (context, value, child) {
        return Container(
          width: 20 + (value * 30),
          height: 20 + (value * 30),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(1 - value),
                blurRadius: 20 * value,
                spreadRadius: 10 * value,
              ),
            ],
          ),
          child: Icon(
            Icons.flash_on,
            color: Colors.white.withOpacity(1 - value),
            size: 20,
          ),
        );
      },
    );
  }
}
```

## Power Indicators

### Voltage Meter Animation
```dart
class VoltageMeter extends StatefulWidget {
  final double voltage;
  final double maxVoltage;

  @override
  _VoltageMeterState createState() => _VoltageMeterState();
}

class _VoltageMeterState extends State<VoltageMeter>
    with TickerProviderStateMixin {
  late AnimationController _needleController;
  late Animation<double> _needleAnimation;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MeterPainter(
        value: _needleAnimation.value,
        color: _getVoltageColor(widget.voltage),
      ),
      child: SizedBox(
        width: 200,
        height: 150,
      ),
    );
  }

  Color _getVoltageColor(double voltage) {
    if (voltage < 50) return Colors.green;
    if (voltage < 250) return Colors.yellow;
    if (voltage < 600) return Colors.orange;
    return Colors.red;
  }
}
```

### Connection Status Animation
```dart
class ConnectionPulse extends StatefulWidget {
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: isConnected ? 16 : 12,
      height: isConnected ? 16 : 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isConnected ? Colors.green : Colors.red,
        boxShadow: isConnected
          ? [
              BoxShadow(
                color: Colors.green.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ]
          : [],
      ),
      child: isConnected
        ? RepeatAnimation(
            duration: Duration(seconds: 2),
            builder: (context, value) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green.withOpacity(1 - value),
                  width: 2,
                ),
              ),
            ),
          )
        : Container(),
    );
  }
}
```

## Load Animations

### Circuit Breaker Toggle
```dart
class CircuitBreakerSwitch extends StatefulWidget {
  final bool isOn;
  final Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isOn),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isOn ? Colors.green : Colors.grey,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 300),
          alignment: isOn
            ? Alignment.centerRight
            : Alignment.centerLeft,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isOn ? Colors.yellow : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.power_settings_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
```

## Performance Optimization
- Use RepaintBoundary for complex animations
- Implement animation controllers efficiently
- Dispose animations properly
- Cache animation frames when possible
- Limit concurrent animations

## Integration Points
- Works with: [[electrical-ui-specialist]]
- Enhances: [[electrical-theme-system]]
- Supports: Trade-specific visual identity

## Performance Metrics
- Frame rate: 60fps consistent
- CPU usage: < 10% for animations
- Memory: < 5MB for animation cache
- Battery impact: Minimal