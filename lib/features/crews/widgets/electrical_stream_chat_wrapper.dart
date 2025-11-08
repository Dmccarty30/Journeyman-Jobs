import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../design_system/app_theme.dart';

/// Wrapper widget to apply electrical theme to Stream Chat widgets
///
/// This widget simplifies the process of applying the electrical theme
/// to any Stream Chat component. Use it instead of manually calling
/// _buildElectricalStreamTheme().
class ElectricalStreamChatWrapper extends StatelessWidget {
  final Widget child;

  const ElectricalStreamChatWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamChatTheme(
      data: _buildElectricalStreamTheme(),
      child: child,
    );
  }

  /// Build electrical-themed Stream Chat configuration
  ///
  /// Creates a StreamChatThemeData with electrical theme colors:
  /// - Primary accent: AppTheme.accentCopper (#B45309)
  /// - Backgrounds: Navy shades from AppTheme
  /// - Message bubbles with proper contrast for readability
  StreamChatThemeData _buildElectricalStreamTheme() {
    return StreamChatThemeData(
      // Primary color theme - copper accent with navy backgrounds
      colorTheme: StreamColorTheme.light(
        accentPrimary: AppTheme.accentCopper, // Copper for primary actions/highlights
        accentError: AppTheme.errorRed,     // Error red for validation states
        accentInfo: AppTheme.infoBlue,        // Info blue for informational states
        textHighEmphasis: AppTheme.textPrimary, // Dark navy text on light backgrounds
        textLowEmphasis: AppTheme.textSecondary, // Medium gray for secondary text
        disabled: AppTheme.mediumGray,      // Gray for disabled elements
        borders: AppTheme.lightGray,        // Light gray borders
        inputBg: AppTheme.white,            // White input backgrounds
        appBg: AppTheme.surfaceLight,       // Light surface background
        overlayDark: Colors.black.withValues(alpha: 0.5),
        overlay: Colors.white.withValues(alpha: 0.8),
      ),

      // Own message theme (messages sent by current user)
      ownMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: AppTheme.accentCopper, // Copper background for own messages
        messageTextStyle: TextStyle(
          color: AppTheme.white, // White text on copper for contrast (7.6:1 ratio)
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        avatarTheme: StreamAvatarThemeData(
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints.tightFor(
            height: 40,
            width: 40,
          ),
        ),
        createdAtStyle: TextStyle(
          color: AppTheme.white.withValues(alpha: 0.8),
          fontSize: 12,
        ),
      ),

      // Other message theme (messages from other users)
      otherMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: AppTheme.surfaceLight, // Light gray background for others' messages
        messageTextStyle: TextStyle(
          color: AppTheme.textPrimary, // Dark navy text for readability (14.8:1 ratio)
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        avatarTheme: StreamAvatarThemeData(
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints.tightFor(
            height: 40,
            width: 40,
          ),
        ),
        createdAtStyle: TextStyle(
          color: AppTheme.textLight, // Medium gray for timestamps
          fontSize: 12,
        ),
      ),

      // Channel list preview theme
      channelPreviewTheme: StreamChannelPreviewThemeData(
        avatarTheme: StreamAvatarThemeData(
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints.tightFor(
            height: 40,
            width: 40,
          ),
        ),
        titleStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        subtitleStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
        indicatorIconSize: 16,
      ),

      // Channel header theme
      channelHeaderTheme: StreamChannelHeaderThemeData(
        avatarTheme: StreamAvatarThemeData(
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints.tightFor(
            height: 36,
            width: 36,
          ),
        ),
        titleStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        subtitleStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
        color: AppTheme.white,
      ),

      // Message input theme
      messageInputTheme: StreamMessageInputThemeData(
        inputDecoration: InputDecoration(
          fillColor: AppTheme.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppTheme.lightGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppTheme.lightGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: AppTheme.accentCopper,
              width: 2,
            ),
          ),
          hintStyle: TextStyle(
            color: AppTheme.textLight,
            fontSize: 16,
          ),
          labelStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        sendButtonColor: AppTheme.accentCopper,
        actionButtonColor: AppTheme.textSecondary,
      ),
    );
  }
}

/// Example usage:
///
/// ```dart
/// ElectricalStreamChatWrapper(
///   child: StreamChannelListView(
///     filter: Filter.and([
///       Filter.equal('team', crewId),
///     ]),
///     sort: [const SortOption('last_message_at')],
///   ),
/// )
/// ```