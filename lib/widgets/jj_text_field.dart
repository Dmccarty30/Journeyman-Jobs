import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

/// A reusable TextFormField that:
///   • Shows a floating label (Material default)
///   • Uses the primary colour (navy) for the border in light mode
///   • Uses the secondary colour (copper) for the border in dark mode
///   • Accepts a controller, optional focus node and any other TextFormField params.
class JJTextField extends StatelessWidget {
  const JJTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.focusNode,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final List<dynamic>?
      inputFormatters; // dynamic to avoid import for now, or use List<TextInputFormatter>
  final bool enabled;

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
    //  Build the InputDecoration that gives us the floating label,
    //  hint text, and the colour‑changing border.
    // --------------------------------------------------------
    final InputDecoration decoration = InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
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
      // inputFormatters: inputFormatters, // Uncomment if needed and import services
      enabled: enabled,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}
