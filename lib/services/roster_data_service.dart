import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/storm_roster_signup.dart'; // Import the renamed model

class RosterDataService {
  // Singleton pattern
  static final RosterDataService _instance = RosterDataService._internal();
  factory RosterDataService() => _instance;
  RosterDataService._internal();

  List<RosterContractor>? _rosterData;

  Future<List<RosterContractor>> loadRosterData() async {
    if (_rosterData != null) {
      return _rosterData!;
    }

    try {
      // Load the CSV file from assets
      final rawData = await rootBundle.loadString('docs/storm roster data/JJ Storm Roster.csv');

      // Parse the CSV data
      // The first row is the header, so we skip it when processing the data.
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
      // Skip the header row (first row)
      final dataRows = csvTable.isNotEmpty ? csvTable.sublist(1) : [];

      // Convert CSV rows to RosterContractor objects
      _rosterData = dataRows.map((row) {
        // Ensure all values are strings before passing to the factory
        final stringRow = row.map((value) => value.toString()).toList();
        return RosterContractor.fromCsv(stringRow);
      }).toList();

      return _rosterData!;
    } catch (e) {
      // Handle potential errors during file loading or parsing
      // Return an empty list or re-throw the exception based on desired error handling
      return [];
    }
  }
}
