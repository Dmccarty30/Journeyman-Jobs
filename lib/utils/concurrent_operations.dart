import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Operation types for queuing and synchronization
enum OperationType {
  loadJobs,
  loadLocals,
  loadUserProfile,
  updateUserProfile,
  signIn,
  signOut,
  refreshData,
}

/// Queued operation data structure
class QueuedOperation {
  final String id;
  final OperationType type;
  final Map<String, dynamic> parameters;
  final Completer<dynamic> completer;
  final DateTime createdAt;
  final int priority;

  QueuedOperation({
    required this.id,
    required this.type,
    this.parameters = const {},
    required this.completer,
    int? priority,
  }) : createdAt = DateTime.now(),
       priority = priority ?? _getDefaultPriority(type);

  static int _getDefaultPriority(OperationType type) {
    switch (type) {
      case OperationType.signIn:
      case OperationType.signOut:
        return 100; // Highest priority
      case OperationType.updateUserProfile:
        return 80;
      case OperationType.loadUserProfile:
        return 70;
      case OperationType.refreshData:
        return 60;
      case OperationType.loadJobs:
      case OperationType.loadLocals:
        return 50; // Normal priority
    }
  }

  @override
  String toString() => 'QueuedOperation(id: $id, type: $type, priority: $priority)';
}

/// Transaction state for atomic operations
class TransactionState {
  final String transactionId;
  final Map<String, dynamic> originalState;
  final Map<String, dynamic> pendingChanges;
  final DateTime startTime;
  bool isCommitted = false;
  bool isRolledBack = false;

  TransactionState({
    required this.transactionId,
    required this.originalState,
  }) : pendingChanges = {},
       startTime = DateTime.now();

  void addChange(String key, dynamic value) {
    if (isCommitted || isRolledBack) {
      throw StateError('Cannot modify committed or rolled back transaction');
    }
    pendingChanges[key] = value;
  }

  void commit() {
    if (isCommitted || isRolledBack) {
      throw StateError('Transaction already finalized');
    }
    isCommitted = true;
  }

  void rollback() {
    if (isCommitted || isRolledBack) {
      throw StateError('Transaction already finalized');
    }
    isRolledBack = true;
  }

  Duration get duration => DateTime.now().difference(startTime);

  @override
  String toString() => 'Transaction(id: $transactionId, changes: ${pendingChanges.length}, committed: $isCommitted)';
}

/// Concurrent operation manager with queuing and synchronization
class ConcurrentOperationManager {
  static const int maxConcurrentOperations = 3;
  static const Duration operationTimeout = Duration(seconds: 30);
  static const Duration lockTimeout = Duration(seconds: 10);

  // Operation queue with priority
  final Queue<QueuedOperation> _operationQueue = Queue<QueuedOperation>();
  
  // Currently running operations
  final Map<String, QueuedOperation> _runningOperations = {};
  
  // Resource locks to prevent conflicts
  final Map<String, Completer<void>> _resourceLocks = {};
  
  // Active transactions
  final Map<String, TransactionState> _activeTransactions = {};
  
  // Operation statistics
  int _completedOperations = 0;
  int _failedOperations = 0;
  int _timeoutOperations = 0;

  /// Check if an operation of a specific type is currently in progress
  bool isOperationInProgress(OperationType type) {
    return _runningOperations.values.any((op) => op.type == type) ||
           _operationQueue.any((op) => op.type == type);
  }

  /// Execute an operation directly (wrapper around queueOperation for compatibility)
  Future<T> executeOperation<T>({
    required OperationType type,
    Map<String, dynamic> parameters = const {},
    int? priority,
    Duration? timeout,
    required Future<T> Function() operation,
  }) async {
    return queueOperation<T>(
      type: type,
      parameters: parameters,
      priority: priority,
      timeout: timeout,
      operation: operation,
    );
  }

  /// Queue an operation for execution
  Future<T> queueOperation<T>({
    required OperationType type,
    Map<String, dynamic> parameters = const {},
    int? priority,
    Duration? timeout,
    required Future<T> Function() operation,
  }) async {
    final operationId = _generateOperationId(type);
    final completer = Completer<T>();
    
    final queuedOp = QueuedOperation(
      id: operationId,
      type: type,
      parameters: parameters,
      completer: completer,
      priority: priority,
    );

    // Add to priority queue
    _addToQueue(queuedOp);
    
    if (kDebugMode) {
      print('ConcurrentOperationManager: Queued operation $operationId (${type.name})');
    }

    // Start processing if possible
    _processQueue();

    // Set up timeout
    final timeoutDuration = timeout ?? operationTimeout;
    Timer(timeoutDuration, () {
      if (!completer.isCompleted) {
        _timeoutOperations++;
        _runningOperations.remove(operationId);
        completer.completeError(TimeoutException('Operation timed out', timeoutDuration));
        _processQueue();
      }
    });

    // Execute the operation when it's dequeued
    completer.future.then((_) {
      _completedOperations++;
    }).catchError((error) {
      _failedOperations++;
      if (kDebugMode) {
        print('ConcurrentOperationManager: Operation $operationId failed - $error');
      }
    });

    // Store the operation function for later execution
    _setupOperationExecution(queuedOp, operation);

    return completer.future;
  }

  /// Add operation to priority queue
  void _addToQueue(QueuedOperation operation) {
    // Insert in priority order (higher priority first)
    bool inserted = false;
    final tempList = _operationQueue.toList();
    _operationQueue.clear();

    for (int i = 0; i < tempList.length; i++) {
      if (!inserted && operation.priority > tempList[i].priority) {
        _operationQueue.add(operation);
        inserted = true;
      }
      _operationQueue.add(tempList[i]);
    }

    if (!inserted) {
      _operationQueue.add(operation);
    }
  }

  /// Process the operation queue
  void _processQueue() {
    while (_operationQueue.isNotEmpty && _runningOperations.length < maxConcurrentOperations) {
      final operation = _operationQueue.removeFirst();
      
      // Check if operation type conflicts with running operations
      if (_hasConflict(operation)) {
        // Put back at front of queue and stop processing
        _operationQueue.addFirst(operation);
        break;
      }

      _runningOperations[operation.id] = operation;
      
      if (kDebugMode) {
        print('ConcurrentOperationManager: Starting operation ${operation.id} (${operation.type.name})');
      }

      // The actual execution is handled by _setupOperationExecution
    }
  }

  /// Check if operation conflicts with running operations
  bool _hasConflict(QueuedOperation operation) {
    for (final running in _runningOperations.values) {
      if (_operationsConflict(operation.type, running.type)) {
        return true;
      }
    }
    return false;
  }

  /// Determine if two operation types conflict
  bool _operationsConflict(OperationType op1, OperationType op2) {
    // Authentication operations are exclusive
    if ([OperationType.signIn, OperationType.signOut].contains(op1) ||
        [OperationType.signIn, OperationType.signOut].contains(op2)) {
      return op1 != op2;
    }

    // Profile updates conflict with profile loads
    if ((op1 == OperationType.updateUserProfile && op2 == OperationType.loadUserProfile) ||
        (op1 == OperationType.loadUserProfile && op2 == OperationType.updateUserProfile)) {
      return true;
    }

    // Refresh operations conflict with specific loads
    if (op1 == OperationType.refreshData || op2 == OperationType.refreshData) {
      return true;
    }

    return false;
  }

  /// Set up operation execution
  void _setupOperationExecution<T>(QueuedOperation queuedOp, Future<T> Function() operation) {
    // This will be called when the operation is actually ready to run
    Timer.run(() async {
      if (!_runningOperations.containsKey(queuedOp.id)) {
        return; // Operation was cancelled or timed out
      }

      try {
        final result = await operation();
        if (!queuedOp.completer.isCompleted) {
          queuedOp.completer.complete(result);
        }
      } catch (error) {
        if (!queuedOp.completer.isCompleted) {
          queuedOp.completer.completeError(error);
        }
      } finally {
        _runningOperations.remove(queuedOp.id);
        _processQueue(); // Process next operations
      }
    });
  }

  /// Start a transaction for atomic state updates
  Future<String> startTransaction(Map<String, dynamic> currentState) async {
    final transactionId = _generateTransactionId();
    
    _activeTransactions[transactionId] = TransactionState(
      transactionId: transactionId,
      originalState: Map<String, dynamic>.from(currentState),
    );

    if (kDebugMode) {
      print('ConcurrentOperationManager: Started transaction $transactionId');
    }

    return transactionId;
  }

  /// Add a change to an active transaction
  void addTransactionChange(String transactionId, String key, dynamic value) {
    final transaction = _activeTransactions[transactionId];
    if (transaction == null) {
      throw ArgumentError('Transaction $transactionId not found');
    }

    transaction.addChange(key, value);
  }

  /// Commit a transaction and apply all changes atomically
  Future<Map<String, dynamic>> commitTransaction(String transactionId) async {
    final transaction = _activeTransactions[transactionId];
    if (transaction == null) {
      throw ArgumentError('Transaction $transactionId not found');
    }

    try {
      transaction.commit();
      
      // Apply all changes atomically
      final finalState = Map<String, dynamic>.from(transaction.originalState);
      finalState.addAll(transaction.pendingChanges);

      if (kDebugMode) {
        print('ConcurrentOperationManager: Committed transaction $transactionId with ${transaction.pendingChanges.length} changes');
      }

      return finalState;
    } finally {
      _activeTransactions.remove(transactionId);
    }
  }

  /// Rollback a transaction
  Future<Map<String, dynamic>> rollbackTransaction(String transactionId) async {
    final transaction = _activeTransactions[transactionId];
    if (transaction == null) {
      throw ArgumentError('Transaction $transactionId not found');
    }

    try {
      transaction.rollback();
      
      if (kDebugMode) {
        print('ConcurrentOperationManager: Rolled back transaction $transactionId');
      }

      return Map<String, dynamic>.from(transaction.originalState);
    } finally {
      _activeTransactions.remove(transactionId);
    }
  }

  /// Acquire a resource lock
  Future<void> acquireResourceLock(String resource) async {
    // Use local reference to avoid race condition
    final existingLock = _resourceLocks[resource];
    if (existingLock != null) {
      // Wait for existing lock to be released
      try {
        await existingLock.future.timeout(lockTimeout);
      } on TimeoutException {
        if (kDebugMode) {
          print('ConcurrentOperationManager: Lock timeout for resource: $resource');
        }
        throw Exception('Resource lock timeout for: $resource');
      }
    }

    _resourceLocks[resource] = Completer<void>();
    
    if (kDebugMode) {
      print('ConcurrentOperationManager: Acquired lock for resource: $resource');
    }
  }

  /// Release a resource lock
  void releaseResourceLock(String resource) {
    final completer = _resourceLocks.remove(resource);
    if (completer != null && !completer.isCompleted) {
      completer.complete();
      
      if (kDebugMode) {
        print('ConcurrentOperationManager: Released lock for resource: $resource');
      }
    }
  }

  /// Cancel all pending operations
  void cancelAllOperations() {
    // Cancel queued operations
    while (_operationQueue.isNotEmpty) {
      final operation = _operationQueue.removeFirst();
      if (!operation.completer.isCompleted) {
        operation.completer.completeError(Exception('Operation cancelled'));
      }
    }

    // Cancel running operations (they'll handle the cancellation)
    for (final operation in _runningOperations.values) {
      if (!operation.completer.isCompleted) {
        operation.completer.completeError(Exception('Operation cancelled'));
      }
    }
    _runningOperations.clear();

    if (kDebugMode) {
      print('ConcurrentOperationManager: Cancelled all operations');
    }
  }

  /// Get operation statistics
  Map<String, dynamic> getOperationStats() {
    return {
      'queuedOperations': _operationQueue.length,
      'runningOperations': _runningOperations.length,
      'completedOperations': _completedOperations,
      'failedOperations': _failedOperations,
      'timeoutOperations': _timeoutOperations,
      'activeTransactions': _activeTransactions.length,
      'activeLocks': _resourceLocks.length,
      'successRate': _completedOperations + _failedOperations > 0 ? 
          '${(_completedOperations / (_completedOperations + _failedOperations) * 100).toStringAsFixed(1)}%' : 'N/A',
    };
  }

  /// Generate unique operation ID
  String _generateOperationId(OperationType type) {
    return '${type.name}_${DateTime.now().millisecondsSinceEpoch}_${_runningOperations.length + _operationQueue.length}';
  }

  /// Generate unique transaction ID
  String _generateTransactionId() {
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_${_activeTransactions.length}';
  }

  /// Cleanup resources
  void dispose() {
    cancelAllOperations();
    
    // Cancel any remaining resource locks
    for (final completer in _resourceLocks.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Manager disposed'));
      }
    }
    _resourceLocks.clear();

    // Rollback any active transactions
    for (final transactionId in _activeTransactions.keys.toList()) {
      rollbackTransaction(transactionId);
    }

    if (kDebugMode) {
      print('ConcurrentOperationManager: Disposed');
    }
  }
}