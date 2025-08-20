# Multi-Agent Crawl4AI Extraction System – Implementation Plan

## Goals

- Implement a coordinated, parallel multi-agent pipeline: URL Discovery → URL Classification → Job Extraction → Data Storage
- Use Crawl4AI for crawling/extraction
- Produce Firestore-compatible job data; optionally write to Firestore when configured
- Robust error handling, logging, and batched parallelism

### Current Context

- Existing agents defined as prompts in v3/.claude/agents/crawling/*.md
- Production orchestrator script exists (v3/scripts/hive_mind_orchestrator_production.py) with mocked extraction and JSON storage
- Crawl4AI vendored at v3/crawl4ai; optimized URL classifier script exists (v3/scripts/crawl4ai_url_classifier_optimized.py)

### Approach

- Create a single Python module that encapsulates the 4 agents and the orchestrator to minimize file changes:
  - URLDiscoveryAgent: obtains discovered URLs per site (leverages existing classifier’s all_urls to avoid duplicate deep crawl)
  - URLClassificationAgent: reuses OptimizedIBEWURLClassifier class from scripts to classify per category (jobs, etc.)
  - JobExtractionAgent: uses Crawl4AI AsyncWebCrawler with optional LLMExtractionStrategy or CSS-based JsonCssExtractionStrategy fallback to extract structured job data
  - DataStorageAgent: Firestore uploader (python google-cloud-firestore) with JSON fallback when Firestore not configured
  - MultiAgentOrchestrator: ties the stages, runs batches concurrently, logs results, writes outputs

- Keep changes minimal: add
  1) docs/multi_agent_extraction_plan.md (this file)
  2) coordination/orchestration/multi_agent_pipeline.py (all agent classes + orchestrator)
  3) scripts/run_multi_agent_pipeline.py (CLI entrypoint)

### Inputs/Outputs

- Input: master_urls.json at v3/data/masters/master_urls.json
- Intermediate: per-site classification results (reused from classifier) in memory
- Output:
  - Extraction JSON per local in v3/data/jobs/local_{local}.json
  - Final run summary v3/data/hive_mind_results.json
  - Logs in v3/logs/hive_mind.log
  - Firestore writes (if configured with GOOGLE_APPLICATION_CREDENTIALS)

### Data Model (Job)

- job_id: string (local_number + hash/sequence)
- classification: string
- company: string | null
- location: string | null
- construction type: string | null
- duration: string | null
- wage: string | null
- per diem: string | null
- requirements: list[string] | string
- posted_date: ISO date string | null
- local_number: string
- source_url: string
- extraction_method: "llm" | "css" | "hybrid"
- extraction_timestamp: ISO datetime

### Parallelism

- Batch N sites concurrently (configurable, default 5)
- Within a site, classify categories concurrently (delegated to the optimized classifier’s logic)
- Extract jobs with asyncio gather and a semaphore (limit concurrency per site)

### Error Handling & Logging

- Use logging to v3/logs/hive_mind.log plus console
- Wrap each phase with try/except and collect per-local errors
- Continue processing other sites even if one fails; capture exceptions via asyncio.gather(return_exceptions=True)

### Firestore Integration

- Try to import google.cloud.firestore
- Initialize using GOOGLE_APPLICATION_CREDENTIALS (service account JSON path) or Application Default Credentials
- If unavailable or init fails, log a warning and store JSON files only
- Upsert by deterministic doc ID `${local_number}_${job_id}` and maintain updated_at/created_at timestamps

### Crawl4AI Usage

- Import from vendored v3/crawl4ai; ensure import path inserted if needed
- For extraction: prefer JsonCssExtractionStrategy with a generic schema; use LLMExtractionStrategy only if API creds are provided (e.g., OpenAI/Vertex) and Crawl4AI supports configured provider
- Use CrawlerRunConfig with cache_mode=ENABLED during development; BYPASS if fresh data required

### Validation & Next Steps

- After implementation:
  - Dry-run CLI in test mode (first 3 URLs) to verify flow
  - If Firestore should be enabled, install: pip install google-cloud-firestore
  - Optionally add unit tests for extraction normalizers and Firestore wrapper

### Risks/Assumptions

- LLM extraction may require provider keys; we default to CSS fallback
- Some job pages may require site-specific selectors; generic schema will extract partial data until custom strategies are added
- Firestore writes require valid credentials and network access
