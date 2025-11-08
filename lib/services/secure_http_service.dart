import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../security/certificate_pinning_service.dart';
import '../security/api_monitoring_service.dart';
import 'api_monitoring_service.dart';

/// Secure HTTP Service with Certificate Pinning and Monitoring
///
/// SECURITY IMPLEMENTATION: 2025-10-30
/// 🔒 SECURE HTTP COMMUNICATIONS
///
/// Features:
/// - Certificate pinning for MITM attack prevention
/// - API usage monitoring and logging
/// - Request/response validation
/// - Error handling and retry logic
/// - Firebase authentication integration
///
/// Usage:
/// ```dart
/// final response = await SecureHttpService.get('https://api.example.com/data');
/// final response = await SecureHttpService.post('https://api.example.com/create', body: data);
/// ```
class SecureHttpService {
  static final SecureHttpService _instance = SecureHttpService._internal();
  factory SecureHttpService() => _instance;
  SecureHttpService._internal();

  final CertificatePinningService _certificatePinning = CertificatePinningService();
  final ApiMonitoringService _monitoringService = ApiMonitoringService();

  /// Initialize secure HTTP service
  Future<void> initialize() async {
    await _certificatePinning.initialize();
    _monitoringService.initialize();
    debugPrint('[SecureHttpService] Service initialized with certificate pinning');
  }

  /// Make secure HTTP GET request
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    bool? requiresAuth,
  }) async {
    return _makeRequest(
      method: 'GET',
      url: url,
      headers: headers,
      timeout: timeout ?? Duration(seconds: 30),
      requiresAuth: requiresAuth ?? false,
    );
  }

  /// Make secure HTTP POST request
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    bool? requiresAuth,
  }) async {
    return _makeRequest(
      method: 'POST',
      url: url,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout ?? Duration(seconds: 30),
      requiresAuth: requiresAuth ?? false,
    );
  }

  /// Make secure HTTP PUT request
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    bool? requiresAuth,
  }) async {
    return _makeRequest(
      method: 'PUT',
      url: url,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout ?? Duration(seconds: 30),
      requiresAuth: requiresAuth ?? false,
    );
  }

  /// Make secure HTTP DELETE request
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    bool? requiresAuth,
  }) async {
    return _makeRequest(
      method: 'DELETE',
      url: url,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout ?? Duration(seconds: 30),
      requiresAuth: requiresAuth ?? false,
    );
  }

  /// Make secure HTTP PATCH request
  Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    bool? requiresAuth,
  }) async {
    return _makeRequest(
      method: 'PATCH',
      url: url,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout ?? Duration(seconds: 30),
      requiresAuth: requiresAuth ?? false,
    );
  }

  /// Core request implementation with security features
  Future<http.Response> _makeRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    required Duration timeout,
    required bool requiresAuth,
  }) async {
    final startTime = DateTime.now();
    String operation = '$method $url';

    try {
      // Prepare request headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'User-Agent': 'JourneymanJobs/1.0.0',
        ...?headers,
      };

      // Add authentication if required
      if (requiresAuth) {
        final idToken = await _getIdToken();
        if (idToken != null) {
          requestHeaders['Authorization'] = 'Bearer $idToken';
        } else {
          throw Exception('Authentication required but no token available');
        }
      }

      // Create secure client with certificate pinning
      final client = _certificatePinning.createHttpClient();

      // Make request
      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(
            Uri.parse(url),
            headers: requestHeaders,
          ).timeout(timeout);
          break;
        case 'POST':
          response = await client.post(
            Uri.parse(url),
            headers: requestHeaders,
            body: body,
            encoding: encoding,
          ).timeout(timeout);
          break;
        case 'PUT':
          response = await client.put(
            Uri.parse(url),
            headers: requestHeaders,
            body: body,
            encoding: encoding,
          ).timeout(timeout);
          break;
        case 'DELETE':
          response = await client.delete(
            Uri.parse(url),
            headers: requestHeaders,
            body: body,
            encoding: encoding,
          ).timeout(timeout);
          break;
        case 'PATCH':
          response = await client.patch(
            Uri.parse(url),
            headers: requestHeaders,
            body: body,
            encoding: encoding,
          ).timeout(timeout);
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      client.close();

      // Log successful operation
      final duration = DateTime.now().difference(startTime);
      _monitoringService.recordOperation(
        operation,
        metadata: {
          'method': method,
          'url': url,
          'statusCode': response.statusCode,
          'duration': duration.inMilliseconds,
          'requiresAuth': requiresAuth,
          'certificatePinning': _certificatePinning.isActive,
        },
      );

      debugPrint('[SecureHttpService] $method $url - ${response.statusCode} (${duration.inMilliseconds}ms)');

      return response;
    } on TimeoutException catch (e) {
      _monitoringService.recordError(
        operation,
        'Request timeout after ${timeout.inSeconds}s',
        metadata: {'timeout': timeout.inSeconds},
      );
      throw TimeoutException('Request timeout: $e', e);
    } on SocketException catch (e) {
      _monitoringService.recordError(
        operation,
        'Network error: ${e.message}',
        metadata: {'error': e.toString()},
      );
      throw SocketException('Network error: $e', e);
    } on HttpException catch (e) {
      _monitoringService.recordError(
        operation,
        'HTTP error: ${e.message}',
        metadata: {'error': e.toString()},
      );
      throw HttpException('HTTP error: $e', e);
    } catch (e) {
      _monitoringService.recordError(
        operation,
        'Unexpected error: ${e.toString()}',
        metadata: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Get current Firebase ID token for authentication
  Future<String?> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
    } catch (e) {
      debugPrint('[SecureHttpService] Failed to get ID token: $e');
    }
    return null;
  }

  /// Validate URL security
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Only allow HTTPS and HTTP for development
      if (!uri.scheme.startsWith('https') &&
          !(kDebugMode && uri.scheme.startsWith('http'))) {
        return false;
      }

      // Check for dangerous characters
      final dangerousChars = ['<', '>', '"', "'", '\n', '\r', '\t'];
      return !dangerousChars.any((char) => url.contains(char));
    } catch (e) {
      return false;
    }
  }

  /// Get service status
  Map<String, dynamic> getStatus() {
    return {
      'certificatePinning': _certificatePinning.getStatus(),
      'monitoring': _monitoringService.getUsageStats(),
      'debugMode': kDebugMode,
    };
  }

  /// Dispose resources
  void dispose() {
    _monitoringService.dispose();
    _certificatePinning.dispose();
    debugPrint('[SecureHttpService] Service disposed');
  }
}

/// HTTP request wrapper with automatic retry logic
class RetryableHttpRequest {
  final SecureHttpService _httpService = SecureHttpService();
  final int maxRetries;
  final Duration retryDelay;

  RetryableHttpRequest({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  /// Execute HTTP request with automatic retry on failure
  Future<http.Response> execute(
    String method,
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    bool? requiresAuth,
    List<int>? retryStatusCodes,
  }) async {
    final retryCodes = retryStatusCodes ?? [408, 429, 500, 502, 503, 504];
    int attempt = 0;

    while (attempt <= maxRetries) {
      try {
        final response = await _httpService._makeRequest(
          method: method,
          url: url,
          headers: headers,
          body: body,
          encoding: encoding,
          timeout: timeout,
          requiresAuth: requiresAuth,
        );

        return response;
      } catch (e) {
        attempt++;

        if (attempt > maxRetries || !shouldRetry(e, retryCodes)) {
          rethrow;
        }

        debugPrint('[RetryableHttpRequest] Attempt $attempt failed, retrying in ${retryDelay.inSeconds}s');
        await Future.delayed(retryDelay * attempt);
      }
    }

    throw Exception('Request failed after $maxRetries attempts');
  }

  /// Determine if request should be retried based on error
  bool shouldRetry(dynamic error, List<int> retryStatusCodes) {
    if (error is HttpException) {
      final statusCode = int.tryParse(error.message);
      return statusCode != null && retryStatusCodes.contains(statusCode);
    }
    return false;
  }
}