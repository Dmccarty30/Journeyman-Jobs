const puppeteer = require('puppeteer-core');
const fs = require('fs').promises;
const path = require('path');

// Set the environment variable for Google Cloud credentials
process.env.GOOGLE_APPLICATION_CREDENTIALS = path.resolve(__dirname, 'X:/Journeyman_Jobs/v3/completed/config/firebase_config.json');

// Proxy Configuration
const AUTH = 'brd-customer-hl_cd00a5b2-zone-scraping_222:0u5wtrzvj8lk';
const SBR_WS_ENDPOINT = `wss://brd-customer-hl_482339a5-zone-scraping222_111:484fl5v89aaf@brd.superproxy.io:9222`;

async function main() {
    console.log('Starting script...');
    const browser = await puppeteer.connect({
        browserWSEndpoint: SBR_WS_ENDPOINT,
    });

    try {
        console.log('Connected! Navigating...');
        const page = await browser.newPage();

        const url = 'https://www.ibew245.com/index.cfm?zone=/unionactive/view_page.cfm&page=Job20Board';
        await page.goto(url, { waitUntil: 'networkidle2' });

        console.log('Navigated! Waiting for job listings to load...');
        await page.waitForSelector('tbody', { timeout: 120000 });

        // Extract job listing information with better filtering
        const jobs = await page.evaluate(() => {
            const jobElements = Array.from(document.querySelectorAll('tbody > tr'));
            const jobList = [];
            
            // Skip header rows and empty rows
            jobElements.forEach(row => {
                const cells = row.querySelectorAll('td');
                if (cells.length === 8) {  // Only process rows with exactly 8 cells
                    const contractor = cells[0]?.innerText.trim();
                    // Only add if it's a real job listing (checking for actual contractor name)
                    if (contractor && contractor !== 'CONTRACTOR' && !contractor.includes('IF YOU ARE INTERESTED')) {
                        const jobData = {
                            contractor: contractor,
                            location: cells[1]?.innerText.trim(),
                            jobDescription: cells[2]?.innerText.trim(),
                            startDate: cells[3]?.innerText.trim(),
                            requirements: cells[4]?.innerText.trim(),
                            positions: cells[5]?.innerText.trim(),
                            hours: cells[6]?.innerText.trim(),
                            perDiem: cells[7]?.innerText.trim(),
                        };
                        // Additional validation - only add if we have actual data
                        if (jobData.location !== 'Unknown Location' && 
                            jobData.jobDescription !== 'No Description Available') {
                            jobList.push(jobData);
                        }
                    }
                }
            });
            return jobList;
        });

        console.log('Scraped job listings:', jobs);
        // Optional: Save to file
        await fs.writeFile('245__job_listings.json', JSON.stringify(jobs, null, 2));

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