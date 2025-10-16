const puppeteer = require('puppeteer-core');
const path = require('path');

// Bright Data Proxy Configuration
const SBR_WS_ENDPOINT = `wss://brd-customer-hl_482339a5-zone-scraping222_111:484fl5v89aaf@brd.superproxy.io:9222`;

async function main() {
  console.log('Starting script...');
  const browser = await puppeteer.connect({
    browserWSEndpoint: SBR_WS_ENDPOINT,
  });

  try {
    console.log('Connected! Navigating...');
    const page = await browser.newPage();
    await page.goto('https://www.ibew125.com/index.cfm?zone=/unionactive/private_view_page.cfm&page=Job20Listings', {
      waitUntil: 'networkidle0'
    });

    // Extract job data
    const jobs = await page.evaluate(() => {
      const jobRows = Array.from(document.querySelectorAll('table tbody tr.resprow'));

      return jobRows.map(row => {
        const titleElement = row.querySelector('a');
        const descriptionElement = row.querySelector('div.w3-card');

        if (titleElement && descriptionElement) {
          return {
            title: titleElement.textContent.trim(),
            link: titleElement.href,
            description: descriptionElement.textContent.trim()
          };
        }
        return null;
      }).filter(job => job !== null);
    });

    console.log('Scraped Job Details:', jobs);

    if (jobs.length === 0) {
      console.log('No jobs found. Double-check the page structure and selectors.');
    }

    // Process scraped jobs
    for (const job of jobs) {
      try {
        // Navigate to the job listing link and scrape detailed information
        await page.goto(job.link, { waitUntil: 'networkidle0' });
        const detailedJobData = await page.evaluate(() => {
          // Extract detailed job information
          const detailedInfo = document.querySelector('div.w3-card');
          return detailedInfo ? detailedInfo.textContent.trim() : '';
        });

        console.log(`Scraped detailed information for job ${job.title}:`, detailedJobData);

        // Return to the main page
        await page.goBack();

        // Add a delay to avoid hitting the navigation limit
        await new Promise(resolve => setTimeout(resolve, 2000)); // 2-second delay
      } catch (err) {
        console.error(`Error navigating to or scraping job ${job.title}:`, err);
      }
    }

  } catch (err) {
    console.error('An error occurred:', err);
  } finally {
    await browser.close();
  }
}

if (require.main === module) {
  main().catch(err => {
    console.error(err.stack || err);
    process.exit(1);
  });
}

module.exports = main;