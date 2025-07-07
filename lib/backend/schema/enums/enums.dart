import 'package:collection/collection.dart';

enum Classification {
  journeymanLineman,
  journeymanWireman,
  journeymanElectrician,
  journeymanTreeTrimmer,
  operator,

}

enum ConstructionTypes {
  distribution,
  transmission,
  subStation,
  residential,
  industrial,
  dataCenter,
  commercial,
  underground,
}

extension EnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension EnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case Classification _:
      return Classification.values.deserialize(value) as T?;
    case ConstructionTypes _:
      return ConstructionTypes.values.deserialize(value) as T?;
    default:
      return null;
  }
}
