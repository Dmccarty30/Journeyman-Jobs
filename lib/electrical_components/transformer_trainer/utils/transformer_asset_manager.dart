import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/unified_cache_service.dart';
import '../services/structured_logger.dart';
import 'transformer_performance_monitor.dart';

/// Manages transformer diagram assets with progressive loading and caching
class TransformerAssetManager {
  
  TransformerAssetManager._();
  static final TransformerAssetManager _instance = TransformerAssetManager._();
  static TransformerAssetManager get instance => _instance;
  
  // Asset cache with memory management
  final Map<String, ui.Image> _imageCache = <String, ui.Image>{};
  final Map<String, List<VoidCallback>> _pendingCallbacks = <String, List<ui.VoidCallback>>{};
  final Map<String, AssetMetadata> _assetMetadata = <String, AssetMetadata>{};
  
  // Progressive loading configuration
  
  // Asset paths by quality
  static const Map<AssetQuality, String> _qualitySuffixes = <AssetQuality, String>{
    AssetQuality.low: '_low',
    AssetQuality.medium: '_medium',
    AssetQuality.high: '',
  };
  
  /// Initialize asset manager with device capabilities
  Future<void> initialize(BuildContext context) async {
    // Determine device quality based on pixel ratio and screen size
    final AssetQuality deviceQuality = _determineDeviceQuality(context);
    
    // Preload critical assets
    await _preloadCriticalAssets(deviceQuality);
  }
  
  /// Get image asset with progressive loading
  Future<ui.Image?> getImage(
    String assetName, {
    AssetQuality? requestedQuality,
    bool preload = false,
  }) async {
    final TransformerPerformanceMonitor monitor = TransformerPerformanceMonitor.instance;
    monitor.startOperation('asset_load');
    
    try {
      // Check memory cache first
      if (_imageCache.containsKey(assetName)) {
        monitor.endOperation('asset_load', metadata: <String, dynamic>{
          'asset_name': assetName,
          'cache_hit': true,
          'asset_size': 0,
        },);
        return _imageCache[assetName];
      }
      
      // Check persistent cache
      final Map<String, dynamic>? cachedData = await UnifiedCacheService.instance.get<Map<String, dynamic>>(
        'transformer_image_$assetName',
      );
      
      if (cachedData != null) {
        // Decode from cached bytes
        final Uint8List bytes = Uint8List.fromList((cachedData['bytes'] as List).cast<int>());
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frame = await codec.getNextFrame();
        final ui.Image image = frame.image;
        
        _imageCache[assetName] = image;
        monitor.endOperation('asset_load', metadata: <String, dynamic>{
          'asset_name': assetName,
          'cache_hit': true,
          'asset_size': bytes.length,
        },);
        return image;
      }
      
      // Load from assets
      final AssetQuality quality = requestedQuality ?? _getOptimalQuality();
      final String assetPath = _getAssetPath(assetName, quality);
      
      // Check if already loading
      if (_pendingCallbacks.containsKey(assetPath)) {
        final Completer<ui.Image?> completer = Completer<ui.Image?>();
        _pendingCallbacks[assetPath]!.add(() {
          completer.complete(_imageCache[assetName]);
        });
        return completer.future;
      }
      
      // Start loading
      _pendingCallbacks[assetPath] = <ui.VoidCallback>[];
      
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: quality == AssetQuality.low ? 512 : null,
        targetHeight: quality == AssetQuality.low ? 512 : null,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image image = frame.image;
      
      // Cache in memory
      _imageCache[assetName] = image;
      
      // Cache persistently if significant size
      if (bytes.length > 10000 && !preload) { // > 10KB
        await UnifiedCacheService.instance.set(
          'transformer_image_$assetName',
          <String, List<int>>{'bytes': bytes.toList()},
          ttl: const Duration(days: 30),
        );
      }
      
      // Update metadata
      _assetMetadata[assetName] = AssetMetadata(
        size: bytes.length,
        width: image.width,
        height: image.height,
        quality: quality,
        loadTime: DateTime.now(),
      );
      
      // Notify pending callbacks
      for (final callback in _pendingCallbacks[assetPath] ?? <dynamic>[]) {
        callback();
      }
      _pendingCallbacks.remove(assetPath);
      
      monitor.endOperation('asset_load', metadata: <String, dynamic>{
        'asset_name': assetName,
        'cache_hit': false,
        'asset_size': bytes.length,
        'quality': quality.toString(),
      },);
      
      return image;
    } catch (e) {
      StructuredLogger.debug('Failed to load asset $assetName: $e');
      monitor.endOperation('asset_load', metadata: <String, dynamic>{
        'asset_name': assetName,
        'error': e.toString(),
      },);
      return null;
    }
  }
  
  /// Preload critical assets for better performance
  Future<void> _preloadCriticalAssets(AssetQuality quality) async {
    final List<String> criticalAssets = <String>[
      'transformer_wye_symbol',
      'transformer_delta_symbol',
      'connection_point',
      'terminal_h1',
      'terminal_h2',
      'terminal_x1',
      'terminal_x2',
    ];
    
    // Load in parallel with timeout
    await Future.wait(
      criticalAssets.map((String asset) => 
        getImage(asset, requestedQuality: quality, preload: true)
          .timeout(const Duration(seconds: 2), onTimeout: () => null),
      ),
    );
  }
  
  /// Determine device quality based on capabilities
  AssetQuality _determineDeviceQuality(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double pixelRatio = mediaQuery.devicePixelRatio;
    final ui.Size size = mediaQuery.size;
    
    // High-end device detection
    if (pixelRatio >= 3.0 && size.width >= 414) {
      return AssetQuality.high;
    }
    
    // Mid-range device
    if (pixelRatio >= 2.0 && size.width >= 375) {
      return AssetQuality.medium;
    }
    
    // Low-end device or constrained memory
    return AssetQuality.low;
  }
  
  /// Get optimal quality based on current memory pressure
  AssetQuality _getOptimalQuality() {
    // Check memory pressure (simplified for now)
    if (_imageCache.length > 50) {
      return AssetQuality.low;
    } else if (_imageCache.length > 25) {
      return AssetQuality.medium;
    }
    return AssetQuality.high;
  }
  
  /// Get asset path with quality suffix
  String _getAssetPath(String assetName, AssetQuality quality) {
    final String suffix = _qualitySuffixes[quality] ?? '';
    return 'assets/transformers/$assetName$suffix.png';
  }
  
  /// Clear memory cache to free resources
  void clearMemoryCache() {
    _imageCache.clear();
    _assetMetadata.clear();
  }
  
  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    int totalSize = 0;
    for (final AssetMetadata metadata in _assetMetadata.values) {
      totalSize += metadata.size;
    }
    
    return <String, dynamic>{
      'cached_images': _imageCache.length,
      'total_size_mb': (totalSize / 1024 / 1024).toStringAsFixed(1),
      'metadata_entries': _assetMetadata.length,
      'pending_loads': _pendingCallbacks.length,
    };
  }
  
  /// Dispose of resources
  void dispose() {
    clearMemoryCache();
    _pendingCallbacks.clear();
  }
}

/// Asset quality levels for progressive loading
enum AssetQuality {
  low,    // 512x512 max, compressed
  medium, // 1024x1024 max, standard
  high,   // Original resolution
}

/// Asset metadata for tracking
class AssetMetadata {
  
  AssetMetadata({
    required this.size,
    required this.width,
    required this.height,
    required this.quality,
    required this.loadTime,
  });
  final int size;
  final int width;
  final int height;
  final AssetQuality quality;
  final DateTime loadTime;
}
