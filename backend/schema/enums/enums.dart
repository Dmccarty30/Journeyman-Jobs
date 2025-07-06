import 'package:collection/collection.dart';

enum Classification {
  JourneymanLineman,
  JourneymanWireman,
  JourneymanElectrician,
  JourneymanTreeTrimmer,
  Operator,
  
}

enum ConstructionTypes {
  Distribution,
  Transmission,
  SubStation,
  Residential,
  Industrial,
  Data_Center,
  Commercial,
  Underground,
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
    case (Classification):
      return Classification.values.deserialize(value) as T?;
    case (ConstructionTypes):
      return ConstructionTypes.values.deserialize(value) as T?;
    default:
      return null;
  }
}
