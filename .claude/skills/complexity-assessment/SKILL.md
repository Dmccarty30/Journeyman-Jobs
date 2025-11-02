---
name: complexity-assessment  
description: Evaluates task complexity, estimates effort, identifies risks, recommends agent assignments. Analyzes code changes, architectural impact, testing needs, and domain expertise requirements for accurate project planning.
---

# Complexity Assessment

## Purpose

Analyze task complexity to provide accurate effort estimates, identify risks, recommend appropriate agent assignments, and support realistic project planning for Journeyman Jobs development.

## When To Use

- Estimating effort for feature requests
- Determining appropriate agent for tasks
- Identifying high-risk or complex tasks
- Sprint planning and capacity allocation
- Prioritizing work based on complexity
- Deciding between sequential vs parallel execution

## Complexity Dimensions

### 1. Technical Complexity

**Factors**:

- Number of domains involved (Frontend, State, Backend, Debug)
- Code volume (lines of code to write/modify)
- Architectural changes required\
-
- New technology or patterns needed
- Integration points with existing systems

**Scoring**:

```dart
LOW (1-3 points):
- Single domain
- <100 lines of code
- No architectural changes
- Familiar patterns only
- No external integrations

MEDIUM (4-6 points):
- 2 domains
- 100-500 lines of code
- Minor architectural adjustments
- Some new patterns
- 1-2 integration points

HIGH (7-9 points):
- 3+ domains
- 500-1000 lines of code
- Significant architectural changes
- Multiple new patterns
- Complex integration requirements

VERY HIGH (10 points):
- All domains involved
- >1000 lines of code
- Core architecture redesign
- Novel patterns required
- Critical system integrations
```

### 2. Domain Expertise Required

**Levels**:

```dart
JUNIOR (1 point):
- Straightforward implementation
- Well-documented patterns
- Minimal decision-making
- Example: "Add text field to form"

MID-LEVEL (2-3 points):
- Moderate design decisions
- Some pattern selection
- Integration considerations
- Example: "Build job filter dropdown"

SENIOR (4-6 points):
- Complex architecture decisions
- Performance optimization needed
- Cross-domain coordination
- Example: "Implement offline sync strategy"

EXPERT (7-10 points):
- Novel solutions required
- Critical system design
- Advanced optimization techniques
- Example: "Design hierarchical initialization system"
```

### 3. Risk Level

**Risk Factors**:

```dart
LOW RISK (1-2 points):
- Well-understood requirements
- Proven patterns available
- Limited user impact
- Easy rollback possible
- Example: "Update button color"

MEDIUM RISK (3-5 points):
- Some requirement ambiguity
- Moderate user impact
- Rollback requires coordination
- Example: "Add new filter type"

HIGH RISK (6-8 points):
- Unclear requirements
- Significant user impact
- Complex rollback procedure
- Performance implications
- Example: "Change state management pattern"

CRITICAL RISK (9-10 points):
- Novel territory
- Massive user impact
- Difficult/impossible rollback
- Core system changes
- Example: "Migrate database structure"
```

### 4. Testing Burden

**Test Complexity**:

```dart
LIGHT (1-2 points):
- Unit tests only
- No integration needed
- Quick validation
- Example: "Utility function change"

MODERATE (3-5 points):
- Unit + integration tests
- Some E2E scenarios
- Multiple validation points
- Example: "New UI component"

HEAVY (6-8 points):
- Comprehensive test suite
- Extensive E2E coverage
- Performance benchmarks
- Multiple environments
- Example: "Payment integration"

EXHAUSTIVE (9-10 points):
- Full regression suite
- Load testing required
- Security audit needed
- Field testing essential
- Example: "Authentication system"
```

## Complexity Scoring

### Total Complexity Score

Sum all dimension scores for overall complexity:

```dart
TOTAL = Technical + Expertise + Risk + Testing

COMPLEXITY LEVELS:
TRIVIAL (4-10 points): <2 hours, any agent
SIMPLE (11-20 points): 2-8 hours, junior agent OK
MODERATE (21-30 points): 1-2 days, mid-level agent
COMPLEX (31-40 points): 3-5 days, senior agent required
VERY COMPLEX (>40 points): 1+ week, expert agent + review
```

## Effort Estimation

### Base Effort Calculation

```dart
BASE EFFORT = Complexity Score × Domain Factor

DOMAIN FACTORS:
Frontend: 0.5 (Flutter well-known, fast iteration)
State: 0.8 (Riverpod moderate complexity)
Backend: 1.0 (Firebase + Cloud Functions slower)
Debug: 1.2 (Testing comprehensive, iterative)
```

### Adjustment Multipliers

```dart
FAMILIARITY:
- Never done before: ×2.0
- Done once before: ×1.5
- Familiar pattern: ×1.0
- Routine task: ×0.8

DEPENDENCIES:
- No dependencies: ×1.0
- Soft dependencies: ×1.2
- Hard dependencies: ×1.5
- Circular dependencies: ×2.0 (requires resolution)

DOCUMENTATION:
- Well documented: ×1.0
- Partial docs: ×1.3
- No docs: ×1.8
- Negative docs (outdated): ×2.0

URGENCY:
- Normal timeline: ×1.0
- Time pressure: ×1.3 (quality rush)
- Critical urgency: ×1.6 (coordination overhead)
```

### Final Estimate

```dart
FINAL EFFORT = BASE EFFORT × Familiarity × Dependencies × Documentation × Urgency

Example:
Task: "Add offline job favoriting"
- Complexity Score: 28 (MODERATE)
- Domain: State (0.8)
- Base: 28 × 0.8 = 22.4 hours

Adjustments:
- Familiarity: Done once (×1.5)
- Dependencies: Hard (×1.5)
- Documentation: Partial (×1.3)
- Urgency: Normal (×1.0)

Final: 22.4 × 1.5 × 1.5 × 1.3 × 1.0 = 65.5 hours ≈ 8 days
```

## Agent Assignment Recommendations

### Agent Selection Matrix

```dart
TASK COMPLEXITY → AGENT LEVEL

TRIVIAL (4-10):
→ Any available agent
→ Good for junior agents (learning opportunity)
→ Quick wins

SIMPLE (11-20):
→ Junior or mid-level agent
→ Orchestrator can review
→ Low coordination overhead

MODERATE (21-30):
→ Mid-level or senior agent
→ May need orchestrator guidance
→ Moderate coordination

COMPLEX (31-40):
→ Senior agent required
→ Orchestrator oversight essential
→ High coordination needs

VERY COMPLEX (>40):
→ Expert agent only
→ Multiple reviews required
→ Extensive coordination
→ Consider breaking down further
```

## Journeyman Jobs Specific Patterns

### Mobile Performance Sensitivity

```dart
ADJUSTMENT: Mobile-first = +2 complexity points

RATIONALE:
- Battery optimization required
- Memory constraints
- Network resilience needed
- Field testing essential

Example:
"Add job list pagination"
- Base complexity: 18 (SIMPLE)
- Mobile adjustment: +2
- Final: 20 (SIMPLE, near MODERATE threshold)
```

### IBEW Domain Knowledge

```dart
ADJUSTMENT: Trade-specific = +1 to +5 complexity points

LEVELS:
+1: Generic feature with IBEW terminology
+2: Requires local union structure knowledge
+3: Involves dispatch procedures
+4: Integrates with local job boards
+5: Novel electrical trade workflow

Example:
"Build crew bidding on jobs together"
- Base complexity: 32 (COMPLEX)
- Trade-specific: +3 (novel crew workflow)
- Final: 35 (COMPLEX)
```

### Offline-First Requirement

```dart
ADJUSTMENT: Offline support = +3 to +8 complexity points

FACTORS:
+3: Read-only offline (caching)
+5: Offline mutations with sync
+8: Conflict resolution required

Example:
"Job favoriting with offline support"
- Base complexity: 20 (SIMPLE)
- Offline: +5 (mutations + sync)
- Final: 25 (MODERATE)
```

## Complexity Assessment Examples

### Example 1: Simple Task

```dart
TASK: "Change job card text color to copper"

ASSESSMENT:
Technical: 2 (single domain, <10 LOC, no architecture)
Expertise: 1 (junior level, straightforward)
Risk: 1 (low impact, easy rollback)
Testing: 1 (visual verification only)

TOTAL: 5 (TRIVIAL)
EFFORT: 0.5 hours
AGENT: Any available frontend agent
```

### Example 2: Moderate Task

```dart
TASK: "Add job location filter with map preview"

ASSESSMENT:
Technical: 5 (2 domains, ~200 LOC, minor architecture)
Expertise: 4 (senior level, map integration)
Risk: 3 (moderate user impact)
Testing: 4 (unit + integration + E2E)

TOTAL: 16 (SIMPLE)
BASE EFFORT: 16 × 0.5 (frontend) = 8 hours

ADJUSTMENTS:
- Familiarity: Done before (×1.0)
- Dependencies: Soft (×1.2) - needs provider
- Documentation: Good (×1.0)
- Urgency: Normal (×1.0)

FINAL: 8 × 1.2 = 9.6 hours ≈ 1.2 days
AGENT: Mid-level frontend agent with map experience
```

### Example 3: Complex Task

```dart
TASK: "Implement crew messaging with offline queue"

ASSESSMENT:
Technical: 8 (3 domains, ~600 LOC, significant architecture)
Expertise: 7 (expert level, real-time + offline)
Risk: 6 (high user impact, complex rollback)
Testing: 7 (comprehensive suite needed)

TOTAL: 28 (MODERATE, near COMPLEX)
BASE EFFORT: 28 × 0.8 (state) = 22.4 hours

ADJUSTMENTS:
- Familiarity: Never done (×2.0)
- Dependencies: Hard (×1.5) - needs Firebase + UI
- Documentation: Partial (×1.3)
- Urgency: Normal (×1.0)
- Mobile: +2
- Offline: +5

ADJUSTED TOTAL: 28 + 2 + 5 = 35 (COMPLEX)
ADJUSTED EFFORT: 35 × 0.8 = 28 hours
FINAL: 28 × 2.0 × 1.5 × 1.3 = 109 hours ≈ 14 days

AGENT: Expert state agent + backend support
RECOMMENDATION: Consider breaking into phases:
  Phase 1: Basic messaging (no offline)
  Phase 2: Add offline queue
```

## Risk Identification

### High-Risk Indicators

```dart
🚨 RED FLAGS:
- Complexity score >35
- Novel technology/pattern
- No clear rollback strategy
- Multiple hard dependencies
- Ambiguous requirements
- Critical user workflow
- Performance sensitive
- Security implications

MITIGATION:
- Prototype first
- Spike investigation
- Expert review required
- Incremental rollout
- Feature flags
- Extensive testing
```

### Uncertainty Factors

```dart
UNKNOWNS ADD RISK:
- "Might need to..." (+20% effort)
- "Possibly requires..." (+30% effort)
- "Unclear if..." (+50% effort)
- "Never done before" (×2.0 effort)

MITIGATION:
- Clarify requirements first
- Spike to reduce unknowns
- Build contingency into estimate
```

## Best Practices

### 1. Conservative Estimates

```dart
❌ OPTIMISTIC: Best-case scenario
✓ REALISTIC: Account for unknowns
✓ PESSIMISTIC: Add buffer for complexity >30

Buffer guidelines:
- TRIVIAL: No buffer needed
- SIMPLE: +10% buffer
- MODERATE: +20% buffer
- COMPLEX: +50% buffer
- VERY COMPLEX: +100% buffer (or break down)
```

### 2. Break Down Very Complex Tasks

```dart
IF complexity >40:
1. Analyze if task can be split
2. Create subtasks with dependencies
3. Estimate subtasks individually
4. Sum with integration overhead (+20%)

Example:
"Build complete crew feature" (Score: 58)
↓ BREAK DOWN ↓
- Crew data model (Score: 15)
- Crew providers (Score: 20)
- Crew UI (Score: 18)
- Integration testing (Score: 12)
Total: 65 + 13 (20% overhead) = 78 hours
```

### 3. Validate Estimates with Team

```dart
PROCESS:
1. Create initial estimate
2. Review with domain orchestrator
3. Sanity check against similar past tasks
4. Adjust based on feedback
5. Document assumptions
```

### 4. Track Actual vs Estimated

```dart
POST-COMPLETION:
- Record actual effort
- Calculate variance
- Identify estimation errors
- Update complexity factors
- Improve future estimates
```

## Integration with Task Distributor

The complexity assessment skill is used by the Task Distributor agent to:

1. **Evaluate** incoming tasks for complexity
2. **Estimate** effort and timeline
3. **Recommend** appropriate agents for assignment
4. **Identify** high-risk tasks requiring special attention
5. **Break down** very complex tasks into manageable subtasks
6. **Support** sprint planning with realistic capacity estimates

The Task Distributor uses this skill to make intelligent assignment decisions and provide accurate project timelines.
