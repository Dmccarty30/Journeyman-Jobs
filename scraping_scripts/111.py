import asyncio
import json
import logging
from pathlib import Path
from html.parser import HTMLParser

from crawl4ai import AsyncWebCrawler
from google.cloud import firestore
from google.cloud.firestore_v1 import FieldValue
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type

DISPATCH_URL = "https://www.ibew111.org/dispatch"
OUTPUT_DIR = Path("/a0/work zone/Jobs/111")
OUTPUT_FILE = OUTPUT_DIR / "ibew111_jobs.json"
FIREBASE_CREDENTIALS_PATH = "android/app/google-services.json"  # <-- fill in your service‑account JSON path

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s – %(message)s")
logger = logging.getLogger(__name__)

def parse_job_row(cells):
    if len(cells) < 12:
        cells += [""] * (12 - len(cells))
    return {
        "Employer": cells[0].strip(),
        "JobClass": cells[1].strip(),
        "NumberOfJobs": cells[2].strip(),
        "City": cells[3].strip(),
        "Hours": cells[4].strip(),
        "StartDate": cells[5].strip(),
        "Wage": cells[6].strip(),
        "StartTime": cells[7].strip(),
        "Sub": cells[8].strip(),
        "SpecialQualifications": cells[9].strip(),
        "Agreement": cells[10].strip(),
        "Notes": cells[11].strip(),
    }

class TableParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_table = False
        self.in_row = False
        self.in_cell = False
        self.current_cells = []
        self.jobs = []
        self.current_data = ""
    def handle_starttag(self, tag, attrs):
        if tag == "table":
            if not self.in_table:
                self.in_table = True
        if self.in_table:
            if tag == "tr":
                self.in_row = True
                self.current_cells = []
            if tag in ("td", "th"):
                self.in_cell = True
                self.current_data = ""
    def handle_endtag(self, tag):
        if tag == "table" and self.in_table:
            self.in_table = False
        if self.in_table:
            if tag == "tr" and self.in_row:
                if any(cell.lower().startswith("employer") for cell in self.current_cells):
                    pass
                else:
                    self.jobs.append(parse_job_row(self.current_cells))
                self.in_row = False
            if tag in ("td", "th") and self.in_cell:
                self.current_cells.append(self.current_data.strip())
                self.in_cell = False
    def handle_data(self, data):
        if self.in_cell:
            self.current_data += data

async def scrape_ibew111():
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(url=DISPATCH_URL, extract_schema="html", timeout=30)
        if not result.success:
            raise RuntimeError(f"Crawl failed: {result.error_message}")
        html = result.html
        parser = TableParser()
        parser.feed(html)
        jobs = parser.jobs
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            json.dump(jobs, f, indent=2, ensure_ascii=False)
        logger.info(f"Scraped {len(jobs)} job entries and saved to {OUTPUT_FILE}")

def sanitize_job_data(job):
    sanitized = {k: (v.strip() if isinstance(v, str) else v) for k, v in job.items()}
    for key in ["employer", "jobClass", "location", "wage", "startDate", "description"]:
        sanitized.setdefault(key, "")
    return sanitized

def generate_job_id(local_number, classification, job):
    import hashlib
    base = f"{local_number}_{classification}_{job.get('employer','')}_{job.get('startDate','')}"
    return hashlib.sha256(base.encode()).hexdigest()[:20]

def validate_job_data(job_data):
    required = ["jobId", "localNumber", "employer", "jobClass", "location", "startDate"]
    return all(bool(job_data.get(k)) for k in required)

@retry(stop=stop_after_attempt(3), wait=wait_fixed(2), retry=retry_if_exception_type(Exception), reraise=True)
def firestore_operation(fn, *args, **kwargs):
    return fn(*args, **kwargs)

def update_database_with_jobs(classification, jobs, local_number):
    if FIREBASE_CREDENTIALS_PATH:
        db = firestore.Client.from_service_account_json(FIREBASE_CREDENTIALS_PATH)
    else:
        db = firestore.Client()
    logger.info(f"Updating Firestore with {len(jobs)} jobs for classification '{classification}' (Local {local_number})")
    def fetch_existing():
        return (
            db.collection("jobs")
            .where("localNumber", "==", local_number)
            .where("classification", "==", classification)
            .stream()
        )
    existing_jobs_snapshot = firestore_operation(fetch_existing)
    existing_jobs = {doc.id: doc.to_dict() for doc in existing_jobs_snapshot}
    logger.info(f"Found {len(existing_jobs)} existing jobs in Firestore for classification '{classification}'")
    valid_job_ids = set()
    for job in jobs:
        sanitized = sanitize_job_data(job)
        job_id = generate_job_id(local_number, classification, sanitized)
        valid_job_ids.add(job_id)
        job_data = {
            "jobId": job_id,
            "localNumber": local_number,
            "classification": classification,
            "employer": sanitized.get("employer"),
            "jobClass": sanitized.get("jobClass") or classification.replace("-", " "),
            "location": sanitized.get("location"),
            "wage": sanitized.get("wage"),
            "startDate": sanitized.get("startDate"),
            "description": sanitized.get("description"),
            "timestamp": existing_jobs.get(job_id, {}).get("timestamp", FieldValue.server_timestamp()),
        }
        if not validate_job_data(job_data):
            logger.warning(f"Invalid job data for {job_id}. Skipping.")
            continue
        doc_ref = db.collection("jobs").document(job_id)
        try:
            if job_id in existing_jobs:
                def update_fn():
                    doc_ref.update({
                        **job_data,
                        "timestamp": existing_jobs[job_id].get("timestamp", FieldValue.server_timestamp()),
                    })
                firestore_operation(update_fn)
                logger.info(f"Updated job {job_id}")
            else:
                def set_fn():
                    doc_ref.set(job_data)
                firestore_operation(set_fn)
                logger.info(f"Added new job {job_id}")
        except Exception as e:
            logger.error(f"Error updating/creating job {job_id}: {e}")
    for existing_id in list(existing_jobs.keys()):
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
    with open(OUTPUT_FILE, "r", encoding="utf-8") as f:
        scraped_jobs = json.load(f)
    for job in scraped_jobs:
        classification = job.get("JobClass", "unknown")
        update_database_with_jobs(classification, [job], local_number="111")