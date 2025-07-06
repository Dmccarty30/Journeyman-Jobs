import '/flutter_flow/flutter_flow_util.dart';
import 'unions_widget.dart' show UnionsWidget;
import 'package:flutter/material.dart';

class UnionsModel extends FlutterFlowModel<UnionsWidget> {
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
