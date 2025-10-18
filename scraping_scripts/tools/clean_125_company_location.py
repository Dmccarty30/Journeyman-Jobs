#!/usr/bin/env python3
"""
Clean and normalize the 125_output.json scrape:
- Split combined company and location values (e.g., "High Country - Tillamook, OR")
- Normalize location formatting to "City, ST" or "Remote"
- Rename "date" to "posted_date"
- Drop any REQ.ID-like keys
- Preserve the rest of the fields, ordering output keys with posted_date first

Usage:
  python tools/clean_125_company_location.py --in "./in-progress/125_output.json" --out "./in-progress/125_output_clean.json"
  python tools/clean_125_company_location.py --in "./in-progress/125_output.json" --check
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

# 50 states + DC + PR (extend if needed)
STATE_ABBREVS = {
    "AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
    "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
    "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
    "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
    "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY",
    "DC","PR"
}

DASH_VARIANTS = ("-", "–", "—")

REQ_ID_KEYS = {"req.id", "req_id", "req-id", "reqid", "req id", "reqid."}


def is_state_abbrev(text: str) -> bool:
    return len(text) == 2 and text.upper() in STATE_ABBREVS


def normalize_whitespace(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def normalize_commas(text: str) -> str:
    # Ensure a single space after commas
    text = re.sub(r",\s*", ", ", text)
    # Remove spaces before commas
    text = re.sub(r"\s+,", ",", text)
    return text


def normalize_dashes(text: str) -> str:
    for dv in DASH_VARIANTS:
        text = text.replace(dv, "-")
    # Collapse spaces around dashes to single hyphen with single spaces around
    text = re.sub(r"\s*-\s*", " - ", text)
    return normalize_whitespace(text)


def normalize_city(city: str) -> str:
    city = normalize_whitespace(city)
    # Preserve common punctuation and apply title case to words
    parts = [p for p in re.split(r"(\b)", city)]
    # Simple title-case per word while preserving separators
    def _tc(word: str) -> str:
        if not word:
            return word
        return word[0].upper() + word[1:].lower()
    return "".join(_tc(w) if w.isalpha() else w for w in parts)


def parse_city_state(text: str) -> Optional[str]:
    """Parse city/state patterns and return normalized "City, ST" or "Remote".

    Accepted patterns for text:
      - "City, ST"
      - "City ST"
      - "City,ST"
      - "Remote" (case-insensitive)
    """
    raw = normalize_whitespace(text)
    if not raw:
        return None

    if raw.lower() == "remote":
        return "Remote"

    raw = normalize_commas(raw)
    # Try comma form: City, ST
    m = re.match(r"^([A-Za-z .\'\-]+),\s*([A-Za-z]{2})$", raw)
    if not m:
        # Try space form: City ST
        m = re.match(r"^([A-Za-z .\'\-]+)\s+([A-Za-z]{2})$", raw)
    if not m:
        # Try no-space-after-comma: City,ST
        m = re.match(r"^([A-Za-z .\'\-]+),([A-Za-z]{2})$", raw)
    if m:
        city, st = m.group(1).strip(), m.group(2).upper()
        if is_state_abbrev(st):
            return f"{normalize_city(city)}, {st}"
    return None


def split_company_location(value: Any) -> Tuple[str, Optional[str]]:
    if value is None:
        return "", None
    if not isinstance(value, str):
        value = str(value)
    text = normalize_dashes(value)

    # Find the last hyphen for splitting
    idx = text.rfind("-")
    if idx == -1:
        return normalize_whitespace(text), None

    left = normalize_whitespace(text[:idx])
    right = normalize_whitespace(text[idx + 1 :])

    # Validate right as a location
    loc = parse_city_state(right)
    if loc:
        return left, loc
    # If not valid location, keep original as company
    return normalize_whitespace(value), None


# Key normalization helpers

def norm_key(k: str) -> str:
    k = k.strip().lower()
    k = k.replace(" ", "_")
    k = k.replace("-", "_")
    k = k.replace(".", "")
    return k


def transform_record(rec: Dict[str, Any]) -> Tuple[Dict[str, Any], bool]:
    """Transform a single scraped record.

    Returns (transformed_record, did_split_location)
    """
    nk = {norm_key(k): k for k in rec.keys()}

    # Extract date -> posted_date (support variants)
    posted_date_val = None
    for dk in ("posted_date", "date", "posteddate"):
        if dk in nk:
            posted_date_val = rec[nk[dk]]
            break

    # Extract company
    company_src_key = None
    for ck in ("company", "company_construction", "company_\u2013_construction", "company_—_construction"):
        if ck in nk:
            company_src_key = nk[ck]
            break
    if company_src_key is None and "company" in rec:
        company_src_key = "company"

    company_val = rec.get(company_src_key) if company_src_key else None
    company_name, location = split_company_location(company_val)
    did_split = location is not None

    # Other pass-through fields
    classification = rec.get(nk.get("classification"), rec.get("classification"))
    certifications = rec.get(nk.get("certifications"), rec.get("certifications"))
    hours = rec.get(nk.get("hours"), rec.get("hours"))

    # Work type can appear as work_type or type_of_work or similar
    wt_key = None
    for wk in ("work_type", "type_of_work", "worktype", "type_of_work_" ):
        if wk in nk:
            wt_key = nk[wk]
            break
    work_type = rec.get(wt_key) if wt_key else rec.get("work_type")

    # Build ordered output
    out: Dict[str, Any] = {}
    out["posted_date"] = posted_date_val
    out["company"] = company_name if company_name is not None else ""
    out["location"] = location
    out["classification"] = classification
    out["certifications"] = certifications
    out["hours"] = hours
    out["work_type"] = work_type

    # Copy any other fields not already set, excluding REQ.ID variants and original date
    blocked = set(REQ_ID_KEYS) | {"reqid", "reqid_", "date", "posteddate"}
    already = set(out.keys())
    for orig_key, val in rec.items():
        nk2 = norm_key(orig_key)
        if nk2 in already:
            continue
        if nk2 in blocked or nk2.startswith("reqid") or nk2 == "reqid":
            continue
        # Avoid re-adding source company field under a different name
        if orig_key == company_src_key:
            continue
        out[orig_key] = val

    return out, did_split


def load_json(path: Path) -> List[Dict[str, Any]]:
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        # Try common containers
        for key in ("data", "rows", "items", "results"):
            if key in data and isinstance(data[key], list):
                return data[key]  # type: ignore[return-value]
        # Fallback: treat dict as single record list
        return [data]  # type: ignore[return-value]
    raise ValueError("Unsupported JSON structure: expected list or dict")


def save_json(path: Path, payload: List[Dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main(argv: Optional[Iterable[str]] = None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="in_path", default="./in-progress/125_output.json", help="Input JSON path")
    ap.add_argument("--out", dest="out_path", default="./in-progress/125_output_clean.json", help="Output JSON path")
    ap.add_argument("--check", action="store_true", help="Show summary without writing output")
    args = ap.parse_args(list(argv) if argv is not None else None)

    in_path = Path(args.in_path)
    out_path = Path(args.out_path)

    records = load_json(in_path)

    cleaned: List[Dict[str, Any]] = []
    split_count = 0
    for rec in records:
        out, did_split = transform_record(rec)
        if did_split:
            split_count += 1
        cleaned.append(out)

    if args.check:
        print(f"Processed {len(records)} records. Split company/location in {split_count} records. Not writing output (--check).")
        return 0

    save_json(out_path, cleaned)
    print(f"Wrote {len(cleaned)} records to {out_path}. Split company/location in {split_count} records.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
