const puppeteer = require('puppeteer-core');
const fs = require('fs').promises;
const path = require('path');
const { Firestore, FieldValue } = require('@google-cloud/firestore');

// Set the environment variable for Google Cloud credentials
process.env.GOOGLE_APPLICATION_CREDENTIALS = path.resolve(__dirname, './config/firebase_config.json');

// Firestore initialization
const firebaseConfig = {
  projectId: 'journeyman-jobs',
  keyFilename: path.resolve(__dirname, './config/firebase_config.json')
};

const db = new Firestore(firebaseConfig);

// Proxy Configuration - Using WebSocket protocol for Puppeteer
const AUTH = 'brd-customer-hl_482339a5-zone-scraping222_111:484fl5v89aaf';
const SBR_WS_ENDPOINT = `wss://${AUTH}@brd.superproxy.io:9222`;

// Function to sanitize strings for Firestore document IDs
function sanitizeString(str) {
  return str ? str.replace(/[\/\\.\#\$\[\]]/g, '').replace(/\s+/g, '_') : '';
}

// Function to generate a consistent job ID
function generateJobId(localNumber, classification, job) {
    const employer = sanitizeString(job.employer || job.Company || job.company || '');
    return `${localNumber}-${classification}-${employer}`;
}

/**
 * Validates if a job entry is within a valid table boundary
 * Helps filter out generated or invalid entries
 *
 * @param {Object} job - The job object to validate
 * @returns {boolean} - True if the job is valid, false otherwise
 */
function isInTable(job) {
    return job.requestDate && job.startDate && !job.comments.includes('GENERATED');
}

// Updated CRUD procedure that maintains isolation between different locals
async function updateDatabaseWithJobs(localNumber, classification, jobs) {
    console.log(`Updating database for Local ${localNumber}, classification: ${classification}`);
    
    // Fetch existing jobs from Firestore for the specific local and classification
    const existingJobsSnapshot = await db
        .collection('jobs')
        .where('localNumber', '==', localNumber)
        .where('classification', '==', classification)
        .get();

    const existingJobs = new Map();
    existingJobsSnapshot.forEach(doc => {
        existingJobs.set(doc.id, doc.data());
    });

    // Track job IDs that are still valid
    const validJobIds = new Set();

    for (const job of jobs) {
        // Create a unique, sanitized job ID
        const jobId = generateJobId(localNumber, classification, job);
        validJobIds.add(jobId);

        const jobData = {
            ...job,
            classification,
            localNumber,
        };

        const jobDocRef = db.collection('jobs').doc(jobId);

        if (existingJobs.has(jobId)) {
            // Job exists; update it without changing the initial timestamp
            const existingJobData = existingJobs.get(jobId);
            await jobDocRef.update({
                ...jobData,
                timestamp: existingJobData.timestamp || FieldValue.serverTimestamp(),
            });
            console.log(`Updated job ${jobId}`);
        } else {
            // Job doesn't exist; create it with a timestamp
            await jobDocRef.set({
                ...jobData,
                timestamp: FieldValue.serverTimestamp(),
            });
            console.log(`Added new job ${jobId}`);
        }
    }

    // Delete jobs that are no longer on the website
    for (const [jobId] of existingJobs) {
        if (!validJobIds.has(jobId)) {
            await db.collection('jobs').doc(jobId).delete();
            console.log(`Deleted outdated job ${jobId}`);
        }
    }
}

module.exports = {
    db,
    SBR_WS_ENDPOINT,
    sanitizeString,
    generateJobId,
    isInTable,
    updateDatabaseWithJobs
};