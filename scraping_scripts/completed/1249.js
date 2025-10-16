const puppeteer = require('puppeteer-core');
const fs = require('fs').promises;
const path = require('path');
const { db, SBR_WS_ENDPOINT, updateDatabaseWithJobs } = require('./jobCrud');

// Local number for this specific scraper
const localNumber = '1249';

async function scrapeJobPostings() {
  try {
    console.log('Starting job scraping for Local 1249...');

    // URL of the job board page
    const targetURL = 'https://ibew1249.org/job-board/';

    // Launch Puppeteer to extract the iframe src
    const browser = await puppeteer.connect({
      browserWSEndpoint: SBR_WS_ENDPOINT,
    });

    const page = await browser.newPage();
    await page.goto(targetURL, { waitUntil: 'networkidle2', timeout: 2 * 60 * 1000 });

    // Extract the iframe src
    const iframeSrc = await page.evaluate(() => {
      const iframe = document.querySelector('iframe[src*="docs.google.com/spreadsheets"]');
      return iframe ? iframe.src : null;
    });

    await browser.close();

    if (!iframeSrc) {
      throw new Error('Google Sheets iframe not found on the page.');
    }

    console.log(`Found iframe source: ${iframeSrc}`);

    // Extract the Spreadsheet ID from the iframe src
    const spreadsheetIdMatch = iframeSrc.match(/\/d\/([a-zA-Z0-9-_]+)/);
    if (!spreadsheetIdMatch || spreadsheetIdMatch.length < 2) {
      throw new Error('Unable to extract Spreadsheet ID from iframe src.');
    }
    const spreadsheetId = spreadsheetIdMatch[1];

    console.log(`Extracted Spreadsheet ID: ${spreadsheetId}`);

    // Construct the CSV export URL
    const csvExportUrl = `https://docs.google.com/spreadsheets/d/${spreadsheetId}/export?format=csv`;

    console.log(`CSV Export URL: ${csvExportUrl}`);

    // Fetch the CSV data using the built-in fetch
    const response = await fetch(csvExportUrl);
    if (!response.ok) {
      throw new Error(`Failed to download CSV data: ${response.statusText}`);
    }
    const csvData = await response.text();

    console.log('CSV data downloaded successfully.');

    // Parse the CSV data
    const rows = csvData.split('\n').map(row => {
      // Handle quoted fields properly
      const fields = [];
      let field = '';
      let inQuotes = false;
      
      for (let i = 0; i < row.length; i++) {
        if (row[i] === '"') {
          inQuotes = !inQuotes;
        } else if (row[i] === ',' && !inQuotes) {
          fields.push(field);
          field = '';
        } else {
          field += row[i];
        }
      }
      fields.push(field);
      return fields;
    });

    console.log('First few rows:', rows.slice(0, 5));

    const filteredJobPostings = [];
    
    // Define the expected headers
    const headers = [
      "Job#",
      "Company",
      "Men Needed",
      "Shift",
      "Duration",
      "Benefits",
      "Type of Work",
      "Location",
      "Notes"
    ];

    // Process each row
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      
      // Skip empty rows or rows that don't have enough columns
      if (!row[0] || row.length < 3) continue;

      // Skip rows that don't look like job entries
      if (row[0].toLowerCase().includes('job') || 
          row[0].toLowerCase().includes('company') ||
          row[0].trim() === '') {
        continue;
      }

      // Create job object from row
      const jobData = {};
      headers.forEach((header, index) => {
        let value = row[index] ? row[index].trim() : '';
        // Remove any quotes and extra whitespace
        value = value.replace(/^["'\s]+|["'\s]+$/g, '');
        
        if (header === "Company") {
          // Clean up company name if it has a number prefix
          const match = value.match(/^\d+\s*(.+)$/);
          jobData[header] = match ? match[1].trim() : value;
        } else {
          jobData[header] = value || 'N/A';
        }
      });

      if (jobData.Company && jobData.Company !== '') {
        filteredJobPostings.push(jobData);
      }
    }

    console.log(`Parsed ${filteredJobPostings.length} job postings.`);
    if (filteredJobPostings.length > 0) {
      console.log('First job posting:', filteredJobPostings[0]);
    }

    // Use the shared updateDatabaseWithJobs function to handle Firestore operations
    const classification = 'Journeyman_Lineman';
    await updateDatabaseWithJobs(localNumber, classification, filteredJobPostings);

    console.log('Scraping and data storage completed successfully.');
  } catch (err) {
    console.error('An error occurred during scraping:', err);
    throw err;
  }
}

// Export the scraping function
module.exports = { scrapeJobPostings };