import os
import json
import requests
import re
import sys
import logging
import hashlib
from google.cloud import firestore
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type

# --- CONFIGURATION ---

# Configuration
TARGET_URL = "https://www.ibew125.com/?zone=/unionactive/view_article.cfm&HomeID=710029&page=Dispatch"
LOCAL_NUMBER = "125"

# Firestore Configuration
# Make sure to fill in your service account JSON path
FIREBASE_CREDENTIALS_PATH = "C:\\Users\\david\\Desktop\\Journeyman-Jobs\\scraping_scripts\\journeyman-jobs-firebase-adminsdk-rwcqx-b2872d649a.json"

# Logging Configuration
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s – %(message)s")
logger = logging.getLogger(__name__)


# --- SCRAPING LOGIC ---

def scrape_jobs():
    """
    Scrapes job listings from IBEW Local 125's dispatch page using Crawl4AI.
    Handles date propagation and data cleaning.
    """
    extraction_schema = {
        "selector": "#maintablenavlist",
        "type": "list",
        "item_selector": "tr:nth-child(n+3)", # Skips the first two header rows
        "schema": {
            "type": "object",
            "properties": {
                "date": {"type": "string", "selector": "td:nth-of-type(1)"},
                "company": {"type": "string", "selector": "td:nth-of-type(2)"},
                "classification": {"type": "string", "selector": "td:nth-of-type(3)"},
                "certifications": {"type": "string", "selector": "td:nth-of-type(4)"},
                "hours": {"type": "string", "selector": "td:nth-of-type(5)"},
                "work_type": {"type": "string", "selector": "td:nth-of-type(6)"}
            }
        }
    }

    payload = {
        "url": TARGET_URL,
        "extraction_schema": extraction_schema,
    }

    headers = {
        "Content-Type": "application/json",
    }

    try:
        # TODO: Implement actual scraping logic for TARGET_URL
        # The Crawl4AI API call has been removed as CRAWL4AI_API_URL was not defined.
        logger.info(f"Scraping logic for IBEW {LOCAL_NUMBER} dispatch page ({TARGET_URL}) needs to be implemented.")
        raw_results = []  # Placeholder: replace with actual scraped data
        if not raw_results:
            logger.warning("Crawl4AI returned no data. The page structure might have changed.")
            return []

        logger.info('Data received, processing job listings...')

        last_date = None
        valid_jobs = []

        for row in raw_results:
            cleaned_data = {key: re.sub(r'\s+', ' ', (value or "").strip()) for key, value in row.items()}
            
            if (cleaned_data.get('company') in ("Company - Construction", "STORM CALLS") or
                    (not cleaned_data.get('company') and not cleaned_data.get('classification'))):
                continue
            
            if cleaned_data.get('date'):
                last_date = cleaned_data['date']
            else:
                cleaned_data['date'] = last_date

            if cleaned_data.get('company') and cleaned_data.get('classification'):
                valid_jobs.append(cleaned_data)

        logger.info(f"Scraped {len(valid_jobs)} potential job entries from the website.")
        return valid_jobs

    except requests.exceptions.RequestException as e:
        logger.error(f"Error in IBEW {LOCAL_NUMBER} scraper during API call: {e}")
        raise
    except Exception as e:
        logger.error(f"An unexpected error occurred during processing: {e}")
        raise


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
            "classification": sane_classification,
            "company": sanitized_job.get("company", ""),
            "datePosted": sanitized_job.get("date", ""),
            "jobClass": sanitized_job.get("classification", "").title(), # Use classification as jobClass
            "location": "", # IBEW 125 does not provide location
            "numberOfJobs": "", # IBEW 125 does not provide this
            "hours": sanitized_job.get("hours", ""),
            "wage": "", # IBEW 125 does not provide wage
            "startDate": sanitized_job.get("date", ""), # Use post date as start date
            "startTime": "", # IBEW 125 does not provide start time
            "sub": "", # IBEW 125 does not provide this
            "qualifications": sanitized_job.get("certifications", ""),
            "agreement": "", # IBEW 125 does not provide this
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
        scraped_jobs = scrape_jobs()
    except Exception as err:
        logger.error(f"Scraping failed: {err}")
        sys.exit(1)
    
    if scraped_jobs:
        # Group jobs by their classification to update the database efficiently
        jobs_by_classification = {}
        for job in scraped_jobs:
            # Normalize classification for grouping (e.g., "Journeyman Lineman" -> "journeyman-lineman")
            classification = job.get("classification", "").lower().strip().replace(" ", "-")
            if classification:
                jobs_by_classification.setdefault(classification, []).append(job)

        # Process each classification group separately
        for classification, jobs in jobs_by_classification.items():
            update_database_with_jobs(
                classification=classification,
                jobs=jobs,
                local_number=LOCAL_NUMBER
            )
        
        logger.info("Scraping and database update completed successfully.")
    else:
        logger.info("No jobs were scraped, skipping database update.")
