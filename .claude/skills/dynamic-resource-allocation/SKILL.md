---
name: dynamic-resource-allocation
description: Monitors agent availability, assesses workload capacity, recommends optimal agent assignments and spawning decisions. Ensures efficient resource utilization across Journeyman Jobs development domains while preventing agent overload.
---

# Dynamic Resource Allocation

## Purpose

Monitor system resources, track agent availability and workload, make intelligent decisions about agent assignment and spawning to optimize development velocity while preventing resource exhaustion.

## When To Use

- Planning agent assignments for new features
- System capacity planning
- Detecting agent overload conditions
- Deciding when to spawn additional agents
- Optimizing parallel execution strategies
- Resource contention resolution

## Core Capabilities

### 1. Agent Status Tracking

Monitor all active agents and their current state:

**Agent Metrics**:

- Current task count (queued + active)
- Average task completion time
- Task success vs failure rate
- Specialization domain
- Availability status (idle, busy, overloaded)

**Example Status**:

```dart
AGENT STATUS SNAPSHOT:

frontend-orchestrator:
  Status: BUSY
  Queue: 3 tasks
  Avg completion: 12 minutes
  Success rate: 95%
  
state-orchestrator:
  Status: IDLE
  Queue: 0 tasks
  Avg completion: 8 minutes
  Success rate: 100%
  
backend-orchestrator:
  Status: OVERLOADED
  Queue: 8 tasks
  Avg completion: 25 minutes
  Success rate: 88%
```

### 2. Workload Assessment

Evaluate capacity and utilization:

**Capacity Metrics**:

- Total agent capacity (theoretical maximum)
- Current utilization percentage
- Available capacity (unused bandwidth)
- Bottleneck identification

**Utilization Levels**:

```dart
IDLE (0-30%): Agent underutilized, can accept more work
HEALTHY (30-70%): Optimal utilization, good throughput
BUSY (70-90%): Near capacity, monitor closely
OVERLOADED (90-100%): At risk, redistribute or spawn help
```

### 3. Assignment Recommendations

Suggest optimal agent for new tasks:

**Decision Factors**:

- Domain expertise match
- Current workload
- Task priority
- Estimated task duration
- Agent performance history

**Example Recommendation**:

```dart
NEW TASK: "Build job filter UI component"

ANALYSIS:
- Domain: Frontend (Flutter)
- Complexity: Medium
- Estimated duration: 2 hours
- Priority: High

AGENT OPTIONS:
1. frontend-orchestrator (current queue: 3, avg: 12min) ← RECOMMENDED
   Rationale: Specialized for Flutter, healthy load, fast completion
   
2. widget-specialist (current queue: 0, avg: 15min)
   Rationale: Idle but slightly slower, could be backup
   
3. SPAWN NEW: frontend-specialist-2
   Rationale: NOT NEEDED - capacity available

RECOMMENDATION: Assign to frontend-orchestrator
```

### 4. Spawn Decisions

Determine when to spawn additional agents:

**Spawn Triggers**:

- Agent queue depth exceeds threshold (>5 tasks)
- Average wait time exceeds SLA (>30 minutes)
- Parallel execution opportunity identified
- Critical path acceleration needed
- Specialized expertise required

**Spawn Avoidance**:

- Don't spawn if existing agents idle
- Don't spawn for short-duration tasks
- Don't spawn during off-peak periods
- Don't spawn without coordination budget

**Example Decision**:

```dart
SPAWN DECISION ANALYSIS:

Scenario: Backend orchestrator has 8 queued tasks

METRICS:
- Queue depth: 8 (threshold: 5) ✗ EXCEEDED
- Average wait: 45 minutes (SLA: 30 minutes) ✗ EXCEEDED
- Idle agents available: No ✗
- Parallel opportunity: Yes ✓
- Coordination budget: Available ✓

RECOMMENDATION: SPAWN backend-specialist-agent
REASON: Overload + parallel opportunity + budget available
EXPECTED BENEFIT: Reduce wait time by 50%, clear queue in 2 hours
```

## Resource Allocation Strategies

### Strategy 1: Load Balancing

Distribute work evenly across available agents:

```dart
SCENARIO: 5 new tasks, 3 agents available

AGENT STATUS:
- Agent A: 2 tasks queued
- Agent B: 1 task queued
- Agent C: 4 tasks queued

ALLOCATION:
Task 1 → Agent B (lowest queue)
Task 2 → Agent A (second lowest)
Task 3 → Agent B (still lowest after Task 1)
Task 4 → Agent A (balance)
Task 5 → Agent B (spread evenly)

RESULT:
- Agent A: 4 tasks
- Agent B: 4 tasks
- Agent C: 4 tasks (no new tasks, already overloaded)
```

### Strategy 2: Specialization Matching

Route tasks to most qualified agent:

```dart
SCENARIO: UI bug fix + Backend optimization

AGENT EXPERTISE:
- frontend-orchestrator: Flutter 95%, Backend 20%
- backend-orchestrator: Backend 95%, Flutter 25%
- full-stack-agent: Flutter 70%, Backend 70%

ALLOCATION:
UI bug fix → frontend-orchestrator (95% match)
Backend optimization → backend-orchestrator (95% match)

RATIONALE: Specialist agents complete tasks faster and with higher quality
```

### Strategy 3: Priority-Based Assignment

Route high-priority tasks to fastest agents:

```dart
SCENARIO: 3 tasks with different priorities

TASKS:
1. Fix production bug (CRITICAL)
2. Build new feature (HIGH)
3. Refactor old code (LOW)

AGENT PERFORMANCE:
- Fast Agent: 10 min avg, 2 tasks queued
- Medium Agent: 15 min avg, 1 task queued
- Slow Agent: 25 min avg, 0 tasks queued

ALLOCATION:
Critical task → Fast Agent (despite queue, need speed)
High task → Medium Agent (good balance)
Low task → Slow Agent (can afford slower completion)
```

### Strategy 4: Parallel Execution

Spawn agents for parallelizable work:

```dart
SCENARIO: Feature with 4 independent components

COMPONENTS:
1. UI component A (30 min)
2. UI component B (30 min)
3. Backend endpoint (45 min)
4. State provider (20 min)

SERIAL EXECUTION: 125 minutes total
PARALLEL EXECUTION: 45 minutes (longest task)

DECISION: Spawn 4 specialized agents
AGENTS:
- frontend-agent-1 → Component A
- frontend-agent-2 → Component B
- backend-agent → Endpoint
- state-agent → Provider

BENEFIT: 63% time reduction
COST: 4x agent coordination overhead
```

## Journeyman Jobs Specific Patterns

### Mobile-First Development Priority

```dart
PRIORITY ORDER FOR RESOURCE ALLOCATION:

1. CRITICAL: Features affecting field workers
   - Offline functionality
   - Performance issues
   - Battery optimization
   - Job board updates

2. HIGH: Core platform features
   - Crew coordination
   - Job matching
   - Notifications
   - Authentication

3. MEDIUM: Enhancement features
   - UI polish
   - Analytics
   - Additional filters

4. LOW: Internal tooling
   - Admin features
   - Developer tools
   - Documentation
```

### Domain Capacity Planning

```dart
BASELINE AGENT ALLOCATION:

Frontend Domain (40% of work):
- frontend-orchestrator (always active)
- widget-specialist (spawn as needed)
- theme-stylist (spawn for major UI overhauls)

State Domain (25% of work):
- state-orchestrator (always active)
- riverpod-specialist (spawn for complex state)

Backend Domain (25% of work):
- backend-orchestrator (always active)
- firebase-specialist (spawn for migrations)

Debug Domain (10% of work):
- debug-orchestrator (always active)
- performance-specialist (spawn for optimization)
```

### Storm Work Surge Capacity

```dart
SURGE SCENARIO: Storm work creates sudden job influx

NORMAL CAPACITY:
- backend-orchestrator: handling routine updates

SURGE RESPONSE:
1. Spawn scraping-specialist (job aggregation)
2. Spawn notification-specialist (FCM alerts)
3. Prioritize backend queue over other domains
4. Temporarily defer non-critical frontend work

RATIONALE: Storm work is time-critical for IBEW members
```

## Best Practices

### 1. Monitor Continuously

Track metrics in real-time:

```dart
MONITORING CADENCE:
- Agent status: Every 5 minutes
- Queue depth: Continuous
- Completion rates: Hourly aggregate
- Resource utilization: Every 15 minutes

ALERTING THRESHOLDS:
⚠️ Warning: Queue depth > 5, Utilization > 80%
🚨 Critical: Queue depth > 10, Utilization > 95%
```

### 2. Avoid Over-Spawning

Don't create agents unnecessarily:

```dart
❌ BAD: Spawn agent for every task
✓ GOOD: Spawn only when capacity exceeded

❌ BAD: Keep spawned agents running indefinitely
✓ GOOD: Terminate idle spawned agents after 30 minutes

❌ BAD: Spawn agents for 5-minute tasks
✓ GOOD: Queue short tasks, spawn for long-running work
```

### 3. Balance Specialization and Flexibility

```dart
IDEAL AGENT MIX:
- 60% specialized agents (domain experts)
- 40% generalist agents (cross-domain flexibility)

BENEFIT:
- Specialists handle routine work efficiently
- Generalists adapt to unexpected demands
```

### 4. Proactive Capacity Planning

Anticipate future needs:

```dart
PLANNING TRIGGERS:
- New feature kickoff → Assess capacity needs
- Sprint planning → Allocate agents to epics
- Release week → Ensure debug capacity available
- Post-release → Plan for bug fix capacity
```

### 5. Cost-Aware Allocation

Consider resource costs:

```dart
COST FACTORS:
- Token usage per agent
- Coordination overhead (more agents = more coordination)
- Context switching penalties
- Spawn/termination costs

OPTIMIZATION:
- Use existing agents before spawning
- Batch similar tasks to same agent
- Minimize agent thrashing
```

## Integration with Master Coordinator

The dynamic resource allocation skill is used by the Master Coordinator to:

1. **Monitor** all domain orchestrators and specialized agents
2. **Assess** system capacity and bottlenecks
3. **Recommend** optimal agent assignments for incoming tasks
4. **Decide** when to spawn additional agents for parallel work
5. **Prevent** resource exhaustion and agent overload
6. **Optimize** overall system throughput and velocity

The Master Coordinator uses this skill to make intelligent resource decisions that maximize development efficiency while maintaining system health.

## Example: Crew Feature Resource Planning

```dart
FEATURE: Crew Formation and Coordination
SCOPE: Multi-domain, large feature
ESTIMATED EFFORT: 40 hours

INITIAL ALLOCATION:
- frontend-orchestrator: 15 hours (UI components)
- state-orchestrator: 10 hours (Crew providers)
- backend-orchestrator: 12 hours (Firestore + Cloud Functions)
- debug-orchestrator: 3 hours (Testing + monitoring)

CAPACITY CHECK:
✓ frontend-orchestrator: Available (2 tasks queued, 8hr capacity)
✓ state-orchestrator: Available (0 tasks queued, 10hr capacity)
✗ backend-orchestrator: OVERLOADED (7 tasks queued, 2hr capacity)
✓ debug-orchestrator: Available (1 task queued, 5hr capacity)

SPAWN DECISION:
SPAWN: firebase-specialist-agent
REASON: Backend overloaded, Firebase expertise needed
ASSIGNMENT: Firestore schema + security rules (6 hours)

ADJUSTED ALLOCATION:
- frontend-orchestrator: 15 hours
- state-orchestrator: 10 hours
- backend-orchestrator: 6 hours (Cloud Functions only)
- firebase-specialist: 6 hours (Firestore work)
- debug-orchestrator: 3 hours

RESULT: Feature completes in planned timeframe without overloading backend
```

## Monitoring Dashboard Example

```dart
═══════════════════════════════════════════════════
          JOURNEYMAN JOBS AGENT MONITOR
═══════════════════════════════════════════════════

SYSTEM CAPACITY: 72% (HEALTHY)
ACTIVE AGENTS: 7
QUEUED TASKS: 18
AVG WAIT TIME: 14 minutes

───────────────────────────────────────────────────
DOMAIN: FRONTEND (40% capacity)
───────────────────────────────────────────────────
frontend-orchestrator      [████████░░] 80% - 4 tasks
widget-specialist          [███░░░░░░░] 30% - 1 task

───────────────────────────────────────────────────
DOMAIN: STATE (55% capacity)
───────────────────────────────────────────────────
state-orchestrator         [█████░░░░░] 50% - 3 tasks
riverpod-specialist        [██████░░░░] 60% - 2 tasks

───────────────────────────────────────────────────
DOMAIN: BACKEND (90% capacity) ⚠️ WARNING
───────────────────────────────────────────────────
backend-orchestrator       [█████████░] 95% - 7 tasks ⚠️
firebase-specialist        [████████░░] 85% - 3 tasks

RECOMMENDATION: Consider spawning backend-specialist-2

───────────────────────────────────────────────────
DOMAIN: DEBUG (25% capacity)
───────────────────────────────────────────────────
debug-orchestrator         [██░░░░░░░░] 25% - 1 task

═══════════════════════════════════════════════════
ALERTS:
⚠️ backend-orchestrator approaching capacity
💡 debug-orchestrator has excess capacity (can absorb work)
═══════════════════════════════════════════════════
```
