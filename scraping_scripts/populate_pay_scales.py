import json
import firebase_admin
from firebase_admin import credentials, firestore
import os

def setup_firestore():
    """Initialize Firestore with credentials"""
    # Use the path from the user's FIREBASE_CREDENTIALS_PATH
    cred_path = r"C:\Users\david\Desktop\Journeyman-Jobs\scraping_scripts\jj-firebase-adminsdk.json"

    if not os.path.exists(cred_path):
        raise FileNotFoundError(f"Firebase credentials not found at {cred_path}")

    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

    return firestore.client()

def load_pay_scales_data():
    """Load the pay scales JSON data"""
    data_path = "scraping_scripts/outputs/pay_scales_20251016_102658.json"

    if not os.path.exists(data_path):
        raise FileNotFoundError(f"Pay scales data not found at {data_path}")

    with open(data_path, 'r') as f:
        data = json.load(f)

    return data

def clean_data(record):
    """Clean and validate a single pay scale record"""
    # Create document ID using Local Number
    doc_id = f"local_{record['Local Number']}"

    # Clean and parse monetary values (remove $ and commas, convert to float)
    def parse_money(value):
        if isinstance(value, str) and value.strip() and value.strip() != "$" and value.strip() != "":
            try:
                # Remove $, commas, and extra spaces
                cleaned = value.replace("$", "").replace(",", "").strip()
                return float(cleaned) if cleaned else None
            except ValueError:
                return None
        return None

    def parse_percentage(value):
        if isinstance(value, str) and value.strip() and value != "" and value != "-%":
            try:
                # Remove % and convert to decimal
                cleaned = value.replace("%", "").strip()
                return float(cleaned) / 100 if cleaned.replace(".", "").isdigit() else None
            except ValueError:
                return None
        return None

    # Parse fields that need cleaning
    cleaned_record = {
        "localNumber": record.get("Local Number"),
        "city": record.get("City", "").strip(),
        "state": record.get("State", "").strip(),
        "yearlySalaryBasedOn40hrWeeks": parse_money(record.get("Yearly SalaryBased On 40hrWeeks")),
        "hourlyRate": parse_money(record.get("Hourly Rate")),
        "totalPackage": parse_money(record.get("Total Package")),
        "costOfLivingAsAPercentageOfNationalAvg": parse_percentage(record.get("Cost Of LivingAs A % OfNational Avg")),
        "adjustedBaseWageForCostOfLiving": parse_money(record.get("Adjusted BaseWage For CostOf Living")),
        "definedPension": parse_money(record.get("DefinedPension")),
        "contributionPension": parse_money(record.get("ContributionPension")),
        "pension401K": parse_money(record.get("401K /Annuity")),
        "perDiem": parse_money(record.get("Per Diem")),
        "nebf": parse_money(record.get("NEBF")),
        "vacationPay": parse_money(record.get("Vacation Pay")) if record.get("Vacation Pay", "").strip() else None,
        "healthAndWelfare": parse_money(record.get("H&W")),
        "dues": record.get("Dues", "").strip() if record.get("Dues", "").strip() else None,
        "lastUpdated": record.get("Last Updated", "").strip() or None,
        "wageSheet": record.get("Wage Sheet", "").strip() or None
    }

    # Remove None values and empty strings
    final_record = {k: v for k, v in cleaned_record.items() if v is not None and v != ""}

    return doc_id, final_record

def populate_pay_scales():
    """Main function to populate payScale collection"""
    print("Setting up Firestore connection...")
    db = setup_firestore()

    print("Loading pay scales data...")
    data = load_pay_scales_data()

    print(f"Found {len(data)} records to process...")

    successful_uploads = 0
    failed_uploads = 0

    # Process in batches for better performance
    batch = db.batch()
    batch_size = 500  # Firestore batch limit is 500 operations

    for i, record in enumerate(data):
        try:
            doc_id, cleaned_record = clean_data(record)

            # Use set() with merged=True to update if exists, create if not
            doc_ref = db.collection("payScale").document(doc_id)
            batch.set(doc_ref, cleaned_record, merge=True)

            successful_uploads += 1

            # Commit batch when it reaches size limit or at the end
            if (i + 1) % batch_size == 0 or i == len(data) - 1:
                print(f"Committing batch {((i + 1) // batch_size) + 1}...")
                batch.commit()
                batch = db.batch()  # Start new batch

                if i + 1 < len(data):
                    print(f"Processed {i + 1}/{len(data)} records...")

        except Exception as e:
            print(f"Error processing record {i + 1}: {e}")
            failed_uploads += 1

    print("\nUpload complete!")
    print(f"Successfully uploaded: {successful_uploads} documents")
    print(f"Failed uploads: {failed_uploads} documents")

    if failed_uploads > 0:
        print("Check the errors above for records that failed to upload.")

if __name__ == "__main__":
    populate_pay_scales()
