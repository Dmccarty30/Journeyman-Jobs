import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/tailboard_theme.dart';

class ElectricalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  const ElectricalTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.maxLines,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TailboardTheme.surfaceLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TailboardTheme.navy600),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onTap: onTap,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
          height: 1.5,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFFFCD34D),
            height: 1.4,
          ),
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF4A5568),
            height: 1.4,
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
