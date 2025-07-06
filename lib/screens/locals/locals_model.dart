import '/backend/backend.dart';
import 'locals_widget.dart' show LocalsWidget;
import 'package:flutter/material.dart';

class LocalsModel {
  ///  State fields for stateful widgets in this page.

  // State field(s) for EmailLogin widget.
  FocusNode? emailLoginFocusNode;
  TextEditingController? emailLoginTextController;
  String? Function(BuildContext, String?)? emailLoginTextControllerValidator;

  void initState(BuildContext context) {}

  void dispose() {
    emailLoginFocusNode?.dispose();
    emailLoginTextController?.dispose();
  }
}
