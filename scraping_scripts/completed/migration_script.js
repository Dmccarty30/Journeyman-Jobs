/**
 * Migration script to implement corrections from scraper_corrections.md
 * This script:
 * 1. Removes invalid Local 125 document
 * 2. Corrects Local 602 document IDs
 * 
 * Run with: node migration_script.js
 */

const { Firestore } = require('@google-cloud/firestore');
const path = require('path');

// Set the environment variable for Google Cloud credentials
process.env.GOOGLE_APPLICATION_CREDENTIALS = path.resolve(__dirname, './config/firebase_config.json');

// Firestore initialization
const firebaseConfig = {
  projectId: 'journeyman-jobs',
  keyFilename: path.resolve(__dirname, './config/firebase_config.json')
};

const db = new Firestore(firebaseConfig);

/**
 * Removes the invalid Local 125 document
 * @returns {Promise<void>}
 */
async function removeInvalidLocal125Doc() {
  try {
    console.log('Removing invalid Local 125 document...');
    const docRef = db.collection('locals').doc('125-line_clearance_tree_trimming-STORM_CALLS');
    await docRef.delete();
    console.log('Successfully removed invalid Local 125 document');
  } catch (error) {
    console.error('Error removing invalid Local 125 document:', error);
  }
}

/**
 * Corrects Local 602 document IDs to include employer
 * @returns {Promise<void>}
 */
async function correctLocal602DocIDs() {
  try {
    console.log('Correcting Local 602 document IDs...');
    
    // Get all Local 602 jobs
    const snapshot = await db
      .collection('jobs')
      .where('localNumber', '==', '602')
      .get();
    
    console.log(`Found ${snapshot.size} Local 602 jobs to process`);
    
    // Process each document
    for (const doc of snapshot.docs) {
      const jobData = doc.data();
      const oldId = doc.id;
      
      // Generate new ID with employer included
      const classification = jobData.classification || jobData.jobClass || 'Unknown';
      const employer = jobData.employer || 'Unknown';
      const newId = `602-${classification}-${employer.replace(/[^a-z0-9]/gi, '_')}`;
      
      // Skip if ID is already correct
      if (oldId === newId) {
        console.log(`Document ${oldId} already has correct ID format`);
        continue;
      }
      
      console.log(`Migrating document ${oldId} to ${newId}`);
      
      // Create new document with correct ID
      await db.collection('jobs').doc(newId).set(jobData);
      
      // Delete old document
      await db.collection('jobs').doc(oldId).delete();
    }
    
    console.log('Successfully corrected Local 602 document IDs');
  } catch (error) {
    console.error('Error correcting Local 602 document IDs:', error);
  }
}

/**
 * Main migration function
 */
async function runMigration() {
  try {
    console.log('Starting migration script...');
    
    // Run migrations
    await removeInvalidLocal125Doc();
    await correctLocal602DocIDs();
    
    console.log('Migration completed successfully');
  } catch (error) {
    console.error('Migration failed:', error);
  }
}

// Run the migration if executed directly
if (require.main === module) {
  runMigration()
    .then(() => console.log('Migration script completed'))
    .catch(err => {
      console.error('Migration script failed:', err);
      process.exit(1);
    });
}

module.exports = { runMigration, removeInvalidLocal125Doc, correctLocal602DocIDs };