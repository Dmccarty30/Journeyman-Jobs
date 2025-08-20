"""
Execution Engine for Multi-Agent Extraction (agents produce plans; engine executes)
- No Crawl4AI code inside agent definitions; all crawling/extraction happens here
- Reads Extraction/Storage plans from this directory (or user-specified path)
- Validates plans and executes Crawl4AI and Firestore writes
"""
from __future__ import annotations
import os
import json
import asyncio
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional
from pathlib import Path
import logging

# Logging setup
LOG_DIR = Path("v3/logs")
LOG_DIR.mkdir(parents=True, exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_DIR / 'hive_mind.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("execution_engine")

# Import Crawl4AI from vendored package (kept outside agents)
import sys
repo_root = Path.cwd()
crawl4ai_path = repo_root / 'v3' / 'crawl4ai'
sys.path.insert(0, str(crawl4ai_path))
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, CacheMode  # type: ignore
from crawl4ai.content_scraping_strategy import LXMLWebScrapingStrategy  # type: ignore
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy, LLMExtractionStrategy  # type: ignore

# Firestore optional
FIRESTORE_AVAILABLE = False
try:
    from google.cloud import firestore  # type: ignore
    FIRESTORE_AVAILABLE = True
except Exception:
    FIRESTORE_AVAILABLE = False

# -------------------- Plan Models --------------------
@dataclass
class ExtractionPlan:
    url: str
    local_number: Optional[str] = None
    strategy: str = "css"  # css | llm | hybrid
    css_schema: Optional[Dict[str, Any]] = None
    llm: Optional[Dict[str, Any]] = None
    wait_for: Optional[List[str]] = None
    js_actions: Optional[List[str]] = None
    pagination: Optional[Dict[str, Any]] = None
    extra: Dict[str, Any] = field(default_factory=dict)

@dataclass
class StoragePlan:
    collection: str = "jobs"
    doc_id_rule: str = "{local_number}_{job_id}"
    dedupe_keys: List[str] = field(default_factory=lambda: ["title","company","local_number"])
    merge: bool = True
    history: bool = True

# -------------------- Validators --------------------

def validate_extraction_plan(plan: Dict[str, Any]) -> ExtractionPlan:
    required = ["url", "strategy"]
    for key in required:
        if key not in plan:
            raise ValueError(f"Extraction plan missing required field: {key}")
    if plan["strategy"] == "css" and not plan.get("css_schema"):
        logger.warning("CSS strategy without css_schema – extraction may be shallow")
    return ExtractionPlan(**plan)


def validate_storage_plan(plan: Dict[str, Any]) -> StoragePlan:
    if "collection" not in plan:
        raise ValueError("Storage plan missing collection")
    return StoragePlan(**plan)

# -------------------- Executors --------------------

async def execute_extraction(plans: List[ExtractionPlan], concurrency: int = 5) -> Dict[str, List[Dict[str, Any]]]:
    sem = asyncio.Semaphore(concurrency)
    results: Dict[str, List[Dict[str, Any]]] = {}

    async def run_one(p: ExtractionPlan):
        async with sem:
            try:
                # Build Crawl4AI config per plan at runtime
                run_cfg = CrawlerRunConfig(
                    scraping_strategy=LXMLWebScrapingStrategy(),
                    cache_mode=CacheMode.ENABLED,
                    stream=False,
                    verbose=False,
                )
                # Choose extraction strategy at runtime based on plan
                extraction_strategy = None
                if p.strategy == "css" and p.css_schema:
                    extraction_strategy = JsonCssExtractionStrategy(schema=p.css_schema, input_format="html")
                elif p.strategy == "llm" and p.llm:
                    # Use LLM only if env configured
                    from crawl4ai.types import LLMConfig  # type: ignore
                    api_env = p.llm.get("api_token_env")
                    token = os.getenv(api_env) if api_env else None
                    provider = p.llm.get("provider")
                    llm_cfg = LLMConfig(provider=provider, api_token=token)
                    extraction_strategy = LLMExtractionStrategy(
                        llm_config=llm_cfg,
                        instruction=p.llm.get("instruction"),
                        schema=p.llm.get("schema"),
                        input_format=p.llm.get("input_format", "markdown"),
                        force_json_response=True,
                        verbose=False,
                    )
                # Hybrid: try CSS first, fallback to LLM if empty
                hybrid = p.strategy == "hybrid"
                if hybrid:
                    css_strategy = JsonCssExtractionStrategy(schema=p.css_schema or {"name":"Item","baseSelector":"div","fields":[]}, input_format="html")
                
                async with AsyncWebCrawler() as crawler:
                    # First pass (css or chosen)
                    primary_strategy = extraction_strategy or (css_strategy if p.strategy in ("css", "hybrid") else None)
                    if primary_strategy:
                        cfg = run_cfg.clone(extraction_strategy=primary_strategy)
                        res = await crawler.arun(url=p.url, config=cfg)
                        items = []
                        try:
                            if res.result and res.result.extracted_content:
                                items = json.loads(res.result.extracted_content)
                        except Exception:
                            items = []
                        if items or not hybrid:
                            results.setdefault(p.local_number or "unknown", []).extend(
                                normalize_jobs(items, p)
                            )
                            return
                    # Fallback to LLM if hybrid and empty
                    if hybrid and p.llm:
                        from crawl4ai.types import LLMConfig  # type: ignore
                        api_env = p.llm.get("api_token_env")
                        token = os.getenv(api_env) if api_env else None
                        provider = p.llm.get("provider")
                        llm_cfg = LLMConfig(provider=provider, api_token=token)
                        llm_strategy = LLMExtractionStrategy(
                            llm_config=llm_cfg,
                            instruction=p.llm.get("instruction"),
                            schema=p.llm.get("schema"),
                            input_format=p.llm.get("input_format", "markdown"),
                            force_json_response=True,
                            verbose=False,
                        )
                        cfg = run_cfg.clone(extraction_strategy=llm_strategy)
                        res = await crawler.arun(url=p.url, config=cfg)
                        items = []
                        try:
                            if res.result and res.result.extracted_content:
                                items = json.loads(res.result.extracted_content)
                        except Exception:
                            items = []
                        results.setdefault(p.local_number or "unknown", []).extend(
                            normalize_jobs(items, p)
                        )
            except Exception as e:
                logger.error(f"Extraction failed for {p.url}: {e}")
                return

    await asyncio.gather(*(run_one(p) for p in plans))
    return results


def normalize_jobs(items: List[Dict[str, Any]], plan: ExtractionPlan) -> List[Dict[str, Any]]:
    normalized = []
    for i, it in enumerate(items):
        job = {
            "job_id": it.get("job_id") or f"{plan.local_number or 'unknown'}_{i+1}",
            "classification": it.get("classification"),
            "company": it.get("company"),
            "location": it.get("location"),
            "construction type": it.get("construction type"),
            "duration": it.get("duration"),
            "wage": it.get("wage"),
            "per diem": it.get("per diem"),
            "requirements": it.get("requirements"),
            "posted_date": it.get("posted_date"),
            "local_number": plan.local_number,
            "source_url": plan.url,
            "extraction_method": plan.strategy,
            "extraction_timestamp": __import__("datetime").datetime.now().isoformat(),
        }
        normalized.append(job)
    return normalized

async def execute_storage(storage_plan: StoragePlan, extracted: Dict[str, List[Dict[str, Any]]]) -> Dict[str, Any]:
    if FIRESTORE_AVAILABLE and os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
        try:
            db = firestore.Client()  # type: ignore
            stats = {"stored": 0, "updated": 0, "errors": []}
            for local, jobs in extracted.items():
                for job in jobs:
                    doc_id = storage_plan.doc_id_rule.format(**job)
                    doc_ref = db.collection(storage_plan.collection).document(doc_id)
                    data = {**job,
                            "created_at": __import__("datetime").datetime.now().isoformat(),
                            "updated_at": __import__("datetime").datetime.now().isoformat(),
                            "active": True}
                    if storage_plan.merge:
                        doc_ref.set(data, merge=True)
                    else:
                        doc_ref.set(data)
                    stats["stored"] += 1
            return stats
        except Exception as e:
            logger.warning(f"Firestore unavailable or failed ({e}); falling back to JSON files")
    # JSON fallback
    out_dir = Path("v3/data/jobs")
    out_dir.mkdir(parents=True, exist_ok=True)
    summary = {}
    for local, jobs in extracted.items():
        fp = out_dir / f"local_{local}_jobs.json"
        with open(fp, 'w', encoding='utf-8') as f:
            json.dump(jobs, f, indent=2, ensure_ascii=False)
        summary[local] = {"stored": len(jobs), "file": str(fp)}
    return summary

# -------------------- Plan Loading --------------------

def load_plans_from_dir(plans_dir: Path) -> List[ExtractionPlan]:
    plans: List[ExtractionPlan] = []
    for path in plans_dir.glob('*.json'):
        try:
            data = json.loads(path.read_text(encoding='utf-8'))
            # allow file with list or single plan
            if isinstance(data, list):
                plans.extend(validate_extraction_plan(p) for p in data)
            else:
                plans.append(validate_extraction_plan(data))
        except Exception as e:
            logger.error(f"Failed to load plan {path}: {e}")
    return plans

# -------------------- CLI Runner --------------------

async def main(plans_dir: str = "plans/extraction", storage_plan_path: str | None = None, concurrency: int = 5, limit: Optional[int] = None):
    base_dir = Path(__file__).parent
    extraction_dir = (base_dir / plans_dir).resolve()
    if not extraction_dir.exists():
        logger.error(f"Plans directory not found: {extraction_dir}")
        return

    plans = load_plans_from_dir(extraction_dir)
    if limit:
        plans = plans[:limit]
    if not plans:
        logger.warning("No extraction plans found")
        return

    # Load storage plan if provided
    storage_plan: StoragePlan = StoragePlan()
    if storage_plan_path:
        p = Path(storage_plan_path)
        if p.exists():
            try:
                storage_plan = validate_storage_plan(json.loads(p.read_text(encoding='utf-8')))
            except Exception as e:
                logger.error(f"Invalid storage plan file: {e}")
        else:
            logger.warning(f"Storage plan not found: {p}")

    logger.info(f"Executing {len(plans)} extraction plans with concurrency={concurrency}")
    extracted = await execute_extraction(plans, concurrency=concurrency)
    logger.info(f"Extraction complete; storing results...")
    storage_result = await execute_storage(storage_plan, extracted)
    logger.info(f"Storage complete: {storage_result}")

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Execute multi-agent extraction plans (no Crawl4AI inside agents)')
    parser.add_argument('--plans-dir', type=str, default='plans/extraction', help='Relative dir under this folder containing Extraction Plans (*.json)')
    parser.add_argument('--storage-plan', type=str, help='Path to a Storage Plan JSON file')
    parser.add_argument('--concurrency', type=int, default=5, help='Concurrent extractions')
    parser.add_argument('--limit', type=int, help='Process only first N plans')
    args = parser.parse_args()
    asyncio.run(main(args.plans_dir, args.storage_plan, args.concurrency, args.limit))

