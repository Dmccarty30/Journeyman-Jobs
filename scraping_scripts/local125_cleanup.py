#!/usr/bin/env python3
"""
Local 125 Firestore Cleanup Script

This script identifies and removes invalid/stale job documents for IBEW Local 125
from the Firestore jobs collection, while preserving valid jobs.

Features:
- Backup creation before any deletions
- Detailed inventory reporting
- Dry-run capability
- Batch processing with retry logic
- Audit trail for all operations

Usage:
    python local125_cleanup.py --backup       # Create backup only
    python local125_cleanup.py --inventory    # Create inventory report only  
    python local125_cleanup.py --dry-run      # Show what would be deleted
    python local125_cleanup.py --cleanup      # Actually delete invalid docs
"""

import re
import json
import time
import random
import argparse
import collections
from pathlib import Path
from google.cloud import firestore

# Configuration
SCRIPT_DIR = Path(__file__).parent
CREDENTIALS_PATH = SCRIPT_DIR / "jj-firebase-adminsdk.json"
BACKUPS_DIR = SCRIPT_DIR / "backups"
REPORTS_DIR = SCRIPT_DIR / "reports"

# Valid classifications for Local 125 jobs
VALID_CLASSIFICATIONS = {
    'journeyman-lineman',
    'general', 
    'line_clearance_tree_trimming',
    'cable-splicer',
    'traffic-control'
}

# Regex patterns for invalid classifications
DATE_RE = re.compile(r'^\d{1,2}([_/.-])\d{1,2}\1\d{2,4}$')
ORDINAL_RE = re.compile(r'^\s*\d+\s+')


def get_db():
    """Initialize Firestore client."""
    return firestore.Client.from_service_account_json(str(CREDENTIALS_PATH))


def fetch_local_125_docs(db):
    """Fetch all Local 125 documents from Firestore."""
    docs = {}
    # Handle both string and numeric localNumber values
    for val in ('125', 125):
        for doc in db.collection('jobs').where(filter=firestore.FieldFilter('localNumber', '==', val)).stream():
            docs[doc.id] = doc
    return docs


def create_backup(db):
    """Create a backup of all Local 125 documents."""
    print("Creating backup of Local 125 documents...")
    docs = fetch_local_125_docs(db)
    
    timestamp = int(time.time())
    backup_path = BACKUPS_DIR / f"jobs_local_125_{timestamp}.jsonl"
    
    BACKUPS_DIR.mkdir(exist_ok=True)
    
    with open(backup_path, 'w', encoding='utf-8') as f:
        for doc in docs.values():
            record = doc.to_dict()
            record['__id'] = doc.id
            f.write(json.dumps(record, default=str) + '\n')
    
    print(f"Backup created: {backup_path}")
    print(f"Backed up {len(docs)} documents")
    return backup_path


def create_inventory(db):
    """Create detailed inventory report of Local 125 documents."""
    print("Creating inventory report...")
    docs = fetch_local_125_docs(db)
    
    classifications = collections.defaultdict(list)
    for doc in docs.values():
        classification = doc.to_dict().get('classification', 'unknown')
        classifications[classification].append(doc.id)
    
    timestamp = int(time.time())
    report = {
        "timestamp": timestamp,
        "total_local_125": len(docs),
        "by_classification": {
            k: {
                "count": len(v), 
                "sample_ids": v[:5]
            } for k, v in classifications.items()
        }
    }
    
    REPORTS_DIR.mkdir(exist_ok=True)
    report_path = REPORTS_DIR / f"local125_baseline_{timestamp}.json"
    
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2)
    
    print(f"Inventory report created: {report_path}")
    print(json.dumps(report, indent=2))
    
    return report_path


def analyze_documents(db):
    """Analyze documents and identify candidates for deletion."""
    print("Analyzing documents...")
    docs = fetch_local_125_docs(db)
    
    to_delete = []
    to_keep = []
    
    for doc in docs.values():
        data = doc.to_dict()
        classification_raw = data.get('classification')
        classification = (classification_raw or '').strip().lower()
        
        reasons = []
        
        # Check for missing classification
        if not classification:
            reasons.append('missing_classification')
        
        # Check for date-like classification
        if classification and DATE_RE.match(classification):
            reasons.append('date_like_classification')
        
        # Check for ordinal prefix (e.g., "1 Forest Tech")
        if classification and ORDINAL_RE.match(classification):
            reasons.append('ordinal_prefix_malformed')
        
        # Check if not in valid classifications (but only if no other issues)
        if classification and not reasons and classification not in VALID_CLASSIFICATIONS:
            reasons.append('not_in_allowlist')
        
        entry = {
            "id": doc.id,
            "classification": classification_raw,
            "reasons": reasons
        }
        
        if reasons:
            to_delete.append(entry)
        else:
            to_keep.append(entry)
    
    return to_delete, to_keep


def perform_dry_run(db):
    """Perform dry run analysis."""
    print("=== DRY RUN MODE ===")
    to_delete, to_keep = analyze_documents(db)
    
    print(f"Total Local 125 documents: {len(to_delete) + len(to_keep)}")
    print(f"Documents to DELETE: {len(to_delete)}")
    print(f"Documents to KEEP: {len(to_keep)}")
    
    if to_delete:
        print("\nDocuments scheduled for deletion:")
        for i, doc in enumerate(to_delete[:10], 1):
            reasons = ", ".join(doc['reasons'])
            print(f"  {i}. {doc['id']} | {doc['classification']} | Reasons: {reasons}")
        
        if len(to_delete) > 10:
            print(f"  ... and {len(to_delete) - 10} more documents")
    
    if to_keep:
        print("\nSample documents to keep:")
        for i, doc in enumerate(to_keep[:5], 1):
            print(f"  {i}. {doc['id']} | {doc['classification']}")
    
    # Save candidates report
    timestamp = int(time.time())
    candidates_report = {
        "timestamp": timestamp,
        "project_id": db.project,
        "total_examined": len(to_delete) + len(to_keep),
        "to_delete_count": len(to_delete),
        "to_keep_count": len(to_keep),
        "to_delete": to_delete,
        "sample_keep": to_keep[:50]
    }
    
    REPORTS_DIR.mkdir(exist_ok=True)
    report_path = REPORTS_DIR / f"local125_cleanup_candidates_{timestamp}.json"
    
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(candidates_report, f, indent=2)
    
    print(f"\nDetailed analysis saved to: {report_path}")
    return len(to_delete)


def perform_cleanup(db):
    """Perform actual document deletion."""
    print("=== CLEANUP MODE ===")
    to_delete, to_keep = analyze_documents(db)
    
    print(f"Found {len(to_delete)} invalid Local 125 documents to delete")
    
    if not to_delete:
        print("No invalid documents found. Nothing to delete.")
        return 0
    
    # Confirm with user
    response = input(f"Are you sure you want to delete {len(to_delete)} documents? [y/N]: ")
    if response.lower() != 'y':
        print("Cleanup cancelled.")
        return 0
    
    # Create audit record
    audit = {
        "timestamp": int(time.time()),
        "deleted": [],
        "dry_run": False
    }
    
    # Delete in batches
    BATCH_SIZE = 450
    deleted_count = 0
    
    for i in range(0, len(to_delete), BATCH_SIZE):
        batch_docs = to_delete[i:i + BATCH_SIZE]
        
        # Retry logic
        attempt = 1
        max_attempts = 5
        delay = 0.5
        
        while attempt <= max_attempts:
            try:
                batch = db.batch()
                for doc_info in batch_docs:
                    batch.delete(db.collection('jobs').document(doc_info['id']))
                
                batch.commit()
                audit['deleted'].extend(batch_docs)
                deleted_count += len(batch_docs)
                
                print(f"Deleted batch {i//BATCH_SIZE + 1}: {len(batch_docs)} documents")
                break
                
            except Exception as e:
                if attempt >= max_attempts:
                    print(f"Failed after {attempt} attempts on batch starting at {i}: {e}")
                    raise
                
                sleep_time = delay * (2 ** (attempt - 1)) * (1 + random.random() * 0.25)
                print(f"Retry {attempt}/{max_attempts} after error: {e} (sleep {sleep_time:.2f}s)")
                time.sleep(sleep_time)
                attempt += 1
    
    # Save audit report
    REPORTS_DIR.mkdir(exist_ok=True)
    audit_path = REPORTS_DIR / f"local125_deleted_{audit['timestamp']}.json"
    
    with open(audit_path, 'w', encoding='utf-8') as f:
        json.dump(audit, f, indent=2)
    
    print(f"Cleanup completed. Deleted {deleted_count} documents.")
    print(f"Audit report saved to: {audit_path}")
    
    return deleted_count


def main():
    parser = argparse.ArgumentParser(description='Local 125 Firestore Cleanup Tool')
    parser.add_argument('--backup', action='store_true', help='Create backup only')
    parser.add_argument('--inventory', action='store_true', help='Create inventory report only')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be deleted (no changes)')
    parser.add_argument('--cleanup', action='store_true', help='Actually delete invalid documents')
    
    args = parser.parse_args()
    
    if not any([args.backup, args.inventory, args.dry_run, args.cleanup]):
        parser.print_help()
        return
    
    # Initialize Firestore client
    try:
        db = get_db()
        print(f"Connected to Firestore project: {db.project}")
    except Exception as e:
        print(f"Error connecting to Firestore: {e}")
        return
    
    try:
        if args.backup:
            create_backup(db)
        
        if args.inventory:
            create_inventory(db)
        
        if args.dry_run:
            count = perform_dry_run(db)
            print(f"\nDry run complete. Would delete {count} documents.")
        
        if args.cleanup:
            # Always create backup before cleanup
            create_backup(db)
            deleted_count = perform_cleanup(db)
            
            if deleted_count > 0:
                print("\nVerifying cleanup...")
                remaining_docs = fetch_local_125_docs(db)
                classifications = collections.Counter(
                    d.to_dict().get('classification', 'unknown') 
                    for d in remaining_docs.values()
                )
                print(f"Remaining Local 125 documents: {len(remaining_docs)}")
                print("By classification:", dict(classifications))
    
    except Exception as e:
        print(f"Error during operation: {e}")
        raise


if __name__ == "__main__":
    main()