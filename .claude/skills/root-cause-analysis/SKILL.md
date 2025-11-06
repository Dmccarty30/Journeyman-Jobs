# Root Cause Analysis Skill

**Category**: Debug/Error Detection
**Complexity**: High (0.85)
**Primary Agents**: debug-orchestrator, error-analyzer-agent
**Prerequisites**: Error classification, initial evidence collection

## Purpose

Systematic debugging methodology using hypothesis-driven investigation to identify true root causes rather than symptoms in Flutter/Firebase applications.

## Core Methodology

### 5 Whys Technique

```yaml
iterative_questioning:
  why_1: "What immediate cause triggered the symptom?"
  why_2: "What allowed that immediate cause to occur?"
  why_3: "What systemic factor enabled the condition?"
  why_4: "What process gap permitted the systemic factor?"
  why_5: "What root organizational/architectural cause exists?"

validation:
  - Each "why" must be evidence-based
  - Stop when fixing the cause prevents recurrence
  - Avoid blaming individuals, focus on systems
```

### Hypothesis Testing Framework

```yaml
hypothesis_cycle:
  step_1_observe:
    - Collect error logs, stack traces, metrics
    - Document user reports and reproduction steps
    - Gather system state at time of error

  step_2_hypothesize:
    - Generate possible root causes (3-5 hypotheses)
    - Rank by likelihood based on evidence
    - Consider multiple failure modes

  step_3_predict:
    - Define testable predictions for each hypothesis
    - Specify expected evidence if hypothesis is true
    - Design experiments or queries

  step_4_test:
    - Execute tests in controlled environment
    - Reproduce issue with varied conditions
    - Collect validation data

  step_5_analyze:
    - Compare predictions to actual results
    - Eliminate disproven hypotheses
    - Refine remaining hypotheses

  step_6_validate:
    - Confirm root cause with fix
    - Verify fix prevents recurrence
    - Document root cause chain
```

## Flutter/Firebase Investigation Patterns

### Firebase Error Investigation

```yaml
firestore_errors:
  symptoms:
    - PERMISSION_DENIED exceptions
    - DEADLINE_EXCEEDED timeouts
    - UNAVAILABLE service errors

  investigation_tree:
    permission_denied:
      hypotheses:
        - "Security rules misconfigured"
        - "User token expired/invalid"
        - "Document path incorrect"
      tests:
        - "Check security rules simulator"
        - "Validate token claims and expiry"
        - "Verify document path construction"

    deadline_exceeded:
      hypotheses:
        - "Query fetching too many documents"
        - "Network latency spike"
        - "Firestore index missing"
      tests:
        - "Measure query result size"
        - "Check network metrics"
        - "Verify indexes in Firebase Console"

    unavailable:
      hypotheses:
        - "Firebase service outage"
        - "Client network disconnected"
        - "Rate limiting triggered"
      tests:
        - "Check Firebase status page"
        - "Test network connectivity"
        - "Review API quota usage"

auth_errors:
  symptoms:
    - Sign-in failures
    - Token refresh errors
    - Session expiration

  investigation_tree:
    sign_in_failure:
      hypotheses:
        - "Invalid credentials"
        - "Auth provider misconfigured"
        - "Network request blocked"
      tests:
        - "Validate credential format"
        - "Check Firebase Auth config"
        - "Inspect network requests"

    token_refresh:
      hypotheses:
        - "Refresh token expired"
        - "Clock skew on device"
        - "Auth state listener missing"
      tests:
        - "Check token expiry timestamps"
        - "Validate device time accuracy"
        - "Verify auth state subscription"
```

### Flutter Framework Investigation

```yaml
widget_errors:
  symptoms:
    - "setState called after dispose"
    - "RenderBox not laid out"
    - "Infinite build loops"

  investigation_tree:
    setstate_after_dispose:
      hypotheses:
        - "Async operation completing after unmount"
        - "Timer/subscription not cancelled"
        - "Missing mounted check"
      tests:
        - "Add mounted check before setState"
        - "Verify dispose cleanup"
        - "Check async operation lifecycle"

    renderbox_error:
      hypotheses:
        - "Unbounded constraints in Flex"
        - "Infinite size in scrollable"
        - "Missing SizedBox wrapper"
      tests:
        - "Wrap with Expanded/Flexible"
        - "Add explicit constraints"
        - "Inspect widget tree structure"

    infinite_build:
      hypotheses:
        - "setState in build method"
        - "Provider update triggering rebuild"
        - "InheritedWidget mutation"
      tests:
        - "Move setState to initState/callbacks"
        - "Check Provider selectors"
        - "Validate data model immutability"

performance_errors:
  symptoms:
    - Frame drops (jank)
    - Memory leaks
    - ANR (Application Not Responding)

  investigation_tree:
    jank:
      hypotheses:
        - "Expensive build operations"
        - "Synchronous I/O on UI thread"
        - "Large widget rebuild trees"
      tests:
        - "Profile with Flutter DevTools"
        - "Move I/O to isolates"
        - "Add const constructors"

    memory_leak:
      hypotheses:
        - "Unclosed streams/subscriptions"
        - "Static references to widgets"
        - "Listeners not removed"
      tests:
        - "Check dispose methods"
        - "Inspect memory snapshot"
        - "Verify listener cleanup"
```

## Analysis Tools & Commands

### Flutter DevTools Investigation

```yaml
devtools_workflow:
  performance_tab:
    - Identify expensive frames (>16ms)
    - Analyze widget rebuild flamegraph
    - Inspect shader compilation jank

  memory_tab:
    - Take heap snapshots before/after
    - Identify leaked objects
    - Track allocation stack traces

  network_tab:
    - Monitor Firebase API calls
    - Measure request/response times
    - Inspect payload sizes

  logging_tab:
    - Filter error/warning messages
    - Correlate logs with timeline
    - Export logs for analysis
```

### Firebase Console Investigation

```yaml
firebase_console_workflow:
  firestore_usage:
    - Check read/write counts
    - Verify index status
    - Monitor query performance

  auth_events:
    - Review sign-in methods
    - Check user activity logs
    - Verify provider configuration

  crashlytics:
    - Group errors by similarity
    - Analyze stack trace patterns
    - Track error frequency trends

  performance_monitoring:
    - Identify slow network requests
    - Track app startup time
    - Monitor screen rendering
```

## Evidence Collection Framework

### Required Evidence Types

```yaml
error_evidence:
  stack_traces:
    - Full call stack with line numbers
    - Exception type and message
    - Thread information

  system_state:
    - App version and build number
    - Device OS and model
    - Network connectivity status
    - Memory and CPU usage

  user_context:
    - User actions preceding error
    - Screen/route when error occurred
    - Authentication status
    - Feature flags active

  timing_data:
    - Error timestamp
    - Error frequency (rate)
    - Time since app start
    - Time of day patterns

  environmental_factors:
    - Firebase region/zone
    - Network type (WiFi/cellular)
    - Background vs foreground
    - Low memory warnings
```

### Evidence Correlation Matrix

```yaml
correlation_analysis:
  error_rate_vs_load:
    metrics: [error_count, active_users, api_calls]
    pattern: "Errors spike with increased load"
    root_cause_indicator: "Scalability issue"

  error_rate_vs_deployment:
    metrics: [error_count, deployment_timestamp]
    pattern: "Errors increase post-deployment"
    root_cause_indicator: "Code regression"

  error_rate_vs_time:
    metrics: [error_count, hour_of_day]
    pattern: "Errors peak at specific times"
    root_cause_indicator: "External service dependency"

  error_distribution:
    metrics: [error_count, device_model, os_version]
    pattern: "Errors isolated to specific devices"
    root_cause_indicator: "Platform compatibility"
```

## Root Cause Validation

### Fix Validation Criteria

```yaml
validation_requirements:
  reproduction:
    - "✅ Issue reproduced reliably before fix"
    - "✅ Issue not reproducible after fix"
    - "✅ Fix tested in multiple scenarios"

  regression:
    - "✅ No new errors introduced"
    - "✅ Related functionality still works"
    - "✅ Performance not degraded"

  scalability:
    - "✅ Fix works under load"
    - "✅ No new bottlenecks created"
    - "✅ Resource usage acceptable"

  documentation:
    - "✅ Root cause documented"
    - "✅ Fix rationale explained"
    - "✅ Prevention measures noted"
```

### Prevention Strategies

```yaml
systemic_fixes:
  code_level:
    - Add input validation
    - Implement error boundaries
    - Add defensive checks

  architecture_level:
    - Refactor tight coupling
    - Add abstraction layers
    - Implement circuit breakers

  process_level:
    - Add code review checklist item
    - Update testing requirements
    - Enhance monitoring alerts

  infrastructure_level:
    - Adjust resource limits
    - Configure auto-scaling
    - Implement rate limiting
```

## Output Format

### Root Cause Report

```yaml
investigation_summary:
  error: "Flutter app crashes on user profile load"
  severity: "High"
  frequency: "12 crashes/hour (affecting 8% of users)"

hypothesis_testing:
  hypothesis_1:
    statement: "Null value in user.photoUrl causing widget error"
    prediction: "Crashes occur for users without profile photos"
    test: "Filter crash logs by user.photoUrl presence"
    result: "❌ Disproven - crashes occur for all users"

  hypothesis_2:
    statement: "Firebase timeout during profile fetch"
    prediction: "Network error precedes crash in logs"
    test: "Correlate network logs with crash timestamps"
    result: "❌ Disproven - no network errors found"

  hypothesis_3:
    statement: "setState called after ProfileWidget disposed"
    prediction: "Async profile fetch completes after navigation"
    test: "Add mounted check + log async completion timing"
    result: "✅ CONFIRMED - 100% of crashes show this pattern"

root_cause_chain:
  immediate_cause: "setState called on disposed ProfileWidget"
  enabling_cause: "Profile fetch continues after user navigates away"
  systemic_cause: "Missing mounted check before setState"
  architectural_cause: "Lack of cancellation for async operations"
  root_cause: "No lifecycle management for async widget operations"

five_whys_analysis:
  why_1:
    question: "Why does the app crash?"
    answer: "setState called on disposed widget"

  why_2:
    question: "Why is setState called after dispose?"
    answer: "Async profile fetch completes after navigation"

  why_3:
    question: "Why doesn't navigation cancel the fetch?"
    answer: "No cancellation mechanism implemented"

  why_4:
    question: "Why is there no cancellation mechanism?"
    answer: "Widget lifecycle not integrated with async operations"

  why_5:
    question: "Why isn't lifecycle integrated?"
    answer: "No architectural pattern for async operation management"

evidence:
  stack_traces: "45 identical stack traces analyzed"
  reproduction: "100% reproduction rate with navigation during fetch"
  timing_analysis: "Avg 350ms between navigation and setState call"
  affected_versions: "v2.1.0 and later (new profile screen)"

fix_validation:
  implementation:
    - "Added mounted check before setState"
    - "Implemented CancelableOperation for fetches"
    - "Added dispose cleanup for pending operations"

  testing:
    - "✅ 0 crashes in 1000 test iterations"
    - "✅ Memory leak test passed"
    - "✅ No regression in profile load time"

  rollout:
    strategy: "Staged rollout (10% → 50% → 100%)"
    validation_criteria: "Crash rate <0.01% for 24 hours"

prevention_measures:
  code_review_checklist:
    - "All async operations checked for mounted state"
    - "Dispose methods cancel pending operations"

  linting_rule:
    - "Add custom lint rule for setState without mounted check"

  testing_requirement:
    - "Widget lifecycle tests for async operations"
    - "Navigation tests during pending operations"
```

## Integration with Other Skills

### Combines With

- **stack-trace-analysis**: Parse stack traces for evidence
- **pattern-recognition**: Identify recurring root causes
- **performance-profiling**: Validate performance-related root causes
- **proactive-monitoring**: Prevent recurrence through monitoring

### Feeds Into

- **auto-recovery**: Design recovery based on root cause
- **graceful-degradation**: Implement fallbacks for identified failure modes
- **optimization-strategy**: Optimize based on root cause findings

## Success Metrics

- **Root Cause Accuracy**: ≥90% (fix prevents recurrence)
- **Investigation Time**: <1 hour for common patterns, <4 hours for novel issues
- **Hypothesis Efficiency**: ≤3 hypotheses tested on average
- **Fix Effectiveness**: ≥95% reduction in error frequency
- **Prevention Success**: <10% recurrence of same root cause category
