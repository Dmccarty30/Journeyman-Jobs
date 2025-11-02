---
name: load-balancing
description: Distributes workload optimally across agents, prevents bottlenecks, maximizes parallel execution. Implements queue management, task routing algorithms, and dynamic rebalancing strategies for efficient Journeyman Jobs development.
---

# Load Balancing

## Purpose

Distribute workload efficiently across available agents to maximize throughput, minimize wait times, prevent bottlenecks, and maintain optimal system utilization.

## When To Use

- Assigning new tasks to agents
- Detecting overloaded agents
- Redistributing work to balance queues
- Planning parallel execution strategies
- Optimizing system throughput
- Preventing agent starvation

## Load Balancing Strategies

### 1. Round Robin

Distribute tasks sequentially across agents:

**Algorithm**:

```dart
agents = [A, B, C]
next_agent_index = 0

for each task:
    assign to agents[next_agent_index]
    next_agent_index = (next_agent_index + 1) % len(agents)
```

**Best For**:

- Tasks of similar complexity
- Homogeneous agents (same capabilities)
- Simple coordination scenarios

**Pros**: Simple, fair distribution
**Cons**: Ignores current queue depth, agent specialization

**Example**:

```dart
5 tasks → 3 agents

Task 1 → Agent A
Task 2 → Agent B  
Task 3 → Agent C
Task 4 → Agent A
Task 5 → Agent B

Result: A=2, B=2, C=1 (relatively balanced)
```

---

### 2. Least Queue Depth

Assign tasks to agent with fewest queued tasks:

**Algorithm**:

```dart
for each task:
    find agent with minimum queue depth
    assign task to that agent
    update queue depth
```

**Best For**:

- Heterogeneous task durations
- Different agent speeds
- Minimizing wait times

**Pros**: Responsive to current load
**Cons**: Can overload fastest agents

**Example**:

```dart
Current State:
- Agent A: 1 task queued
- Agent B: 3 tasks queued
- Agent C: 0 tasks queued

New task arrives:
→ Assign to Agent C (queue depth = 0)

Updated State:
- Agent A: 1 task
- Agent B: 3 tasks
- Agent C: 1 task
```

---

### 3. Weighted Load Balancing

Consider agent capacity and performance:

**Algorithm**:

```dart
for each agent:
    effective_load = queue_depth / agent_capacity
    
assign to agent with minimum effective_load
```

**Best For**:

- Agents with different capabilities
- Heterogeneous hardware
- Mixed skill levels

**Pros**: Accounts for agent differences
**Cons**: Requires performance profiling

**Example**:

```dart
Agent Capacities:
- Agent A: 10 tasks/hour (capacity weight = 1.0)
- Agent B: 5 tasks/hour (capacity weight = 0.5)

Current Queues:
- Agent A: 5 tasks (effective load = 5/10 = 0.5)
- Agent B: 2 tasks (effective load = 2/5 = 0.4)

New task arrives:
→ Assign to Agent B (lower effective load)

This prevents overwhelming slower Agent B while keeping both agents utilized.
```

---

### 4. Specialization-Aware Routing

Route tasks to agents with domain expertise:

**Algorithm**:

```dart
for each task:
    identify required domain (Frontend, State, Backend, Debug)
    find agents with domain expertise
    within domain experts, use least queue depth
```

**Best For**:

- Domain-specific tasks
- Specialized agents
- Quality-critical work

**Pros**: Faster completion, higher quality
**Cons**: Can create domain bottlenecks

**Example**:

```dart
Task: "Build Flutter widget"
Domain: Frontend

Available Agents:
- frontend-agent: 2 tasks queued, Flutter expert
- backend-agent: 0 tasks queued, no Flutter knowledge
- full-stack-agent: 1 task queued, Flutter proficient

Route to: frontend-agent or full-stack-agent (domain match)
Choose: full-stack-agent (lower queue depth)
```

---

### 5. Priority-Based Assignment

Route high-priority tasks to best agents:

**Algorithm**:

```dart
if task.priority == CRITICAL:
    assign to fastest available agent (regardless of queue)
elif task.priority == HIGH:
    assign to agent with <3 tasks queued
else:
    use least queue depth strategy
```

**Best For**:

- Tasks with varying urgency
- SLA-driven development
- Production incidents

**Pros**: Critical work completes fast
**Cons**: Can create priority starvation

**Example**:

```dart
New Critical Bug:
- Agent A: 0 tasks, avg 20 min completion
- Agent B: 5 tasks, avg 10 min completion

Route to: Agent B (fastest, despite queue)
Rationale: Critical bug needs fastest resolution
```

---

## Queue Management

### Queue Depth Thresholds

```dart
AGENT QUEUE STATUS:

IDLE (0 tasks):
- Status: Underutilized
- Action: Route new work immediately
- Concern: Agent starvation

HEALTHY (1-3 tasks):
- Status: Optimal
- Action: Continue normal routing
- Concern: None

BUSY (4-6 tasks):
- Status: High utilization
- Action: Route only if no better option
- Concern: Monitor for overload

OVERLOADED (7+ tasks):
- Status: At risk
- Action: Redistribute tasks
- Concern: Bottleneck forming
```

### Rebalancing Triggers

```dart
TRIGGER REBALANCING WHEN:

1. Queue imbalance >5 tasks difference
   Example: Agent A has 8 tasks, Agent B has 1 task
   
2. Agent wait time >30 minutes
   Example: Task has been queued for 35 minutes
   
3. Agent failure or unavailability
   Example: Agent crashes with 4 queued tasks
   
4. Priority task needs immediate attention
   Example: Production bug needs fast agent
```

### Rebalancing Strategies

- **Strategy 1: Task Migration**

```dart
Source Agent (overloaded): 8 tasks
Target Agent (idle): 0 tasks

Action: Move 4 tasks from source to target

Result:
- Source: 4 tasks (balanced)
- Target: 4 tasks (utilized)

Constraints:
- Only migrate tasks not yet started
- Preserve task dependencies
- Minimize migration overhead
```

- **Strategy 2: New Work Diversion**

```dart
Overloaded Agent: 7 tasks queued

Action: 
- Stop routing new work to overloaded agent
- Route all new tasks to other agents
- Wait for queue to drain naturally

Result: Gradual rebalancing without migration overhead
```

- **Strategy 3: Agent Spawning**

```dart
All Agents Overloaded:
- Agent A: 8 tasks
- Agent B: 7 tasks  
- Agent C: 9 tasks

Action: Spawn Agent D

Rebalance:
- Migrate 2 tasks from each agent to Agent D
- Agent D starts with 6 tasks
- All agents now at 6-7 tasks (balanced)
```

---

## Parallel Execution Optimization

### Identifying Parallelizable Work

```dart
PARALLEL CRITERIA:
- Tasks have no dependencies
- Tasks from different domains
- Tasks use different resources
- Tasks can be validated independently

Example:
Feature: "Add job filtering"
Tasks:
1. Build filter UI (Frontend)
2. Create filter provider (State)
3. Add Firestore indexes (Backend)

Analysis:
✓ Tasks 1-3 can start in parallel
✓ No dependencies between tasks
✓ Different domains reduce coordination

Strategy: Assign to 3 different agents simultaneously
```

### Dependency-Aware Scheduling

```dart
Feature: "Crew messaging"
Tasks:
1. Firestore schema (Backend) - No dependencies
2. Cloud Functions (Backend) - Depends on #1
3. Message provider (State) - Depends on #1
4. Chat UI (Frontend) - Depends on #3

Parallel Schedule:
Wave 1: Task 1 (foundation)
Wave 2: Tasks 2 & 3 (parallel after #1)
Wave 3: Task 4 (after #3)

Load Distribution:
- backend-agent: Tasks 1, 2 (sequential)
- state-agent: Task 3 (parallel with Task 2)
- frontend-agent: Task 4 (after Task 3)
```

---

## Journeyman Jobs Specific Patterns

### Domain Load Distribution

```dart
TYPICAL LOAD PATTERNS:

Sprint Start:
- Backend: HIGH (schema changes, setup)
- State: MEDIUM (provider design)
- Frontend: LOW (waiting for providers)
- Debug: LOW (test planning)

Mid-Sprint:
- Backend: LOW (foundation complete)
- State: HIGH (building providers)
- Frontend: MEDIUM (starting UI work)
- Debug: MEDIUM (integration tests)

Sprint End:
- Backend: LOW (stable)
- State: LOW (complete)
- Frontend: MEDIUM (polish)
- Debug: HIGH (comprehensive testing)

Load Balancing Strategy:
- Shift agents between domains based on phase
- Spawn domain specialists for peak periods
- Cross-train agents for flexibility
```

### Storm Work Surge Handling

```dart
NORMAL LOAD:
- backend-agent: 2 tasks (job updates)
- frontend-agent: 3 tasks (UI work)
- state-agent: 1 task (state updates)

STORM SURGE (sudden job influx):
- Job scraping: 5 urgent tasks
- Notifications: 3 urgent tasks
- UI updates: 2 urgent tasks

REBALANCING:
1. Spawn scraping-specialist (handle 5 scraping tasks)
2. Spawn notification-specialist (handle 3 notification tasks)
3. Prioritize backend work over other domains
4. Defer non-critical frontend polish

Result: Storm work handled with minimal impact on other development
```

### Mobile Performance Priority

```dart
TASK PRIORITIES FOR LOAD BALANCING:

P0 (CRITICAL): 
- App crashes
- Data loss bugs
- Authentication failures
→ Route to fastest available agent immediately

P1 (HIGH):
- Performance degradation
- Battery drain issues
- Offline sync failures
→ Route to specialized agent within 1 hour

P2 (MEDIUM):
- New features
- UI improvements
- Analytics enhancements
→ Use normal load balancing

P3 (LOW):
- Code cleanup
- Documentation
- Internal tooling
→ Fill idle agent capacity only
```

---

## Best Practices

### 1. Monitor Continuously

```dart
METRICS TO TRACK:
- Queue depth per agent (every 5 minutes)
- Average wait time per task
- Task completion rate
- Agent utilization percentage
- Bottleneck identification

ALERTING:
⚠️ Warning: Agent queue >5, wait time >20 min
🚨 Critical: Agent queue >10, wait time >45 min
```

### 2. Avoid Overreacting

```dart
❌ BAD: Rebalance after every task assignment
✓ GOOD: Rebalance when imbalance >5 tasks

❌ BAD: Spawn agent for temporary spike
✓ GOOD: Wait 15 minutes, spawn if sustained

❌ BAD: Migrate in-progress tasks
✓ GOOD: Only migrate queued (not started) tasks
```

### 3. Preserve Locality

```dart
KEEP RELATED WORK TOGETHER:

Example: "Crew feature" tasks
- Keep all crew UI tasks on same frontend agent
- Keep all crew state tasks on same state agent

Benefits:
- Shared context reduces ramp-up time
- Better code consistency
- Faster completion

Exception: Overload trumps locality
If frontend-agent overloaded, split crew UI tasks to another agent
```

### 4. Balance Specialization vs Flexibility

```dart
IDEAL MIX:
- 70% tasks to specialized agents (faster, higher quality)
- 30% tasks to generalist agents (flexibility, cross-training)

This provides:
✓ Efficient specialist utilization
✓ Flexibility for surge capacity
✓ Agent cross-training opportunities
✓ Reduced single points of failure
```

### 5. Consider Coordination Overhead

```dart
COORDINATION COSTS:

1 agent: No coordination needed
2 agents: 1 coordination link (Low overhead)
3 agents: 3 coordination links (Moderate overhead)
4+ agents: 6+ coordination links (High overhead)

Formula: Coordination Links = N × (N-1) / 2

Strategy:
- Prefer fewer agents for small features
- Use multiple agents only when parallelism benefits > coordination costs
```

---

## Load Balancing Algorithms

### Algorithm 1: Weighted Round Robin

```python
class WeightedRoundRobin:
    def __init__(self, agents):
        self.agents = agents  # {agent: weight}
        self.current = 0
        
    def next_agent(self):
        # Generate weighted sequence
        sequence = []
        for agent, weight in self.agents.items():
            sequence.extend([agent] * weight)
            
        agent = sequence[self.current % len(sequence)]
        self.current += 1
        return agent

# Example usage:
balancer = WeightedRoundRobin({
    'fast-agent': 3,    # Gets 3x more work
    'medium-agent': 2,  # Gets 2x more work  
    'slow-agent': 1     # Gets 1x work
})

# Task distribution follows 3:2:1 ratio
```

### Algorithm 2: Least Connections

```python
class LeastConnections:
    def __init__(self, agents):
        self.agents = {agent: 0 for agent in agents}
        
    def assign_task(self, task):
        # Find agent with fewest active tasks
        min_agent = min(self.agents, key=self.agents.get)
        self.agents[min_agent] += 1
        return min_agent
        
    def complete_task(self, agent):
        self.agents[agent] -= 1

# Always routes to least busy agent
```

### Algorithm 3: Power of Two Choices

```python
import random

class PowerOfTwoChoices:
    def __init__(self, agents):
        self.agents = {agent: 0 for agent in agents}
        
    def assign_task(self, task):
        # Randomly pick 2 agents
        candidates = random.sample(list(self.agents.keys()), 2)
        
        # Choose one with fewer tasks
        chosen = min(candidates, key=lambda a: self.agents[a])
        self.agents[chosen] += 1
        return chosen

# Proven to be nearly optimal with low overhead
```

---

## Integration with Resource Allocator

The load balancing skill is used by the Resource Allocator agent to:

1. **Distribute** incoming tasks across available agents
2. **Monitor** queue depths and identify imbalances
3. **Rebalance** workload when bottlenecks detected
4. **Optimize** parallel execution opportunities
5. **Prevent** agent overload and starvation
6. **Maximize** overall system throughput

The Resource Allocator uses this skill to maintain optimal workload distribution and system efficiency.

---

## Example: Feature Development Load Balancing

```dart
FEATURE: "Add job location filtering"
TASKS:
1. Build map component (Frontend, 8 hours)
2. Add location filter provider (State, 4 hours)
3. Create location indexes (Backend, 2 hours)
4. Integration testing (Debug, 3 hours)

AGENT STATUS:
- frontend-agent: 2 tasks queued (6 hours)
- state-agent: 0 tasks queued (0 hours)
- backend-agent: 4 tasks queued (10 hours)
- debug-agent: 1 task queued (2 hours)

LOAD BALANCING DECISIONS:

Task 1 (Frontend, 8hr):
→ frontend-agent (domain match, acceptable queue)
  New queue: 2 tasks + Task 1 = 3 tasks (14 hours)

Task 2 (State, 4hr):
→ state-agent (domain match, idle - perfect!)
  New queue: 0 + Task 2 = 1 task (4 hours)

Task 3 (Backend, 2hr):
→ backend-agent OVERLOADED (10hr queue)
→ Check for alternatives...
→ DECISION: Queue anyway (only 2hr, specialized work)
  New queue: 4 tasks + Task 3 = 5 tasks (12 hours)

Task 4 (Debug, 3hr):
→ debug-agent (domain match, light queue)
  Depends on: Tasks 1-3 complete
  Queue later after dependencies done

RESULT:
Balanced load across domains, respects dependencies, minimizes wait times
```
