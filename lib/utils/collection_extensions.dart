/// Extension methods for working with collections and iterables.
/// 
/// This file provides utility extensions for common collection operations,
/// particularly for filtering null values and working with nullable types.

/// Extension for Iterable<T?> to provide null filtering and utilities.
extension NullableIterableExtensions<T> on Iterable<T?> {
  /// Filters out null values and returns an Iterable<T>.
  /// 
  /// This is equivalent to calling `.where((item) => item != null).cast<T>()`
  /// but provides a more convenient and readable syntax.
  /// 
  /// Example usage:
  /// ```dart
  /// final nullableList = [1, null, 2, null, 3];
  /// final nonNullList = nullableList.withoutNulls.toList(); // [1, 2, 3]
  /// ```
  Iterable<T> get withoutNulls => where((item) => item != null).cast<T>();
  
  /// Filters out null values and returns a List<T>.
  /// 
  /// This is a convenience method that calls withoutNulls.toList().
  List<T> get withoutNullsList => withoutNulls.toList();
  
  /// Filters out null values and returns a Set<T>.
  /// 
  /// This is useful when you want to remove duplicates along with nulls.
  Set<T> get withoutNullsSet => withoutNulls.toSet();
}

/// Extension for Iterable<T> to provide additional utility methods.
extension IterableExtensions<T> on Iterable<T> {
  /// Returns true if this iterable contains no elements.
  bool get isEmpty => length == 0;
  
  /// Returns true if this iterable contains at least one element.
  bool get isNotEmpty => !isEmpty;
  
  /// Returns the first element, or null if the iterable is empty.
  T? get firstOrNull => isEmpty ? null : first;
  
  /// Returns the last element, or null if the iterable is empty.
  T? get lastOrNull => isEmpty ? null : last;
  
  /// Returns the element at the given index, or null if out of bounds.
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
  
  /// Chunks the iterable into lists of the specified size.
  /// 
  /// The last chunk may be smaller than the specified size if the
  /// total number of elements is not evenly divisible.
  /// 
  /// Example:
  /// ```dart
  /// [1, 2, 3, 4, 5].chunked(2) // [[1, 2], [3, 4], [5]]
  /// ```
  Iterable<List<T>> chunked(int size) sync* {
    if (size <= 0) throw ArgumentError('Size must be positive');
    
    final iterator = this.iterator;
    while (iterator.moveNext()) {
      final chunk = <T>[iterator.current];
      for (int i = 1; i < size && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }
      yield chunk;
    }
  }
  
  /// Groups elements by a key function.
  /// 
  /// Returns a Map where keys are the result of calling [keySelector]
  /// on each element, and values are lists of elements with that key.
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final result = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      result.putIfAbsent(key, () => <T>[]).add(element);
    }
    return result;
  }
  
  /// Returns a new iterable with distinct elements.
  /// 
  /// Uses the provided [keySelector] to determine uniqueness.
  /// If no key selector is provided, uses the elements themselves.
  Iterable<T> distinctBy<K>([K Function(T)? keySelector]) {
    final seen = <K>{};
    final selector = keySelector ?? (T element) => element as K;
    
    return where((element) => seen.add(selector(element)));
  }
  
  /// Returns distinct elements (shorthand for distinctBy with no key selector).
  Iterable<T> get distinct => distinctBy();
}

/// Extension for List<T> to provide additional utility methods.
extension ListExtensions<T> on List<T> {
  /// Safely gets an element at the specified index.
  /// 
  /// Returns null if the index is out of bounds.
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// Safely sets an element at the specified index.
  /// 
  /// Does nothing if the index is out of bounds.
  /// Returns true if the operation was successful.
  bool safeSet(int index, T value) {
    if (index < 0 || index >= length) return false;
    this[index] = value;
    return true;
  }
  
  /// Adds an element if it's not null.
  void addIfNotNull(T? element) {
    if (element != null) add(element);
  }
  
  /// Adds all non-null elements from an iterable.
  void addAllNotNull(Iterable<T?> elements) {
    addAll(elements.withoutNulls);
  }
}

/// Extension for Map to provide additional utility methods.
extension MapExtensions<K, V> on Map<K, V> {
  /// Gets a value by key, returning null if the key doesn't exist.
  /// 
  /// This is the same as the [] operator but makes the nullable return explicit.
  V? getNullable(K key) => this[key];
  
  /// Gets a value by key, returning a default value if the key doesn't exist.
  V getOrDefault(K key, V defaultValue) => this[key] ?? defaultValue;
  
  /// Gets a value by key, creating and storing a default value if the key doesn't exist.
  V getOrPut(K key, V Function() defaultValue) {
    if (containsKey(key)) return this[key] as V;
    final value = defaultValue();
    this[key] = value;
    return value;
  }
  
  /// Filters the map by keys.
  Map<K, V> filterKeys(bool Function(K) predicate) {
    return Map.fromEntries(
      entries.where((entry) => predicate(entry.key)),
    );
  }
  
  /// Filters the map by values.
  Map<K, V> filterValues(bool Function(V) predicate) {
    return Map.fromEntries(
      entries.where((entry) => predicate(entry.value)),
    );
  }
  
  /// Maps the values while keeping the same keys.
  Map<K, R> mapValues<R>(R Function(V) transform) {
    return map((key, value) => MapEntry(key, transform(value)));
  }
  
  /// Maps the keys while keeping the same values.
  Map<R, V> mapKeys<R>(R Function(K) transform) {
    return map((key, value) => MapEntry(transform(key), value));
  }
}

/// Extension for Set to provide additional utility methods.
extension SetExtensions<T> on Set<T> {
  /// Toggles an element in the set.
  /// 
  /// Adds the element if it's not present, removes it if it is present.
  /// Returns true if the element was added, false if it was removed.
  bool toggle(T element) {
    if (contains(element)) {
      remove(element);
      return false;
    } else {
      add(element);
      return true;
    }
  }
  
  /// Adds an element if it's not null.
  void addIfNotNull(T? element) {
    if (element != null) add(element);
  }
  
  /// Adds all non-null elements from an iterable.
  void addAllNotNull(Iterable<T?> elements) {
    addAll(elements.withoutNulls);
  }
}