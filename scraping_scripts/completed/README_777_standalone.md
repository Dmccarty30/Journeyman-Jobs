# IBEW Local 77 Standalone Scraper

This standalone script allows you to run the IBEW Local 77 job scraper without requiring Firebase initialization. It's designed for troubleshooting and testing purposes.

## Features

- Scrapes job listings from the IBEW Local 77 website
- Saves results to local JSON files instead of Firebase
- Creates separate files for raw data, individual job classifications, and all combined jobs
- Includes detailed logging for troubleshooting

## Prerequisites

- Node.js installed
- Puppeteer-core installed (`npm install puppeteer-core`)
- Access to a browser automation service or a locally running browser instance with a WebSocket endpoint

## Configuration

Before running the script, you need to configure the WebSocket endpoint:

1. Open `777_standalone.js`
2. Locate the `SBR_WS_ENDPOINT` constant (around line 15)
3. Replace `'YOUR_BROWSER_WEBSOCKET_ENDPOINT_HERE'` with your actual WebSocket endpoint

### Getting a WebSocket Endpoint

You have several options:

#### Option 1: Use a local Chrome instance

```javascript
// Add this to the top of your script
const puppeteer = require('puppeteer');

// Replace the existing scrapeJobs function with this modified version
async function scrapeJobs() {
  console.log('Starting script...');
  
  // Launch a local browser instead of connecting to an endpoint
  const browser = await puppeteer.launch({
    headless: false, // Set to true for headless mode
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  try {
    // Rest of the function remains the same
    // ...
  } finally {
    await browser.close();
  }
}
```

#### Option 2: Use a browser automation service

If you're using a service like SBR, Bright Data, or similar:

1. Get your WebSocket endpoint from your provider's dashboard
2. It typically looks like: `wss://your-provider.com/browser/12345...`

## Usage

1. Make sure you've configured the WebSocket endpoint
2. Run the script:

```bash
node 777_standalone.js
```

3. The script will:
   - Connect to the browser
   - Navigate to the IBEW Local 77 job board
   - Scrape job listings
   - Save the results to the `output` directory

## Output Files

The script creates several JSON files in the `output` directory:

- `local77_raw_data_[timestamp].json`: Raw data extracted from the page
- `local77_[classification]_[timestamp].json`: One file per job classification
- `local77_all_jobs_[timestamp].json`: All combined jobs in a single file

## Troubleshooting

### Common Issues

1. **WebSocket Connection Error**
   - Make sure your WebSocket endpoint is correct and active
   - Check if your browser automation service subscription is active

2. **Selector Not Found**
   - The website structure may have changed
   - Check the console output for the table HTML and update selectors if needed

3. **Empty Results**
   - The page might not have fully loaded
   - Try increasing the wait time or changing the waitUntil condition

### Debugging Tips

- The script logs the HTML content of the job table, which can help identify changes in the page structure
- Check the raw data file to see exactly what was extracted before combination
- If the script fails, the error will be logged to the console

## Modifying the Script

If you need to modify how the data is processed:

- The job extraction happens in the `page.evaluate()` function
- The job combination logic is in the `combinedJobs` array construction
- File saving happens in the `saveJobsToFile()` function

## **TODO**

- I need to extract the [Book Status] from this URL.

    (("https://www.ibew77.org/outside-line"))

- I need to get the [Referral Guidelines] from:
    (https://issuu.com/ibewlocal77/docs/referral_guidelines_modified_10.25.2021?fr=sOTIyMzQzNTc3NDg)

    #__layout > div > div > div.page-content.section > div > div > div.grid-x > div.cell.large-4.medium-11.small-10

    #__layout > div > div > div.page-content.section > div > div > div.grid-x > div.cell.large-5.medium-11.small-11