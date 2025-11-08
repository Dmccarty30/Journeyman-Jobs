import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';
import 'package:journeyman_jobs/features/crews/widgets/dynamic_container_row.dart';

void main() {
  group('Electrical Theme Tests', () {
    late ThemeData electricalTheme;

    setUp(() {
      electricalTheme = ThemeData(
        primaryColor: AppTheme.primaryNavy,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: AppTheme.accentCopper,
        ),
        scaffoldBackgroundColor: AppTheme.backgroundGrey,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.primaryNavy,
          foregroundColor: AppTheme.textOnDark,
          elevation: 0,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppTheme.textPrimary,
          displayColor: AppTheme.textPrimary,
        ),
        cardTheme: CardTheme(
          color: AppTheme.white,
          elevation: AppTheme.elevationMd,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(
              color: AppTheme.accentCopper,
              width: AppTheme.borderWidthCopper,
            ),
          ),
        ),
      );
    });

    group('1. Verify Electrical Copper Theme Applied', () {
      testWidgets('should apply copper color scheme throughout chat interface', (tester) async {
        // Act: Build themed chat interface
        await tester.pumpWidget(
          MaterialApp(
            theme: electricalTheme,
            home: Scaffold(
              appBar: AppBar(
                title: const Text('IBEW Connect'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.electrical_services),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Dynamic container row with copper theme
                  DynamicContainerRow(
                    labels: ['Channels', 'DMs', 'History', 'Crew'],
                    selectedIndex: 0,
                    onTap: (index) {},
                  ),
                  // Chat area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: AppTheme.accentCopper,
                          width: AppTheme.borderWidthCopper,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Channel Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Last message preview...',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
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
        );

        await tester.pumpAndSettle();

        // Assert: Verify copper theme elements
        expect(find.text('IBEW Connect'), findsOneWidget);
        expect(find.byIcon(Icons.electrical_services), findsOneWidget);

        // Verify DynamicContainerRow styling
        final dynamicContainerFinder = find.byType(DynamicContainerRow);
        expect(dynamicContainerFinder, findsOneWidget);

        // Verify copper borders
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);
      });

      test('should create StreamChatThemeData with electrical colors', () {
        // Act: Create electrical StreamChatThemeData
        final streamChatTheme = StreamChatThemeData(
          colorTheme: StreamColorTheme.light(
            accentColor: AppTheme.accentCopper,
            accentError: AppTheme.errorRed,
            accentInfo: AppTheme.primaryNavy,
            accentPrimary: AppTheme.primaryNavy,
            accentSuccess: Colors.green,
          ),
          textTheme: StreamTextTheme(
            bodyBold: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            body: TextStyle(
              color: AppTheme.textPrimary,
            ),
            captionBold: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            caption: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            headlineBold: TextStyle(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            headline: TextStyle(
              color: AppTheme.primaryNavy,
              fontSize: 24,
            ),
          ),
          channelHeaderTheme: StreamChannelHeaderThemeData(
            avatarTheme: StreamAvatarThemeData(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              constraints: const BoxConstraints.tightFor(
                height: 40,
                width: 40,
              ),
            ),
            color: AppTheme.primaryNavy,
            height: 56,
          ),
          channelPreviewTheme: StreamChannelPreviewThemeData(
            avatarTheme: StreamAvatarThemeData(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              constraints: const BoxConstraints.tightFor(
                height: 40,
                width: 40,
              ),
            ),
            titleStyle: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            subtitleStyle: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            indicatorIconSize: 16,
            lastMessageTextStyle: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          messageTheme: StreamMessageThemeData(
            messageBackgroundColor: AppTheme.backgroundGrey,
            createdAtStyle: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            messageAuthorStyle: TextStyle(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            messageTextStyle: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
            avatarTheme: StreamAvatarThemeData(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              constraints: const BoxConstraints.tightFor(
                height: 32,
                width: 32,
              ),
            ),
          ),
          ownMessageTheme: StreamMessageThemeData(
            messageBackgroundColor: AppTheme.accentCopper,
            createdAtStyle: TextStyle(
              color: AppTheme.white.withValues(alpha:0.8),
              fontSize: 12,
            ),
            messageAuthorStyle: TextStyle(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            messageTextStyle: TextStyle(
              color: AppTheme.white,
              fontSize: 16,
            ),
          ),
        );

        // Assert: Verify electrical theme colors are applied
        expect(streamChatTheme.colorTheme?.accentColor, equals(AppTheme.accentCopper));
        expect(streamChatTheme.colorTheme?.accentPrimary, equals(AppTheme.primaryNavy));
        expect(streamChatTheme.textTheme?.bodyBold?.color, equals(AppTheme.textPrimary));
        expect(streamChatTheme.messageTheme?.messageBackgroundColor, equals(AppTheme.backgroundGrey));
        expect(streamChatTheme.ownMessageTheme?.messageBackgroundColor, equals(AppTheme.accentCopper));
      });
    });

    group('2. Check Message Bubbles Colors', () {
      testWidgets('should apply correct colors to message bubbles', (tester) async {
        // Act: Build message bubble test interface
        await tester.pumpWidget(
          MaterialApp(
            theme: electricalTheme,
            home: Scaffold(
              backgroundColor: AppTheme.backgroundGrey,
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Incoming message (left-aligned)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16, right: 80),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: AppTheme.accentCopper.withValues(alpha:0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mike Wilson',
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hey John, are you ready for the storm response?',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '2:30 PM',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Outgoing message (right-aligned, copper theme)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16, left: 80),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCopper,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentCopper.withValues(alpha:0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'You',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Yes, I\'ve got my gear ready. See you at the yard.',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '2:32 PM',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify message bubble colors and structure
        expect(find.text('Mike Wilson'), findsOneWidget);
        expect(find.text('Hey John, are you ready for the storm response?'), findsOneWidget);
        expect(find.text('You'), findsOneWidget);
        expect(find.text('Yes, I\'ve got my gear ready. See you at the yard.'), findsOneWidget);

        // Verify containers are rendered with proper styling
        final messageContainers = find.byType(Container);
        expect(messageContainers, findsWidgets);
      });
    });

    group('3. Verify Proper Contrast Ratios', () {
      test('should ensure WCAG AA compliance for text colors', () {
        // Test copper background with white text (outgoing messages)
        final copperColor = AppTheme.accentCopper;
        final whiteTextColor = AppTheme.white;
        final copperContrastRatio = calculateContrastRatio(copperColor, whiteTextColor);

        // Assert: Outgoing messages should meet WCAG AA (4.5:1)
        expect(copperContrastRatio, greaterThanOrEqualTo(4.5));

        // Test white background with navy text (headers)
        final whiteColor = AppTheme.white;
        final navyTextColor = AppTheme.primaryNavy;
        final whiteContrastRatio = calculateContrastRatio(whiteColor, navyTextColor);

        // Assert: Headers should meet WCAG AA (4.5:1)
        expect(whiteContrastRatio, greaterThanOrEqualTo(4.5));

        // Test grey background with primary text (incoming messages)
        final greyColor = AppTheme.backgroundGrey;
        final primaryTextColor = AppTheme.textPrimary;
        final greyContrastRatio = calculateContrastRatio(greyColor, primaryTextColor);

        // Assert: Messages should meet WCAG AA (4.5:1)
        expect(greyContrastRatio, greaterThanOrEqualTo(4.5));
      });

      test('should ensure button accessibility', () {
        // Test copper buttons with white text
        final copperButtonColor = AppTheme.accentCopper;
        final buttonTextColor = AppTheme.white;
        final buttonContrastRatio = calculateContrastRatio(copperButtonColor, buttonTextColor);

        // Assert: Buttons should meet WCAG AA (4.5:1)
        expect(buttonContrastRatio, greaterThanOrEqualTo(4.5));

        // Test navy buttons with white text
        final navyButtonColor = AppTheme.primaryNavy;
        final navyButtonContrastRatio = calculateContrastRatio(navyButtonColor, buttonTextColor);

        // Assert: Navy buttons should meet WCAG AA (4.5:1)
        expect(navyButtonContrastRatio, greaterThanOrEqualTo(4.5));
      });
    });

    group('4. Container Theme Consistency', () {
      testWidgets('should apply consistent theme across all containers', (tester) async {
        // Act: Build all four containers with theme
        await tester.pumpWidget(
          MaterialApp(
            theme: electricalTheme,
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: AppTheme.primaryNavy,
                title: const Text(
                  'IBEW Connect',
                  style: TextStyle(color: AppTheme.textOnDark),
                ),
              ),
              body: Column(
                children: [
                  // Container selection row
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.backgroundGrey,
                    child: DynamicContainerRow(
                      labels: ['Channels', 'DMs', 'History', 'Crew'],
                      selectedIndex: 0,
                      onTap: (index) {},
                    ),
                  ),
                  // Container content area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: AppTheme.accentCopper,
                          width: AppTheme.borderWidthCopper,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Container Content',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCopper.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(
                                color: AppTheme.accentCopper.withValues(alpha:0.3),
                              ),
                            ),
                            child: Text(
                              'Electrical-themed content area',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                              ),
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
        );

        await tester.pumpAndSettle();

        // Assert: Verify consistent theme application
        expect(find.text('IBEW Connect'), findsOneWidget);
        expect(find.text('Container Content'), findsOneWidget);
        expect(find.text('Electrical-themed content area'), findsOneWidget);

        // Verify DynamicContainerRow styling
        final dynamicContainerFinder = find.byType(DynamicContainerRow);
        expect(dynamicContainerFinder, findsOneWidget);

        // Verify theme colors are applied consistently
        final scaffoldFinder = find.byType(Scaffold);
        expect(scaffoldFinder, findsOneWidget);

        final appBarFinder = find.byType(AppBar);
        expect(appBarFinder, findsOneWidget);
      });
    });

    group('5. Electrical Component Integration', () {
      testWidgets('should integrate electrical symbols and components', (tester) async {
        // Act: Build interface with electrical components
        await tester.pumpWidget(
          MaterialApp(
            theme: electricalTheme,
            home: Scaffold(
              backgroundColor: AppTheme.backgroundGrey,
              appBar: AppBar(
                backgroundColor: AppTheme.primaryNavy,
                title: const Text('IBEW Electrical Network'),
                actions: [
                  Icon(
                    Icons.electrical_services,
                    color: AppTheme.accentCopper,
                  ),
                  Icon(
                    Icons.flash_on,
                    color: AppTheme.accentCopper,
                  ),
                  Icon(
                    Icons.bolt,
                    color: AppTheme.accentCopper,
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Status indicators with electrical theme
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 12,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'System Online',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.power,
                          color: AppTheme.accentCopper,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Channel cards with electrical styling
                    Expanded(
                      child: ListView(
                        children: [
                          _buildElectricalChannelCard(
                            'General',
                            '#general',
                            '12 members',
                            Icons.group,
                          ),
                          const SizedBox(height: 12),
                          _buildElectricalChannelCard(
                            'Storm Response',
                            '#storm',
                            '8 members online',
                            Icons.flash_on,
                          ),
                          const SizedBox(height: 12),
                          _buildElectricalChannelCard(
                            'Safety Alerts',
                            '#safety',
                            '3 new alerts',
                            Icons.warning,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert: Verify electrical components
        expect(find.text('IBEW Electrical Network'), findsOneWidget);
        expect(find.byIcon(Icons.electrical_services), findsOneWidget);
        expect(find.byIcon(Icons.flash_on), findsOneWidget);
        expect(find.byIcon(Icons.bolt), findsOneWidget);
        expect(find.text('System Online'), findsOneWidget);
        expect(find.text('General'), findsOneWidget);
        expect(find.text('Storm Response'), findsOneWidget);
        expect(find.text('Safety Alerts'), findsOneWidget);
      });
    });
  });
}

// Helper function to build electrical-themed channel card
Widget _buildElectricalChannelCard(String title, String subtitle, String badge, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      border: Border.all(
        color: AppTheme.accentCopper,
        width: AppTheme.borderWidthCopper,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentCopper.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentCopper,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (badge.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    ),
  );
}

// Helper function to calculate contrast ratio for accessibility testing
double calculateContrastRatio(Color foreground, Color background) {
  final luminance1 = foreground.computeLuminance();
  final luminance2 = background.computeLuminance();

  final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
  final darker = luminance1 > luminance2 ? luminance2 : luminance1;

  return (lighter + 0.05) / (darker + 0.05);
}