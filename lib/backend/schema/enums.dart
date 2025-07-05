enum Classification {
  JourneymanLineman,
  JourneymanElectrician,
  JourneymanWireman,
  JourneymanTreeTrimmer,
  Operator,
}

extension ClassificationExtension on Classification {
  String serialize() {
    switch (this) {
      case Classification.JourneymanLineman:
        return 'Journeyman Lineman';
      case Classification.JourneymanElectrician:
        return 'Journeyman Electrician';
      case Classification.JourneymanWireman:
        return 'Journeyman Wireman';
      case Classification.JourneymanTreeTrimmer:
        return 'Journeyman Tree Trimmer';
      case Classification.Operator:
        return 'Operator';
    }
  }
}

