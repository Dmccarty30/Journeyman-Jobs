const puppeteer = require('puppeteer-core');
const { db, SBR_WS_ENDPOINT, updateDatabaseWithJobs } = require('./jobCrud');

// Local number for this specific scraper
const localNumber = '125';

async function scrapeJobs() {
  console.log('Starting script...');
  const browser = await puppeteer.connect({
    browserWSEndpoint: SBR_WS_ENDPOINT,
  });

  try {
    console.log('Connected! Navigating...');
    const page = await browser.newPage();
    await page.goto('https://www.ibew125.com/?zone=/unionactive/view_article.cfm&HomeID=710029&page=Dispatch', {
      waitUntil: 'networkidle0'
    });

    // Wait for table to load using waitForSelector with XPath
    await page.waitForSelector("xpath=//table[@id='maintablenavlist']");

    // Extract job data using XPath extraction (adapted from Python extraction strategy)
    const jobs = await page.evaluate(() => {
      const rows = [];
      const xpathExpression = "//table[@id='maintablenavlist']//tr[position()>1]";
      const result = document.evaluate(xpathExpression, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
      
      for (let i = 0; i < result.snapshotLength; i++) {
        const row = result.snapshotItem(i);
        
        // Helper function to get text content using XPath
        const getTextByXPath = (xpath, contextNode) => {
          const result = document.evaluate(xpath, contextNode, null, XPathResult.STRING_TYPE, null);
          return result.stringValue.trim();
        };

        const company = getTextByXPath(".//td[1]", row);
        const classification = getTextByXPath(".//td[2]", row);
        const certifications = getTextByXPath(".//td[3]", row);
        const hours = getTextByXPath(".//td[4]", row);
        const work_type = getTextByXPath(".//td[5]", row);

        // Only include rows that have meaningful content
        if (company || classification || certifications || hours || work_type) {
          // Filter out header rows and empty rows
          if (!(company.includes("Company - Construction") || 
                company.includes("STORM CALLS") || 
                company.length === 0)) {
            rows.push({
              company,
              classification,
              certifications,
              hours,
              work_type,
              // Add metadata for Firestore
              timestamp: new Date().toISOString(),
              source: 'IBEW 125 Dispatch',
              url: 'https://www.ibew125.com/?zone=/unionactive/view_article.cfm&HomeID=710029&page=Dispatch'
            });
          }
        }
      }
      return rows;
    });

    console.log('Extracted Job Details:', jobs);

    if (jobs.length === 0) {
      console.log('No jobs found. Double-check the page structure and selectors.');
      return;
    }

    // Update Firestore with extracted job data
    for (const job of jobs) {
      try {
        // Use company name as classification key, fallback to date if company is empty
        const classificationKey = (job.company || job.classification || 'unknown')
          .replace(/[^a-zA-Z0-9]/g, '_')
          .replace(/_+/g, '_')
          .toLowerCase();

        await updateDatabaseWithJobs(localNumber, classificationKey, [{
          title: `${job.classification} - ${job.company}`,
          description: `
            Classification: ${job.classification}
            Company: ${job.company}
            Certifications Required: ${job.certifications}
            Hours: ${job.hours}
            Work Type: ${job.work_type}
          `.trim(),
          raw_data: job,
          timestamp: job.timestamp,
          source: job.source,
          url: job.url
        }]);

        console.log(`Updated Firestore with job from ${job.company}`);
      } catch (err) {
        console.error(`Error updating database for job from ${job.company}:`, err);
        // Continue with next job even if database update fails
        continue;
      }
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
