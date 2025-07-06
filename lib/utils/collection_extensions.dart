// This file is auto generated, do not modify manually.

extension MapExtensions<K, V> on Map<K, V> {
  Map<K, V> withoutNulls() {
    return Map.fromEntries(
      entries.where((e) => e.value != null),
    );
  }
}

extension ListExtensions<T> on List<T> {
  List<T> get withoutNulls => where((e) => e != null).toList();
}

extension IterableExtensions<T> on Iterable<T> {
  List<Widget> divide(SizedBox spacer) => toList().divide(spacer);
}
