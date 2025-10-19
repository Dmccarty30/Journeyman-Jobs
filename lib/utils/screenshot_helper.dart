import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper class for capturing and saving screenshots during development
class ScreenshotHelper {
  static final GlobalKey _boundaryKey = GlobalKey();

  /// Wraps a widget to make it screenshottable
  static Widget screenshotBoundary({required Widget child}) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: Stack(
        children: [
          child,
          // Debug screenshot button (only in debug mode)
          if (kDebugMode)
            Positioned(
              bottom: 100,
              right: 20,
              child: _ScreenshotButton(boundaryKey: _boundaryKey),
            ),
        ],
      ),
    );
  }

  /// Captures a screenshot of the current screen
  static Future<Uint8List?> captureScreenshot(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing screenshot: $e');
      return null;
    }
  }

  /// Saves screenshot to device storage
  static Future<String?> saveScreenshot(Uint8List imageBytes) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        debugPrint('Storage permission denied');
        return null;
      }

      // Get the directory to save screenshots
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return null;

      // Create screenshots folder
      final screenshotsDir = Directory('${directory.path}/JourneymanJobs/screenshots');
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${screenshotsDir.path}/screenshot_$timestamp.png';

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      debugPrint('Screenshot saved: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error saving screenshot: $e');
      return null;
    }
  }
}

/// Debug button for capturing screenshots
class _ScreenshotButton extends StatefulWidget {
  final GlobalKey boundaryKey;

  const _ScreenshotButton({required this.boundaryKey});

  @override
  State<_ScreenshotButton> createState() => _ScreenshotButtonState();
}

class _ScreenshotButtonState extends State<_ScreenshotButton>
    with SingleTickerProviderStateMixin {
  bool _isCapturing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _captureScreenshot() async {
    setState(() => _isCapturing = true);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Capture the screenshot
    final imageBytes = await ScreenshotHelper.captureScreenshot(widget.boundaryKey);

    if (imageBytes != null) {
      // Save to file
      final filePath = await ScreenshotHelper.saveScreenshot(imageBytes);

      // Show feedback
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              filePath != null
                  ? 'Screenshot saved!'
                  : 'Failed to save screenshot',
            ),
            backgroundColor: filePath != null ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    setState(() => _isCapturing = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: _isCapturing
                  ? Colors.green
                  : Theme.of(context).primaryColor,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _isCapturing ? null : _captureScreenshot,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  child: _isCapturing
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Icon(
                          Icons.screenshot,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}