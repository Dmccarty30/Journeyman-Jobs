import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:journeyman_jobs/firebase_options.dart';
import 'package:journeyman_jobs/models/contractor_model.dart';

// To run this script, execute the following command from the project root:
// dart run scripts/populate_contractors.dart

Future<void> main() async {
  // --- Firebase Initialization ---
  // This boilerplate is necessary to use Firestore in a standalone Dart script.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully.');
  } catch (e) {
    print('Error initializing Firebase: $e');
    exit(1); // Exit if Firebase can't be initialized
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference contractorsCollection = firestore.collection(
    'contractors',
  );

  // --- File Reading ---
  // Use dart:io to read the file from the filesystem.
  final File rosterFile = File('docs/storm_roster.json');
  if (!await rosterFile.exists()) {
    print('Error: storm_roster.json not found in the /docs directory.');
    exit(1);
  }
  final String rosterJson = await rosterFile.readAsString();
  final List<dynamic> rosterData = json.decode(rosterJson);

  // --- Data Processing and Upload ---
  WriteBatch batch = firestore.batch();
  int operationCount = 0;
  int totalContractors = rosterData.length;

  print('Starting to process $totalContractors contractors...');

  for (int i = 0; i < totalContractors; i++) {
    var contractorData = rosterData[i] as Map<String, dynamic>;

    // Generate a unique ID if one is not present in the JSON
    String docId = contractorData['id'] ?? contractorsCollection.doc().id;
    contractorData['id'] = docId; // Ensure the ID is part of the data

    final contractor = Contractor.fromJson(contractorData);
    final DocumentReference docRef = contractorsCollection.doc(docId);

    // Use the toFirestore() method for proper data conversion
    batch.set(docRef, contractor.toFirestore());
    operationCount++;

    // Commit the batch every 500 operations to avoid exceeding limits
    if (operationCount >= 500) {
      await batch.commit();
      print('Committed a batch of $operationCount contractors.');
      batch = firestore.batch(); // Start a new batch
      operationCount = 0;
    }
  }

  // Commit any remaining operations in the final batch
  if (operationCount > 0) {
    await batch.commit();
    print('Committed the final batch of $operationCount contractors.');
  }

  print('\n-----------------------------------------');
  print('Successfully populated Firestore with $totalContractors contractors!');
  print('-----------------------------------------');
  exit(0); // Exit successfully
}
