class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng(latitude: $latitude, longitude: $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude);

  @override
  int get hashCode => Object.hash(latitude, longitude);
}