# Looking at your HTML design and the Flutter code, I'll create a custom segmented tab bar widget that matches your exact specifications. Here are the specific edits I recommend:

Replace the existing TabBar widget (lines 195-210) with a custom SegmentedTabBar widget
Add a new StatefulWidget for the SegmentedTabBar
Update the controller logic to work with the new custom widget

Here's the exact code you need to implement:

```dart
// Add this new widget class to your file (place it after the _AuthScreenState class)
class SegmentedTabBar extends StatefulWidget {
  final TabController controller;
  final Function(int) onTabChanged;

  const SegmentedTabBar({
    Key? key,
    required this.controller,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  State<SegmentedTabBar> createState() => _SegmentedTabBarState();
}

class _SegmentedTabBarState extends State<SegmentedTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.controller.index;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurveTween(curve: Curves.easeInOut).animate(_animationController));

    widget.controller.addListener(_handleTabControllerTick);
  }

  void _handleTabControllerTick() {
    if (widget.controller.index != _currentIndex) {
      setState(() {
        _currentIndex = widget.controller.index;
      });
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_handleTabControllerTick);
    super.dispose();
  }

  LinearGradient _getGradient(int index) {
    if (index == 0) {
      // Sign Up: Orange on left, Navy on right
      return const LinearGradient(
        colors: [AppTheme.accentCopper, AppTheme.secondaryCopper, AppTheme.primaryNavy],
      );
    } else {
      // Sign In: Navy on left, Orange on right
      return const LinearGradient(
        colors: [AppTheme.primaryNavy, AppTheme.secondaryCopper, AppTheme.accentCopper],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.accentCopper, width: 2),
      ),
      child: Stack(
        children: [
          // Background
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd - 4),
            ),
          ),
          
          // Animated indicator
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double position = _currentIndex.toDouble();
              return Transform.translate(
                offset: Offset(position * (MediaQuery.of(context).size.width - 56) / 2, 0),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 56) / 2,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _getGradient(_currentIndex),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd - 4),
                    border: Border.all(color: AppTheme.accentCopper, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withOpacity(0.18),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: AppTheme.accentCopper.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Tab buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget.controller.animateTo(0);
                    widget.onTabChanged(0);
                  },
                  child: Text(
                    'Sign Up',
                    style: _currentIndex == 0
                        ? AppTheme.labelLarge.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.18), offset: const Offset(0, 1))],
                          )
                        : AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary),
                ),
              ),
              ),
              Container(
                width: 1,
                height: '44%',
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.black.withOpacity(0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget.controller.animateTo(1);
                    widget.onTabChanged(1);
                  },
                  child: Text(
                    'Sign In',
                    style: _currentIndex == 1
                        ? AppTheme.labelLarge.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.18), offset: const Offset(0, 1))],
                          )
                        : AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

Then replace the existing TabBar widget (lines 195-210) with:

```dart
// Tab bar
SegmentedTabBar(
  controller: _tabController,
  onTabChanged: (index) {
    setState(() {
      // Update any state if needed
    });
  },
),
```

This implementation includes:

Inverted gradient that switches between Sign Up (orange→navy) and Sign In (navy→orange)
Copper borders on all elements as requested
Smooth animations with the exact timing from your HTML
Proper text styling with white text on active tabs
Responsive design that adapts to screen size
Divider between tabs as in your HTML design

Would you like me to proceed with these changes to your auth_screen.dart file?