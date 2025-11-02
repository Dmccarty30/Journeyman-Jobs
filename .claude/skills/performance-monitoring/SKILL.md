---
name: performance-monitoring
description: Tracks agent performance metrics, identifies bottlenecks, detects degradation patterns, generates performance reports. Monitors completion rates, response times, success rates, and resource utilization for Journeyman Jobs development optimization.
---

# Performance Monitoring

## Purpose

Track, analyze, and report on agent performance metrics to identify bottlenecks, detect degradation, optimize resource allocation, and maintain system health.

## When To Use

- Tracking agent performance over time
- Identifying slow or failing agents
- Detecting system bottlenecks
- Optimizing resource allocation
- Generating performance reports
- Troubleshooting coordination issues

## Key Performance Indicators

### 1. Task Completion Rate

**Metric**: Tasks completed per hour per agent

```dart
Completion Rate = Tasks Completed / Time Period

TARGETS:
EXCELLENT: >6 tasks/hour
GOOD: 4-6 tasks/hour
ACCEPTABLE: 2-4 tasks/hour
SLOW: <2 tasks/hour

Factors affecting rate:
- Task complexity
- Agent specialization  
- System resources
- Coordination overhead
```

**Tracking**:

```dart
frontend-agent:
- Last hour: 5 tasks (GOOD)
- Last day: 42 tasks (GOOD average)
- Trend: Stable

backend-agent:
- Last hour: 1 task (SLOW)
- Last day: 18 tasks (ACCEPTABLE average)
- Trend: Declining ⚠️
```

---

### 2. Average Response Time

**Metric**: Time from task assignment to completion

```dart
Response Time = Completion Time - Assignment Time

TARGETS:
EXCELLENT: <15 minutes
GOOD: 15-30 minutes
ACCEPTABLE: 30-60 minutes
SLOW: >60 minutes

Components:
- Queue wait time
- Execution time
- Coordination delays
```

**Analysis**:

```dart
Agent Response Time Breakdown:

fast-agent:
- Queue wait: 2 min (5%)
- Execution: 10 min (25%)
- Coordination: 28 min (70%)
- Total: 40 min
→ BOTTLENECK: Coordination overhead

slow-agent:
- Queue wait: 25 min (50%)
- Execution: 20 min (40%)
- Coordination: 5 min (10%)
- Total: 50 min
→ BOTTLENECK: Queue depth
```

---

### 3. Success Rate

**Metric**: Percentage of tasks completed successfully without errors

```dart
Success Rate = (Successful Tasks / Total Tasks) × 100%

TARGETS:
EXCELLENT: >95%
GOOD: 90-95%
ACCEPTABLE: 80-90%
POOR: <80%

Failure categories:
- Syntax errors
- Logic errors
- Integration failures
- Timeout failures
```

**Tracking**:

```dart
state-agent:
- Success: 47 tasks
- Failed: 3 tasks
- Success rate: 94% (GOOD)
- Common failures: Provider initialization errors

debug-agent:
- Success: 29 tasks
- Failed: 1 task  
- Success rate: 97% (EXCELLENT)
- Failure: Test environment timeout
```

---

### 4. Resource Utilization

**Metric**: Percentage of time agent is actively working

```dart
Utilization = (Active Time / Total Time) × 100%

TARGETS:
EXCELLENT: 60-80% (sustainable)
GOOD: 40-60%
UNDERUTILIZED: <40%
OVERLOADED: >80% (burnout risk)

Idle time reasons:
- No tasks available
- Waiting for dependencies
- Coordination delays
- System maintenance
```

**Dashboard**:

```dart
═══════════════════════════════════════
       AGENT UTILIZATION REPORT
═══════════════════════════════════════

frontend-orchestrator:  [██████████] 100% ⚠️
state-orchestrator:     [███████░░░] 70% ✓
backend-orchestrator:   [████████░░] 80% ⚠️
debug-orchestrator:     [███░░░░░░░] 30% ⓘ

ALERTS:
⚠️ frontend-orchestrator: OVERLOADED
⚠️ backend-orchestrator: HIGH UTILIZATION
ⓘ debug-orchestrator: UNDERUTILIZED
```

---

### 5. Queue Depth Trends

**Metric**: Number of queued tasks over time

```dart
Queue Trend Analysis:

HEALTHY PATTERN:
├─ Morning: 2-3 tasks (steady)
├─ Midday: 4-6 tasks (peak)
└─ Evening: 1-2 tasks (declining)

UNHEALTHY PATTERN:
├─ Morning: 3 tasks (starting)
├─ Midday: 8 tasks (growing) ⚠️
└─ Evening: 12 tasks (accelerating) 🚨

INTERPRETATION:
Healthy: Work flows in and out smoothly
Unhealthy: Queue growing = bottleneck forming
```

---

## Performance Degradation Detection

### Baseline Establishment

```dart
ESTABLISH BASELINE METRICS (first 30 days):

Example: frontend-agent baseline
- Avg completion time: 18 minutes
- Std deviation: ±5 minutes
- Success rate: 96%
- Tasks per hour: 3.2

THRESHOLD ALERTS:
Warning: >2 std deviations from baseline
Critical: >3 std deviations from baseline
```

### Anomaly Detection

```dart
DETECT PERFORMANCE ANOMALIES:

Statistical Method:
- Current: 45 min completion time
- Baseline: 18 ± 5 min
- Deviation: (45 - 18) / 5 = 5.4 std deviations
- Status: 🚨 CRITICAL ANOMALY

Possible causes:
1. Task complexity increased
2. System resource contention
3. Agent error/degradation
4. Network issues
5. Coordination delays
```

### Trend Analysis

```dart
TREND PATTERNS:

IMPROVING (✓):
Week 1: 25 min avg
Week 2: 22 min avg
Week 3: 20 min avg
Week 4: 18 min avg
→ Learning curve, optimization working

STABLE (✓):
Week 1-4: 18 ± 2 min avg
→ Consistent performance, no issues

DEGRADING (⚠️):
Week 1: 18 min avg
Week 2: 22 min avg
Week 3: 28 min avg
Week 4: 35 min avg
→ Investigation needed urgently
```

---

## Bottleneck Identification

### System Bottlenecks

```dart
COMMON BOTTLENECKS:

1. AGENT OVERLOAD
   Symptom: One agent has 10+ tasks queued
   Others: idle or lightly loaded
   Solution: Redistribute work or spawn help

2. DEPENDENCY CHAIN
   Symptom: Multiple agents waiting on one
   Example: Frontend + State waiting on Backend
   Solution: Prioritize blocking work

3. COORDINATION OVERHEAD
   Symptom: High coordination time, low execution time
   Example: 70% coordination, 25% execution
   Solution: Reduce coordination points

4. RESOURCE CONTENTION
   Symptom: All agents slow simultaneously
   Example: All response times 2x baseline
   Solution: Scale infrastructure

5. SPECIALIZATION GAP
   Symptom: Tasks queued, but no specialized agent
   Example: Firebase tasks, but only Flutter agents available
   Solution: Spawn or train specialized agent
```

### Bottleneck Analysis Example

```dart
PERFORMANCE REPORT: Backend Domain

Metrics:
- Average completion: 45 min (baseline: 18 min) 🚨
- Queue depth: 12 tasks (baseline: 2 tasks) 🚨
- Success rate: 85% (baseline: 96%) ⚠️

Root Cause Analysis:
1. Check agent logs → Firestore timeout errors
2. Check queue composition → 8 of 12 are complex queries
3. Check dependencies → No blockers from other domains
4. Check resources → Firestore quota near limit

DIAGNOSIS: Firestore performance degradation
BOTTLENECK: Database query optimization needed

SOLUTION:
1. Add composite indexes (immediate)
2. Optimize query patterns (short-term)
3. Implement query caching (long-term)
4. Increase Firestore quota (infrastructure)
```

---

## Performance Reports

### Daily Performance Summary

```dart
═══════════════════════════════════════════
     DAILY PERFORMANCE REPORT
     Date: 2025-10-31
═══════════════════════════════════════════

SYSTEM OVERVIEW:
- Total tasks completed: 127
- Average completion time: 22 minutes
- Success rate: 94%
- System utilization: 68%

AGENT PERFORMANCE:

[FRONTEND DOMAIN]
frontend-orchestrator:
  Tasks: 45 (35% of total)
  Avg time: 18 min ✓
  Success: 96% ✓
  Status: HEALTHY

[STATE DOMAIN]
state-orchestrator:
  Tasks: 32 (25% of total)
  Avg time: 20 min ✓
  Success: 94% ✓
  Status: HEALTHY

[BACKEND DOMAIN]
backend-orchestrator:
  Tasks: 38 (30% of total)
  Avg time: 31 min ⚠️
  Success: 89% ⚠️
  Status: DEGRADED

[DEBUG DOMAIN]
debug-orchestrator:
  Tasks: 12 (10% of total)
  Avg time: 25 min ✓
  Success: 100% ✓
  Status: UNDERUTILIZED

BOTTLENECKS:
⚠️ Backend domain showing degradation
   Recommendation: Investigate Firestore performance

OPPORTUNITIES:
ⓘ Debug domain has excess capacity
   Recommendation: Route additional testing work

═══════════════════════════════════════════
```

### Weekly Trend Report

```dart
═══════════════════════════════════════════
     WEEKLY TREND REPORT
     Week of: Oct 24-31, 2025
═══════════════════════════════════════════

COMPLETION TREND:
Mon: 118 tasks
Tue: 132 tasks
Wed: 145 tasks (+13% momentum)
Thu: 128 tasks
Fri: 127 tasks
─────────────────
Avg: 130 tasks/day
Trend: Slightly improving ✓

RESPONSE TIME TREND:
Mon: 24 min
Tue: 22 min
Wed: 19 min (improving)
Thu: 23 min  
Fri: 22 min
─────────────────
Avg: 22 min
Trend: Stable with midweek spike ✓

SUCCESS RATE TREND:
Mon: 95%
Tue: 94%
Wed: 92% ⚠️
Thu: 96%
Fri: 94%
─────────────────
Avg: 94%
Trend: Wednesday dip investigated

INSIGHTS:
- Wednesday degradation due to complex feature push
- System recovered well by Thursday
- Overall performance stable and healthy
- No urgent interventions needed

═══════════════════════════════════════════
```

---

## Journeyman Jobs Specific Monitoring

### Mobile Performance Metrics

```dart
MOBILE-SPECIFIC KPIS:

1. Battery Impact
   Target: <5% battery drain per hour
   Monitor: Power consumption metrics
   Alert if: >10% drain detected

2. Network Resilience
   Target: 95% offline functionality
   Monitor: Offline operation success rate
   Alert if: <90% offline success

3. Render Performance
   Target: 60 FPS UI rendering
   Monitor: Frame drops, jank events
   Alert if: Consistent drops <45 FPS

4. Memory Usage
   Target: <200MB RAM footprint
   Monitor: Memory allocation trends
   Alert if: >300MB or leak detected
```

### Storm Work Responsiveness

```dart
STORM SURGE METRICS:

During storm events (job influx):
- Job scraping latency: <5 min target
- Notification delivery: <2 min target
- UI update propagation: <1 min target

Example Storm Event:
─────────────────────────────────────
Event Start: 14:35
Job Count: 0 → 150 jobs in 20 minutes

Performance:
- Scraping latency: 3.2 min ✓
- Notifications: 1.8 min ✓
- UI updates: 0.9 min ✓

Result: EXCELLENT RESPONSE
System handled surge without degradation
─────────────────────────────────────
```

### IBEW Integration Health

```dart
INTEGRATION MONITORING:

1. Local Job Board Scraping
   Success rate: 98% ✓
   Avg latency: 45 seconds
   Failures: 2% (timeout-related)

2. Crew Coordination
   Message delivery: 99.8% ✓
   Avg latency: 1.2 seconds
   Real-time sync: Operational

3. Offline Sync
   Queue processing: 95% ✓
   Conflict rate: 0.3%
   Sync latency: 8 seconds avg
```

---

## Best Practices

### 1. Establish Baselines Early

```dart
BASELINE COLLECTION:

Week 1-2: Initial baseline
- Collect all metrics
- No optimization yet
- Document normal patterns

Week 3-4: Refine baseline
- Filter anomalies
- Calculate statistics
- Set alert thresholds

Ongoing: Update baseline
- Quarterly reviews
- Adjust for system changes
- Account for growth
```

### 2. Alert Fatigue Prevention

```dart
ALERT TUNING:

❌ BAD: Alert on every deviation
✓ GOOD: Alert on sustained problems

Example Rules:
- Single spike: Log, don't alert
- 3 consecutive spikes: Warning alert
- 10 consecutive spikes: Critical alert
- Degrading trend over 3 days: Investigation alert

This reduces noise and focuses on real issues.
```

### 3. Actionable Metrics

```dart
GOOD METRIC: "Backend response time: 45 min (target: 20 min)"
→ Clear problem, clear target, actionable

BAD METRIC: "System health score: 73"
→ Unclear what's wrong, unclear action

Always pair metrics with:
- Baseline/target for comparison
- Trend (improving/stable/degrading)
- Recommended action if threshold exceeded
```

### 4. Root Cause Investigation

```dart
INVESTIGATION PROCESS:

1. DETECT: Metric exceeds threshold
   Example: Response time 2x baseline

2. CORRELATE: Check related metrics
   - Queue depth (is agent overloaded?)
   - Success rate (are tasks failing?)
   - Other agents (system-wide issue?)

3. ISOLATE: Narrow to specific cause
   - Specific task types affected?
   - Specific time period?
   - Specific agent or domain?

4. VALIDATE: Reproduce if possible
   - Can we trigger the issue?
   - Does it occur predictably?

5. REMEDIATE: Apply targeted fix
   - Address root cause, not symptom
   - Monitor to confirm resolution
```

### 5. Continuous Optimization

```dart
OPTIMIZATION CYCLE:

1. MEASURE: Collect baseline metrics
2. ANALYZE: Identify slowest components
3. OPTIMIZE: Improve top bottlenecks
4. VALIDATE: Measure impact
5. REPEAT: Move to next bottleneck

Example:
Iteration 1: Reduced queue wait time 20 → 15 min
Iteration 2: Reduced execution time 25 → 20 min
Iteration 3: Reduced coordination 10 → 7 min
Result: Total time 55 → 42 min (24% improvement)
```

---

## Integration with Resource Allocator

The performance monitoring skill is used by the Resource Allocator agent to:

1. **Track** agent performance metrics continuously
2. **Detect** degradation patterns and bottlenecks
3. **Analyze** root causes of performance issues
4. **Generate** performance reports for stakeholders
5. **Recommend** optimizations based on metrics
6. **Validate** that resource allocation strategies are effective

The Resource Allocator uses this skill to maintain visibility into system health and make data-driven decisions about resource allocation and optimization priorities.

---

## Example: Performance Investigation

```dart
ALERT TRIGGERED:
backend-orchestrator response time: 58 minutes
Threshold: 30 minutes (2x exceeded) 🚨

INVESTIGATION:

Step 1: Check Current Metrics
- Queue depth: 9 tasks (baseline: 3) ⚠️
- Success rate: 87% (baseline: 96%) ⚠️
- Utilization: 98% (baseline: 70%) ⚠️

Step 2: Correlate with Other Agents
- frontend-orchestrator: Normal performance ✓
- state-orchestrator: Normal performance ✓
- debug-orchestrator: Normal performance ✓
→ ISOLATED to backend domain

Step 3: Analyze Task Composition
- 6 Firestore complex queries
- 2 Cloud Function deployments
- 1 Auth integration
→ Query-heavy workload

Step 4: Check Logs
- Firestore timeout errors: 8 occurrences
- Error: "Deadline exceeded on read"
→ DATABASE PERFORMANCE ISSUE

ROOT CAUSE: Missing Firestore composite index

REMEDIATION:
1. Add required composite index (immediate)
2. Migrate 3 heavy queries to different agent
3. Monitor for 30 minutes

VALIDATION:
After 30 minutes:
- Response time: 24 minutes ✓
- Success rate: 95% ✓
- Queue depth: 3 tasks ✓
→ ISSUE RESOLVED
```
