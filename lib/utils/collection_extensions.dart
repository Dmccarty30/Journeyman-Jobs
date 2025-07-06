import 'package:flutter/material.dart';

extension ListDivideExt<T extends Widget> on Iterable<T> {
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

extension ListSwapExt<T> on List<T> {
  void swap(int first, int second) {
    final temp = this[first];
    this[first] = this[second];
    this[second] = temp;
  }
}

extension ListRemoveExt<T> on List<T> {
  T removeGet(int index) => removeAt(index);
}

extension ListRemoveNullExt<T> on List<T?> {
  void removeNulls() => removeWhere((e) => e == null);
}

extension StringListJoinExt on List<String> {
  String joinWithNewline() => join('\n');
}

extension ListFilterExt<T> on Iterable<T> {
  List<T> filter(bool Function(T) test) => where(test).toList();
}

extension ListUniqueExt<T> on Iterable<T> {
  List<T> unique() => toSet().toList();
}

extension ListLimitExt<T> on Iterable<T> {
  List<T> limit(int count) => take(count).toList();
}

extension ListSortedExt<T> on List<T> {
  List<T> sortedBy(Comparable Function(T) keyOf) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keyOf(a).compareTo(keyOf(b)));
    return copy;
  }
}

extension ListContainsAllExt<T> on Iterable<T> {
  bool containsAll(Iterable<T> other) => other.every(contains);
}

extension ListIntersectionExt<T> on Iterable<T> {
  Set<T> intersection(Iterable<T> other) => toSet().intersection(other.toSet());
}

extension ListDifferenceExt<T> on Iterable<T> {
  Set<T> difference(Iterable<T> other) => toSet().difference(other.toSet());
}