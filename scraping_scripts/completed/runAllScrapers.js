const scraper111 = require('./111').scrapeJobs;
const scraper1249 = require('./1249').scrapeJobPostings;
const scraper125 = require('./125').scrapeJobs;
const scraper602 = require('./602').scrapeJobs;
const scraper77 = require('./77').scrapeJobs;
const scraper84 = require('./84').scrapeJobs;
const scraper226 = require('./226').scrapeJobs;

async function runAllScrapers() {
    const scrapers = [
        { name: 'Local 111', fn: scraper111 },
        { name: 'Local 1249', fn: scraper1249 },
        { name: 'Local 125', fn: scraper125 },
        { name: 'Local 226', fn: scraper226 },
        { name: 'Local 602', fn: scraper602 },
        { name: 'Local 77', fn: scraper77 },
        { name: 'Local 84', fn: scraper84 }
    ];

    console.log('Starting all scrapers...\n');

    for (const scraper of scrapers) {
        console.log(`\n${'-'.repeat(50)}`);
        console.log(`Starting ${scraper.name} scraper...`);
        console.log(`${'-'.repeat(50)}\n`);

        try {
            await scraper.fn();
            console.log(`\n✓ ${scraper.name} completed successfully\n`);
        } catch (error) {
            console.error(`\n✗ Error in ${scraper.name}:`, error);
            // Continue with next scraper even if one fails
        }

        // Add a delay between scrapers to avoid overwhelming resources
        await new Promise(resolve => setTimeout(resolve, 5000));
    }

    console.log(`\n${'-'.repeat(50)}`);
    console.log('All scrapers have finished running');
    console.log(`${'-'.repeat(50)}\n`);
}

// Run if called directly
if (require.main === module) {
    runAllScrapers().catch(error => {
        console.error('Fatal error:', error);
        process.exit(1);
    });
}

module.exports = runAllScrapers;