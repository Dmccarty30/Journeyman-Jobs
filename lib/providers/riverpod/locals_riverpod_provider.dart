import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/locals_record.dart';
import '../../utils/concurrent_operations.dart';
import 'jobs_riverpod_provider.dart' show firestoreServiceProvider;

part 'locals_riverpod_provider.g.dart';
/// Represents the state for the IBEW locals feature.
///
/// This immutable class holds the complete list of locals, a filtered list
/// for searching, the current search term, and UI state like loading and error status.
class LocalsState {
  /// Creates an instance of the locals state.
  const LocalsState({
    this.locals = const <LocalsRecord>[],
    this.filteredLocals = const <LocalsRecord>[],
    this.searchTerm = '',
    this.isLoading = false,
    this.error,
    this.cachedLocals = const <String, LocalsRecord>{},
    this.lastDocument,
  });

  /// The complete list of all local union records fetched from the database.
  final List<LocalsRecord> locals;

  /// A sub-list of locals that matches the current search term.
  final List<LocalsRecord> filteredLocals;

  /// The search term currently being used to filter the list of locals.
  final String searchTerm;

  /// `true` if a data loading operation for locals is currently in progress.
  final bool isLoading;

  /// A string description of the last error that occurred while fetching data.
  final String? error;

  /// A cached map of local records, keyed by their ID, for quick access.
  final Map<String, LocalsRecord> cachedLocals;

  /// The last Firestore document from the previous fetch, used for pagination.
  final DocumentSnapshot? lastDocument;

  /// Creates a new [LocalsState] instance with updated field values.
  LocalsState copyWith({
    List<LocalsRecord>? locals,
    List<LocalsRecord>? filteredLocals,
    String? searchTerm,
    bool? isLoading,
    String? error,
    Map<String, LocalsRecord>? cachedLocals,
    DocumentSnapshot? lastDocument,
  }) =>
      LocalsState(
        locals: locals ?? this.locals,
        filteredLocals: filteredLocals ?? this.filteredLocals,
        searchTerm: searchTerm ?? this.searchTerm,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        cachedLocals: cachedLocals ?? this.cachedLocals,
        lastDocument: lastDocument ?? this.lastDocument,
      );
  /// Returns a new [LocalsState] instance with the `error` field cleared.
  LocalsState clearError() => copyWith(error: null);
}

/// The state notifier for managing the [LocalsState].
///
/// This class handles all logic for fetching, paginating, searching, and
/// filtering IBEW local union data.
@riverpod
class LocalsNotifier extends _$LocalsNotifier {
  late final ConcurrentOperationManager _operationManager;
  static const int _pageSize = 20; // Define page size for pagination

  @override
  LocalsState build() {
    _operationManager = ConcurrentOperationManager();
    return const LocalsState();
  }

  /// Loads IBEW local union data from Firestore.
  ///
  /// This method supports pagination and can be forced to refresh the data.
  ///
  /// - [forceRefresh]: If `true`, clears the existing list and fetches from the start.
  /// - [loadMore]: If `true`, fetches the next page of data.
  Future<void> loadLocals({bool forceRefresh = false, bool loadMore = false}) async {
    if (state.isLoading) {
      return;
    }

    if (!forceRefresh && !loadMore && state.locals.isNotEmpty) {
      return;
    }

    if (loadMore && state.lastDocument == null && state.locals.isNotEmpty) {
      // No more documents to load if we're trying to load more and lastDocument is null
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final QuerySnapshot<Object?> snapshot = await _operationManager.queueOperation<QuerySnapshot<Object?>>(
        type: OperationType.loadLocals,
        operation: () async {
          return ref.read(firestoreServiceProvider).getLocals(
            startAfter: loadMore ? state.lastDocument : null,
            limit: _pageSize,
          ).first;
        },
      );

      final List<LocalsRecord> newLocals = snapshot.docs
          .map(LocalsRecord.fromFirestore)
          .toList();

      final List<LocalsRecord> updatedLocals = loadMore
          ? [...state.locals, ...newLocals]
          : newLocals;

      final Map<String, LocalsRecord> cached = Map.from(state.cachedLocals);
      for (final LocalsRecord l in newLocals) {
        cached[l.id] = l;
      }

      state = state.copyWith(
        locals: updatedLocals,
        filteredLocals: updatedLocals,
        isLoading: false,
        cachedLocals: cached,
        lastDocument: newLocals.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Filters the list of locals based on a search term.
  ///
  /// This performs a client-side search on the already loaded locals data.
  /// The search is case-insensitive and matches against the local's number,
  /// name, city, state, and phone number. Results are sorted with a preference
  /// for exact matches and "starts with" matches on the local number and name.
  ///
  /// - [term]: The search query string.
  void searchLocals(String term) {
    final String normalized = term.toLowerCase().trim();
    if (normalized.isEmpty) {
      state = state.copyWith(filteredLocals: state.locals, searchTerm: '');
      return;
    }
    final List<LocalsRecord> filtered = state.locals.where((LocalsRecord local) =>
        local.localNumber.toLowerCase().contains(normalized) ||
        local.localName.toLowerCase().contains(normalized) ||
        local.city.toLowerCase().contains(normalized) ||
        local.state.toLowerCase().contains(normalized) ||
        local.phone.toLowerCase().contains(normalized),
    ).toList()
      ..sort((LocalsRecord a, LocalsRecord b) {
        final String aNum = a.localNumber.toLowerCase();
        final String bNum = b.localNumber.toLowerCase();
        final String aName = a.localName.toLowerCase();
        final String bName = b.localName.toLowerCase();
        if (aNum == normalized) {
          return -1;
        }
        if (bNum == normalized) {
          return 1;
        }
        if (aNum.startsWith(normalized) && !bNum.startsWith(normalized)) {
          return -1;
        }
        if (bNum.startsWith(normalized) && !aNum.startsWith(normalized)) {
          return 1;
        }
        if (aName.startsWith(normalized) && !bName.startsWith(normalized)) {
          return -1;
        }
        if (bName.startsWith(normalized) && !aName.startsWith(normalized)) {
          return 1;
        }
        return aNum.compareTo(bNum);
      });
    state = state.copyWith(filteredLocals: filtered, searchTerm: term);
  }

  /// Retrieves a single local by its ID from the cached map for efficient access.
  LocalsRecord? getLocalById(String id) => state.cachedLocals[id];

  /// Returns a list of locals filtered by a specific state name.
  List<LocalsRecord> getLocalsByState(String stateName) => state.locals
      .where((LocalsRecord l) => l.state.toLowerCase() == stateName.toLowerCase())
      .toList();

  /// Returns a list of locals filtered by a specific job classification.
  List<LocalsRecord> getLocalsByClassification(String classification) => state.locals
      .where((LocalsRecord l) => l.classification?.toLowerCase() == classification.toLowerCase())
      .toList();

  /// Placeholder for finding nearby locals.
  ///
  /// NOTE: This currently returns an empty list as the [LocalsRecord] model
  /// does not contain the necessary geolocation data.
  List<LocalsRecord> getNearbyLocals({
    required double latitude,
    required double longitude,
    double radiusMiles = 50.0,
  }) {
    // No location data in LocalsRecord; return empty list
    return <LocalsRecord>[];
  }

  /// Clears the current search term and resets the filtered list to show all locals.
  void clearSearch() {
    state = state.copyWith(filteredLocals: state.locals, searchTerm: '');
  }

  /// Clears any error message from the state.
  void clearError() {
    state = state.clearError();
  }

  /// Disposes of managed resources like the [ConcurrentOperationManager].
  void dispose() {
    _operationManager.dispose();
  }
}

/// An auto-disposing provider that fetches a single [LocalsRecord] by its ID.
@riverpod
Future<LocalsRecord?> localById(Ref ref, String localId) async {
  final service = ref.watch(firestoreServiceProvider);
  try {
    final doc = await service.getLocal(localId);
    if (doc.exists) {
      return LocalsRecord.fromFirestore(doc);
    }
    return null;
  } catch (e) {
    // Log error and return null for graceful handling
    return null;
  }
}

/// A provider that filters the main list of locals by a given state name.
@riverpod
List<LocalsRecord> localsByState(Ref ref, String stateName) {
  final localsState = ref.watch(localsProvider);
  return localsState.locals
      .where((l) => l.state.toLowerCase() == stateName.toLowerCase())
      .toList();
}

/// A provider that filters the main list of locals by a given job classification.
@riverpod
List<LocalsRecord> localsByClassification(Ref ref, String classification) {
  final localsState = ref.watch(localsProvider);
  return localsState.locals
      .where((l) => l.classification?.toLowerCase() == classification.toLowerCase())
      .toList();
}

/// A provider that performs a client-side search on the main list of locals.
@riverpod
List<LocalsRecord> searchedLocals(Ref ref, String searchTerm) {
  final localsState = ref.watch(localsProvider);
  if (searchTerm.trim().isEmpty) {
    return localsState.locals;
  }
  final String normalized = searchTerm.toLowerCase().trim();
  // ignore: inference_failure_on_untyped_parameter
  return localsState.locals.where((l) =>
      l.localNumber.toLowerCase().contains(normalized) ||
      l.localName.toLowerCase().contains(normalized) ||
      l.city.toLowerCase().contains(normalized) ||
      l.state.toLowerCase().contains(normalized) ||
      l.phone.toLowerCase().contains(normalized),
  ).toList();
}

/// A provider that derives a sorted, unique list of all state abbreviations
/// from the full list of locals.
@riverpod
List<String> allStates(Ref ref) {
  final localsState = ref.watch(localsProvider);
  final Set<String> set = <String>{};
  for (final l in localsState.locals) {
    set.add(l.state);
  }
  final List<String> list = set.toList()..sort();
  return list;
}

/// A provider that derives a sorted, unique list of all job classifications
/// from the full list of locals.
@riverpod
List<String> allClassifications(Ref ref) {
  final localsState = ref.watch(localsProvider);
  final Set<String> set = <String>{};
  for (final l in localsState.locals) {
    if (l.classification != null) {
      set.add(l.classification!);
    }
  }
  final List<String> list = set.toList()..sort();
  return list;
}

// End of file