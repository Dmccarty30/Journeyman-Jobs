import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Dark Mode Theme Preview and Configuration
///
/// This class demonstrates the dark mode color scheme based on the existing
/// auth and onboarding screens, with all the subtle design elements inverted
/// while maintaining the same visual hierarchy and electrical theme.
class DarkModePreview extends StatelessWidget {
  const DarkModePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        extensions: [DarkModeTheme()],
      ),
      child: Scaffold(
        backgroundColor: DarkModeTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildColorPalette(),
                const SizedBox(height: 32),
                _buildComponentExamples(),
                const SizedBox(height: 32),
                _buildAuthScreenPreview(),
                const SizedBox(height: 32),
                _buildOnboardingPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DarkModeTheme.surface.withOpacity(0.8),
            DarkModeTheme.surface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DarkModeTheme.copperAccent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: DarkModeTheme.copperGlow.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dark Mode Preview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DarkModeTheme.textPrimary,
              shadows: [
                Shadow(
                  color: DarkModeTheme.copperGlow,
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inverted color scheme maintaining the same electrical theme',
            style: TextStyle(
              fontSize: 16,
              color: DarkModeTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Palette',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DarkModeTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _colorTile('Background', DarkModeTheme.background),
            _colorTile('Surface', DarkModeTheme.surface),
            _colorTile('Surface Elevated', DarkModeTheme.surfaceElevated),
            _colorTile('Copper Accent', DarkModeTheme.copperAccent),
            _colorTile('Copper Light', DarkModeTheme.copperLight),
            _colorTile('Navy Dark', DarkModeTheme.navyDark),
            _colorTile('Text Primary', DarkModeTheme.textPrimary),
            _colorTile('Text Secondary', DarkModeTheme.textSecondary),
            _colorTile('Border', DarkModeTheme.borderColor),
            _colorTile('Copper Glow', DarkModeTheme.copperGlow),
          ],
        ),
      ],
    );
  }

  Widget _colorTile(String name, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DarkModeTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: DarkModeTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: DarkModeTheme.copperAccent.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 10,
                    color: DarkModeTheme.textSecondary,
                  ),
                ),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 9,
                    color: DarkModeTheme.textTertiary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Component Examples',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DarkModeTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Back button with copper gradient (like in onboarding)
        _buildBackButton(),

        const SizedBox(height: 16),

        // Tab bar with animated gradient
        _buildTabBar(),

        const SizedBox(height: 16),

        // Text field
        _buildTextField(),

        const SizedBox(height: 16),

        // Buttons
        _buildButtons(),
      ],
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        // Dark surface with subtle gradient
        gradient: RadialGradient(
          colors: [
            DarkModeTheme.surface,
            DarkModeTheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DarkModeTheme.copperAccent,
          width: 1.25,
        ),
        boxShadow: [
          // Inner glow
          BoxShadow(
            color: DarkModeTheme.copperGlow.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
          // Outer copper radiant glow (the effect you mentioned!)
          BoxShadow(
            color: DarkModeTheme.copperAccent.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          // Deep shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_back,
        color: DarkModeTheme.textPrimary,
        shadows: [
          Shadow(
            color: DarkModeTheme.copperGlow,
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DarkModeTheme.surface.withOpacity(0.6),
            DarkModeTheme.surface.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DarkModeTheme.copperAccent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: DarkModeTheme.copperGlow.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: DarkModeTheme.copperNavyGradient,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DarkModeTheme.copperAccent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DarkModeTheme.copperGlow.withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: DarkModeTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: DarkModeTheme.copperGlow,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: DarkModeTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DarkModeTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DarkModeTheme.copperAccent.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: DarkModeTheme.copperGlow.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.email_outlined,
            color: DarkModeTheme.copperAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Email Address',
              style: TextStyle(
                color: DarkModeTheme.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Primary button with copper gradient
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: DarkModeTheme.buttonGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DarkModeTheme.copperAccent,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: DarkModeTheme.copperGlow.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Create Account',
              style: TextStyle(
                color: DarkModeTheme.textOnAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: DarkModeTheme.navyDark.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Secondary button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DarkModeTheme.copperAccent.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: DarkModeTheme.copperGlow.withOpacity(0.1),
                blurRadius: 12,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.g_mobiledata,
                  color: DarkModeTheme.errorColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: DarkModeTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthScreenPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DarkModeTheme.surface.withOpacity(0.3),
            DarkModeTheme.background,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DarkModeTheme.copperAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Auth Screen Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DarkModeTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Logo with copper glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: DarkModeTheme.buttonGradient,
              shape: BoxShape.circle,
              border: Border.all(
                color: DarkModeTheme.copperAccent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: DarkModeTheme.copperGlow.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.electrical_services,
              size: 40,
              color: DarkModeTheme.textOnAccent,
              shadows: [
                Shadow(
                  color: DarkModeTheme.copperGlow,
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join Journeyman Jobs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: DarkModeTheme.textPrimary,
              shadows: [
                Shadow(
                  color: DarkModeTheme.copperGlow.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DarkModeTheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DarkModeTheme.copperAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Onboarding Screen Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DarkModeTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Progress indicator with electrical theme
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: DarkModeTheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: DarkModeTheme.copperAccent.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: DarkModeTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: DarkModeTheme.copperGlow.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step 2 of 3',
            style: TextStyle(
              fontSize: 12,
              color: DarkModeTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark Mode Theme Configuration
///
/// This extension provides all dark mode colors and gradients
/// inverted from the light theme while maintaining the electrical aesthetic
extension DarkModeTheme on Never {
  // Base colors (inverted from light)
  static const Color background = Color(0xFF0F1419); // Very dark navy
  static const Color surface = Color(0xFF1A202C); // Dark navy (was primaryNavy)
  static const Color surfaceElevated = Color(0xFF2D3748); // Elevated surface

  // Copper accents (slightly adjusted for dark mode)
  static const Color copperAccent = Color(0xFFD97706); // Brighter copper for dark
  static const Color copperLight = Color(0xFFFBBF24); // Light copper
  static const Color copperGlow = Color(0xFFFF8C00); // Glowing copper effect

  // Navy colors (darker variants)
  static const Color navyDark = Color(0xFF0A0E14); // Deepest navy
  static const Color navyMedium = Color(0xFF1A202C); // Medium navy

  // Text colors (inverted)
  static const Color textPrimary = Color(0xFFF7FAFC); // Almost white
  static const Color textSecondary = Color(0xFFCBD5E1); // Light gray
  static const Color textTertiary = Color(0xFF94A3B8); // Medium gray
  static const Color textOnAccent = Color(0xFFFFFFFF); // Pure white on accents

  // Border colors
  static const Color borderColor = Color(0xFF475569); // Medium gray border
  static const Color borderLight = Color(0xFF334155); // Light border

  // Status colors (adjusted for dark mode)
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF00D4FF);

  // Gradients (inverted)
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      copperAccent,
      copperLight,
    ],
  );

  static const LinearGradient copperNavyGradient = LinearGradient(
    colors: [
      copperAccent,
      copperLight,
      navyMedium,
    ],
  );

  static const LinearGradient navyCopperGradient = LinearGradient(
    colors: [
      navyMedium,
      copperLight,
      copperAccent,
    ],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      surface,
      surfaceElevated,
    ],
  );

  // Shadows (enhanced for dark mode)
  static List<BoxShadow> get electricalGlow => [
    BoxShadow(
      color: copperGlow.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get subtleGlow => [
    BoxShadow(
      color: copperAccent.withOpacity(0.1),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}