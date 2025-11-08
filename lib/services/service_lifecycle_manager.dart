import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'interfaces/i_error_manager.dart';
import 'interfaces/i_performance_monitor.dart';

/// Service lifecycle manager for coordinated service initialization and disposal
///
/// Manages the lifecycle of all app services to prevent initialization race conditions
/// and ensure proper cleanup. Handles dependencies between services and provides
/// graceful degradation when services fail to initialize.
class ServiceLifecycleManager {
  static final ServiceLifecycleManager _instance = ServiceLifecycleManager._internal();
  factory ServiceLifecycleManager() => _instance;
  ServiceLifecycleManager._internal();

  // Service states
  final Map<String, ServiceState> _services = {};
  final Map<String, List<String>> _dependencies = {};
  final List<ServiceLifecycleListener> _listeners = [];

  // Initialization state
  bool _isInitialized = false;
  bool _isInitializing = false;
  DateTime? _initializationStartTime;

  /// Add a service to be managed
  void registerService(
    String name,
    ServiceFactory factory, {
    List<String> dependencies = const [],
    ServicePriority priority = ServicePriority.normal,
    bool required = false,
  }) {
    if (_services.containsKey(name)) {
      debugPrint('[ServiceLifecycleManager] Service $name already registered');
      return;
    }

    _services[name] = ServiceState(
      name: name,
      factory: factory,
      priority: priority,
      required: required,
    );

    _dependencies[name] = dependencies;

    debugPrint('[ServiceLifecycleManager] Registered service: $name');
    if (dependencies.isNotEmpty) {
      debugPrint('[ServiceLifecycleManager] Dependencies: ${dependencies.join(', ')}');
    }
  }

  /// Initialize all registered services
  Future<ServiceInitializationResult> initializeAll() async {
    if (_isInitialized || _isInitializing) {
      return ServiceInitializationResult(
        success: _isInitialized,
        initializedServices: _services.values
            .where((s) => s.status == ServiceStatus.initialized)
            .map((s) => s.name)
            .toList(),
        failedServices: _services.values
            .where((s) => s.status == ServiceStatus.failed)
            .map((s) => s.name)
            .toList(),
      );
    }

    _isInitializing = true;
    _initializationStartTime = DateTime.now();

    debugPrint('[ServiceLifecycleManager] Starting service initialization...');

    try {
      // Wait for Firebase to be ready
      await _waitForFirebaseInitialization();

      // Initialize services in dependency order
      final result = await _initializeServicesInOrder();

      _isInitialized = true;
      _isInitializing = false;

      debugPrint('[ServiceLifecycleManager] Service initialization completed in '
          '${DateTime.now().difference(_initializationStartTime!).inMilliseconds}ms');

      return result;
    } catch (e, stackTrace) {
      debugPrint('[ServiceLifecycleManager] Service initialization failed: $e');
      debugPrint('[ServiceLifecycleManager] Stack trace: $stackTrace');

      _isInitializing = false;

      // Attempt graceful degradation
      await _attemptGracefulDegradation();

      return ServiceInitializationResult(
        success: false,
        initializedServices: _services.values
            .where((s) => s.status == ServiceStatus.initialized)
            .map((s) => s.name)
            .toList(),
        failedServices: _services.values
            .where((s) => s.status == ServiceStatus.failed)
            .map((s) => s.name)
            .toList(),
        error: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  /// Wait for Firebase to be initialized
  Future<void> _waitForFirebaseInitialization() async {
    const maxWaitTime = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 100);

    final startTime = DateTime.now();

    while (Firebase.apps.isEmpty) {
      if (DateTime.now().difference(startTime) > maxWaitTime) {
        debugPrint('[ServiceLifecycleManager] Firebase initialization timeout');
        break;
      }

      await Future.delayed(checkInterval);
    }

    if (Firebase.apps.isNotEmpty) {
      debugPrint('[ServiceLifecycleManager] Firebase initialized successfully');
    } else {
      debugPrint('[ServiceLifecycleManager] Firebase not initialized, continuing in offline mode');
    }
  }

  /// Initialize services in dependency order
  Future<ServiceInitializationResult> _initializeServicesInOrder() async {
    final initializedServices = <String>[];
    final failedServices = <String>[];
    final errors = <String, String>{};

    // Sort services by priority and dependencies
    final sortedServices = _topologicalSort();

    for (final serviceName in sortedServices) {
      final service = _services[serviceName]!;

      // Check if dependencies are satisfied
      final dependencies = _dependencies[serviceName] ?? [];
      if (dependencies.any((dep) => !initializedServices.contains(dep))) {
        debugPrint('[ServiceLifecycleManager] Skipping $serviceName - dependencies not satisfied');
        continue;
      }

      try {
        debugPrint('[ServiceLifecycleManager] Initializing service: $serviceName');
        await _initializeService(service);
        initializedServices.add(serviceName);
        debugPrint('[ServiceLifecycleManager] Service $serviceName initialized successfully');
      } catch (e) {
        debugPrint('[ServiceLifecycleManager] Failed to initialize service $serviceName: $e');
        failedServices.add(serviceName);
        errors[serviceName] = e.toString();

        if (service.required) {
          // Required service failed - rethrow
          rethrow;
        } else {
          // Optional service failed - continue
          debugPrint('[ServiceLifecycleManager] Optional service $serviceName failed, continuing...');
        }
      }
    }

    return ServiceInitializationResult(
      success: failedServices.isEmpty || !failedServices.any((name) => _services[name]!.required),
      initializedServices: initializedServices,
      failedServices: failedServices,
      errors: errors,
    );
  }

  /// Initialize a single service
  Future<void> _initializeService(ServiceState service) async {
    service.status = ServiceStatus.initializing;
    _notifyListeners(ServiceLifecycleEvent.serviceInitializing(service.name));

    try {
      service.instance = await service.factory.create();
      service.status = ServiceStatus.initialized;
      _notifyListeners(ServiceLifecycleEvent.serviceInitialized(service.name));
    } catch (e) {
      service.status = ServiceStatus.failed;
      service.error = e.toString();
      _notifyListeners(ServiceLifecycleEvent.serviceFailed(service.name, e.toString()));
      rethrow;
    }
  }

  /// Topological sort to resolve dependencies
  List<String> _topologicalSort() {
    final visited = <String>{};
    final result = <String>[];
    final temp = <String>{};

    void visit(String node) {
      if (temp.contains(node)) {
        throw StateError('Circular dependency detected involving $node');
      }
      if (visited.contains(node)) return;

      temp.add(node);
      for (final dep in _dependencies[node] ?? []) {
        visit(dep);
      }
      temp.remove(node);
      visited.add(node);
      result.add(node);
    }

    for (final service in _services.keys) {
      visit(service);
    }

    // Sort by priority within dependency constraints
    result.sort((a, b) {
      final priorityA = _services[a]!.priority.index;
      final priorityB = _services[b]!.priority.index;
      return priorityB.compareTo(priorityA); // Higher priority first
    });

    return result;
  }

  /// Attempt graceful degradation when services fail
  Future<void> _attemptGracefulDegradation() async {
    debugPrint('[ServiceLifecycleManager] Attempting graceful degradation...');

    // Initialize only critical services
    final criticalServices = _services.entries
        .where((entry) => entry.value.required)
        .map((entry) => entry.key)
        .toList();

    for (final serviceName in criticalServices) {
      final service = _services[serviceName]!;
      if (service.status == ServiceStatus.failed) {
        try {
          debugPrint('[ServiceLifecycleManager] Retrying critical service: $serviceName');
          await _initializeService(service);
        } catch (e) {
          debugPrint('[ServiceLifecycleManager] Critical service $serviceName failed permanently: $e');
        }
      }
    }
  }

  /// Get a service instance
  T? getService<T>(String name) {
    final service = _services[name];
    if (service?.status == ServiceStatus.initialized) {
      return service?.instance as T?;
    }
    return null;
  }

  /// Check if a service is initialized
  bool isServiceInitialized(String name) {
    return _services[name]?.status == ServiceStatus.initialized;
  }

  /// Dispose all services
  Future<void> disposeAll() async {
    debugPrint('[ServiceLifecycleManager] Disposing all services...');

    // Dispose in reverse order of initialization
    final servicesToDispose = _services.values
        .where((s) => s.status == ServiceStatus.initialized)
        .toList()
        .reversed;

    for (final service in servicesToDispose) {
      try {
        if (service.instance is dynamic) {
          dynamic instance = service.instance;
          if (instance.dispose != null) {
            await instance.dispose();
          }
        }
        service.status = ServiceStatus.disposed;
        debugPrint('[ServiceLifecycleManager] Disposed service: ${service.name}');
      } catch (e) {
        debugPrint('[ServiceLifecycleManager] Failed to dispose service ${service.name}: $e');
      }
    }

    _services.clear();
    _dependencies.clear();
    _listeners.clear();
    _isInitialized = false;

    debugPrint('[ServiceLifecycleManager] All services disposed');
  }

  /// Add a lifecycle listener
  void addListener(ServiceLifecycleListener listener) {
    _listeners.add(listener);
  }

  /// Remove a lifecycle listener
  void removeListener(ServiceLifecycleListener listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of an event
  void _notifyListeners(ServiceLifecycleEvent event) {
    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        debugPrint('[ServiceLifecycleManager] Listener error: $e');
      }
    }
  }

  /// Get initialization status
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  DateTime? get initializationStartTime => _initializationStartTime;
}

/// Service state information
class ServiceState {
  final String name;
  final ServiceFactory factory;
  final ServicePriority priority;
  final bool required;

  ServiceStatus status = ServiceStatus.registered;
  dynamic instance;
  String? error;

  ServiceState({
    required this.name,
    required this.factory,
    required this.priority,
    required this.required,
  });
}

/// Service factory for creating service instances
abstract class ServiceFactory<T> {
  Future<T> create();
}

/// Service status enumeration
enum ServiceStatus {
  registered,
  initializing,
  initialized,
  failed,
  disposed,
}

/// Service priority enumeration
enum ServicePriority {
  critical,  // Initialize first
  high,      // Initialize early
  normal,    // Initialize in normal order
  low,       // Initialize last
}

/// Service initialization result
class ServiceInitializationResult {
  final bool success;
  final List<String> initializedServices;
  final List<String> failedServices;
  final Map<String, String>? errors;
  final String? error;
  final StackTrace? stackTrace;

  ServiceInitializationResult({
    required this.success,
    required this.initializedServices,
    required this.failedServices,
    this.errors,
    this.error,
    this.stackTrace,
  });
}

/// Service lifecycle event
class ServiceLifecycleEvent {
  final String serviceName;
  final ServiceEventType type;
  final String? error;

  ServiceLifecycleEvent._(this.serviceName, this.type, {this.error});

  factory ServiceLifecycleEvent.serviceInitializing(String name) =>
      ServiceLifecycleEvent._(name, ServiceEventType.initializing);

  factory ServiceLifecycleEvent.serviceInitialized(String name) =>
      ServiceLifecycleEvent._(name, ServiceEventType.initialized);

  factory ServiceLifecycleEvent.serviceFailed(String name, String error) =>
      ServiceLifecycleEvent._(name, ServiceEventType.failed, error: error);

  factory ServiceLifecycleEvent.serviceDisposed(String name) =>
      ServiceLifecycleEvent._(name, ServiceEventType.disposed);
}

/// Service lifecycle event type
enum ServiceEventType {
  initializing,
  initialized,
  failed,
  disposed,
}

/// Service lifecycle listener
typedef ServiceLifecycleListener = void Function(ServiceLifecycleEvent event);