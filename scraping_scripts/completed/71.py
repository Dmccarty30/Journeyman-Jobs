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

DISPATCH_URL = "https://www.ibew71.org/AvailableJobs/#"
OUTPUT_DIR = Path("scraping_scripts/outputs")
OUTPUT_FILE = OUTPUT_DIR / "ibew71_jobs.json"
FIREBASE_CREDENTIALS_PATH = "C:\\Users\\david\\Desktop\\Journeyman-Jobs\\scraping_scripts\\jj-firebase-adminsdk.json"  # <-- fill in your service‑account JSON path

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s – %(message)s")
logger = logging.getLogger(__name__)

# --- NEW SCRAPING LOGIC ---

# Define the specific job classifications to scrape (adapted based on observed job classes in the HTML)
TARGET_CLASSIFICATIONS = {
    "journeyman-lineman",
    "journeyman-wireman",
    "teledata-lineman",
    "street-light-technician",
    "operator",
    "welder",
    "journeyman-cbl-splicer",
    "line-equipment-operator",
    "journeyman-substation-tech",
    "inside-wireman",
}

# Map the parsed keys to the desired JSON keys (adapted from the MD guidance)
FIELD_MAP = {
    "Job Class": "jobClass",
    "Positions Requested": "numberOfJobs",
    "Worksite": "location",
    "Request Date": "datePosted",
    "Report On": "startTime",
    "Comments": "notes",  # Will parse further for sub-fields
}

def to_title_case(value):
    """Converts a string to title case, removing hyphens, periods, and other special characters."""
    if not value:
        return ""
    # Remove special characters: hyphens, periods, etc.
    cleaned = re.sub(r'[-.\s]+', ' ', value)  # Replace hyphens/periods/spaces with single space
    cleaned = re.sub(r'[^a-zA-Z0-9\s]', '', cleaned)  # Remove other special chars
    # Title case: capitalize first letter of each word
    return ' '.join(word.capitalize() for word in cleaned.split())

def parse_comments(comments):
    """Parses the Comments field for sub-details like Location, Hours, etc."""
    parsed = {
        "qualifications": "",
        "hours": "",
        "work_type": "",
        "notes": "",
        "location": "",
    }
    if not comments:
        return parsed
    
    # Split on ', ' only if followed by a key like 'Key:'
    parts = re.split(r',\s*(?=[A-Z][^:]+:)', comments)
    for part in parts:
        part = part.strip()
        if ':' in part:
            key, value = part.split(':', 1)
            key = key.strip()
            value = value.strip()
            if key in {'Requirement', 'Requirements'}:
                parsed['qualifications'] = value
            elif key == 'Location':
                parsed['location'] = value
            elif key == 'Hours Working':
                parsed['hours'] = value
            elif key == 'Work Type':
                parsed['work_type'] = value
            elif key == 'Other Incentives':
                parsed['notes'] = value  # Per diem or bonuses
            elif key == 'Position':
                pass  # Ignore, as we have jobClass
    
    return parsed

async def scrape_ibew71():
    """Scrapes job data from the IBEW 71 available jobs page using BeautifulSoup."""
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(url=DISPATCH_URL, extract_schema="html", timeout=30)
        if not result.success:
            raise RuntimeError(f"Crawl failed: {result.error_message}")

    html = result.html
    soup = BeautifulSoup(html, 'lxml')
    all_jobs = []

    table = soup.select_one("table.jobFrameTable")
    if not table:
        logger.info("No job table found, skipping.")
        return

    job_headers = table.select("tr.jobHeaders")
    if not job_headers:
        logger.info("No job headers found.")
        return
    
    logger.info(f"Found {len(job_headers)} potential jobs.")

    for header in job_headers:
        tds = header.select("td")
        if len(tds) < 4:
            continue
        
        # Extract company/employer
        strong = tds[0].select_one("strong")
        company = strong.text.strip() if strong else ""
        
        # City (often empty)
        city = tds[1].text.strip()
        
        # Start date from header
        start_date = tds[2].text.strip()
        
        # Short call
        short_call = tds[3].text.strip()
        
        # Extract row_id (dispatchNumber) from onclick
        a = header.select_one("a[onclick]")
        dispatch_number = ""
        if a and 'onclick' in a.attrs:
            onclick = a['onclick']
            match = re.search(r'showRow\((\d+)\)', onclick)
            if match:
                dispatch_number = match.group(1)
        
        # Find the corresponding bodyrow tbody
        row_id = f"row{dispatch_number}" if dispatch_number else ""
        bodyrow = soup.find("tbody", id=row_id)
        if not bodyrow:
            logger.info(f"No bodyrow found for row {row_id}, skipping.")
            continue
        
        td = bodyrow.select_one("tr.jobInfoRow td[colspan='5']")
        if not td:
            continue
        
        details_text = td.text.strip()
        details_lines = [line.strip() for line in details_text.split('\n') if line.strip()]
        
        job_data = {
            "localNumber": "71",
            "company": to_title_case(company),
            "startDate": start_date,
            "dispatchNumber": dispatch_number,
            "notes": f"Short Call: {short_call}",
        }
        
        # Parse the br-separated lines
        details = {}
        current_key = None
        current_value = ""
        for line in details_lines:
            if ':' in line:
                if current_key:
                    details[current_key] = current_value.strip()
                key, value = line.split(':', 1)
                current_key = key.strip()
                current_value = value.strip()
            else:
                current_value += " " + line.strip()
        if current_key:
            details[current_key] = current_value.strip()
        
        for source_key, json_key in FIELD_MAP.items():
            job_data[json_key] = details.get(source_key, "")
        
        # Parse comments for additional fields
        comments = details.get("Comments", "")
        parsed_comments = parse_comments(comments)
        job_data["qualifications"] = parsed_comments["qualifications"]
        job_data["hours"] = parsed_comments["hours"]
        # Append work_type to notes if present
        if parsed_comments["work_type"]:
            job_data["notes"] += f" Work Type: {parsed_comments['work_type']}"
        if parsed_comments["notes"]:
            job_data["notes"] += f" Other Incentives: {parsed_comments['notes']}"
        
        # Override location if in parsed_comments
        if parsed_comments.get("location"):
            job_data["location"] = parsed_comments["location"]
        elif city:
            job_data["location"] = city
        
        # Set classification from jobClass, normalized to slug
        job_class_raw = job_data.get("jobClass", "")
        job_class_slug = job_class_raw.lower().replace(" ", "-").replace("-out-of-classificaton", "").replace("-out-of-classification", "")
        job_data["classification"] = job_class_slug
        
        # Filter to target classifications
        if job_data["classification"] not in TARGET_CLASSIFICATIONS:
            logger.info(f"Skipping job with classification '{job_data['classification']}' (not in targets).")
            continue
        
        # Standardize jobClass to title case without special chars
        job_data["jobClass"] = to_title_case(job_class_raw)
        
        # Apply title case to other relevant fields if needed
        job_data["location"] = to_title_case(job_data.get("location", ""))
        job_data["qualifications"] = to_title_case(job_data.get("qualifications", ""))
        job_data["hours"] = to_title_case(job_data.get("hours", ""))
        job_data["notes"] = to_title_case(job_data.get("notes", ""))

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
        # Format: 71-journeyman-lineman-d-d-power-1
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
            "jobClass": sanitized_job.get("jobClass", "") or to_title_case(classification),
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
    asyncio.run(scrape_ibew71())

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
                local_number="71"
            )
    else:
        logger.info("No jobs were scraped, skipping database update.")