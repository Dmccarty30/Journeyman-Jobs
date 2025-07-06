import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_system/app_theme.dart';
import '../navigation/app_router.dart';

class NavBarPage extends StatefulWidget {
  final Widget child;

  const NavBarPage({
    super.key,
    required this.child,
  });

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    setState(() {
      _selectedIndex = AppRouter.getTabIndex(location);
    });
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      final route = AppRouter.getRouteForTab(index);
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppTheme.white,
          selectedItemColor: AppTheme.accentCopper,
          unselectedItemColor: AppTheme.mediumGray,
          selectedLabelStyle: AppTheme.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTheme.labelSmall,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.home_outlined, Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.work_outline, Icons.work, 1),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.flash_on_outlined, Icons.flash_on, 2),
              label: 'Storm',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.people_outline, Icons.people, 3),
              label: 'Locals',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.more_horiz_outlined, Icons.more_horiz, 4),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData outlineIcon, IconData filledIcon, int index) {
    final isSelected = _selectedIndex == index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppTheme.accentCopper.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isSelected ? filledIcon : outlineIcon,
        size: 24,
        color: isSelected ? AppTheme.accentCopper : AppTheme.mediumGray,
      ),
    );
  }
}