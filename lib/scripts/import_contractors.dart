import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script to import contractor data from storm_roster.json into Firestore
/// 
/// Usage:
/// 1. Ensure you have the storm_roster.json file in the docs/ directory
/// 2. Run this script from your Flutter project
/// 3. The script will batch import all contractors to the 'contractors' collection
/// 
/// Note: This is a one-time migration script. Run with caution in production.
Future<void> importContractors() async {
  try {
    // Read the JSON file
    final file = File('docs/storm_roster.json');
    
    if (!await file.exists()) {
      return;
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> contractors = json.decode(jsonString);
    
    
    // Initialize Firestore
    final firestore = FirebaseFirestore.instance;
    
    // Process in batches of 500 (Firestore batch limit)
    const batchSize = 500;
    
    for (int i = 0; i < contractors.length; i += batchSize) {
      final batch = firestore.batch();
      final end = (i + batchSize < contractors.length) ? i + batchSize : contractors.length;
      
      
      for (int j = i; j < end; j++) {
        final contractor = contractors[j];
        final docRef = firestore.collection('contractors').doc();
        
        // Map the JSON fields to Firestore format
        batch.set(docRef, {
          'id': docRef.id,
          'company': contractor['COMPANY'] ?? '',
          'howToSignup': contractor['HOW TO SIGNUP'] ?? '',
          'phoneNumber': contractor['PHONE NUMBER'],
          'email': contractor['EMAIL'],
          'website': contractor['WEBSITE'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Commit the batch
      await batch.commit();
    }
    
    
  } catch (e) {
    rethrow;
  }
}

/// Alternative method: Import with validation and error handling
Future<void> importContractorsWithValidation() async {
  try {
    final file = File('docs/storm_roster.json');
    
    if (!await file.exists()) {
      return;
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> contractors = json.decode(jsonString);
    
    
    final firestore = FirebaseFirestore.instance;
    int successCount = 0;
    // ignore: unused_local_variable
    int errorCount = 0;
    
    for (var contractor in contractors) {
      try {
        // Validate required fields
        if (contractor['COMPANY'] == null || contractor['COMPANY'].toString().isEmpty) {
          errorCount++;
          continue;
        }
        
        final docRef = firestore.collection('contractors').doc();
        
        await docRef.set({
          'id': docRef.id,
          'company': contractor['COMPANY'] ?? '',
          'howToSignup': contractor['HOW TO SIGNUP'] ?? '',
          'phoneNumber': contractor['PHONE NUMBER'],
          'email': contractor['EMAIL'],
          'website': contractor['WEBSITE'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        successCount++;
        
        if (successCount % 10 == 0) {
        }
        
      } catch (e) {
        errorCount++;
      }
    }
    
    
  } catch (e) {
    rethrow;
  }
}

/// Utility function to check if contractors already exist
Future<bool> contractorsExist() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('contractors').limit(1).get();
    return snapshot.docs.isNotEmpty;
  } catch (e) {
    return false;
  }
}

/// Main function to run the import
void main() async {
  
  // Check if contractors already exist
  final exists = await contractorsExist();
  if (exists) {
    await Future.delayed(const Duration(seconds: 5));
  }
  
  // Run the import with validation
  await importContractorsWithValidation();
  
}