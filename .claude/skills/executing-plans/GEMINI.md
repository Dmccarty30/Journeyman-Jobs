# Executing Plans

Load plan, review critically, execute tasks in batches, report for review between batches.

## Core Principle
**Batch execution with checkpoints for architect review.**

## The Process

### Step 1: Load and Review Plan
1. Read the plan file.
2. Review critically - identify any questions or concerns.
3. Raise concerns with the user before starting.

### Step 2: Execute Batch
**Default: Execute in batches of 3 tasks.**
For each task:
1. Follow each step exactly (plan should have bite-sized steps).
2. Run verifications as specified.
3. Mark as completed.

### Step 3: Report
When a batch is complete:
- Show what was implemented.
- Show verification output.
- Ask for feedback.

### Step 4: Continue
- Apply changes based on feedback.
- Execute the next batch.
- Repeat until complete.

## When to STOP
**Stop immediately if:**
- You hit a blocker (missing dependency, test failure, unclear instruction).
- There are critical gaps in the plan.
- Verification fails repeatedly.

**Do not guess. Ask for clarification.**
