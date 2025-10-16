const puppeteer = require('puppeteer-core');
const fs = require('fs').promises;
const path = require('path');
const { Firestore, FieldValue } = require('@google-cloud/firestore');

// Set the environment variable for Google Cloud credentials
process.env.GOOGLE_APPLICATION_CREDENTIALS = path.resolve(__dirname, '../completed/config/firebase_config.json');

// Firestore initialization
const firebaseConfig = {
  projectId: 'journeyman-jobs',
  keyFilename: path.resolve(__dirname, '../completed/config/firebase_config.json')
};

const db = new Firestore(firebaseConfig);

// Proxy Configuration - Using HTTPS protocol as shown in Python examples
const AUTH = 'brd-customer-hl_482339a5-zone-scraping222_111:484fl5v89aaf';
const SBR_WS_ENDPOINT = `https://${AUTH}@brd.superproxy.io:9222`;

// Adjust this variable to match the specific local you are targeting
const localNumber = '111';

// Function to sanitize strings for Firestore document IDs
function sanitizeString(str) {
    return str.replace(/[\/\\\.\#\$\[\]]/g, '').replace(/\s+/g, '_');
}

// Function to generate a consistent job ID
function generateJobId(localNumber, classification, job) {
    const company = sanitizeString(job.company || '');
    const location = sanitizeString(job.location || '');
    return `${localNumber}-${classification}-${company}-${location}`;
}

async function scrapeJobsForClassification(page, classification) {
    console.log(`Scraping data for ${classification}...`);

    const jobs = await page.evaluate((classification) => {
        const jobElements = document.querySelectorAll(`div.${classification}.dispatch-section div.dispatch_cms-item`);
        const jobs = [];

        jobElements.forEach(job => {
            const company = job.querySelector('.company .dispatch-paragraph')?.innerText.trim();
            const datePosted = job.querySelector('.dateposted .dispatch-paragraph')?.innerText.trim();
            const jobClass = job.querySelector('.class .dispatch-paragraph')?.innerText.trim();
            const numberOfJobs = job.querySelector('.ofjobs .dispatch-paragraph')?.innerText.trim();
            const location = job.querySelector('.locations .dispatch-paragraph p')?.innerText.trim();
            const hours = job.querySelector('.hours .dispatch-paragraph')?.innerText.trim();
            const startDate = job.querySelector('.startdate .dispatch-paragraph')?.innerText.trim();
            const wage = job.querySelector('.wage .dispatch-paragraph')?.innerText.trim();
            const startTime = job.querySelector('.starttime .dispatch-paragraph')?.innerText.trim();
            const sub = job.querySelector('.sub .dispatch-paragraph')?.innerText.trim();
            const qualifications = job.querySelector('.qual .dispatch-paragraph p')?.innerText.trim();
            const agreement = job.querySelector('.agreement .dispatch-paragraph')?.innerText.trim();

            jobs.push({
                company,
                datePosted,
                jobClass,
                numberOfJobs,
                location,
                hours,
                startDate,
                wage,
                startTime,
                sub,
                qualifications,
                agreement,
            });
        });

        return jobs;
    }, classification);

    console.log(`Finished scraping data for ${classification}.`);
    return jobs;
}

async function updateDatabaseWithJobs(classification, jobs) {
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

async function main() {
    console.log('Connecting to Scraping Browser...');
    const browser = await puppeteer.connect({
        browserWSEndpoint: SBR_WS_ENDPOINT,
    });
    let page;

    try {
        console.log('Connected! Navigating...');
        page = await browser.newPage();
        await page.goto('https://www.ibew611.org/outside-daybook', { timeout: 2 * 60 * 1000 });
        console.log('Navigated! Scraping page content...');

        const classifications = [
            'journeyman-lineman',
            'journeyman-wireman',
            'traffic-technician',
            'journeyman-fitter',
            'street-light-technician',
            'operator',
            'groundman',
            'cdl-groundman',
            'line-equipment-operator',
        ];

        for (const classification of classifications) {
            const jobs = await scrapeJobsForClassification(page, classification);
            await updateDatabaseWithJobs(classification, jobs);

            // Delay before moving to the next classification to avoid overwhelming the server
            await new Promise(resolve => setTimeout(resolve, 3000)); // 3-second delay
        }

        console.log('All job data has been updated in Firestore.');
    } catch (err) {
        console.error('An error occurred:', err);
    } finally {
        try {
            if (page) {
                console.log('Taking screenshot to page.png');
                const screenshotPath = path.join(__dirname, 'page.png');
                await fs.mkdir(path.dirname(screenshotPath), { recursive: true });
                await page.screenshot({ path: screenshotPath, fullPage: true });
            }
        } catch (error) {
            console.error('Error taking screenshot:', error);
        }
        await browser.close();
    }
}

if (require.main === module) {
    main().catch(err => {
        console.error(err.stack || err);
        process.exit(1);
    });
}
