const axios = require('axios');
const OpenAI = require('openai');
const { updateDatabaseWithJobs } = require('./jobCrud');

// Local number for this specific scraper
const localNumber = '226';

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

/**
 * Preprocesses HTML content to reduce its size before sending to OpenAI API
 * This helps avoid context length exceeded errors by:
 * 1. Extracting only job-related sections when possible
 * 2. Removing scripts, styles, and comments
 * 3. Limiting the overall size to stay within token limits
 * 
 * @param {string} html - The raw HTML content from the webpage
 * @returns {string} - Preprocessed HTML content with reduced size
 */
function preprocessHtml(html) {
  // Try to extract only the job listings section
  const jobSectionRegex = /<div[^>]*class="[^"]*job-listings[^"]*"[^>]*>([\s\S]*?)<\/div>/i;
  const jobSection = jobSectionRegex.exec(html);
  
  if (jobSection && jobSection[1]) {
    console.log('Found job listings section, extracting only relevant content');
    // Return just the job listings section
    return jobSection[1];
  }
  
  // If we can't find a specific section, try to reduce the HTML
  console.log('No specific job section found, reducing overall HTML size');
  
  // Remove scripts, styles, and comments
  let reduced = html
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '')
    .replace(/<!--[\s\S]*?-->/g, '')
    .replace(/\s+/g, ' ');
  
  // Limit to a reasonable size (approximately 6000 tokens)
  // A rough estimate is 4 characters per token
  const maxLength = 24000;
  if (reduced.length > maxLength) {
    console.log(`HTML content too large (${reduced.length} chars), truncating to ${maxLength} chars`);
    reduced = reduced.substring(0, maxLength);
  }
  
  return reduced;
}

async function extractJobsWithLLM(html) {
  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: "Extract job listings from the HTML content. For each job, identify the title, company, and description. Format requirements, location, and other details as part of the description."
        },
        {
          role: "user",
          content: html
        }
      ],
      temperature: 0.2,
    });

    // Parse the response into structured job data
    const jobData = JSON.parse(completion.choices[0].message.content);
    return jobData;
  } catch (error) {
    console.error('Error in LLM extraction:', error);
    throw error;
  }
}

async function scrapeJobs() {
  console.log('Starting IBEW 226 scraper...');

  try {
    // Fetch the job listings page
    const response = await axios.get('https://www.ibew226.com/ibew226_dir/Jobs', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }
    });

    // Preprocess HTML to reduce size before sending to OpenAI
    const processedHtml = preprocessHtml(response.data);
    console.log(`Original HTML size: ${response.data.length}, Processed HTML size: ${processedHtml.length}`);
    
    // Extract jobs using LLM with the preprocessed HTML
    const rawJobs = await extractJobsWithLLM(processedHtml);

    // Transform the jobs into the standard format
    const processedJobs = rawJobs.map(job => {
      // Extract company name from content if available
      const companyMatch = job.content[1]?.match(/^([^|]+)\|/);
      const company = companyMatch ? companyMatch[1].trim() : 'Unknown';

      return {
        title: job.content[0] || 'Unknown Position',
        company: company,
        description: job.content.slice(1).join('\n').trim(),
        timestamp: new Date().toISOString()
      };
    });

    // Group jobs by their title as classification
    const jobsByClassification = {};
    for (const job of processedJobs) {
      const classification = job.title.replace(/[^a-zA-Z0-9]/g, '_');
      if (!jobsByClassification[classification]) {
        jobsByClassification[classification] = [];
      }
      jobsByClassification[classification].push(job);
    }

    // Update database for each classification group
    for (const [classification, jobs] of Object.entries(jobsByClassification)) {
      await updateDatabaseWithJobs(localNumber, classification, jobs);
    }

    console.log('All IBEW 226 job data has been updated in Firestore.');
  } catch (error) {
    console.error('An error occurred:', error);
    throw error;
  }
}

// Export the scraping function
module.exports = { scrapeJobs };