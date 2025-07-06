class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  factory LatLng.fromMap(Map<String, dynamic> map) {
    return LatLng(
      (map['latitude'] ?? 0.0).toDouble(),
      (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'LatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}