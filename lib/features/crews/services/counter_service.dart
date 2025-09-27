import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// Service for managing global counters in Firestore.
/// Used for generating unique IDs with sequential counters.
class CounterService {
  final FirebaseFirestore _firestore;

  CounterService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection and document paths
  static const String _configCollection = 'config';
  static const String _globalCountersDoc = 'globalCounters';
  static const String _crewCounterField = 'crewCounter';

  /// Atomically gets and increments the crew counter.
  /// 
  /// Uses a Firestore transaction to ensure atomicity and handle concurrency.
  /// If the counter doesn't exist, it will be initialized to 1.
  /// 
  /// Returns the new counter value after incrementing.
  /// 
  /// Throws an exception if the transaction fails after retries.
  Future<int> getAndIncrementCrewCounter() async {
    const maxRetries = 3;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await _firestore.runTransaction<int>((transaction) async {
          final counterRef = _firestore
              .collection(_configCollection)
              .doc(_globalCountersDoc);

          final counterDoc = await transaction.get(counterRef);

          int currentCounter;
          
          if (counterDoc.exists && counterDoc.data()?.containsKey(_crewCounterField) == true) {
            // Counter exists, increment it
            currentCounter = (counterDoc.data()![_crewCounterField] as num).toInt();
          } else {
            // Counter doesn't exist, initialize to 0 (will be incremented to 1)
            currentCounter = 0;
          }

          final newCounter = currentCounter + 1;

          // Update the counter in the transaction
          transaction.set(
            counterRef,
            {_crewCounterField: newCounter},
            SetOptions(merge: true),
          );

          if (kDebugMode) {
            print('🔢 Crew counter incremented: $currentCounter -> $newCounter');
          }

          return newCounter;
        });
      } catch (e) {
        attempts++;
        if (kDebugMode) {
          print('⚠️ Crew counter transaction attempt $attempts failed: $e');
        }
        
        if (attempts >= maxRetries) {
          throw Exception('Failed to increment crew counter after $maxRetries attempts: $e');
        }
        
        // Wait a bit before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: 100 * attempts));
      }
    }

    // This should never be reached, but just in case
    throw Exception('Failed to increment crew counter: Unknown error');
  }

  /// Gets the current crew counter value without incrementing it.
  /// 
  /// Returns the current counter value, or 0 if the counter doesn't exist.
  /// 
  /// This is useful for checking the current state without modifying it.
  Future<int> getCurrentCrewCounter() async {
    try {
      final counterDoc = await _firestore
          .collection(_configCollection)
          .doc(_globalCountersDoc)
          .get();

      if (counterDoc.exists && counterDoc.data()?.containsKey(_crewCounterField) == true) {
        return (counterDoc.data()![_crewCounterField] as num).toInt();
      }

      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error getting current crew counter: $e');
      }
      throw Exception('Error getting current crew counter: $e');
    }
  }

  /// Resets the crew counter to a specific value.
  /// 
  /// This should be used with caution, typically only for testing or
  /// administrative purposes.
  /// 
  /// [value] - The value to set the counter to (must be >= 0)
  Future<void> resetCrewCounter(int value) async {
    if (value < 0) {
      throw ArgumentError('Counter value must be >= 0');
    }

    try {
      await _firestore
          .collection(_configCollection)
          .doc(_globalCountersDoc)
          .set({_crewCounterField: value}, SetOptions(merge: true));

      if (kDebugMode) {
        print('🔢 Crew counter reset to: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error resetting crew counter: $e');
      }
      throw Exception('Error resetting crew counter: $e');
    }
  }

  /// Ensures the global counters document exists.
  /// 
  /// This is called automatically when needed, but can be called manually
  /// to ensure the document structure is set up.
  Future<void> ensureCounterDocumentExists() async {
    try {
      final counterRef = _firestore
          .collection(_configCollection)
          .doc(_globalCountersDoc);

      final counterDoc = await counterRef.get();

      if (!counterDoc.exists) {
        // Create the document with the crew counter field
        await counterRef.set({_crewCounterField: 0});
        
        if (kDebugMode) {
          print('📄 Created global counters document');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error ensuring counter document exists: $e');
      }
      throw Exception('Error ensuring counter document exists: $e');
    }
  }
}