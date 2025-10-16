# Scraper Corrections Plan

## Local 77 Issues

1. **Missing Job Entry**

```javascript
// To be added to jobs array
const missingJob77 = {
  employer: 'ASPLUNDH TREE EXPERT, LLC',
  city: 'SPOKANE, WA',
  startDate: '1/27/2025',
  shortCall: 'No',
  jobClass: 'JRY TREE TRMR',
  positionsRequested: '1',
  positionsAvailable: '',
  book: 'SPOKANE TT',
  worksite: 'Spokane',
  hourlyWage: '41.43',
  reportTo: 'Spokane', 
  requestDate: '01/22/2025',
  comments: ''
};

// Document ID format fix (employer as third value)
function generateJobID(localNumber, classification, employer) {
  return `${localNumber}-${classification}-${employer.replace(/[ ,]/g,'_')}`;
}
```

## Local 125 Issue

```javascript
// Remove invalid document
const docRef = db.collection('locals').doc('125-line_clearance_tree_trimming-STORM_CALLS');
await docRef.delete();
```

## Local 226 Investigation

Required checks:

1. Validate HTML table parsing logic
2. Verify field mappings:

```javascript
// Current mapping suspect fields:
const worksite = row.querySelector('span[data-bind="text: WORKSITE_DESC"]'); // Might be incorrect binding
// Should likely be:
const worksite = row.querySelector('span[data-bind="text: WORKSITE_DESCRIPTION"]');
```

## Local 602 DocumentID Fix

```javascript
// Current ID generation (flawed):
`${localNumber}-${classification}`;

// Corrected ID generation:
`${localNumber}-${classification}-${employer.replace(/[^a-z0-9]/gi, '_')}`; 
```

## Universal Requirements

1. Add table boundary validation:

```javascript
function isInTable(job) {
  return job.requestDate && job.startDate && !job.comments.includes('GENERATED');
}

// Usage:
jobs = jobs.filter(isInTable);
```

## Implementation Steps

1. [ ] Update job ID generation logic
2. [ ] Add table boundary validation
3. [ ] Fix Local 226 field mappings
4. [ ] Create migration script for:
   - Adding missing Local77 job
   - Removing invalid Local125 doc
   - Correcting Local602 doc IDs
5. [ ] Add validation tests:

```javascript
describe('Job Validation', () => {
  test('Document IDs contain employer', () => {
    expect(jobDocID).toMatch(/^\d+-.+-.+$/);
  });
});
```

## Verification Process

1. Run scraper in dry-run mode
2. Check Firestore console for:
   - Removed Local125 document
   - Corrected Local602 doc IDs
   - New Local77 job entry
3. Validate counts before/after operations
