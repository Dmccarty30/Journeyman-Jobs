#!/usr/bin/env python3
"""Scrape IBEW Local 111 dispatch page and save job listings as JSON.

Requirements
------------
- Python 3.9+ (the environment already has a virtual‑env activated)
- Crawl4AI library (`pip install crawl4ai`)

The script:
1. Loads the dispatch page (`https://www.ibew111.org/dispatch`).
2. Uses Crawl4AI's adaptive crawler to extract the job table.
3. Normalises each row into a dictionary with the same keys that were used for the
   Local 111 example you approved earlier.
4. Writes the list of jobs to `/a0/work zone/Jobs/111/ibew111_jobs.json`.
"""

import asyncio
import json
import os
from pathlib import Path

from crawl4ai import AsyncWebCrawler

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DISPATCH_URL = "https://www.ibew111.org/dispatch"
OUTPUT_DIR = Path("/a0/work zone/Jobs/111")
OUTPUT_FILE = OUTPUT_DIR / "ibew111_jobs.json"

# Ensure the output directory exists (it should already, but just in case)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# Helper: transform a raw HTML table row into a clean dict
# ---------------------------------------------------------------------------
def parse_job_row(cells: list) -> dict:
    """Map the list of <td> elements to the expected fields.

    The exact column order on the IBEW 111 page (as of the last scrape) is:
    0 – Company / Employer
    1 – Class
    2 – Number of Jobs
    3 – Location / City
    4 – Hours
    5 – Starting Date
    6 – Wage
    7 – Starting Time
    8 – Sub (if any)
    9 – Special Qualifications
    10 – Agreement
    11 – Notes
    """
    # Guard against malformed rows
    if len(cells) < 12:
        # Pad missing columns with empty strings
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

# ---------------------------------------------------------------------------
# Main async crawler
# ---------------------------------------------------------------------------
async def scrape_ibew111() -> None:
    async with AsyncWebCrawler() as crawler:
        # Crawl the page – we ask Crawl4AI to return the raw HTML so we can parse it ourselves.
        result = await crawler.arun(
            url=DISPATCH_URL,
            # We only need the main content; Crawl4AI will strip navigation, ads, etc.
            extract_schema="html",
            # A short timeout keeps the run cheap; the page is lightweight.
            timeout=30,
        )

        if not result.success:
            raise RuntimeError(f"Crawl failed: {result.error_message}")

        html = result.html
        # -------------------------------------------------------------------
        # Simple HTML parsing – we avoid heavy dependencies (BeautifulSoup) by
        # using the built‑in html.parser library which is sufficient for the
        # straightforward table on the dispatch page.
        # -------------------------------------------------------------------
        from html.parser import HTMLParser

        class TableParser(HTMLParser):
            def __init__(self):
                super().__init__()
                self.in_table = False
                self.in_row = False
                self.in_cell = False
                self.current_cells = []
                self.jobs = []

            def handle_starttag(self, tag, attrs):
                if tag == "table":
                    # The dispatch page contains a single job table – we capture the first one.
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
                        # Skip header rows that contain column titles (they usually have <th>)
                        if any(cell.lower().startswith("employer") for cell in self.current_cells):
                            pass
                        else:
                            self.jobs.append(parse_job_row(self.current_cells))
                        self.in_row = False
                    if tag in ("td", "th") and self.in_cell:
                        # Store the collected text for this cell
                        self.current_cells.append(self.current_data.strip())
                        self.in_cell = False

            def handle_data(self, data):
                if self.in_cell:
                    self.current_data += data

        parser = TableParser()
        parser.feed(html)
        jobs = parser.jobs

        # -------------------------------------------------------------------
        # Write results to JSON file
        # -------------------------------------------------------------------
        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            json.dump(jobs, f, indent=2, ensure_ascii=False)

        print(f"✅ Scraped {len(jobs)} job entries and saved to {OUTPUT_FILE}")

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    asyncio.run(scrape_ibew111())
