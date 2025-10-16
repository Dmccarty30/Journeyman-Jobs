import json
import os
import re
import time
import random
import logging
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import (
    NoSuchElementException,
    TimeoutException,
)
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager  # For automatic driver management
from google.cloud import firestore  # Firestore

# Initialize Firestore
db = firestore.Client()

def setup_driver(headless=True):
    """Set up the Selenium WebDriver."""
    chrome_options = Options()
    if headless:
        chrome_options.add_argument("--headless")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)"
        " Chrome/85.0.4183.102 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko)"
        " Version/14.0 Safari/605.1.15",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)"
        " Chrome/88.0.4324.96 Safari/537.36",
    ]
    chrome_options.add_argument(f'user-agent={random.choice(user_agents)}')

    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
    return driver

def navigate_to_job_listings(driver, url):
    """Navigate to the job listings page."""
    logging.info(f"Navigating to {url}")
    driver.get(url)
    try:
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "ul.job_listings"))
        )
        logging.info("Navigated to job listings page.")
    except TimeoutException:
        logging.error("Timeout while loading job listings page.")
        driver.quit()
        exit(1)

def extract_job_links(driver):
    """Extract all job listing links."""
    try:
        job_elements = driver.find_elements(By.CSS_SELECTOR, "ul.job_listings li.job_listing a")
        job_links = [job.get_attribute("href") for job in job_elements]
        logging.info(f"Found {len(job_links)} job listings.")
        return job_links
    except NoSuchElementException:
        logging.error("No job listings found.")
        return []

def extract_job_details(driver):
    """Extract job details from the job detail page."""
    job_data = {}
    try:
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "div.single_job_listing"))
        )

        # Extract Job Title
        try:
            job_title = driver.find_element(By.CSS_SELECTOR, "#breadcrumbs > div > div > span:nth-child(3)").text.strip()
        except NoSuchElementException:
            job_title = "N/A"

        # Extract Company Name
        try:
            company = driver.find_element(By.CSS_SELECTOR, "div.company_header p.name strong").text.strip()
        except NoSuchElementException:
            company = "N/A"

        # Extract Location
        try:
            location = driver.find_element(By.CSS_SELECTOR, "ul.job-listing-meta li.location a").text.strip()
        except NoSuchElementException:
            location = "N/A"

        # Extract Date Posted
        try:
            date_posted = driver.find_element(By.CSS_SELECTOR, "ul.job-listing-meta li.date-posted time").text.strip()
        except NoSuchElementException:
            date_posted = "N/A"

        # Extract Job Description
        try:
            job_description = driver.find_element(By.CSS_SELECTOR, "div.job_description p").text.strip()
        except NoSuchElementException:
            job_description = "N/A"

        job_data = {
            "Job Title": job_title,
            "Company": company,
            "Location": location,
            "Date Posted": date_posted,
            "Job Description": job_description,
           # "Job URL": driver.current_url
        }

        # Categorize the job description fields
        categorize_job_description(job_data)

    except TimeoutException:
        logging.error("Timeout while loading job detail page.")
    except Exception as e:
        logging.error(f"Error extracting job details: {e}")

    return job_data

def categorize_job_description(job_data):
    """Categorizes the job description for hours, per diem, and wage."""
    job_description = job_data["Job Description"]

    # Initialize fields
    job_data["Hours"] = None
    job_data["Per Diem"] = None
    job_data["Wage"] = None
    job_data["Shift"] = None

    # Regular expressions for extraction
    hours_pattern = re.compile(r'(\d+-\d+|(\d+))')
    per_diem_pattern = re.compile(r'\$([\d,]+(?:\.\d+)?)\s*(?:a day|per diem)?')
    wage_pattern = re.compile(r'\$([\d,]+(?:\.\d+)?)\s*(?:\w+)?\s*(?:hour|hourly)?')
    shift_pattern = re.compile(r'(?:\d+[a-z]*\s*shift)')

    # Extract hours
    hours_match = hours_pattern.search(job_description)
    if hours_match:
        job_data["Hours"] = hours_match.group(0)

    # Extract per diem
    per_diem_match = per_diem_pattern.search(job_description)
    if per_diem_match:
        job_data["Per Diem"] = f"${per_diem_match.group(1)}"

    # Extract wage
    wage_match = wage_pattern.search(job_description)
    if wage_match:
        job_data["Wage"] = f"${wage_match.group(1)}"

    # Extract shift
    shift_match = shift_pattern.search(job_description)
    if shift_match:
        job_data["Shift"] = shift_match.group(0)

def save_to_json(job_list, output_path, filename="job_listings.json"):
    """Save the list of job dictionaries to a JSON file."""
    if not job_list:
        logging.warning("No job data to save.")
        return

    os.makedirs(output_path, exist_ok=True)

    full_path = os.path.join(output_path, filename)

    try:
        with open(full_path, mode="w", encoding="utf-8") as file:
            json.dump(job_list, file, ensure_ascii=False, indent=4)
        logging.info(f"Saved job data to {full_path}")
    except Exception as e:
        logging.error(f"Failed to save JSON file: {e}")

def configure_logging(output_path):
    """Configure logging to a file and console."""
    log_file = os.path.join(output_path, "104_job_scraper.log")
    os.makedirs(output_path, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file, mode='a', encoding='utf-8'),
            logging.StreamHandler()
        ]
    )

def update_database_with_jobs(jobs, local_number):
    """Update Firestore with the given jobs."""
    valid_job_ids = set()

    for job in jobs:
        title_parts = job["Job Title"].split(' ', 2)
        positions = title_parts[0]
        classification = title_parts[1] + " " + title_parts[2] if len(title_parts) > 2 else "N/A"
        job_id = f"{local_number}-{classification}-{sanitize_string(job['Company'])}"

        valid_job_ids.add(job_id)

        job_data = {
            'job_title': job["Job Title"],
            'company': job["Company"],
            'location': job["Location"],
            'date_posted': job["Date Posted"],
            'job_description': job["Job Description"],            
            'hours': job.get("Hours"),
            'per_diem': job.get("Per Diem"),
            'wage': job.get("Wage"),
            'shift': job.get("Shift"),
        }

        job_doc_ref = db.collection('jobs').document(job_id)

        if job_doc_ref.get().exists:
            job_doc_ref.update(job_data)
            logging.info(f'Updated job {job_id}')
        else:
            job_doc_ref.set(job_data)
            logging.info(f'Added new job {job_id}')

    existing_jobs = db.collection('jobs').where('local_number', '==', local_number).get()
    existing_job_ids = {job.id for job in existing_jobs}
    
    for job_id in existing_job_ids:
        if job_id not in valid_job_ids:
            db.collection('jobs').document(job_id).delete()
            logging.info(f'Deleted outdated job {job_id}')

def sanitize_string(str):
    return str.replace('/', '_').replace('\\', '_').replace('#', '').replace('$', '')

def main():
    # Configuration
    JOB_LISTINGS_URL = "https://ibew104.org/ibew-local-104-referral/current-open-calls/"
    OUTPUT_DIRECTORY = r"X:\Journeyman_Jobs\v3\.outputs\scrapers"
    OUTPUT_FILENAME = "104_job_listings.json"
    HEADLESS_MODE = True

    # Configure logging
    configure_logging(OUTPUT_DIRECTORY)
    logging.info("Job Scraper Started.")

    # Initialize WebDriver
    driver = setup_driver(headless=HEADLESS_MODE)

    try:
        # Navigate to the job listings page
        navigate_to_job_listings(driver, JOB_LISTINGS_URL)

        # Extract all job links
        job_links = extract_job_links(driver)

        if not job_links:
            logging.warning("No jobs to process.")
            return

        job_data_list = []

        for index, job_url in enumerate(job_links, start=1):
            logging.info(f"Processing Job {index}: {job_url}")
            retry_count = 0
            max_retries = 3

            while retry_count < max_retries:
                try:
                    driver.execute_script("window.open(arguments[0], '_blank');", job_url)
                    driver.switch_to.window(driver.window_handles[1])  # Switch to the new tab

                    job_data = extract_job_details(driver)
                    job_data_list.append(job_data)

                    logging.info(f"Extracted data for Job {index}: {job_data['Job Title']} at {job_data['Company']}")

                    driver.close()
                    driver.switch_to.window(driver.window_handles[0])  # Switch back to the main tab

                    time.sleep(random.uniform(1, 3))
                    break

                except Exception as e:
                    logging.error(f"An error occurred while processing Job {index}: {e}")
                    retry_count += 1
                    logging.info(f"Retrying ({retry_count}/{max_retries})...")
                    time.sleep(2)
                    if retry_count == max_retries:
                        logging.error(f"Failed to process Job {index} after {max_retries} attempts.")
                        job_data_list.append({
                            "Job Title": "N/A",
                            "Company": "N/A",
                            "Location": "N/A",
                            "Date Posted": "N/A",
                            "Job Description": "N/A",
                           # "Job URL": job_url
                        })

        save_to_json(job_data_list, OUTPUT_DIRECTORY, filename=OUTPUT_FILENAME)

        local_number = JOB_LISTINGS_URL.split('-')[2]

        update_database_with_jobs(job_data_list, local_number)

    finally:
        driver.quit()
        logging.info("Browser closed.")
        logging.info("Job Scraper Finished.")

if __name__ == "__main__":
    main()