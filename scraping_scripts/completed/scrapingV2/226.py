import json
import asyncio
import os
from crawl4ai import AsyncWebCrawler
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy, LLMExtractionStrategy

async def extract_job_data():
    # Define the CSS extraction schema for job listings
    css_schema = {
        "name": "Job Listings",
        "baseSelector": ".job-listing",
        "fields": [
            {
                "name": "title",
                "selector": "h2.title",
                "type": "text"
            },
            {
                "name": "company",
                "selector": "div.company",
                "type": "text"
            },
            {
                "name": "location",
                "selector": "div.location",
                "type": "text"
            },
            {
                "name": "pay",
                "selector": "div.pay",
                "type": "text"
            },
            {
                "name": "requirements",
                "selector": "div.requirements",
                "type": "text"
            },
            {
                "name": "description",
                "selector": "div.description",
                "type": "text"
            }
        ]
    }

    # Create the CSS extraction strategy
    css_strategy = JsonCssExtractionStrategy(css_schema, verbose=True)

    async with AsyncWebCrawler(verbose=True) as crawler:
        # First, extract structured data using CSS strategy
        css_result = await crawler.arun(
            url="https://www.ibew226.com/ibew226_dir/Jobs",
            extraction_strategy=css_strategy,
            bypass_cache=True,
        )

        # Ensure the CSS extraction was successful
        if not css_result.success:
            print("Failed to crawl and extract job listings using CSS strategy.")
            return

        # Parse the extracted content
        jobs = json.loads(css_result.extracted_content)
        print(f"Successfully extracted {len(jobs)} job listings using CSS strategy.")

        # Prepare for LLM extraction for semantic analysis
        llm_strategy = LLMExtractionStrategy(
            provider="openai/gpt-4o",
            api_token=os.getenv('OPENAI_API_KEY'),
            instruction="Analyze the job listings to classify their classification, pay, and location.",
            extraction_type="schema"
        )

        # Use the LLM strategy for semantic analysis on the extracted job data
        llm_result = await crawler.arun(
            url="https://www.ibew226.com/ibew226_dir/Jobs",
            extraction_strategy=llm_strategy,
            bypass_cache=True,
        )

        # Ensure the LLM extraction was successful
        if not llm_result.success:
            print("Failed to analyze job listings using LLM strategy.")
            return

        # Parse the LLM extracted content
        analyzed_jobs = json.loads(llm_result.extracted_content)
        print(f"Successfully analyzed job listings with LLM strategy.")

        # Ensure the output directory exists
        output_dir = ".outputs/scrapers/"
        os.makedirs(output_dir, exist_ok=True)

        # Save results to JSON files
        with open(os.path.join(output_dir, "css_extracted_jobs.json"), "w", encoding="utf-8") as f:
            json.dump(jobs, f, indent=2)

        with open(os.path.join(output_dir, "llm_analyzed_jobs.json"), "w", encoding="utf-8") as f:
            json.dump(analyzed_jobs, f, indent=2)

# Run the async function
asyncio.run(extract_job_data())