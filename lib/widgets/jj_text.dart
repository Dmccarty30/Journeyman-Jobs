import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

/// A set of reusable Text widgets that adhere to the AppTheme typography.
/// Usage:
///   JJText.header('Title')
///   JJText.body('Some content...')
class JJText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  const JJText._({
    Key? key,
    required this.text,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : super(key: key);

  /// Large Header (H1)
  factory JJText.h1(String text, {Color? color, TextAlign? textAlign}) {
    return JJText._(
      text: text,
      style: AppTheme.headerLarge,
      color: color,
      textAlign: textAlign,
    );
  }

  /// Medium Header (H2)
  factory JJText.h2(String text, {Color? color, TextAlign? textAlign}) {
    return JJText._(
      text: text,
      style: AppTheme.headerMedium,
      color: color,
      textAlign: textAlign,
    );
  }

  /// Small Header (H3)
  factory JJText.h3(String text, {Color? color, TextAlign? textAlign}) {
    return JJText._(
      text: text,
      style: AppTheme.headerSmall,
      color: color,
      textAlign: textAlign,
    );
  }

  /// Body Text
  factory JJText.body(String text,
      {Color? color,
      TextAlign? textAlign,
      int? maxLines,
      TextOverflow? overflow}) {
    return JJText._(
      text: text,
      style: AppTheme.bodyMedium,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Small Label / Caption
  factory JJText.caption(String text, {Color? color, TextAlign? textAlign}) {
    return JJText._(
      text: text,
      style: AppTheme.labelSmall,
      color: color,
      textAlign: textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: color != null ? style.copyWith(color: color) : style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
