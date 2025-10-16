const puppeteer = require('puppeteer');
const fs = require('fs').promises;
const path = require('path');

// Configuration for the standalone script
const OUTPUT_FILE = 'ibew125_jobs.json';

/**
 * Standalone function to save results to a JSON file
 */
async function saveResultsToFile(data, filename) {
  try {
    await fs.writeFile(filename, JSON.stringify(data, null, 2));
    console.log(`Results saved to ${filename}`);
  } catch (error) {
    console.error(`Error saving results: ${error.message}`);
  }
}

/**
 * Scrapes job listings from IBEW Local 125's dispatch page
 * Handles date propagation and data cleaning
 */
async function scrapeJobs() {
  let browser = null;
  try {
    // Launch a browser instance (instead of connecting to an external one)
    console.log('Launching browser...');
    browser = await puppeteer.launch({
      headless: "new", // Use new headless mode
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    // Create new page and navigate
    const page = await browser.newPage();
    console.log('Navigating to IBEW 125 dispatch page...');
    await page.goto('https://www.ibew125.com/?zone=/unionactive/view_article.cfm&HomeID=710029&page=Dispatch', {
      waitUntil: 'networkidle0',
      timeout: 60000
    });

    // Wait for table to load
    await page.waitForSelector('#maintablenavlist');
    console.log('Page loaded, extracting job data...');

    // Extract job data from table and build JSON object with metadata
    const result = await page.evaluate(() => {
      const rows = Array.from(document.querySelectorAll('#maintablenavlist tr')).slice(2); // Skip header rows
      let total_rows = rows.length;
      let lastDate = null;
      let lastCompany = null;
      let currentCompanyDate = null;
      
      // Initialize counters for logging
      let skipped_rows = 0;
      let filtered_rows = 0;
      
      const validJobs = [];

      // Process each row
      for (const row of rows) {
        const cells = Array.from(row.querySelectorAll('td'));
        if (cells.length < 5) {
          skipped_rows++;
          continue;
        }
        
        // Extract raw data from cells
        const rawData = {
          date: cells[0]?.textContent?.trim() || "",
          company: cells[1]?.textContent?.trim() || "",
          classification: cells[2]?.textContent?.trim().replace(/\s+/g, " ") || "",
          certifications: cells[3]?.textContent?.trim() || "",
          hours: cells[4]?.textContent?.trim() || "",
          work_type: cells[5]?.textContent?.trim() || ""
        };
        
        // Clean whitespace from all values similar to Python's approach
        const cleanedData = {};
        for (const [key, value] of Object.entries(rawData)) {
          cleanedData[key] = (value || '').toString().trim().replace(/\s+/g, ' ');
        }
        
        // Skip header rows, "STORM CALLS", and empty rows
        if (cleanedData.company === "Company - Construction" || 
            cleanedData.company === "STORM CALLS" ||
            (!cleanedData.company && !cleanedData.classification)) {
          skipped_rows++;
          continue;
        }

        // Handle date propagation logic
        if (cleanedData.date) {
          lastDate = cleanedData.date;
          lastCompany = cleanedData.company;
          currentCompanyDate = lastDate;
        } else if (cleanedData.company) {
          if (!currentCompanyDate || lastCompany !== cleanedData.company) {
            currentCompanyDate = lastDate;
            lastCompany = cleanedData.company;
          }
          cleanedData.date = currentCompanyDate;
        }
        
        // Only include valid job entries
        if (cleanedData.company && cleanedData.classification) {
          // Sort fields alphabetically to match Python output
          const sortedData = {
            certifications: cleanedData.certifications,
            classification: cleanedData.classification,
            company: cleanedData.company,
            date: cleanedData.date,
            hours: cleanedData.hours,
            work_type: cleanedData.work_type
          };
          validJobs.push(sortedData);
          filtered_rows++;
        }
      }
      
      // Create metadata object to match Python output
      const metadata = {
        total_rows,
        rows_kept: filtered_rows,
        rows_skipped: skipped_rows
      };
      
      return { 
        job_listings: validJobs, 
        metadata
      };
    });

    console.log(`Found ${result.job_listings.length} valid job listings`);

    // Log all job listings for debugging
    result.job_listings.forEach((job, index) => {
      console.log(`\nJob Listing ${index + 1}:`);
      console.log(`Date: ${job.date}`);
      console.log(`Company: ${job.company}`);
      console.log(`Classification: ${job.classification}`);
      console.log(`Certifications: ${job.certifications}`);
      console.log(`Hours: ${job.hours}`);
      console.log(`Work Type: ${job.work_type}`);
      console.log("--------------------------------------------------");
    });

    return result;
  } catch (error) {
    console.error('Error in IBEW 125 scraper:', error);
    throw error;
  } finally {
    // Clean up browser resources
    if (browser) {
      try {
        await browser.close();
        console.log('Browser closed');
      } catch (error) {
        console.error('Error closing browser:', error);
      }
    }
  }
}

// Run the script if executed directly
if (require.main === module) {
  console.log('Starting standalone IBEW 125 scraper...');
  scrapeJobs()
    .then(() => console.log('Scraping completed successfully'))
    .catch(err => {
      console.error('Scraping failed:', err);
      process.exit(1);
    });
}

module.exports = { scrapeJobs };