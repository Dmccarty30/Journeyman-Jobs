import 'package:flutter/material.dart';
import 'tailboard_theme.dart';

/// Adaptive text field component that responds to system theme
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AdaptiveTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TailboardTheme.getSurfaceColor(context, level: 2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TailboardTheme.getBorderColor(context)),
        boxShadow: TailboardTheme.getElevation2(context),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onTap: onTap,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TailboardTheme.getBodyLarge(context),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: TailboardTheme.getBodyMedium(context).copyWith(
            color: TailboardTheme.getAccentCopper(context),
          ),
          hintStyle: TailboardTheme.getBodyMedium(context).copyWith(
            color: TailboardTheme.getTextColor(context, isPrimary: false),
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
