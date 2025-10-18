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

# URL for IBEW Local 125 job listings page
DISPATCH_URL = "https://www.ibew125.com/index.cfm?zone=/unionactive/private_view_page.cfm&page=Job20Listings"
OUTPUT_DIR = Path("outputs")
OUTPUT_FILE = OUTPUT_DIR / "ibew125_jobs.json"
FIREBASE_CREDENTIALS_PATH = "C:\\Users\\david\\Desktop\\Journeyman-Jobs\\scraping_scripts\\jj-firebase-adminsdk.json"

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

def extract_job_info(text):
    """Extract job information from text content using pattern matching."""
    job_data = {
        "company": "",
        "datePosted": "",
        "jobClass": "",
        "numberOfJobs": "",
        "location": "",
        "hours": "",
        "startDate": "",
        "wage": "",
        "startTime": "",
        "sub": "",
        "qualifications": "",
        "agreement": "",
        "notes": "",
        "dispatchNumber": ""
    }
    
    # Extract patterns from the text
    lines = text.split('\n')
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Look for wage patterns
        if '$' in line and '/h' in line.lower():
            job_data['wage'] = re.sub(r'[^\d.$/-]', '', line).strip('$').strip()
        
        # Look for location patterns
        if 'location:' in line.lower():
            job_data['location'] = line.split(':', 1)[1].strip() if ':' in line else ""
        elif any(city in line for city in ['Portland', 'Oregon City', 'Rose City', 'Canby']):
            if not job_data['location']:
                job_data['location'] = line
        
        # Look for hours patterns
        if 'hours:' in line.lower() or ('am' in line.lower() and 'pm' in line.lower()):
            job_data['hours'] = line.split(':', 1)[1].strip() if ':' in line else line
        elif re.search(r'\d{1,2}:\d{2}\s*(am|pm)', line.lower()):
            if not job_data['hours']:
                job_data['hours'] = line
        
        # Look for pay patterns
        if 'pay:' in line.lower():
            wage_text = line.split(':', 1)[1].strip() if ':' in line else ""
            job_data['wage'] = wage_text.replace('$', '').strip()
    
    return job_data

async def scrape_ibew125():
    """Scrapes job data from the IBEW 125 job listings page using crawl4ai."""
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(url=DISPATCH_URL, extract_schema="html", timeout=30)
        if not result.success:
            raise RuntimeError(f"Crawl failed: {result.error_message}")
    
    html = result.html
    soup = BeautifulSoup(html, 'lxml')
    all_jobs = []
    
    # Since IBEW 125 doesn't have clear classifications on the page,
    # we'll categorize based on job titles
    job_items = soup.select('td.resprow')
    
    if not job_items:
        # Try alternative selectors
        job_items = soup.find_all(['tr', 'div'], class_=re.compile(r'.*job.*|.*listing.*', re.I))
    
    # If still no items, look for any table cells with job info
    if not job_items:
        tables = soup.find_all('table')
        for table in tables:
            rows = table.find_all('tr')
            for row in rows:
                # Look for rows that contain job information
                if row.text and any(keyword in row.text.lower() for keyword in ['lineman', 'lineworker', 'cable splicer', 'flagger', 'utility']):
                    job_items.append(row)
    
    logger.info(f"Found {len(job_items)} potential job entries")
    
    for item in job_items:
        # Extract job title and determine classification
        title_elem = item.find(['h3', 'h4', 'strong', 'b', 'a'])
        if not title_elem:
            # Try to find the first text that looks like a title
            text = _get_text_safely(item)
            if text:
                # Use first line as title
                title = text.split('\n')[0].strip()
            else:
                continue
        else:
            title = _get_text_safely(title_elem)
        
        if not title:
            continue
        
        # Determine classification based on title
        classification = determine_classification(title)
        
        # Extract all text from the item
        full_text = _get_text_safely(item)
        
        # Parse job information
        job_data = extract_job_info(full_text)
        
        # Set required fields
        job_data["localNumber"] = "125"
        job_data["classification"] = classification
        
        # Extract company from title or text
        if not job_data["company"]:
            # Check for known companies
            companies = ['PGE', 'BPA', 'Portland General Electric', 'Bonneville Power', 
                        'Canby', 'UTS Traffic Services', 'United Traffic Control', 'Northwest Traffic Control']
            for company in companies:
                if company.lower() in title.lower() or company.lower() in full_text.lower():
                    job_data["company"] = company
                    break
            
            # If no known company found, use first part of title
            if not job_data["company"] and title:
                job_data["company"] = title.split('-')[0].strip() if '-' in title else title[:30]
        
        # Set jobClass from title if not already set
        if not job_data["jobClass"]:
            job_data["jobClass"] = title
        
        # Look for location in the full text if not found
        if not job_data["location"]:
            locations = ['Portland', 'Oregon City', 'Rose City', 'Canby', 'Oregon', 'OR']
            for loc in locations:
                if loc in full_text:
                    job_data["location"] = loc
                    break
        
        # Set a default location if still empty (required field)
        if not job_data["location"]:
            job_data["location"] = "Portland, OR"
        
        # Extract dispatch number if present (like R6922, R7541, etc.)
        dispatch_match = re.search(r'R\d{4}', full_text)
        if dispatch_match:
            job_data["dispatchNumber"] = dispatch_match.group()
        
        # Ensure startDate has a value (required field)
        if not job_data["startDate"]:
            job_data["startDate"] = "ASAP"
        
        all_jobs.append(job_data)
    
    # Ensure output directory exists
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Write to JSON file
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(all_jobs, f, indent=2, ensure_ascii=False)
    
    logger.info(f"Scraped {len(all_jobs)} total job entries and saved to {OUTPUT_FILE}")

def determine_classification(title):
    """Determine job classification based on title."""
    title_lower = title.lower()
    
    # Map titles to standard classifications in title case
    if 'lineman' in title_lower or 'lineworker' in title_lower or 'line worker' in title_lower:
        return 'Journeyman Lineman'
    elif 'cable splicer' in title_lower:
        return 'Cable Splicer'
    elif 'utility worker' in title_lower:
        return 'Utility Worker'
    elif 'flagger' in title_lower or 'traffic control' in title_lower:
        return 'Traffic Control'
    elif 'wireman' in title_lower:
        return 'Journeyman Wireman'
    elif 'operator' in title_lower:
        return 'Line Equipment Operator'
    elif 'substation' in title_lower:
        return 'Journeyman Substation Tech'
    else:
        # Default classification
        return 'General'

# --- FIRESTORE AND DATA HANDLING LOGIC (EXACT COPY FROM 111.py) ---

def generate_job_id(local_number, classification, job):
    """Generates a unique, readable document ID based on the required convention."""
    company = job.get("company", "").strip()
    sanitized_company = re.sub(r'[^a-z0-9]+', '-', company.lower()).strip('-')
    
    # Convert title case classification to slug for ID
    classification_slug = re.sub(r'[^a-z0-9]+', '-', classification.lower()).strip('-')
    
    dispatch_number = job.get("dispatchNumber")
    if dispatch_number:
        # Format: 125-journeyman-lineman-pge-R6922
        return f"{local_number}-{classification_slug}-{sanitized_company}-{dispatch_number}"
    else:
        # Fallback to a hash for robustness if dispatch number isn't found
        details = f"{job.get('company','')}{job.get('location','')}{job.get('startDate','')}"
        details_hash = hashlib.sha256(details.encode()).hexdigest()[:8]
        return f"{local_number}-{classification_slug}-{sanitized_company}-{details_hash}"

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
            "jobClass": sanitized_job.get("jobClass", "") or classification,
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
    asyncio.run(scrape_ibew125())
    
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
                local_number="125"
            )
    else:
        logger.info("No jobs were scraped, skipping database update.")