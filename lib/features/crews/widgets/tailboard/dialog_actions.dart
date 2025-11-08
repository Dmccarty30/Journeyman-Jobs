import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/tailboard_components.dart';

class DialogActions extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String cancelText;
  final String confirmText;
  final bool isConfirmLoading;

  const DialogActions({
    super.key,
    this.onConfirm,
    this.confirmText = 'Submit',
    this.onCancel,
    this.cancelText = 'Cancel',
    this.isConfirmLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TailboardComponents.actionButton(
          context,
          text: cancelText,
          onPressed: onCancel ?? () => Navigator.pop(context),
          isPrimary: false,
        ),
        const SizedBox(width: 16),
        TailboardComponents.actionButton(
          context,
          text: confirmText,
          onPressed: isConfirmLoading ? () {} : onConfirm,
          isPrimary: true,
          isLoading: isConfirmLoading,
        ),
      ],
    );
  }
}
