import json
import os
import time
from dotenv import load_dotenv  # For loading .env
from firebase_admin import credentials
from firebase_admin import firestore
import firebase_admin

# Load environment variables from .env file
load_dotenv()

# Path to service account key from env (add GOOGLE_APPLICATION_CREDENTIALS=/path/to/your-service-account-key.json to your .env)
cred = credentials.Certificate("C:\\Users\\david\\Desktop\\Journeyman-Jobs\\.secrets\\journeyman-jobs-firebase-adminsdk-rwcqx-b2872d649a.json")
firebase_admin.initialize_app(cred)

# Script to import contractor data from storm_roster.json into Firestore
#
# Usage:
# 1. Ensure you have the storm_roster.json file in the docs/ directory
# 2. Run this script from your project
# 3. The script will batch import all contractors to the 'stormcontractors' collection
#
# Note: This is a one-time migration script. Run with caution in production.
def import_contractors():
    try:
        # Read the JSON file
        file_path = 'docs/storm_roster.json'
        
        if not os.path.exists(file_path):
            return
        
        with open(file_path, 'r') as file:
            json_string = file.read()
        contractors = json.loads(json_string)
        
        
        # Initialize Firestore
        db = firestore.client()
        
        # Process in batches of 500 (Firestore batch limit)
        batch_size = 500
        
        for i in range(0, len(contractors), batch_size):
            batch = db.batch()
            end = i + batch_size if i + batch_size < len(contractors) else len(contractors)
            
            
            for j in range(i, end):
                contractor = contractors[j]
                doc_ref = db.collection('stormcontractors').document()
                
                # Map the JSON fields to Firestore format
                batch.set(doc_ref, {
                    'id': doc_ref.id,
                    'company': contractor['COMPANY'] if 'COMPANY' in contractor else '',
                    'howToSignup': contractor['HOW TO SIGNUP'] if 'HOW TO SIGNUP' in contractor else '',
                    'phoneNumber': contractor['PHONE NUMBER'],
                    'email': contractor['EMAIL'],
                    'website': contractor['WEBSITE'],
                    'createdAt': firestore.SERVER_TIMESTAMP,
                })
            
            # Commit the batch
            batch.commit()
        
        
    except Exception as e:
        raise e

def import_contractors_with_validation():
    try:
        # Construct path to docs/storm_roster.json from the project root
        project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
        file_path = os.path.join(project_root, 'docs', 'storm_roster.json')
        
        print(f"Attempting to read data from: {file_path}")

        if not os.path.exists(file_path):
            print(f"Error: Data file not found.")
            print(f"Please ensure 'storm_roster.json' exists in the '{os.path.join(project_root, 'docs')}' directory.")
            return
        
        with open(file_path, 'r') as file:
            json_string = file.read()
        contractors = json.loads(json_string)
        print(f"Found {len(contractors)} records in the JSON file.")
        
        
        db = firestore.client()
        success_count = 0
        error_count = 0
        
        for contractor in contractors:
            try:
                # Validate required fields
                if 'COMPANY' not in contractor or not str(contractor['COMPANY']):
                    error_count += 1
                    continue
                
                doc_ref = db.collection('stormcontractors').document()

                doc_ref.set({
                    'id': doc_ref.id,
                    'company': contractor.get('COMPANY', '').strip(),
                    'howToSignup': contractor.get('HOW TO SIGNUP', '').strip(),
                    'phoneNumber': contractor.get('PHONE NUMBER', '').strip(),
                    'email': contractor.get('EMAIL', '').strip(),
                    'website': contractor.get('WEBSITE', '').strip(),
                    'createdAt': firestore.SERVER_TIMESTAMP,
                })
                
                success_count += 1
                
            except Exception as validation_error:
                print(f"Error processing a record: {validation_error}")
                error_count += 1
        
        print(f"\nImport complete.")
        print(f"Successfully imported {success_count} contractors.")
        if error_count > 0:
            print(f"Skipped {error_count} records due to missing data or errors.")
        
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        raise e

# Utility function to check if contractors already exist
def contractors_exist():
    try:
        db = firestore.client()
        snapshot = db.collection('stormcontractors').limit(1).get()
        return len(snapshot) > 0
    except Exception:
        return False

# Main function to run the import
def main():
    print("Starting contractor import script...")
    
    # Check if contractors already exist
    if contractors_exist():
        print("It looks like contractors have already been imported. Aborting to prevent duplicates.")
        return
    
    # Run the import with validation
    print("Importing contractors...")
    import_contractors_with_validation()
    print("Import script finished.")

if __name__ == '__main__':
    main()
