import asyncio
import json
import logging
import re
import hashlib
from pathlib import Path

from bs4 import BeautifulSoup
from crawl4ai import AsyncWebCrawler
from google.cloud import firestore
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type

DISPATCH_URL = "https://www.ibew111.org/dispatch"
OUTPUT_DIR = Path("scraping_scripts/outputs")
OUTPUT_FILE = OUTPUT_DIR / "ibew111_jobs.json"
FIREBASE_CREDENTIALS_PATH = "C:\\Users\\david\\Desktop\\Journeyman-Jobs\\scraping_scripts\\jj-firebase-adminsdk.json"  # <-- fill in your service‑account JSON path

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s – %(message)s")
logger = logging.getLogger(__name__)

# --- NEW SCRAPING LOGIC ---

# Define the specific job classifications to scrape
TARGET_CLASSIFICATIONS = {
    "journeyman-lineman",
    "journeyman-wireman",
    "line-equipment-operator",
    "wireman-foremen",  # Note: The HTML class name is plural
    "journeyman-substation-tech",
}

# Map the HTML class names of data points to the desired JSON keys
FIELD_MAP = {
    "company": "company",
    "dateposted": "datePosted",
    "class": "jobClass",
    "ofjobs": "numberOfJobs",
    "locations": "location",
    "hours": "hours",
    "startdate": "startDate",
    "wage": "wage",
    "starttime": "startTime",
    "sub": "sub",
    "qual": "qualifications",
    "agreement": "agreement",
    "notes": "notes",
}

def _get_text_safely(element, selector):
    """Safely extracts and cleans text from a BeautifulSoup element."""
    if not element:
        return ""
    found = element.select_one(selector)
    if not found:
        return ""
    
    # Handle rich text fields that might have multiple lines or tags
    return ' '.join(found.stripped_strings)

async def scrape_ibew111():
    """Scrapes job data from the IBEW 111 dispatch page using BeautifulSoup."""
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(url=DISPATCH_URL, extract_schema="html", timeout=30)
        if not result.success:
            raise RuntimeError(f"Crawl failed: {result.error_message}")

    html = result.html
    soup = BeautifulSoup(html, 'lxml')
    all_jobs = []

    for classification_slug in TARGET_CLASSIFICATIONS:
        section = soup.select_one(f"div.{classification_slug}.dispatch-section")
        if not section:
            logger.info(f"No section found for classification '{classification_slug}', skipping.")
            continue
            
        job_items = section.select("div.dispatch_cms-item")
        if not job_items:
            logger.info(f"No jobs found for classification '{classification_slug}'.")
            continue
        
        logger.info(f"Found {len(job_items)} jobs for classification '{classification_slug}'.")

        for item in job_items:
            # Standardize classification name (e.g., wireman-foremen -> wireman-foreman)
            classification = classification_slug.replace('-foremen', '-foreman')
            
            job_data = {
                "localNumber": "111",
                "classification": classification,
            }
            
            job_data["dispatchNumber"] = _get_text_safely(item, "div.dispatch_number")
            grid = item.select_one("div.grid.cc-dispatch-item")

            for div_class, json_key in FIELD_MAP.items():
                selector = f"div.{div_class} .dispatch-paragraph"
                job_data[json_key] = _get_text_safely(grid, selector)
            
            # Clean up wage field to remove currency symbols
            if 'wage' in job_data:
                job_data['wage'] = job_data['wage'].replace('$', '').strip()

            all_jobs.append(job_data)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(all_jobs, f, indent=2, ensure_ascii=False)
    
    logger.info(f"Scraped {len(all_jobs)} total job entries and saved to {OUTPUT_FILE}")

# --- REVISED FIRESTORE AND DATA HANDLING LOGIC ---

def generate_job_id(local_number, classification, job):
    """Generates a unique, readable document ID based on the required convention."""
    company = job.get("company", "").strip()
    sanitized_company = re.sub(r'[^a-z0-9]+', '-', company.lower()).strip('-')
    
    dispatch_number = job.get("dispatchNumber")
    if dispatch_number:
        # Format: 111-journeyman-lineman-d-d-power-1
        return f"{local_number}-{classification}-{sanitized_company}-{dispatch_number}"
    else:
        # Fallback to a hash for robustness if dispatch number isn't found
        details = f"{job.get('company','')}{job.get('location','')}{job.get('startDate','')}"
        details_hash = hashlib.sha256(details.encode()).hexdigest()[:8]
        return f"{local_number}-{classification}-{sanitized_company}-{details_hash}"

def sanitize_job_data(job):
    """Strips whitespace from all string values in the job dictionary."""
    return {k: (v.strip() if isinstance(v, str) else v) for k, v in job.items()}

def validate_job_data(job_data):
    """Validates that essential job data fields are present and not empty."""
    required = ["jobId", "localNumber", "classification", "company", "jobClass", "location", "startDate"]
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
        job_id = generate_job_id(local_number, classification, sanitized_job)
        valid_job_ids.add(job_id)

        job_data = {
            "jobId": job_id,
            "localNumber": local_number,
            "classification": classification,
            "company": sanitized_job.get("company", ""),
            "datePosted": sanitized_job.get("datePosted", ""),
            "jobClass": sanitized_job.get("jobClass", "") or classification.replace("-", " ").title(),
            "location": sanitized_job.get("location", ""),
            "numberOfJobs": sanitized_job.get("numberOfJobs", ""),
            "hours": sanitized_job.get("hours", ""),
            "wage": sanitized_job.get("wage", ""),
            "startDate": sanitized_job.get("startDate", ""),
            "startTime": sanitized_job.get("startTime", ""),
            "sub": sanitized_job.get("sub", ""),
            "qualifications": sanitized_job.get("qualifications", ""),
            "agreement": sanitized_job.get("agreement", ""),
            "notes": sanitized_job.get("notes", ""),
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
    asyncio.run(scrape_ibew111())

    try:
        with open(OUTPUT_FILE, "r", encoding="utf-8") as f:
            scraped_jobs = json.load(f)
    except FileNotFoundError:
        logger.error(f"Output file not found: {OUTPUT_FILE}. Scraper may have failed.")
        scraped_jobs = []
    
    if scraped_jobs:
        # Group jobs by their classification to update the database efficiently
        jobs_by_classification = {}
        for job in scraped_jobs:
            classification = job.get("classification")
            if classification:
                jobs_by_classification.setdefault(classification, []).append(job)

        # Process each classification group separately
        for classification, jobs in jobs_by_classification.items():
            update_database_with_jobs(
                classification=classification,
                jobs=jobs,
                local_number="111"
            )
    else:
        logger.info("No jobs were scraped, skipping database update.")
