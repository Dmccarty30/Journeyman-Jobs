#!/usr/bin/env python3
"""
IBEW Union Pay Scales Scraper
Scrapes pay scale data from unionpayscales.com for IBEW linemen
"""

import requests
from bs4 import BeautifulSoup
import json
import csv
from typing import List, Dict, Optional
import logging
import time

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class PayScalesScraper:
    def __init__(self, url: str = "https://unionpayscales.com/trades/ibew-linemen/"):
        self.url = url
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }

    def fetch_page(self) -> Optional[str]:
        """Fetch the webpage content"""
        try:
            logger.info(f"Fetching data from {self.url}")
            response = requests.get(self.url, headers=self.headers, timeout=30)
            response.raise_for_status()
            logger.info("Successfully fetched webpage")
            return response.text
        except requests.RequestException as e:
            logger.error(f"Failed to fetch webpage: {e}")
            return None

    def extract_table_data(self, html_content: str) -> List[Dict[str, str]]:
        """Extract data from the pay scales table"""
        soup = BeautifulSoup(html_content, 'html.parser')

        # Find the main table
        table = soup.find('table', {'id': 'tablepress-3'})
        if not table:
            logger.warning("Could not find the pay scales table")
            return []

        # Extract headers from thead
        headers = []
        thead = table.find('thead')
        if thead:
            # Find all header rows and get the most complete one
            header_rows = thead.find_all('tr')
            for header_row in header_rows:
                th_elements = header_row.find_all(['th'])
                temp_headers = []
                for th in th_elements:
                    # Try multiple ways to get the header text
                    header_text = None

                    # First try the dt-column-title span
                    span = th.find('span', class_='dt-column-title')
                    if span:
                        header_text = span.get_text(strip=True)
                    else:
                        # Fall back to direct text
                        header_text = th.get_text(strip=True)

                    if header_text and header_text not in ['', ' ', '\n']:
                        temp_headers.append(header_text)

                # Use this row if it has more headers than previous ones
                if len(temp_headers) > len(headers):
                    headers = temp_headers

        # If we still don't have headers, try alternative approach
        if not headers:
            # Look for headers in the dt-scroll-head section
            head_section = soup.find('div', class_='dt-scroll-head')
            if head_section:
                table_in_head = head_section.find('table')
                if table_in_head:
                    thead_in_head = table_in_head.find('thead')
                    if thead_in_head:
                        header_row = thead_in_head.find('tr')
                        if header_row:
                            th_elements = header_row.find_all('th')
                            for th in th_elements:
                                span = th.find('span', class_='dt-column-title')
                                if span:
                                    headers.append(span.get_text(strip=True))

        logger.info(f"Found {len(headers)} headers: {headers}")

        # Extract data rows from tbody
        data_rows = []
        tbody = table.find('tbody')
        if tbody:
            rows = tbody.find_all('tr')
            for row in rows:
                cells = row.find_all(['td', 'th'])
                if len(cells) >= len(headers):
                    row_data = {}
                    for i, cell in enumerate(cells[:len(headers)]):
                        # Get text content
                        text = cell.get_text(strip=True)

                        # Handle special cases
                        if i == len(headers) - 1:  # Wage Sheet column (links)
                            link = cell.find('a')
                            if link and link.get('href'):
                                text = link['href']
                            else:
                                text = ""

                        # Store with header name
                        if i < len(headers):
                            row_data[headers[i]] = text

                    # Only add rows that have meaningful data (not empty first column)
                    if row_data.get(headers[0], '').strip() and row_data[headers[0]] != 'Average Of All Cities':
                        data_rows.append(row_data)
                        logger.debug(f"Extracted row: {row_data.get(headers[0], 'Unknown')}")

        logger.info(f"Extracted {len(data_rows)} data rows")
        return data_rows

    def clean_data(self, data: List[Dict[str, str]]) -> List[Dict[str, str]]:
        """Clean and normalize the extracted data"""
        cleaned_data = []

        for row in data:
            cleaned_row = {}
            for key, value in row.items():
                # Clean up the value
                cleaned_value = value.replace('\n', ' ').strip()

                # Handle special cases
                if 'No Data' in cleaned_value:
                    cleaned_value = ''
                elif cleaned_value == '-' or cleaned_value == '--':
                    cleaned_value = ''

                # Clean commas from numbers
                if any(char.isdigit() for char in cleaned_value):
                    # Remove commas from numeric strings
                    cleaned_value = cleaned_value.replace(',', '')

                cleaned_row[key] = cleaned_value

            cleaned_data.append(cleaned_row)

        return cleaned_data

    def save_to_csv(self, data: List[Dict[str, str]], filename: str) -> None:
        """Save data to CSV file"""
        if not data:
            logger.warning("No data to save")
            return

        try:
            with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=data[0].keys())
                writer.writeheader()
                writer.writerows(data)
            logger.info(f"Data saved to {filename}")
        except Exception as e:
            logger.error(f"Failed to save CSV: {e}")

    def save_to_json(self, data: List[Dict[str, str]], filename: str) -> None:
        """Save data to JSON file"""
        try:
            with open(filename, 'w', encoding='utf-8') as jsonfile:
                json.dump(data, jsonfile, indent=2, ensure_ascii=False)
            logger.info(f"Data saved to {filename}")
        except Exception as e:
            logger.error(f"Failed to save JSON: {e}")

    def scrape_and_save(self, output_format: str = 'both') -> List[Dict[str, str]]:
        """Main scraping function that fetches data and saves to files"""
        # Fetch the webpage
        html_content = self.fetch_page()
        if not html_content:
            return []

        # Extract table data
        raw_data = self.extract_table_data(html_content)
        if not raw_data:
            logger.warning("No data extracted from table")
            return []

        # Clean the data
        cleaned_data = self.clean_data(raw_data)
        logger.info(f"Successfully extracted and cleaned {len(cleaned_data)} pay scale records")

        # Ensure outputs directory exists
        import os
        os.makedirs('scraping_scripts/outputs', exist_ok=True)

        # Save to files
        timestamp = time.strftime("%Y%m%d_%H%M%S")

        if output_format in ['csv', 'both']:
            csv_filename = f'scraping_scripts/outputs/pay_scales_{timestamp}.csv'
            self.save_to_csv(cleaned_data, csv_filename)

        if output_format in ['json', 'both']:
            json_filename = f'scraping_scripts/outputs/pay_scales_{timestamp}.json'
            self.save_to_json(cleaned_data, json_filename)

        return cleaned_data

def main():
    """Main function to run the scraper"""
    scraper = PayScalesScraper()

    # Scrape and save data
    data = scraper.scrape_and_save()

    if data:
        logger.info(f"✅ Successfully scraped {len(data)} pay scale records")

        # Show sample of the data
        logger.info("Sample records:")
        for i, record in enumerate(data[:3]):  # Show first 3 records
            logger.info(f"Record {i+1}: {record.get('City', 'Unknown')} - ${record.get('Yearly Salary Based On 40hr Weeks', 'N/A')}")

        print(f"\n📊 Total locations scraped: {len(data)}")
        print("Data saved to scraping_scripts/outputs/")

    else:
        logger.error("❌ Failed to scrape pay scale data")
        return 1

    return 0

if __name__ == "__main__":
    exit(main())
