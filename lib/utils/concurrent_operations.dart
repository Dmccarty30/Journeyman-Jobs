import 'dart:async';
import 'dart:collection';
import 'package.flutter/foundation.dart';

/// Defines the types of asynchronous operations that can be managed and queued.
///
/// This helps in prioritizing and preventing conflicts between operations.
enum OperationType {
  /// An operation to load job data.
  loadJobs,
  /// An operation to load IBEW local union data.
  loadLocals,
  /// An operation to load a user's profile.
  loadUserProfile,
  /// An operation to update a user's profile.
  updateUserProfile,
  /// An operation for user sign-in.
  signIn,
  /// An operation for user sign-out.
  signOut,
  /// An operation to refresh all app data.
  refreshData,
}

/// Represents a single operation waiting in the execution queue.
class QueuedOperation {
  /// A unique identifier for the operation instance.
  final String id;
  /// The type of the operation.
  final OperationType type;
  /// Optional parameters associated with the operation.
  final Map<String, dynamic> parameters;
  /// The completer that will be resolved when the operation finishes.
  final Completer<dynamic> completer;
  /// The timestamp when the operation was created.
  final DateTime createdAt;
  /// The priority level of the operation (higher value means higher priority).
  final int priority;

  /// Creates an instance of a [QueuedOperation].
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

/// Manages the state of a single atomic transaction.
class TransactionState {
  /// The unique ID for this transaction.
  final String transactionId;
  /// The state of the data when the transaction began.
  final Map<String, dynamic> originalState;
  /// A map of changes to be applied upon commit.
  final Map<String, dynamic> pendingChanges;
  /// The time the transaction was started.
  final DateTime startTime;
  /// `true` if the transaction has been successfully committed.
  bool isCommitted = false;
  /// `true` if the transaction has been rolled back.
  bool isRolledBack = false;

  /// Creates an instance of [TransactionState].
  TransactionState({
    required this.transactionId,
    required this.originalState,
  }) : pendingChanges = {},
       startTime = DateTime.now();

  /// Adds a key-value pair representing a change to the transaction.
  void addChange(String key, dynamic value) {
    if (isCommitted || isRolledBack) {
      throw StateError('Cannot modify committed or rolled back transaction');
    }
    pendingChanges[key] = value;
  }

  /// Marks the transaction as committed.
  void commit() {
    if (isCommitted || isRolledBack) {
      throw StateError('Transaction already finalized');
    }
    isCommitted = true;
  }

  /// Marks the transaction as rolled back.
  void rollback() {
    if (isCommitted || isRolledBack) {
      throw StateError('Transaction already finalized');
    }
    isRolledBack = true;
  }

  /// The total duration of the transaction so far.
  Duration get duration => DateTime.now().difference(startTime);

  @override
  String toString() => 'Transaction(id: $transactionId, changes: ${pendingChanges.length}, committed: $isCommitted)';
}

/// A manager for handling concurrent asynchronous operations with queuing,
/// priority, and resource locking.
///
/// This class ensures that a limited number of operations run simultaneously,
/// prioritizes important tasks (like authentication), and prevents race conditions
/// by locking resources during critical operations.
class ConcurrentOperationManager {
  /// The maximum number of operations that can run at the same time.
  static const int maxConcurrentOperations = 3;
  /// The default timeout for an operation before it fails.
  static const Duration operationTimeout = Duration(seconds: 30);
  /// The default timeout for acquiring a resource lock.
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

  /// Checks if an operation of a specific [type] is already running or queued.
  bool isOperationInProgress(OperationType type) {
    return _runningOperations.values.any((op) => op.type == type) ||
           _operationQueue.any((op) => op.type == type);
  }

  /// Executes an operation by adding it to the queue.
  ///
  /// This is a convenience wrapper around [queueOperation].
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

  /// Adds an operation to the priority queue for execution.
  ///
  /// The operation will be executed when its turn comes based on priority and
  /// the number of concurrent operations allowed.
  ///
  /// Returns a `Future` that completes with the result of the [operation].
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

  /// Begins a new transaction for atomic state updates.
  ///
  /// - [currentState]: The initial state of the data before any changes.
  ///
  /// Returns a unique transaction ID.
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

  /// Adds a change to an active transaction.
  ///
  /// - [transactionId]: The ID of the transaction to modify.
  /// - [key]: The key of the data to change.
  /// - [value]: The new value for the key.
  void addTransactionChange(String transactionId, String key, dynamic value) {
    final transaction = _activeTransactions[transactionId];
    if (transaction == null) {
      throw ArgumentError('Transaction $transactionId not found');
    }

    transaction.addChange(key, value);
  }

  /// Commits a transaction, applying all pending changes atomically.
  ///
  /// - [transactionId]: The ID of the transaction to commit.
  ///
  /// Returns a `Future` with the final, updated state map.
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

  /// Rolls back a transaction, discarding all pending changes.
  ///
  /// - [transactionId]: The ID of the transaction to roll back.
  ///
  /// Returns a `Future` with the original state map.
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

  /// Acquires a lock on a specific resource to prevent concurrent access.
  ///
  /// If the resource is already locked, this method will wait until the lock
  /// is released or until [lockTimeout] is reached.
  ///
  /// - [resource]: A unique string identifying the resource to lock.
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

  /// Releases a previously acquired lock on a resource.
  ///
  /// - [resource]: The identifier of the resource to unlock.
  void releaseResourceLock(String resource) {
    final completer = _resourceLocks.remove(resource);
    if (completer != null && !completer.isCompleted) {
      completer.complete();
      
      if (kDebugMode) {
        print('ConcurrentOperationManager: Released lock for resource: $resource');
      }
    }
  }

  /// Cancels all queued and running operations.
  ///
  /// Operations that are cancelled will complete with an error.
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

  /// Returns a map of statistics about the manager's current state.
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

  /// Cleans up all resources, cancelling pending operations and transactions.
  ///
  /// This should be called when the manager is no longer needed.
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