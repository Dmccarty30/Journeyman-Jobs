import 'package:flutter/material.dart';

class UnionsModel {
  ///  State fields for stateful widgets in this page.

  // State field(s) for EmailLogin widget.
  FocusNode? emailLoginFocusNode;
  TextEditingController? emailLoginTextController;
  String? Function(BuildContext, String?)? emailLoginTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailLoginFocusNode?.dispose();
    emailLoginTextController?.dispose();
  }
}
