import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';

/// A reusable TextFormField that combines the floating label and theme-aware borders
/// with the original, widely-used API from reusable_components.dart.
///
/// It:
///   • Shows a floating label (Material default).
///   • Uses the primary colour (navy) for the border in light mode.
///   • Uses the secondary colour (copper) for the border in dark mode.
///   • Is backward-compatible with the original JJTextField API.
class JJTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const JJTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------------
    //  Decide which colour to use based on the current brightness
    // --------------------------------------------------------
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Primary = navy (light mode), Secondary = copper (dark mode)
    final Color borderColor =
        isDark ? AppTheme.accentCopper : AppTheme.primaryNavy;

    // --------------------------------------------------------
    //  Handle IconData to Widget conversion for backward compatibility
    // --------------------------------------------------------
    final Widget? prefixIconWidget = prefixIcon != null
        ? Icon(prefixIcon, color: AppTheme.textLight)
        : null;
    
    final Widget? suffixIconWidget = suffixIcon != null
        ? IconButton(
            icon: Icon(suffixIcon, color: AppTheme.textLight),
            onPressed: onSuffixIconPressed,
          )
        : null;

    // --------------------------------------------------------
    //  Build the InputDecoration that gives us the floating label,
    //  hint text, and the colour‑changing border.
    // --------------------------------------------------------
    final InputDecoration decoration = InputDecoration(
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: prefixIconWidget,
      suffixIcon: suffixIconWidget,
      // Border when the field is *enabled* but NOT focused
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      // Border when the field *has* focus – we switch colour here
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.errorRed, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    // --------------------------------------------------------
    //  Return the actual TextFormField
    // --------------------------------------------------------
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: decoration,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      enabled: enabled,
      style: AppTheme.bodyMedium.copyWith(
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}
