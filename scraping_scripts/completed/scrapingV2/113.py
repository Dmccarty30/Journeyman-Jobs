import requests
from bs4 import BeautifulSoup
import json
import os

# URL to scrape
url = "https://ibew113.com/job-board/"

# Send a GET request to the URL
response = requests.get(url)

# Check if the request was successful
if response.status_code == 200:
    # Parse the HTML content
    soup = BeautifulSoup(response.content, 'html.parser')

    # Find the table by its ID
    table = soup.find('table', {'id': 'jobs-table'})

    # Debugging: Check if table is found
    if table is None:
        print("Table not found. Please check the HTML structure.")
    else:
        # Initialize a list to hold the extracted data
        data = []

        # Extract headers
        headers = [header.get_text(strip=True) for header in table.find_all('th')]

        # Debugging: Print headers
        print("Headers:", headers)

        # Extract rows
        for row in table.find_all('tr')[1:]:  # Skip the header row
            cols = row.find_all('td')
            row_data = [col.get_text(strip=True) for col in cols]
            data.append(dict(zip(headers, row_data)))

        # Define the output file path
        output_file_path = "X:/Journeyman_Jobs/v3/.outputs/scrapers/113__job_listings.json"
        os.makedirs(os.path.dirname(output_file_path), exist_ok=True)

        # Save the extracted data to a JSON file
        with open(output_file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)

        print(f"Data extracted and saved to {output_file_path}")
else:
    print(f"Failed to retrieve data. Status code: {response.status_code}")