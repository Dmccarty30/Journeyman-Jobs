import 'package:flutter/material.dart';

/// An extension on `Iterable<Widget>` to insert a divider between elements.
extension ListDivideExt<T extends Widget> on Iterable<T> {
  /// Inserts a given [divider] widget between each element of this iterable.
  ///
  /// Useful for building column or row layouts with separators.
  /// Example: `[Text('1'), Text('2')].divide(Divider())`
  Iterable<Widget> divide(Widget divider) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;
    
    yield iterator.current;
    while (iterator.moveNext()) {
      yield divider;
      yield iterator.current;
    }
  }
}

/// An extension on `List` to provide a convenient swap method.
extension ListSwapExt<T> on List<T> {
  /// Swaps the elements at the given [first] and [second] indices.
  void swap(int first, int second) {
    final temp = this[first];
    this[first] = this[second];
    this[second] = temp;
  }
}

/// An extension on `List` to remove an element and return it in one step.
extension ListRemoveExt<T> on List<T> {
  /// Removes the element at the specified [index] and returns it.
  T removeGet(int index) => removeAt(index);
}

/// An extension on a `List` of nullable types to remove all null elements.
extension ListRemoveNullExt<T> on List<T?> {
  /// Removes all `null` entries from the list in-place.
  void removeNulls() => removeWhere((e) => e == null);
}

/// An extension on `List<String>` for common joining operations.
extension StringListJoinExt on List<String> {
  /// Joins the list of strings with a newline character.
  String joinWithNewline() => join('\n');
}

/// An extension on `Iterable` to provide a more explicit `filter` method.
extension ListFilterExt<T> on Iterable<T> {
  /// Filters the iterable based on the given [test] predicate.
  ///
  /// This is an alias for `where(test).toList()`.
  List<T> filter(bool Function(T) test) => where(test).toList();
}

/// An extension on `Iterable` to get a list of unique elements.
extension ListUniqueExt<T> on Iterable<T> {
  /// Returns a new list containing only the unique elements from this iterable.
  List<T> unique() => toSet().toList();
}

/// An extension on `Iterable` to limit the number of elements.
extension ListLimitExt<T> on Iterable<T> {
  /// Returns a new list containing the first [count] elements of this iterable.
  ///
  /// This is an alias for `take(count).toList()`.
  List<T> limit(int count) => take(count).toList();
}

/// An extension on `List` to provide a convenient sorting method that returns a new list.
extension ListSortedExt<T> on List<T> {
  /// Returns a new sorted list based on the [keyOf] function, without
  /// modifying the original list.
  ///
  /// - [keyOf]: A function that returns a `Comparable` key for an element.
  List<T> sortedBy(Comparable Function(T) keyOf) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keyOf(a).compareTo(keyOf(b)));
    return copy;
  }
}

/// An extension on `Iterable` for advanced containment checks.
extension ListContainsAllExt<T> on Iterable<T> {
  /// Checks if this iterable contains all the elements from the [other] iterable.
  bool containsAll(Iterable<T> other) => other.every(contains);
}

/// An extension on `Iterable` for set-based intersection operations.
extension ListIntersectionExt<T> on Iterable<T> {
  /// Returns a `Set` containing all the elements that are in both this and the
  /// [other] iterable.
  Set<T> intersection(Iterable<T> other) => toSet().intersection(other.toSet());
}

/// An extension on `Iterable` for set-based difference operations.
extension ListDifferenceExt<T> on Iterable<T> {
  /// Returns a `Set` containing all the elements of this iterable that are not
  /// in the [other] iterable.
  Set<T> difference(Iterable<T> other) => toSet().difference(other.toSet());
}