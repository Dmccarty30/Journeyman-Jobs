import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/jobs_record.dart';
import '../models/users_record.dart';

enum AnimationTrigger { onPageLoad, onPageEnd, inherited }

class AnimationInfo {
  final AnimationTrigger trigger;
  final String effect;

  final Duration duration;

  const AnimationInfo({
    required this.trigger,
    required this.effect,
    required this.duration,
  });
}

class FlutterFlowTheme {
  static const Color primaryBackground = Color(0xFF090F13);
  static const Color secondaryBackground = Color(0xFF0E171E);
  static const Color primary = Color(0xFF43A047);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF757575);
  static const Color tertiary = Color(0xFFE0E3E7);

  static TextStyle? get title1 => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32.0,
    fontWeight: FontWeight.w400,
    color: primaryText,
  );

  static TextStyle? get bodyText1 => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: primaryText,
  );

  // Shim for theme usage
  static FlutterFlowTheme of(BuildContext context) => const FlutterFlowTheme();

  const FlutterFlowTheme();
}

class FFButtonOptions {
  final TextStyle? textStyle;
  final double? elevation;
  final Color? backgroundColor;
  final bool showBorder;
  final Color? borderColor;
  final double? borderRadius;
  final BorderStyle? borderStyle;

  const FFButtonOptions({
    this.textStyle,
    this.elevation,
    this.backgroundColor = Colors.white,
    this.showBorder = false,
    this.borderColor = Colors.transparent,
    this.borderRadius = 8.0,
    this.borderStyle = BorderStyle.solid,
  });
}

class FFButtonWidget extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? text;
  final FFButtonOptions options;
  final Widget? child;
  final Color? fillColor;
  final Color? splashColor;
  final bool showLoading;

  const FFButtonWidget({
    super.key,
    required this.onPressed,
    this.text,
    this.options = const FFButtonOptions(),
    this.child,
    this.fillColor,
    this.splashColor,
    this.showLoading = false,
  });

  @override
  State<FFButtonWidget> createState() => _FFButtonWidgetState();
}

class _FFButtonWidgetState extends State<FFButtonWidget> {
  bool _isLoading = false;

  Future<void> _onPressWithLoading() async {
    if (widget.showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      widget.onPressed?.call();
    } finally {
      if (widget.showLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: widget.fillColor ?? widget.options.backgroundColor,
      elevation: widget.options.elevation ?? 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.options.borderRadius ?? 8),
        side: widget.options.showBorder
            ? BorderSide(color: widget.options.borderColor ?? Colors.transparent, style: widget.options.borderStyle ?? BorderStyle.solid)
            : BorderSide.none,
      ),
      splashFactory: widget.splashColor != null ? InkSplash.splashFactory : InkRipple.splashFactory,
      foregroundColor: widget.splashColor,
    );

    return ElevatedButton(
      style: buttonStyle,
      onPressed: _isLoading ? null : _onPressWithLoading,
      child: _isLoading && widget.showLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : widget.child ?? Text(widget.text ?? '', style: widget.options.textStyle),
    );
  }
}

class FlutterFlowIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final Color? backgroundColor;

  const FlutterFlowIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = Colors.white,
    this.size = 24.0,
    this.backgroundColor,
  });

  @override
  State<FlutterFlowIconButton> createState() => _FlutterFlowIconButtonState();
}

class _FlutterFlowIconButtonState extends State<FlutterFlowIconButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(widget.icon, color: widget.color, size: widget.size),
        onPressed: widget.onPressed,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
class TailboardModel extends ChangeNotifier {
  AnimationInfo? animationInfo;
  JobsRecord? selectedJob;
  UsersRecord? user;
  bool _mounted = true;

  TailboardModel();

  factory TailboardModel.createModel(BuildContext context) {
    final model = TailboardModel();
    model.animationInfo = const AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effect: 'fadeIn',
      duration: Duration(milliseconds: 600),
    );
    return model;
  }

  bool get mounted => _mounted;

  void safeSetState(VoidCallback fn) {
    if (_mounted) setState(fn);
  }

  void setState(VoidCallback fn) {
    if (_mounted) {
      fn();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}


// Stubs for query functions used in tailboard
Future<List<JobsRecord>> queryJobsRecord({DocumentReference? Function(DocumentSnapshot Function(BuildContext))? getDocument}) async {
  // Stub: return empty list; implement actual Firestore query
  return [];
}

Future<List<UsersRecord>> queryUsersRecord({DocumentReference? Function(DocumentSnapshot Function(BuildContext))? getDocument}) async {
  // Stub: return empty list; implement actual Firestore query
  return [];
}
