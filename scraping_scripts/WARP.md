# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Commonly used commands and how to run them (scoped to the completed directory):

- Install dependencies (prefer reproducible install since package-lock.json exists):
  - From completed/: `npm ci` (or `npm install`)
- Run all scrapers:
  - From completed/: `npm start` (runs `node runAllScrapers.js`)
- Run a single scraper (examples):
  - From completed/: `node 77.js`
  - From completed/: `node 602.js`
  - From completed/: `node 1249.js`
  - Note: 125.js is a standalone scraper that writes JSON output locally (does not use Firestore): `node 125.js`
- Run validation tests:
  - From completed/: `node validation_tests.js`
- Run data migration:
  - From completed/: `node migration_script.js`

### Notes/requirements for running:
- Google Cloud Firestore access is required for most scrapers. The code expects a credentials file at `completed/config/firebase_config.json` and internally sets `GOOGLE_APPLICATION_CREDENTIALS` to that path.
- Puppeteer usage:
  - Most scrapers use puppeteer-core and connect to a remote browser via a WebSocket endpoint defined as `SBR_WS_ENDPOINT` in `completed/jobCrud.js`. This must point to a valid endpoint to run those scrapers.
  - The 125.js scraper launches a local Chrome instance using puppeteer (not puppeteer-core), so it does not need a remote endpoint.
- OpenAI dependency:
  - The 226.js scraper relies on the OpenAI API and requires the `OPENAI_API_KEY` environment variable to be set.

## High-level architecture and structure (big picture):

### Directory focus: completed/
- **Orchestrator**: `runAllScrapers.js` imports per-local scrapers (e.g., 77.js, 602.js, 1249.js, 84.js, 226.js) and runs them sequentially with a delay and error handling so one failure does not stop others.
- **Shared utilities and data layer**: `jobCrud.js` centralizes integration points and cross-cutting logic:
  - Firestore client initialization and usage
  - Remote puppeteer WebSocket endpoint configuration (SBR_WS_ENDPOINT)
  - Helper functions:
    - `sanitizeString`: ensures strings are safe for Firestore document IDs
    - `generateJobId`: constructs document IDs as localNumber-classification-employer
    - `isInTable`: filters out invalid entries based on presence of dates and excluding generated rows
    - `updateDatabaseWithJobs`: upserts jobs for a given local and classification, and deletes outdated entries
- **Scrapers**: one module per local. Typical flow:
  - Connect to remote browser (puppeteer-core) or launch local Chrome (125.js)
  - Navigate to the target site and extract job rows using DOM selectors (or LLM-based extraction in 226.js)
  - Normalize/map data into a common job shape
  - Optionally filter with isInTable
  - Persist via updateDatabaseWithJobs to Firestore using consistent IDs
- **Validation and migrations**:
  - `validation_tests.js`: integration checks that Firestore updates conform to recent corrections (IDs include employer, boundary validation, presence/removal of specific docs)
  - `migration_script.js`: one-off data fixups (remove invalid Local 125 doc, correct Local 602 doc IDs)
- **Experimental/alternative implementations**: `completed/scrapingV2/` contains Python and JS variants for some locals not wired into the orchestrator.

## Relevant project docs/rules discovered:
- README.md in this directory is essentially empty.
- `completed/README_777_standalone.md` explains how to run a standalone scraper for Local 77 without Firebase and with a browser WebSocket endpoint configuration; reference it if working on standalone, local-output workflows.
- No CLAUDE.md, Cursor rules, or Copilot instruction files were found in this codebase.