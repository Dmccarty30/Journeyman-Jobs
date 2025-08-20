# URL Scraping Command

## Agent Task: Implement IBEW Web Data Extraction Pipeline

**Overall Goal:** Implement and execute a robust, multi-stage web data extraction pipeline to systematically crawl IBEW local union websites, identify relevant job-related content, extract structured job listing data, and store it in a structured database (Firebase Firestore with JSON fallback).

**Input:** The agent will receive a list of starting URLs, each representing an IBEW local union's home page.

**Multi-Agent Architecture Overview:**
This pipeline leverages a multi-agent system, where specialized sub-agents handle distinct phases of the extraction process. The implementing agent will act as the orchestrator, coordinating these sub-agents and managing data flow.

**Pipeline Stages and Sub-Agent Responsibilities:**

For each starting URL, the pipeline must execute the following four phases sequentially, with robust error handling and parallelism where applicable:

### Phase 1: URL Discovery (Delegated to `url-discoverer`)

**Objective:** For a given starting URL, crawl the domain to discover all internal URLs relevant to the IBEW local union.

**Instructions for `url-discoverer`:**

- **Crawl Strategy:** Employ comprehensive crawling strategies including sitemap parsing, depth-first crawling (using Crawl4AI framework), and link extraction (using BeautifulSoup4 and Playwright selectors).
- **Tools:** Utilize `Crawl4AI` as the primary tool, with `Playwright-based crawlers` as fallback.
- **Output:** The agent should return a JSON object containing `discovered_urls` (list of URLs) and relevant metadata (e.g., `depth`, `source_url`).
- **Error Handling:** Log any errors encountered during discovery (e.g., network issues, inaccessible sites) and attempt to continue processing other URLs if possible.

### Phase 2: URL Classification (Delegated to `url-classifier`)

**Objective:** Classify the `discovered_urls` from Phase 1 to determine their relevance for job data extraction or other key IBEW categories.

**Instructions for `url-classifier`:**

- **Classification Method:** Apply ML-based classification using URL tokens, path depth, and keyword presence. The `URL_CLASSIFIER_README.md` provides detailed guidance.
- **Target Categories & Keywords (from `URL_CLASSIFIER_README.md`):**
  - **Jobs:**
    - Keywords: "job board", "job listing", "employment", "dispatch board"
    - URL patterns: `*job*`, `*open calls*`, `*job board*`, `*AvailableJobs*`, `*job listings*`, `*jobcalls*`, `*job calls*`, `*outside construction*`, `*job postings*`, `*jobs*`, `*job hotline*`
  - **Book Signing:**
    - Keywords: "book signing", "sign the book", "out of work list", "journeyman book"
    - URL patterns: `*books*`, `*sign*`, `*out-of-work*`, `*sign*`, `*journeyman book*`, `*book procedures*`
  - **Re-signing:**
    - Keywords: "re-sign", "resign", "renew", "book renewal", "quarterly sign"
    - URL patterns: `*resign*`, `*renew*`, `*re-sign*`, `*update*`, `*quarterly sign*`, `*re-sign form*`, `*re-sign*`, `*re-sign procedure*`, `*referral-and-resign*`
  - **Policies & Procedures:**
    - Keywords: "policy", "procedure", "rule", "guideline", "bylaw", "regulation"
    - URL patterns: `*referrals*`, `*procedure*`, `*hiring hall*`, `*bylaw*`, `*referral*`, `*policy*`, `*procedure*`, `*rule*`, `*guideline*`, `*bylaw*`, `*regulation*`, `*referral rules*`, `*hiring hall referrals*`, `*dispatch rules*`
  - **Contracts:**
    - Keywords: "contract", "CBA", "collective bargaining", "wage scale"
    - URL patterns: `*contract*`, `*cba*`, `*agreement*`, `*bargaining*`
  - **Agreements:**
    - Keywords: "working agreement", "portability", "reciprocal", "pension agreement"
    - URL patterns: `*agreement*`, `*constitution*`, `*CBA*`, `*pension*`
- **Confidence Threshold:** Consider URLs with a relevance score > 0.7 for inclusion in relevant categories.
- **Output:** Return a JSON object with `classified_urls` categorized by type (e.g., `jobs`, `contracts`).
- **Filtering:** Filter out irrelevant URLs based on classification results before proceeding to the next phase.
- **Error Handling:** Log any classification errors and proceed with valid URLs.

### Phase 3: Job Data Extraction (Delegated to `job-extractor`)

**Objective:** For each relevant classified URL (especially those categorized as 'Jobs'), scrape the webpage and extract structured job listing data.

**Instructions for `job-extractor`:**

- **Extraction Schema (from `scraping_process.md`):** Extract data conforming to the following JSON structure:

    ```json
    {
        "job_id": "unique_identifier",
        "title": "Journeyman Electrician",
        "company": "ABC Electrical",
        "location": "Chicago, IL",
        "type": "commercial",
        "duration": "6 months",
        "wage": "$45.50/hr",
        "benefits": "full package",
        "requirements": "valid license",
        "posted_date": "2024-01-15",
        "local_number": "134"
    }
    ```

- **Extraction Methods:** Employ a combination of Rule-Based (CSS/XPath selectors for known formats) and LLM-Powered (e.g., Gemini 2.0 via LiteLLM for unstructured content) methods.
- **Output:** Return a JSON object for each extracted job listing.
- **Error Handling:** Log any extraction errors (e.g., parsing failures, missing data) and attempt to extract from other URLs.

### Phase 4: Data Storage (Delegated to `data-storage`)

**Objective:** Store the extracted job data from Phase 3 into Firebase Firestore, with a fallback to JSON file storage if Firestore is unavailable or fails.

**Instructions for `data-storage`:**

- **Database Schema:** Store data in Firestore under the `jobs` collection. Document IDs should be `{local_number}_{job_id}`. Consider subcollections like `history` or `applicants` if applicable.
- **Fallback Mechanism:** If Firebase Firestore integration fails, save the extracted data as structured JSON files (e.g., `v3/data/backups/`).
- **Error Handling:** Log any storage errors and ensure data persistence through the fallback.

**Orchestration and Parallelism (Instructions for the Implementing Agent):**

- **Concurrency:** Process multiple starting URLs concurrently where possible. For each sub-agent call within the pipeline, use `call_subordinate` with `dedicated_context=true` to ensure independent and parallel execution of sub-tasks.
- **Data Flow Management:** Ensure seamless passing of data (e.g., `discovered_urls` from Phase 1 to Phase 2, `classified_urls` to Phase 3, extracted job data to Phase 4).
- **Robust Error Handling:** Implement comprehensive error handling at each stage. If a stage fails for a specific URL, log the error details and attempt to continue with other URLs or stages if feasible. Collect all errors.
- **Result Aggregation:** Collect all results (discovered URLs, classified URLs, extracted jobs, storage status) and errors throughout the entire process.

**Final Output (from the Implementing Agent):**

Once all starting URLs have been processed through the pipeline, provide a summary report including:

- Total number of starting URLs processed.
- Number of URLs successfully processed through each stage (discovered, classified, extracted, stored).
- A list of any URLs that encountered errors at any stage, along with the specific error details.
- A sample of the extracted job data (if any) to demonstrate successful extraction.

**Contextual Documents:**

- The `scraping_process.md` and `URL_CLASSIFIER_README.md` files contain additional technical details, keywords, and implementation guidance that should be consulted by the sub-agents for optimal performance and accuracy.
