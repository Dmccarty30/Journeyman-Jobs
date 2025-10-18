import os
import json
import asyncio
import re
import sys
import logging
import hashlib
from pathlib import Path
from bs4 import BeautifulSoup
from crawl4ai import AsyncWebCrawler
from google.cloud import firestore
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type

# --- CONFIGURATION ---

# Configuration  
TARGET_URL = "https://www.ibew125.com/?zone=/unionactive/view_article.cfm&HomeID=710029&page=Dispatch"
LOCAL_NUMBER = "125"
# Output to same directory as script
SCRIPT_DIR = Path(__file__).parent
OUTPUT_FILE = SCRIPT_DIR / "125_output.json"

# Firestore Configuration
# Make sure to fill in your service account JSON path
FIREBASE_CREDENTIALS_PATH = "C:\\Users\\david\\Desktop\\Journeyman-Jobs\\scraping_scripts\\jj-firebase-adminsdk.json"

# Logging Configuration
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s – %(message)s")
logger = logging.getLogger(__name__)


# --- SCRAPING LOGIC ---

def _get_text_safely(element, selector=None):
    """Safely extracts and cleans text from a BeautifulSoup element."""
    if not element:
        return ""
    
    if selector:
        found = element.select_one(selector)
        if not found:
            return ""
        return ' '.join(found.stripped_strings)
    
    # If no selector, get text from element itself
    return ' '.join(element.stripped_strings) if element else ""

def determine_classification(text):
    """Determine job classification based on text content."""
    text_lower = text.lower()
    
    # Map content to standard classifications in title case
    if 'lineman' in text_lower or 'lineworker' in text_lower or 'line worker' in text_lower:
        return 'Journeyman Lineman'
    elif 'cable splicer' in text_lower:
        return 'Cable Splicer'
    elif 'utility worker' in text_lower:
        return 'Utility Worker'
    elif 'flagger' in text_lower or 'traffic control' in text_lower:
        return 'Traffic Control'
    elif 'wireman' in text_lower:
        return 'Journeyman Wireman'
    elif 'operator' in text_lower:
        return 'Line Equipment Operator'
    elif 'substation' in text_lower:
        return 'Journeyman Substation Tech'
    else:
        # Default classification
        return 'General'

# --- Company/location normalization ---
STATE_ABBREVS = {
    "AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
    "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
    "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
    "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
    "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY",
    "DC","PR"
}
DASH_VARIANTS = ("-", "–", "—")

def _normalize_whitespace(text: str) -> str:
    return re.sub(r"\s+", " ", text or "").strip()

def _normalize_commas(text: str) -> str:
    text = re.sub(r",\s*", ", ", text)
    text = re.sub(r"\s+,", ",", text)
    return text

def _normalize_dashes(text: str) -> str:
    for dv in DASH_VARIANTS:
        text = text.replace(dv, "-")
    text = re.sub(r"\s*-\s*", " - ", text)
    return _normalize_whitespace(text)

def _is_state_abbrev(text: str) -> bool:
    return len(text) == 2 and text.upper() in STATE_ABBREVS

def _normalize_city(city: str) -> str:
    city = _normalize_whitespace(city)
    parts = [p for p in re.split(r"(\b)", city)]
    def _tc(word: str) -> str:
        if not word:
            return word
        return word[0].upper() + word[1:].lower()
    return "".join(_tc(w) if w.isalpha() else w for w in parts)

def _parse_city_state(text: str):
    raw = _normalize_whitespace(text)
    if not raw:
        return None
    if raw.lower() == "remote":
        return "Remote"
    raw = _normalize_commas(raw)
    m = re.match(r"^([A-Za-z .\'\-]+),\s*([A-Za-z]{2})$", raw)
    if not m:
        m = re.match(r"^([A-Za-z .\'\-]+)\s+([A-Za-z]{2})$", raw)
    if not m:
        m = re.match(r"^([A-Za-z .\'\-]+),([A-Za-z]{2})$", raw)
    if m:
        city, st = m.group(1).strip(), m.group(2).upper()
        if _is_state_abbrev(st):
            return f"{_normalize_city(city)}, {st}"
    return None

def split_company_location(value: str):
    text = _normalize_dashes(value or "")
    idx = text.rfind("-")
    if idx == -1:
        return _normalize_whitespace(text), None
    left = _normalize_whitespace(text[:idx])
    right = _normalize_whitespace(text[idx+1:])
    loc = _parse_city_state(right)
    if loc:
        return left, loc
    return _normalize_whitespace(value or ""), None

async def scrape_jobs():
    """
    Scrapes job listings from IBEW Local 125's dispatch page using advanced crawl4ai features.
    Handles date propagation and data cleaning.
    """
    logger.info(f"Starting to scrape IBEW {LOCAL_NUMBER} dispatch page: {TARGET_URL}")
    
    async with AsyncWebCrawler(
        # Advanced crawl4ai configuration
        headless=True,
        browser_type="chromium",
        verbose=True,
        always_by_pass_cache=True,
        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    ) as crawler:
        
        # Advanced crawling with multiple extraction strategies
        result = await crawler.arun(
            url=TARGET_URL,
            # Use advanced extraction schema for structured data
            extraction_schema={
                "type": "json_css",
                "selector": "table",
                "fields": [
                    {
                        "name": "job_rows",
                        "selector": "tr",
                        "type": "nested",
                        "fields": [
                            {"name": "date", "selector": "td:nth-child(1)", "type": "text"},
                            {"name": "company", "selector": "td:nth-child(2)", "type": "text"},
                            {"name": "classification", "selector": "td:nth-child(3)", "type": "text"},
                            {"name": "certifications", "selector": "td:nth-child(4)", "type": "text"},
                            {"name": "hours", "selector": "td:nth-child(5)", "type": "text"},
                            {"name": "work_type", "selector": "td:nth-child(6)", "type": "text"}
                        ]
                    }
                ]
            },
            # Additional crawl4ai parameters for better extraction
            wait_for="css:table",
            timeout=30,
            delay_before_return_html=2,
            page_timeout=60,
            # Use CSS selectors to wait for content
            css_selector="#maintablenavlist, table"
        )
        
        if not result.success:
            logger.error(f"Crawl4AI failed: {result.error_message}")
            # Fallback to basic HTML parsing
            basic_result = await crawler.arun(url=TARGET_URL, timeout=30)
            if not basic_result.success:
                raise RuntimeError(f"Both advanced and basic crawling failed: {basic_result.error_message}")
            result = basic_result

    # Parse HTML with BeautifulSoup for robust extraction
    soup = BeautifulSoup(result.html, 'html.parser')
    
    # Try multiple table selectors
    tables = soup.select('#maintablenavlist') or soup.select('table')
    
    if not tables:
        logger.warning("No dispatch table found. Trying alternative selectors.")
        # Look for any table with job-like content
        all_tables = soup.find_all('table')
        tables = [t for t in all_tables if 'company' in t.get_text().lower() or 'dispatch' in t.get_text().lower()]
    
    if not tables:
        logger.warning("No suitable tables found on the page.")
        return []
    
    table = tables[0]  # Use the first matching table
    rows = table.find_all('tr')[2:]  # Skip header rows
    
    logger.info(f"Found {len(rows)} potential job rows in dispatch table")
    
    last_date = None
    valid_jobs = []
    
    for row in rows:
        cells = row.find_all(['td', 'th'])
        if len(cells) < 3:  # Need at least date, company, classification
            continue
            
        # Extract data from cells with safe text extraction
        row_data = {
            'date': _get_text_safely(cells[0]) if len(cells) > 0 else "",
            'company': _get_text_safely(cells[1]) if len(cells) > 1 else "",
            'classification': _get_text_safely(cells[2]) if len(cells) > 2 else "",
            'certifications': _get_text_safely(cells[3]) if len(cells) > 3 else "",
            'hours': _get_text_safely(cells[4]) if len(cells) > 4 else "",
            'work_type': _get_text_safely(cells[5]) if len(cells) > 5 else ""
        }
        
        # Clean and normalize data
        cleaned_data = {key: re.sub(r'\s+', ' ', (value or "").strip()) for key, value in row_data.items()}

        # Skip header rows and invalid entries
        if (cleaned_data.get('company') in ("Company", "Company - Construction", "STORM CALLS") or
                (not cleaned_data.get('company') and not cleaned_data.get('classification'))):
            continue

        # Handle date propagation and rename to posted_date
        if cleaned_data.get('date'):
            last_date = cleaned_data['date']
        cleaned_data['posted_date'] = cleaned_data.get('date') or last_date
        cleaned_data.pop('date', None)

        # Normalize classification to title case
        if cleaned_data.get('classification'):
            cleaned_data['classification'] = determine_classification(cleaned_data['classification'])

        # Split company/location into separate fields
        company_name, location = split_company_location(cleaned_data.get('company', ''))
        cleaned_data['company'] = company_name
        cleaned_data['location'] = location

        # Only keep valid job entries
        if cleaned_data.get('company') and cleaned_data.get('classification'):
            valid_jobs.append(cleaned_data)
    
    # Write JSON output to script directory
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(valid_jobs, f, indent=2, ensure_ascii=False)
    
    logger.info(f"Scraped {len(valid_jobs)} valid job entries and saved to {OUTPUT_FILE}")
    return valid_jobs


# --- FIRESTORE AND DATA HANDLING LOGIC (from 111.py) ---

def generate_job_id(local_number, classification, job):
    """Generates a unique, readable document ID for IBEW 125 jobs."""
    company = job.get("company", "").strip()
    sanitized_company = re.sub(r'[^a-z0-9]+', '-', company.lower()).strip('-')

    # IBEW 125 doesn't have a dispatch number, so we create a stable hash
    # from the job's core details to ensure uniqueness.
    details = (
        f"{job.get('company','')}"
        f"{job.get('classification','')}"
        f"{job.get('work_type','')}"
        f"{job.get('hours','')}"
    )
    details_hash = hashlib.sha256(details.encode()).hexdigest()[:8]

    return f"{local_number}-{classification}-{sanitized_company}-{details_hash}"

def sanitize_job_data(job):
    """Strips whitespace from all string values in the job dictionary."""
    return {k: (v.strip() if isinstance(v, str) else v) for k, v in job.items()}

def validate_job_data(job_data):
    """Validates that essential job data fields for IBEW 125 are present."""
    required = ["jobId", "localNumber", "classification", "company"]
    return all(job_data.get(k) for k in required)

@retry(stop=stop_after_attempt(3), wait=wait_fixed(2), retry=retry_if_exception_type(Exception), reraise=True)
def firestore_operation(fn, *args, **kwargs):
    """Executes a Firestore operation with retry logic."""
    return fn(*args, **kwargs)

def update_database_with_jobs(classification, jobs, local_number):
    """Adds, updates, or removes job listings in Firestore for a given classification."""
    if FIREBASE_CREDENTIALS_PATH:
        try:
            db = firestore.Client.from_service_account_json(FIREBASE_CREDENTIALS_PATH)
        except Exception as e:
            logger.error(f"Failed to initialize Firestore with service account: {e}")
            return
    else:
        db = firestore.Client()

    logger.info(f"Updating Firestore with {len(jobs)} jobs for classification '{classification}' (Local {local_number})")

    def fetch_existing():
        return (
            db.collection("jobs")
            .where(filter=firestore.FieldFilter("localNumber", "==", local_number))
            .where(filter=firestore.FieldFilter("classification", "==", classification))
            .stream()
        )

    try:
        existing_jobs_snapshot = firestore_operation(fetch_existing)
        existing_jobs = {doc.id: doc.to_dict() for doc in existing_jobs_snapshot}
        logger.info(f"Found {len(existing_jobs)} existing jobs in Firestore for classification '{classification}'")
    except Exception as e:
        logger.error(f"Failed to fetch existing jobs from Firestore: {e}")
        return

    valid_job_ids = set()
    for job in jobs:
        sanitized_job = sanitize_job_data(job)
        # Standardize classification for ID generation (e.g., 'journeyman lineman' -> 'journeyman-lineman')
        sane_classification = sanitized_job.get("classification", "").lower().replace(" ", "-")

        job_id = generate_job_id(local_number, sane_classification, sanitized_job)
        valid_job_ids.add(job_id)

        # Map scraped data to the Firestore schema
        job_data = {
            "jobId": job_id,
            "localNumber": local_number,
            "classification": sanitized_job.get("classification", ""),  # Keep title case for user display
            "company": sanitized_job.get("company", ""),
            "datePosted": sanitized_job.get("posted_date", ""),
            "jobClass": sanitized_job.get("classification", ""),  # Use title case classification as jobClass
            "location": sanitized_job.get("location", "") or "",
            "numberOfJobs": "",
            "hours": sanitized_job.get("hours", ""),
            "wage": "",
            "startDate": sanitized_job.get("posted_date", ""),
            "startTime": "",
            "sub": "",
            "qualifications": sanitized_job.get("certifications", ""),
            "agreement": "",
            "notes": sanitized_job.get("work_type", ""),
            "timestamp": existing_jobs.get(job_id, {}).get("timestamp", firestore.SERVER_TIMESTAMP),
        }

        if not validate_job_data(job_data):
            logger.warning(f"Invalid job data, skipping: {job_data}")
            continue

        doc_ref = db.collection("jobs").document(job_id)
        try:
            if job_id in existing_jobs:
                def update_fn():
                    doc_ref.update(job_data)
                firestore_operation(update_fn)
                logger.info(f"Updated job {job_id}")
            else:
                def set_fn():
                    doc_ref.set(job_data)
                firestore_operation(set_fn)
                logger.info(f"Added new job {job_id}")
        except Exception as e:
            logger.error(f"Error updating/creating job {job_id}: {e}")

    # Delete jobs that are no longer on the dispatch page
    for existing_id in existing_jobs:
        if existing_id not in valid_job_ids:
            try:
                def delete_fn():
                    db.collection("jobs").document(existing_id).delete()
                firestore_operation(delete_fn)
                logger.info(f"Deleted outdated job {existing_id}")
            except Exception as e:
                logger.error(f"Error deleting job {existing_id}: {e}")

    logger.info(f"Firestore update completed for classification '{classification}'")

if __name__ == "__main__":
    logger.info(f"Starting IBEW {LOCAL_NUMBER} scraper...")
    try:
        scraped_jobs = asyncio.run(scrape_jobs())
    except Exception as err:
        logger.error(f"Scraping failed: {err}")
        sys.exit(1)
    
    if scraped_jobs:
        # Group jobs by their classification for reporting and DB updates
        jobs_by_classification = {}
        for job in scraped_jobs:
            classification = job.get("classification", "").strip()
            if classification:
                jobs_by_classification.setdefault(classification, []).append(job)

        # Update Firestore for each classification group
        for classification, jobs in jobs_by_classification.items():
            update_database_with_jobs(classification, jobs, LOCAL_NUMBER)

        # Print summary to terminal
        print("\n" + "="*60)
        print(f"SCRAPED RESULTS FOR IBEW LOCAL {LOCAL_NUMBER}")
        print("="*60)

        for classification, jobs in jobs_by_classification.items():
            print(f"\n{classification}: {len(jobs)} jobs")
            for i, job in enumerate(jobs[:3], 1):  # Show first 3 jobs per classification
                print(f"  {i}. {job.get('company', 'N/A')} - {job.get('posted_date', 'N/A')}")
                print(f"     Hours: {job.get('hours', 'N/A')} | Type: {job.get('work_type', 'N/A')} | Location: {job.get('location', 'N/A')}")
            if len(jobs) > 3:
                print(f"     ... and {len(jobs)-3} more jobs")

        print(f"\nTotal jobs scraped: {len(scraped_jobs)}")
        print(f"JSON output saved to: {OUTPUT_FILE}")
        print("="*60)

        logger.info(f"Completed - {len(scraped_jobs)} jobs found, grouped by {len(jobs_by_classification)} classifications and pushed to Firestore")
    else:
        logger.info("No jobs were scraped.")
        print("\nNo jobs found on the dispatch page.")
