import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../services/structured_logger.dart';
import 'transformer_performance_monitor.dart';

/// Manages rendering optimizations for transformer diagrams
class RenderOptimizationManager {
  
  RenderOptimizationManager._();
  static final RenderOptimizationManager _instance = RenderOptimizationManager._();
  static RenderOptimizationManager get instance => _instance;
  
  // Picture caching for static backgrounds
  final Map<String, ui.Picture> _pictureCache = <String, ui.Picture>{};
  final Map<String, ui.Image> _rasterCache = <String, ui.Image>{};
  final Map<String, DateTime> _cacheTimestamps = <String, DateTime>{};
  
  // Render layer management
  final Map<String, RenderLayer> _renderLayers = <String, RenderLayer>{};
  
  // Configuration
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const int maxCacheSize = 20;
  
  /// Create optimized render layers for transformer diagram
  RenderLayerSet createRenderLayers(String diagramType, Size size) {
    final TransformerPerformanceMonitor monitor = TransformerPerformanceMonitor.instance;
    monitor.startOperation('diagram_render');
    
    try {
      // Create or retrieve render layers
      final RenderLayer backgroundLayer = _getOrCreateLayer(
        '${diagramType}_background',
        LayerType.static,
        size,
      );
      
      final RenderLayer connectionLayer = _getOrCreateLayer(
        '${diagramType}_connections',
        LayerType.dynamic,
        size,
      );
      
      final RenderLayer animationLayer = _getOrCreateLayer(
        '${diagramType}_animations',
        LayerType.animated,
        size,
      );
      
      monitor.endOperation('diagram_render', metadata: <String, dynamic>{
        'diagram_type': diagramType,
        'size': '${size.width}x${size.height}',
        'cached': _pictureCache.containsKey('${diagramType}_background'),
      },);
      
      return RenderLayerSet(
        background: backgroundLayer,
        connections: connectionLayer,
        animations: animationLayer,
      );
    } catch (e) {
      monitor.endOperation('diagram_render', metadata: <String, dynamic>{
        'error': e.toString(),
      },);
      rethrow;
    }
  }
  
  /// Get or create a render layer
  RenderLayer _getOrCreateLayer(String id, LayerType type, Size size) {
    final RenderLayer? existing = _renderLayers[id];
    if (existing != null && existing.size == size) {
      return existing;
    }
    
    final RenderLayer layer = RenderLayer(
      id: id,
      type: type,
      size: size,
    );
    
    _renderLayers[id] = layer;
    return layer;
  }
  
  /// Cache static background as picture
  Future<ui.Picture?> cacheStaticBackground(
    String cacheKey,
    Size size,
    void Function(Canvas) paintCallback,
  ) async {
    // Check if cached and not expired
    final ui.Picture? cachedPicture = _pictureCache[cacheKey];
    final DateTime? timestamp = _cacheTimestamps[cacheKey];
    
    if (cachedPicture != null && 
        timestamp != null &&
        DateTime.now().difference(timestamp) < cacheExpiration) {
      return cachedPicture;
    }
    
    // Create new picture
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = Canvas(recorder);
    
    // Execute paint operations
    paintCallback(canvas);
    
    // End recording
    final ui.Picture picture = recorder.endRecording();
    
    // Cache the picture
    _pictureCache[cacheKey] = picture;
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    // Manage cache size
    _cleanupCache();
    
    return picture;
  }
  
  /// Rasterize picture for better performance
  Future<ui.Image?> rasterizePicture(
    String cacheKey,
    ui.Picture picture,
    Size size,
  ) async {
    // Check raster cache
    final ui.Image? cached = _rasterCache[cacheKey];
    if (cached != null) {
      return cached;
    }
    
    try {
      // Convert picture to image
      final ui.Image image = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      
      // Cache the rasterized image
      _rasterCache[cacheKey] = image;
      
      return image;
    } catch (e) {
      StructuredLogger.debug('Failed to rasterize picture: $e');
      return null;
    }
  }
  
  /// Create optimized paint object
  Paint createOptimizedPaint({
    Color color = Colors.black,
    double strokeWidth = 2.0,
    PaintingStyle style = PaintingStyle.stroke,
    StrokeCap strokeCap = StrokeCap.round,
    StrokeJoin strokeJoin = StrokeJoin.round,
    bool antiAlias = true,
  }) {
    return Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = style
      ..strokeCap = strokeCap
      ..strokeJoin = strokeJoin
      ..isAntiAlias = antiAlias
      ..filterQuality = FilterQuality.medium; // Balance quality and performance
  }
  
  /// Optimize path for rendering
  Path optimizePath(Path originalPath) {
    // Simplify path if too complex
    final ui.PathMetrics metrics = originalPath.computeMetrics();
    int pointCount = 0;
    
    for (final ui.PathMetric metric in metrics) {
      pointCount += metric.length.toInt();
    }
    
    // If path is too complex, simplify it
    if (pointCount > 1000) {
      return _simplifyPath(originalPath);
    }
    
    return originalPath;
  }
  
  /// Simplify complex paths
  Path _simplifyPath(Path path) {
    // Douglas-Peucker algorithm for path simplification
    // This is a simplified implementation
    final ui.Path simplified = Path();
    final ui.PathMetrics metrics = path.computeMetrics();
    
    for (final ui.PathMetric metric in metrics) {
      final double length = metric.length;
      final double step = length / 100; // Sample 100 points max
      
      ui.Tangent? lastTangent;
      for (double distance = 0; distance <= length; distance += step) {
        final ui.Tangent? tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          if (lastTangent == null) {
            simplified.moveTo(tangent.position.dx, tangent.position.dy);
          } else {
            simplified.lineTo(tangent.position.dx, tangent.position.dy);
          }
          lastTangent = tangent;
        }
      }
    }
    
    return simplified;
  }
  
  /// Clean up expired cache entries
  void _cleanupCache() {
    if (_pictureCache.length <= maxCacheSize) return;
    
    // Find oldest entries
    final List<MapEntry<String, DateTime>> entries = _cacheTimestamps.entries.toList()
      ..sort((MapEntry<String, DateTime> a, MapEntry<String, DateTime> b) => a.value.compareTo(b.value));
    
    // Remove oldest entries
    final Iterable<MapEntry<String, DateTime>> toRemove = entries.take(entries.length - maxCacheSize);
    for (final MapEntry<String, DateTime> entry in toRemove) {
      _pictureCache.remove(entry.key);
      _rasterCache[entry.key]?.dispose();
      _rasterCache.remove(entry.key);
      _cacheTimestamps.remove(entry.key);
    }
  }
  
  /// Batch render operations for better performance
  void batchRenderOperations(List<RenderOperation> operations) {
    // Sort operations by priority
    operations.sort((RenderOperation a, RenderOperation b) => b.priority.compareTo(a.priority));
    
    // Execute in batches
    const int batchSize = 5;
    for (int i = 0; i < operations.length; i += batchSize) {
      final Iterable<RenderOperation> batch = operations.skip(i).take(batchSize);
      
      // Execute batch
      for (final RenderOperation operation in batch) {
        operation.execute();
      }
      
      // Allow frame to render between batches
      WidgetsBinding.instance.scheduleFrame();
    }
  }
  
  /// Clear all caches
  void clearCache() {
    _pictureCache.clear();
    for (final ui.Image image in _rasterCache.values) {
      image.dispose();
    }
    _rasterCache.clear();
    _cacheTimestamps.clear();
    _renderLayers.clear();
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() => <String, dynamic>{
      'picture_cache_size': _pictureCache.length,
      'raster_cache_size': _rasterCache.length,
      'render_layers': _renderLayers.length,
      'oldest_cache': _cacheTimestamps.values.isEmpty 
          ? 'none' 
          : _cacheTimestamps.values.reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b).toIso8601String(),
    };
}

/// Render layer for organizing drawing operations
class RenderLayer {
  
  RenderLayer({
    required this.id,
    required this.type,
    required this.size,
  });
  final String id;
  final LayerType type;
  final Size size;
  ui.Picture? cachedPicture;
  ui.Image? cachedImage;
  bool isDirty = true;
  
  void markDirty() {
    isDirty = true;
  }
  
  void markClean() {
    isDirty = false;
  }
}

/// Types of render layers
enum LayerType {
  static,   // Background, rarely changes
  dynamic,  // Connections, changes occasionally
  animated, // Animations, changes frequently
}

/// Set of render layers for a diagram
class RenderLayerSet {
  
  RenderLayerSet({
    required this.background,
    required this.connections,
    required this.animations,
  });
  final RenderLayer background;
  final RenderLayer connections;
  final RenderLayer animations;
}

/// Render operation for batching
class RenderOperation {
  
  RenderOperation({
    required this.execute,
    this.priority = 0,
  });
  final VoidCallback execute;
  final int priority;
}
