import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/locals_record.dart';
import '../../utils/concurrent_operations.dart';
import 'jobs_riverpod_provider.dart' show firestoreServiceProvider;

part 'locals_riverpod_provider.g.dart';
/// Represents the state of locals data used by Riverpod.
class LocalsState {
  /// Creates a [LocalsState] with optional initial values.
  const LocalsState({
    this.locals = const <LocalsRecord>[],
    this.filteredLocals = const <LocalsRecord>[],
    this.searchTerm = '',
    this.isLoading = false,
    this.error,
    this.cachedLocals = const <String, LocalsRecord>{},
    this.lastDocument,
  });

  /// The complete list of locals records.
  final List<LocalsRecord> locals;

  /// The list of locals after applying any search filter.
  final List<LocalsRecord> filteredLocals;

  /// The current search term entered by the user.
  final String searchTerm;

  /// Whether the locals are currently being loaded.
  final bool isLoading;

  /// An optional error message if loading fails.
  /// An optional error message if loading fails.
  final String? error;

  /// A map of locals keyed by their ID for quick lookup.
  final Map<String, LocalsRecord> cachedLocals;

  /// The last document snapshot from Firestore for pagination.
  final DocumentSnapshot? lastDocument;

  /// Returns a new [LocalsState] with the given fields replaced.
  ///
  /// Any parameter left `null` will retain its current value.
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
/// Returns a copy of the state with the error cleared.
  /// Returns a copy of the state with the error cleared.
  /// Returns a copy of the state with the error cleared.
  /// Returns a copy of the state with the error cleared.
  LocalsState clearError() => copyWith();
}

@riverpod
/// Riverpod notifier that manages loading and searching of locals.
class LocalsNotifier extends _$LocalsNotifier {
  late final ConcurrentOperationManager _operationManager;
  static const int _pageSize = 20; // Define page size for pagination

  @override
  LocalsState build() {
    _operationManager = ConcurrentOperationManager();
    return const LocalsState();
  }

  /// Loads locals from Firestore, optionally forcing a refresh or loading more data.
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

  /// Searches locals by the given term, updating filteredLocals.
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

  /// Retrieves a local by its ID from the cached map.
  LocalsRecord? getLocalById(String id) => state.cachedLocals[id];

  /// Returns locals filtered by a given state name.
  List<LocalsRecord> getLocalsByState(String stateName) => state.locals
      .where((LocalsRecord l) => l.state.toLowerCase() == stateName.toLowerCase())
      .toList();

  /// Returns locals filtered by a given classification.
  List<LocalsRecord> getLocalsByClassification(String classification) => state.locals
      .where((LocalsRecord l) => l.classification?.toLowerCase() == classification.toLowerCase())
      .toList();

  /// Returns an empty list as location data is not available in LocalsRecord.
  List<LocalsRecord> getNearbyLocals({
    required double latitude,
    required double longitude,
    double radiusMiles = 50.0,
  }) {
    // No location data in LocalsRecord; return empty list
    return <LocalsRecord>[];
  }

  /// Clears the current search, resetting filteredLocals and searchTerm.
  void clearSearch() {
    state = state.copyWith(filteredLocals: state.locals, searchTerm: '');
  }

  /// Clears any error in the state.
  void clearError() {
    state = state.clearError();
  }

  void dispose() {
    _operationManager.dispose();
  }
}

@riverpod
/// Riverpod provider that fetches a single local by ID.
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

@riverpod
/// Riverpod provider that returns locals filtered by state.
List<LocalsRecord> localsByState(Ref ref, String stateName) {
  final localsState = ref.watch(localsNotifierProvider);
  return localsState.locals
      .where((l) => l.state.toLowerCase() == stateName.toLowerCase())
      .toList();
}

@riverpod
/// Riverpod provider that returns locals filtered by classification.
List<LocalsRecord> localsByClassification(Ref ref, String classification) {
  final localsState = ref.watch(localsNotifierProvider);
  return localsState.locals
      .where((l) => l.classification?.toLowerCase() == classification.toLowerCase())
      .toList();
}

@riverpod
/// Riverpod provider that returns locals matching a search term.
List<LocalsRecord> searchedLocals(Ref ref, String searchTerm) {
  final localsState = ref.watch(localsNotifierProvider);
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

@riverpod
List<String> allStates(Ref ref) {
  final localsState = ref.watch(localsNotifierProvider);
  final Set<String> set = <String>{};
  for (final l in localsState.locals) {
    set.add(l.state);
  }
  final List<String> list = set.toList()..sort();
  return list;
}

@riverpod
List<String> allClassifications(Ref ref) {
  final localsState = ref.watch(localsNotifierProvider);
  final Set<String> set = <String>{};
  for (final l in localsState.locals) {
    if (l.classification != null) {
      set.addAll(l.classification! as Iterable<String>);
    }
  }
  final List<String> list = set.toList()..sort();
  return list;
}

// End of file