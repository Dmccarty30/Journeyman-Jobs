import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Electrical-themed Stream Chat configuration for Journeyman Jobs
///
/// Provides consistent electrical copper and navy theme across all Stream Chat
/// components. Used to maintain brand identity and visual consistency.
class ElectricalStreamChatTheme {
  /// Creates a StreamChatThemeData with electrical theme colors:
  /// - Primary accent: AppTheme.accentCopper (#B45309)
  /// - Backgrounds: Navy shades from AppTheme
  /// - Message bubbles with proper contrast for readability
  static StreamChatThemeData get theme {
    return StreamChatThemeData(
      colorTheme: StreamColorTheme.light(
        accentPrimary: AppTheme.accentCopper,
        accentError: AppTheme.errorRed,
        accentInfo: AppTheme.infoBlue,
        textHighEmphasis: AppTheme.textPrimary,
        textLowEmphasis: AppTheme.textSecondary,
        disabled: AppTheme.mediumGray,
        borders: AppTheme.lightGray,
        inputBg: AppTheme.white,
        appBg: AppTheme.surfaceLight,
        overlayDark: Colors.black.withValues(alpha: 0.5),
        overlay: Colors.white.withValues(alpha: 0.8),
      ),
      ownMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: AppTheme.accentCopper,
        messageTextStyle: TextStyle(
          color: AppTheme.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        createdAtStyle: TextStyle(
          color: AppTheme.white.withValues(alpha: 0.8),
          fontSize: 12,
        ),
      ),
      otherMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: AppTheme.surfaceLight,
        messageTextStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        createdAtStyle: TextStyle(
          color: AppTheme.textLight,
          fontSize: 12,
        ),
      ),
      channelHeaderTheme: StreamChannelHeaderThemeData(
        color: AppTheme.white,
        subtitleStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
        titleStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageInputTheme: StreamMessageInputThemeData(
        sendButtonColor: AppTheme.accentCopper,
        actionButtonColor: AppTheme.textSecondary,
        inputBackgroundColor: AppTheme.white,
        inputTextStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
        ),
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
      ),
    );
  }
}