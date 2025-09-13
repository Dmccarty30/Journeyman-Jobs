
/// A generic bounded cache that stores items up to a specified capacity.
/// It maintains insertion order and can deduplicate items based on an optional ID extractor.
class BoundedJobCache<T> {
  final int capacity;
  final String Function(T)? _idExtractor;
  final List<T> _items;
  final Map<String, int> _indexById; // Stores index of item by its ID for quick lookup and deduplication

  /// Creates a new [BoundedJobCache] with the given [capacity].
  ///
  /// An optional [idExtractor] can be provided to extract a unique ID from each item.
  /// If [idExtractor] is provided, items with duplicate IDs will be replaced,
  /// ensuring only the most recent version of an item with a given ID is kept.
  BoundedJobCache({required this.capacity, String Function(T)? idExtractor})
      : assert(capacity > 0, 'Capacity must be greater than 0'),
        _idExtractor = idExtractor,
        _items = [],
        _indexById = {};

  /// Appends new items to the cache, maintaining insertion order and capacity.
  ///
  /// If an [idExtractor] was provided, existing items with the same ID as new items
  /// will be replaced by the new items. If the cache exceeds its capacity,
  /// the oldest items are removed first.
  void addAll(List<T> newItems) {
    for (final item in newItems) {
      _add(item);
    }
    _enforceCapacity();
  }

  /// Returns all cached items in their stable insertion order (most-recent-last).
  List<T> getAll() {
    return List.unmodifiable(_items);
  }

  /// Returns a safe slice of the cached items within the specified range.
  ///
  /// The [start] and [end] indices are 0-based and inclusive for [start], exclusive for [end].
  /// If the range is out of bounds, it will be adjusted to fit the current cache size.
  List<T> getRange(int start, int end) {
    if (start < 0) start = 0;
    if (end > _items.length) end = _items.length;
    if (start >= end) return [];
    return List.unmodifiable(_items.sublist(start, end));
  }

  /// Clears all items from the cache.
  void clear() {
    _items.clear();
    _indexById.clear();
  }

  /// The current number of items in the cache.
  int get length => _items.length;


  /// Returns a heuristic estimate of the memory usage of the cache in bytes.
  ///
  /// This is a simple heuristic: `length * averageItemSizeBytes`.
  /// A default constant of 200 bytes per item is used if not specified.
  int estimatedMemoryUsageBytes({int averageItemSizeBytes = 200}) {
    return _items.length * averageItemSizeBytes;
  }

  /// Adds a single item to the cache, handling deduplication if an ID extractor is present.
  void _add(T item) {
    if (_idExtractor != null) {
      final id = _idExtractor(item);
      if (_indexById.containsKey(id)) {
        // Replace existing item
        final existingIndex = _indexById[id]!;
        _items[existingIndex] = item;
      } else {
        _items.add(item);
        _indexById[id] = _items.length - 1;
      }
    } else {
      _items.add(item);
    }
  }

  /// Enforces the cache capacity by removing the oldest items if the cache
  /// exceeds its maximum capacity.
  void _enforceCapacity() {
    while (_items.length > capacity) {
      final removedItem = _items.removeAt(0);
      if (_idExtractor != null) {
        final id = _idExtractor(removedItem);
        _indexById.remove(id);
        // Rebuild index for remaining items if an item was removed from the beginning
        _rebuildIndex();
      }
    }
  }

  /// Rebuilds the ID-to-index map. This is called when items are removed from
  /// the beginning of the list to ensure indices are correct.
  void _rebuildIndex() {
    if (_idExtractor != null) {
      _indexById.clear();
      for (int i = 0; i < _items.length; i++) {
        _indexById[_idExtractor(_items[i])] = i;
      }
    }
  }
}