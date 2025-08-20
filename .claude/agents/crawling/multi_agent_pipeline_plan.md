# Multi-Agent Extraction Pipeline (No hardcoding Crawl4AI inside agents)

Goals

- Agents think and output plans; they do not contain Crawl4AI code
- Execution Engine (separate Python) consumes plans and runs Crawl4AI/Firestore
- Pipeline: URL Discovery → URL Classification → Job Extraction → Data Storage
- Parallel, resilient, Firestore-compatible outputs

Agent layer (planning only)

- URL Discovery Agent → Discovery Plan (JSON): how to discover and constraints; plus discovered_urls[]
- URL Classification Agent → Classification Result (JSON): categorized URLs with confidence and reasons
- Job Extraction Agent → Extraction Plans (JSON per URL): strategy choice (css | llm | hybrid), schema or instructions, waits, JS actions, pagination
- Data Storage Agent → Storage Plan (JSON): collection/doc ID rule, merge/upsert policy, dedupe keys, history logging

Execution layer (action only)

- Plan Validator: validates JSON plans against lightweight schemas
- Crawl Executor: translates Extraction Plan into Crawl4AI configs at runtime
- Storage Executor: upserts to Firestore (if configured) or writes JSON files
- Orchestrator: runs stages in parallel, applies retries/backoff, writes logs

Plan contracts (lightweight)

- Discovery Plan (output):
  {
    "home_url": "https://...",
    "methods": ["sitemap", "crawl"],
    "max_depth": 2,
    "include_external": false,
    "blocked_patterns": ["*.pdf", "*logout*"],
    "discovered_urls": [{"url": "...", "depth": 1, "parent_url": "...", "link_text": "..."}],
    "timestamp": "ISO"
  }
- Classification Result:
  {
    "home_url": "https://...",
    "classified_urls": {"jobs": [{"url": "...", "confidence": 0.91, "title": "..."}], "contracts": []},
    "all_urls": ["..."],
    "errors": [],
    "timestamp": "ISO"
  }
- Extraction Plan (per URL):
  {
    "url": "<https://site/jobs>",
    "local_number": "46",
    "strategy": "css" | "llm" | "hybrid",
    "css_schema": {"name": "Jobs","baseSelector": "div.job","fields": [{"name":"title","selector":"h3","type":"text"}]},
    "llm": {"provider": "openai/gpt-4o","api_token_env": "OPENAI_API_KEY","instruction": "Extract job listings...","schema": {"properties": {"title": {"type":"string"}}}},
    "wait_for": ["css:.job"],
    "js_actions": ["click:[data-testid='load']"],
    "pagination": {"type": "click", "selector": ".next"}
  }
- Storage Plan:
  {
    "collection": "jobs",
    "doc_id_rule": "{local_number}_{job_id}",
    "dedupe_keys": ["title","company","local_number"],
    "merge": true,
    "history": true
  }

Folder conventions (plans/messages)

- Place agent outputs (plans) anywhere; by default, executor will look under this folder:
  - v3/.claude/agents/crawling/plans/extraction/*.json
  - v3/.claude/agents/crawling/plans/storage/*.json
  - (optionally) discovery/ and classification/ for auditing

Parallelism & reliability

- Batch sites concurrently; per-site semaphores for extraction concurrency
- Retry with exponential backoff; circuit-break domain on repeated failures
- Logging to v3/logs/hive_mind.log and per-run summaries in v3/data

Firestore (executor only)

- Uses google-cloud-firestore if GOOGLE_APPLICATION_CREDENTIALS/App Default Credentials are present
- Otherwise writes JSON outputs to v3/data/jobs/local_{local}.json

Next steps

- Use execution_engine.py (in this folder) to validate and execute any Extraction/Storage plans produced by agents
- Run run_multi_agent_pipeline.py --plans-dir plans/extraction --limit 3 (test mode)

Notes

- Agent markdown files remain concept/role prompts only (no Crawl4AI code)
- Execution Engine is the only place that imports Crawl4AI and Firestore
