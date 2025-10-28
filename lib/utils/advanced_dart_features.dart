import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Advanced Dart utilities with isolates, streams, and performance optimization
///
/// Features:
/// - Isolate-based parallel processing for CPU-intensive tasks
/// - Enhanced stream management with backpressure handling
/// - Type-safe generic utilities
/// - Memory-efficient data structures
/// - Comprehensive error handling and recovery
/// - Performance monitoring and optimization

/// Isolate-based parallel processing manager
class IsolateProcessor<T, R> {
  static final Map<String, SendPort> _isolatePool = {};
  static int _isolateCounter = 0;

  late final String _processorId;
  late final Isolate _isolate;
  late final ReceivePort _receivePort;
  late final SendPort _sendPort;
  bool _isDisposed = false;

  /// Creates an isolate processor for CPU-intensive operations
  IsolateProcessor({
    required Future<R> Function(T data) processorFunction,
    required String processorName,
  }) {
    _processorId = '${processorName}_${++_isolateCounter}';
    _receivePort = ReceivePort();

    // Initialize isolate
    _initializeIsolate(processorFunction);
  }

  Future<void> _initializeIsolate(Future<R> Function(T data) processorFunction) async {
    try {
      _isolate = await Isolate.spawn(
        _isolateEntryPoint<T, R>,
        _IsolateConfig<T, R>(
          processorFunction: processorFunction,
          sendPort: _receivePort.sendPort,
        ).toSendPort(),
        debugName: 'IsolateProcessor_$_processorId',
      );

      // Wait for isolate to send back its SendPort
      final completer = Completer<SendPort>();
      late StreamSubscription subscription;

      subscription = _receivePort.listen((message) {
        if (message is SendPort && !completer.isCompleted) {
          completer.complete(message);
          subscription.cancel();

          // Set up the main message handler
          _receivePort.listen(_handleMessage);
        }
      });

      _sendPort = await completer.future;
      _isolatePool[_processorId] = _sendPort;

      developer.log('[IsolateProcessor] Initialized: $_processorId');
    } catch (e) {
      throw IsolateProcessorException(
        'Failed to initialize isolate processor: $e',
        processorId: _processorId,
      );
    }
  }

  /// Processes data in isolate with timeout and error handling
  Future<R> process(T data, {Duration? timeout}) async {
    if (_isDisposed) {
      throw StateError('IsolateProcessor has been disposed');
    }

    final completer = Completer<R>();
    final requestId = _generateRequestId();

    // Send request to isolate
    _sendPort.send(_IsolateRequest<T>(
      requestId: requestId,
      data: data,
      responsePort: _receivePort.sendPort,
    ).toSendPort());

    // Listen for response
    late StreamSubscription subscription;
    subscription = _receivePort.listen((message) {
      if (message is _IsolateResponse<R> && message.requestId == requestId) {
        subscription.cancel();

        if (message.error != null) {
          completer.completeError(
            IsolateProcessorException(
              message.error!,
              processorId: _processorId,
            ),
          );
        } else {
          completer.complete(message.data!);
        }
      }
    });

    // Apply timeout if specified
    if (timeout != null) {
      Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.completeError(
            TimeoutException('Isolate processing timed out after $timeout', timeout),
          );
        }
      });
    }

    return completer.future;
  }

  void _handleMessage(dynamic message) {
    // Handle other messages if needed
    if (message is String && message.startsWith('log:')) {
      developer.log('[Isolate$_processorId] ${message.substring(4)}');
    }
  }

  String _generateRequestId() {
    return '${_processorId}_${DateTime.now().millisecondsSinceEpoch}_${Object.hash(DateTime.now())}';
  }

  /// Disposes the isolate and cleans up resources
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    _receivePort.close();
    _isolatePool.remove(_processorId);

    // Send dispose signal to isolate
    _sendPort.send('dispose');

    await _isolate.kill(priority: Isolate.immediate);
    developer.log('[IsolateProcessor] Disposed: $_processorId');
  }

  /// Isolate entry point
  static void _isolateEntryPoint<T, R>(SendPort configSendPort) async {
    final configReceivePort = ReceivePort();
    configSendPort.send(configReceivePort.sendPort);

    final config = await configReceivePort.first as _IsolateConfig<T, R>;
    final processor = config.processorFunction;
    final mainSendPort = config.sendPort;

    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    await for (final message in receivePort) {
      if (message == 'dispose') {
        receivePort.close();
        configReceivePort.close();
        break;
      }

      if (message is _IsolateRequest<T>) {
        try {
          final result = await processor(message.data);
          mainSendPort.send(_IsolateResponse<R>(
            requestId: message.requestId,
            data: result,
          ).toSendPort());
        } catch (e) {
          mainSendPort.send(_IsolateResponse<R>(
            requestId: message.requestId,
            error: e.toString(),
          ).toSendPort());
        }
      }
    }
  }

  /// Gets performance metrics for all isolates
  static Map<String, dynamic> getIsolateMetrics() {
    return {
      'activeIsolates': _isolatePool.length,
      'totalCreated': _isolateCounter,
      'activeProcessorIds': _isolatePool.keys.toList(),
    };
  }
}

/// Enhanced stream management with backpressure handling
class ManagedStream<T> {
  final StreamController<T> _controller;
  final StreamSubscription<T>? _subscription;
  final Duration _bufferTimeout;
  final int _maxBufferSize;

  int _bufferSize = 0;
  Timer? _bufferTimer;

  ManagedStream({
    required Stream<T> source,
    this._bufferTimeout = const Duration(seconds: 5),
    this._maxBufferSize = 1000,
  }) : _controller = StreamController<T>.broadcast() {
    _subscription = source.listen(
      _handleData,
      onError: _handleError,
      onDone: _handleDone,
    );
  }

  void _handleData(T data) {
    if (_bufferSize >= _maxBufferSize) {
      _controller.addError(
        StreamBufferException('Buffer overflow: $_maxBufferSize items exceeded'),
      );
      return;
    }

    _bufferSize++;
    _controller.add(data);

    // Reset buffer timer
    _bufferTimer?.cancel();
    _bufferTimer = Timer(_bufferTimeout, () {
      _bufferSize = 0;
    });
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _controller.addError(error, stackTrace);
  }

  void _handleDone() {
    _bufferTimer?.cancel();
    _controller.close();
  }

  Stream<T> get stream => _controller.stream;

  Future<void> dispose() async {
    _bufferTimer?.cancel();
    await _subscription?.cancel();
    await _controller.close();
  }
}

/// Type-safe generic cache with LRU eviction
class LRUCache<K, V> {
  final int maxSize;
  final Map<K, _CacheNode<K, V>> _cache = {};
  _CacheNode<K, V>? _head;
  _CacheNode<K, V>? _tail;

  LRUCache({this.maxSize = 100});

  V? get(K key) {
    final node = _cache[key];
    if (node == null) return null;

    _moveToHead(node);
    return node.value;
  }

  void put(K key, V value) {
    final node = _cache[key];

    if (node != null) {
      node.value = value;
      _moveToHead(node);
      return;
    }

    final newNode = _CacheNode(key: key, value: value);
    _cache[key] = newNode;
    _addToHead(newNode);

    if (_cache.length > maxSize) {
      _removeTail();
    }
  }

  void remove(K key) {
    final node = _cache.remove(key);
    if (node != null) {
      _removeNode(node);
    }
  }

  void clear() {
    _cache.clear();
    _head = null;
    _tail = null;
  }

  int get size => _cache.length;

  void _moveToHead(_CacheNode<K, V> node) {
    _removeNode(node);
    _addToHead(node);
  }

  void _addToHead(_CacheNode<K, V> node) {
    node.prev = null;
    node.next = _head;

    if (_head != null) {
      _head!.prev = node;
    }
    _head = node;

    if (_tail == null) {
      _tail = node;
    }
  }

  void _removeNode(_CacheNode<K, V> node) {
    if (node.prev != null) {
      node.prev!.next = node.next;
    } else {
      _head = node.next;
    }

    if (node.next != null) {
      node.next!.prev = node.prev;
    } else {
      _tail = node.prev;
    }
  }

  void _removeTail() {
    if (_tail != null) {
      _cache.remove(_tail!.key);
      _removeNode(_tail!);
    }
  }
}

/// Cache node for LRU implementation
class _CacheNode<K, V> {
  final K key;
  V value;
  _CacheNode<K, V>? prev;
  _CacheNode<K, V>? next;

  _CacheNode({required this.key, required this.value});
}

/// Enhanced error handling utilities
class ErrorRecovery {
  static final Map<Type, List<ErrorHandler>> _handlers = {};

  /// Registers an error handler for a specific exception type
  static void registerHandler<T extends Exception>(ErrorHandler handler) {
    _handlers.putIfAbsent(T, () => []).add(handler);
  }

  /// Attempts to recover from an error using registered handlers
  static Future<ErrorRecoveryResult> recover<T extends Exception>(
    T error, {
    int maxAttempts = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    final handlers = _handlers[T] ?? [];

    if (handlers.isEmpty) {
      return ErrorRecoveryResult.failure(
        'No recovery handlers registered for ${T.runtimeType}',
      );
    }

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      for (final handler in handlers) {
        try {
          final result = await handler.handle(error, attempt);
          if (result.success) {
            return result;
          }
        } catch (e) {
          developer.log('[ErrorRecovery] Handler failed: $e');
        }
      }

      if (attempt < maxAttempts) {
        await Future.delayed(retryDelay * attempt);
      }
    }

    return ErrorRecoveryResult.failure(
      'All recovery attempts failed after $maxAttempts tries',
    );
  }
}

/// Error handler interface
abstract class ErrorHandler {
  Future<ErrorRecoveryResult> handle(Exception error, int attempt);
}

/// Error recovery result
class ErrorRecoveryResult {
  const ErrorRecoveryResult.success(this.message) : _success = true;
  const ErrorRecoveryResult.failure(this.message) : _success = false;

  final bool _success;
  final String message;

  bool get success => _success;
  bool get failure => !_success;

  @override
  String toString() => 'ErrorRecoveryResult.${success ? 'success' : 'failure'}: $message';
}

/// Performance monitoring utilities
class PerformanceMonitor {
  static final Map<String, PerformanceMetric> _metrics = {};
  static final List<PerformanceListener> _listeners = [];

  /// Records a performance metric
  static void recordMetric(
    String name,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final metric = PerformanceMetric(
      name: name,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _metrics[name] = metric;
    _notifyListeners(metric);
  }

  /// Gets a performance metric by name
  static PerformanceMetric? getMetric(String name) => _metrics[name];

  /// Gets all recorded metrics
  static Map<String, PerformanceMetric> getAllMetrics() => Map.from(_metrics);

  /// Adds a performance listener
  static void addListener(PerformanceListener listener) {
    _listeners.add(listener);
  }

  /// Removes a performance listener
  static void removeListener(PerformanceListener listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners(PerformanceMetric metric) {
    for (final listener in _listeners) {
      try {
        listener.onMetricRecorded(metric);
      } catch (e) {
        developer.log('[PerformanceMonitor] Listener error: $e');
      }
    }
  }

  /// Measures execution time of a function
  static Future<T> measure<T>(
    String name,
    Future<T> Function() function, {
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await function();
      stopwatch.stop();

      recordMetric(name, stopwatch.elapsed, metadata: metadata);
      return result;
    } catch (e) {
      stopwatch.stop();

      recordMetric(
        '${name}_error',
        stopwatch.elapsed,
        metadata: {...?metadata, 'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Measures execution time of a synchronous function
  static T measureSync<T>(
    String name,
    T Function() function, {
    Map<String, dynamic>? metadata,
  }) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = function();
      stopwatch.stop();

      recordMetric(name, stopwatch.elapsed, metadata: metadata);
      return result;
    } catch (e) {
      stopwatch.stop();

      recordMetric(
        '${name}_error',
        stopwatch.elapsed,
        metadata: {...?metadata, 'error': e.toString()},
      );
      rethrow;
    }
  }
}

/// Performance metric data class
class PerformanceMetric {
  const PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });

  final String name;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  @override
  String toString() => 'PerformanceMetric('
      'name: $name, '
      'duration: ${duration.inMilliseconds}ms, '
      'timestamp: $timestamp'
      ')';
}

/// Performance listener interface
abstract class PerformanceListener {
  void onMetricRecorded(PerformanceMetric metric);
}

/// Memory-efficient byte buffer utilities
class ByteBuffer {
  Uint8List _buffer;
  int _position = 0;
  int _limit;

  ByteBuffer(int initialSize) : _buffer = Uint8List(initialSize), _limit = initialSize;

  ByteBuffer.fromList(Uint8List data)
      : _buffer = Uint8List.fromList(data),
        _limit = data.length;

  int get position => _position;
  int get remaining => _limit - _position;

  void writeByte(int value) {
    _ensureCapacity(1);
    _buffer[_position++] = value;
  }

  void writeBytes(Uint8List bytes) {
    _ensureCapacity(bytes.length);
    _buffer.setRange(_position, _position + bytes.length, bytes);
    _position += bytes.length;
  }

  void writeString(String value) {
    final bytes = utf8.encode(value);
    writeInt(bytes.length);
    writeBytes(Uint8List.fromList(bytes));
  }

  int readByte() {
    if (_position >= _limit) {
      throw RangeError('No more bytes to read');
    }
    return _buffer[_position++];
  }

  Uint8List readBytes(int length) {
    if (_position + length > _limit) {
      throw RangeError('Not enough bytes to read');
    }

    final bytes = Uint8List(length);
    bytes.setRange(0, length, _buffer, _position);
    _position += length;
    return bytes;
  }

  String readString() {
    final length = readInt();
    final bytes = readBytes(length);
    return utf8.decode(bytes);
  }

  void writeInt(int value) {
    _ensureCapacity(4);
    _buffer[_position++] = (value >> 24) & 0xFF;
    _buffer[_position++] = (value >> 16) & 0xFF;
    _buffer[_position++] = (value >> 8) & 0xFF;
    _buffer[_position++] = value & 0xFF;
  }

  int readInt() {
    if (_position + 4 > _limit) {
      throw RangeError('Not enough bytes to read int');
    }

    return (_buffer[_position++] << 24) |
           (_buffer[_position++] << 16) |
           (_buffer[_position++] << 8) |
           _buffer[_position++];
  }

  void _ensureCapacity(int required) {
    if (_position + required > _buffer.length) {
      final newSize = (_buffer.length * 2).clamp(_position + required, 1024 * 1024);
      final newBuffer = Uint8List(newSize);
      newBuffer.setRange(0, _limit, _buffer);
      _buffer = newBuffer;
      _limit = _position;
    }
  }

  Uint8List toBytes() {
    return Uint8List.fromList(_buffer.sublist(0, _limit));
  }

  void reset() {
    _position = 0;
    _limit = _buffer.length;
  }
}

// Internal data structures for isolate communication

class _IsolateConfig<T, R> {
  final Future<R> Function(T data) processorFunction;
  final SendPort sendPort;

  _IsolateConfig({
    required this.processorFunction,
    required this.sendPort,
  });

  SendPort toSendPort() => sendPort;
}

class _IsolateRequest<T> {
  final String requestId;
  final T data;
  final SendPort responsePort;

  _IsolateRequest({
    required this.requestId,
    required this.data,
    required this.responsePort,
  });

  SendPort toSendPort() => responsePort;
}

class _IsolateResponse<R> {
  final String requestId;
  final R? data;
  final String? error;

  _IsolateResponse({
    required this.requestId,
    this.data,
    this.error,
  });

  SendPort toSendPort() => throw UnsupportedError('Response cannot be sent back');
}

/// Custom exceptions

class IsolateProcessorException implements Exception {
  const IsolateProcessorException(this.message, {this.processorId});

  final String message;
  final String? processorId;

  @override
  String toString() => 'IsolateProcessorException: $message${processorId != null ? ' (Processor: $processorId)' : ''}';
}

class StreamBufferException implements Exception {
  const StreamBufferException(this.message);

  final String message;

  @override
  String toString() => 'StreamBufferException: $message';
}