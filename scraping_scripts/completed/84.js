 const puppeteer = require('puppeteer-core');
const { db, SBR_WS_ENDPOINT, updateDatabaseWithJobs } = require('./jobCrud');

// Local number for this specific scraper
const localNumber = '84';

async function scrapeJobs() {
  console.log('Starting script...');
  const browser = await puppeteer.connect({
    browserWSEndpoint: SBR_WS_ENDPOINT,
  });

  try {
    console.log('Connected! Navigating...');
    const page = await browser.newPage();
    await page.goto('https://ibew84.workingsystems.com/workeropenjobs', {
      waitUntil: 'networkidle0'
    });

    // Wait for the table to load
    await page.waitForSelector('.wsiTable');

    // Log the HTML content of the job table
    const tableHTML = await page.evaluate(() => {
      return document.querySelector('.wsiTable').outerHTML;
    });
    console.log('Job Table HTML:', tableHTML);
    
    // Click all expand buttons to show job details (fi-plus/fi-minus toggle)
    await page.evaluate(() => {
      const buttons = document.querySelectorAll('td[data-bind="click: function() { $root.toggleDetails($data); }"] i');
      buttons.forEach(button => {
        if (button.classList.contains('fi-plus')) {
          button.click(); // Click to expand job details
        }
      });
    });

    // Extract job data
    const jobs = await page.evaluate(() => {
      const jobRows = Array.from(document.querySelectorAll('.wsiTable tbody tr'));

      return jobRows.map(row => {
        // Get the employer name
        const employer = row.querySelector('span[data-bind="text: EMPLOYER_NAME"]');
        const city = row.querySelector('span[data-bind="text: CITY"]');
        const startDate = row.querySelector('span[data-bind="text: START_DATE"]');

        // Extract expanded job details (once clicked)
        const jobClass = row.querySelector('span[data-bind="text: JOB_CLASS_DESCRIPTION"]');
        const positionsRequested = row.querySelector('span[data-bind="text: POSITIONS_REQUESTED()"]');
        const positionsAvailable = row.querySelector('span[data-bind="text: POSITIONS_REQUESTED() - POSITIONS_FILLED()"]');
        const book = row.querySelector('span[data-bind="text: BOOK_DESCRIPTION"]');
        const worksite = row.querySelector('span[data-bind="text: WORKSITE_DESCRIPTION"]');
        const hourlyWage = row.querySelector('span[data-bind="text: HOURLY_WAGE"]');
        const reportTo = row.querySelector('span[data-bind="text: REPORT_TO_LOCATION_CODE"]');
        const requestDate = row.querySelector('span[data-bind="text: REQUEST_DATE"]');
        const comments = row.querySelector('span[data-bind="text: REQUEST_NOTE"]');

        // Return the extracted job details
        return {
          employer: employer ? employer.textContent.trim() : 'N/A',
          city: city ? city.textContent.trim() : 'N/A',
          startDate: startDate ? startDate.textContent.trim() : 'N/A',
          shortCall: row.querySelector('span[data-bind="text: SHORT_CALL() == \'T\' ? \'Yes\' : \'No\'"]') ? row.querySelector('span[data-bind="text: SHORT_CALL() == \'T\' ? \'Yes\' : \'No\'"]').textContent.trim() : 'N/A',
          jobClass: jobClass ? jobClass.textContent.trim() : '',
          positionsRequested: positionsRequested ? positionsRequested.textContent.trim() : '',
          positionsAvailable: positionsAvailable ? positionsAvailable.textContent.trim() : '',
          book: book ? book.textContent.trim() : '',
          worksite: worksite ? worksite.textContent.trim() : '',
          hourlyWage: hourlyWage ? hourlyWage.textContent.trim() : '',
          reportTo: reportTo ? reportTo.textContent.trim() : '',
          requestDate: requestDate ? requestDate.textContent.trim() : '',
          comments: comments ? comments.textContent.trim() : ''
        };
      });
    });

    // Combine job data
    const combinedJobs = [
      {
        employer: jobs[0].employer,
        city: jobs[1].city,
        startDate: jobs[0].startDate,
        shortCall: jobs[0].shortCall,
        jobClass: jobs[1].jobClass,
        positionsRequested: jobs[1].positionsRequested,
        positionsAvailable: jobs[1].positionsAvailable,
        book: jobs[1].book,
        worksite: jobs[1].worksite,
        hourlyWage: jobs[1].hourlyWage,
        reportTo: jobs[1].reportTo,
        requestDate: jobs[1].requestDate,
        comments: jobs[1].comments
      },
      {
        employer: jobs[2].employer,
        city: jobs[3].city,
        startDate: jobs[2].startDate,
        shortCall: jobs[2].shortCall,
        jobClass: jobs[3].jobClass,
        positionsRequested: jobs[3].positionsRequested,
        positionsAvailable: jobs[3].positionsAvailable,
        book: jobs[3].book,
        worksite: jobs[3].worksite,
        hourlyWage: jobs[3].hourlyWage,
        reportTo: jobs[3].reportTo,
        requestDate: jobs[3].requestDate,
        comments: jobs[3].comments
      }
    ];

    console.log('Combined Job Details:', combinedJobs);

    // Use shared updateDatabaseWithJobs for each combined job
    for (const job of combinedJobs) {
      const classification = job.jobClass || 'Unknown';
      await updateDatabaseWithJobs(localNumber, classification, [job]);
    }

    console.log('All job data has been updated in Firestore.');
  } catch (err) {
    console.error('An error occurred:', err);
    throw err;
  } finally {
    await browser.close();
  }
}

// Export the scraping function
module.exports = { scrapeJobs };
