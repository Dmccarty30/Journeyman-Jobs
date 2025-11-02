# Pattern Recognition Skill

**Category**: Debug/Error Detection
**Complexity**: High (0.75)
**Primary Agents**: error-analyzer-agent, performance-monitor-agent
**Prerequisites**: Historical error data, performance metrics

## Purpose

Recurring error identification and trend analysis to detect patterns in failures, predict future issues, and enable systematic prevention in Flutter/Firebase applications.

## Core Methodology

### Pattern Detection Algorithms
```yaml
statistical_pattern_detection:
  frequency_analysis:
    algorithm: "Count occurrences over time windows"
    thresholds:
      - recurring: ">3 occurrences in 24 hours"
      - chronic: ">10 occurrences in 7 days"
      - epidemic: ">50 occurrences in 1 hour"
    use_case: "Identify repeating errors"

  temporal_clustering:
    algorithm: "DBSCAN or hierarchical clustering on timestamps"
    parameters:
      - epsilon: "5 minutes (cluster window)"
      - min_samples: "3 (minimum cluster size)"
    use_case: "Find error bursts and correlated failures"

  correlation_analysis:
    algorithm: "Pearson correlation coefficient"
    variables: [error_rate, user_count, deployment_time, feature_usage]
    threshold: "r > 0.7 (strong correlation)"
    use_case: "Identify error triggers and relationships"

machine_learning_patterns:
  sequence_mining:
    algorithm: "PrefixSpan or GSP"
    input: "Ordered sequences of user actions + errors"
    output: "Common error sequences"
    use_case: "Discover user flows leading to errors"

  classification:
    algorithm: "Random Forest or Decision Tree"
    features: [device_model, os_version, app_version, network_type]
    output: "Error likelihood by characteristics"
    use_case: "Predict error-prone configurations"

  anomaly_detection:
    algorithm: "Isolation Forest or One-Class SVM"
    input: "Error characteristics vector"
    output: "Novel error patterns vs known patterns"
    use_case: "Detect new error types early"
```

### Pattern Categories
```yaml
pattern_types:
  temporal_patterns:
    - Time-of-day patterns (peak error hours)
    - Day-of-week patterns (weekend vs weekday)
    - Seasonal patterns (holiday traffic)
    - Event-driven patterns (deployment correlation)

  spatial_patterns:
    - Geographic clustering (region-specific errors)
    - Network-type patterns (WiFi vs cellular)
    - Device-type patterns (iOS vs Android, specific models)

  behavioral_patterns:
    - User journey patterns (login → error)
    - Feature usage patterns (specific feature combinations)
    - Session patterns (duration, actions before error)

  code_patterns:
    - Error signature patterns (same stack trace)
    - Error message patterns (similar messages)
    - Error location patterns (same file/method)
    - Error type patterns (same exception class)
```

## Flutter/Firebase Pattern Recognition

### Flutter-Specific Patterns
```yaml
widget_lifecycle_patterns:
  setstate_after_dispose:
    pattern_signature:
      - "StateError" exception type
      - "setState" + "dispose" in stack trace
      - Async gap present
    temporal_pattern: "Occurs during rapid navigation"
    frequency_pattern: "Spikes during high user activity"
    mitigation: "Add mounted checks, cancel async in dispose"

  rebuild_storms:
    pattern_signature:
      - "performRebuild" repeated in stack
      - High CPU usage correlation
      - Frame drops correlation
    temporal_pattern: "Constant during specific screen usage"
    frequency_pattern: "Increases with data volume"
    mitigation: "Implement const, memo, or selective rebuild"

  constraint_violations:
    pattern_signature:
      - "RenderBox" + "constraints" in error message
      - "performLayout" in stack trace
    temporal_pattern: "Occurs on specific screen sizes"
    frequency_pattern: "Clusters by device model"
    mitigation: "Add Expanded/Flexible, fix layout constraints"

navigation_patterns:
  navigation_errors:
    pattern_signature:
      - "Navigator" in stack trace
      - Named route errors
    temporal_pattern: "During deep linking or push notifications"
    frequency_pattern: "Spikes after app updates"
    mitigation: "Validate route arguments, handle unknown routes"

  back_button_errors:
    pattern_signature:
      - "pop" in stack trace
      - Empty navigator stack
    temporal_pattern: "When user presses back rapidly"
    frequency_pattern: "Higher on Android devices"
    mitigation: "Check Navigator.canPop(), handle back button"
```

### Firebase-Specific Patterns
```yaml
firestore_patterns:
  permission_denied_pattern:
    pattern_signature:
      - "PERMISSION_DENIED" error code
      - Specific collection/document path
    temporal_pattern: "After user role changes"
    user_pattern: "New users or recently logged in"
    correlation: "Security rule updates"
    mitigation: "Review security rules, validate auth state"

  timeout_pattern:
    pattern_signature:
      - "DEADLINE_EXCEEDED" error code
      - Specific query operations
    temporal_pattern: "During peak hours (12pm-2pm, 6pm-8pm)"
    load_correlation: "User count > 1000 concurrent"
    mitigation: "Add pagination, implement caching, optimize queries"

  rate_limiting_pattern:
    pattern_signature:
      - "RESOURCE_EXHAUSTED" error code
      - Rapid sequential requests
    temporal_pattern: "Bursts every 5-10 minutes"
    user_pattern: "Single user or bot-like behavior"
    mitigation: "Implement client-side throttling, add rate limiting"

auth_patterns:
  token_expiry_pattern:
    pattern_signature:
      - "UNAUTHENTICATED" error code
      - Token refresh errors
    temporal_pattern: "Exactly 1 hour after login"
    session_pattern: "Long-running sessions"
    mitigation: "Implement token refresh, handle auth state changes"

  network_auth_pattern:
    pattern_signature:
      - "UNAVAILABLE" during sign-in
      - Network errors
    temporal_pattern: "During poor connectivity periods"
    device_pattern: "Mobile devices on cellular"
    mitigation: "Add offline auth caching, retry logic"

storage_patterns:
  upload_failure_pattern:
    pattern_signature:
      - "Upload failed" errors
      - Large file sizes (>5MB)
    temporal_pattern: "During background app state"
    network_pattern: "Weak cellular connections"
    mitigation: "Chunked uploads, resume capability, background tasks"
```

### Cross-Service Patterns
```yaml
cascading_failure_patterns:
  auth_to_firestore:
    sequence:
      - "Auth token refresh fails"
      - "Firestore PERMISSION_DENIED"
      - "UI shows error state"
    correlation: "99% of Firestore errors follow auth failures"
    mitigation: "Graceful auth degradation, offline mode"

  network_to_multiple:
    sequence:
      - "Network connectivity lost"
      - "Firebase UNAVAILABLE across all services"
      - "Local cache activation"
    correlation: "100% Firebase errors during network issues"
    mitigation: "Offline-first architecture, connection monitoring"

  deployment_regression:
    sequence:
      - "App version update deployed"
      - "New error types appear within 1 hour"
      - "Error rate 10x increase"
    correlation: "95% correlated with deployments"
    mitigation: "Staged rollouts, canary deployments, monitoring"
```

## Pattern Analysis Workflow

### Pattern Discovery Process
```yaml
discovery_workflow:
  step_1_data_collection:
    timeframe: "Last 30 days of error data"
    data_points: [error_type, timestamp, stack_trace, user_id, device_info]
    minimum_samples: "100 errors for statistical significance"

  step_2_signature_generation:
    process:
      - Extract error signatures (type, location, message)
      - Normalize stack traces (remove variable parts)
      - Generate hash for grouping
    output: "Error signature catalog"

  step_3_clustering:
    process:
      - Group by signature
      - Cluster by temporal proximity
      - Correlate with external factors
    output: "Error clusters with characteristics"

  step_4_pattern_extraction:
    process:
      - Analyze cluster characteristics
      - Identify common attributes
      - Compute correlation strengths
    output: "Identified patterns with confidence scores"

  step_5_validation:
    process:
      - Test pattern predictions on new data
      - Measure pattern recurrence rate
      - Validate causation vs correlation
    output: "Validated patterns with accuracy metrics"
```

### Trend Analysis Process
```yaml
trend_analysis_workflow:
  baseline_establishment:
    metric: "Error rate per 1000 sessions"
    calculation: "Rolling 7-day median"
    update_frequency: "Daily"

  trend_detection:
    methods:
      - linear_regression: "Detect consistent growth/decline"
      - moving_average: "Smooth noise, identify direction"
      - change_point: "Detect sudden shifts"

  trend_classification:
    increasing_trend:
      definition: "Error rate growing >5% per week"
      severity: "High if rate >2x baseline"
      action: "Immediate investigation"

    decreasing_trend:
      definition: "Error rate declining >5% per week"
      severity: "Low (positive trend)"
      action: "Monitor for regression"

    cyclical_trend:
      definition: "Repeating pattern (daily/weekly)"
      severity: "Medium (predictable)"
      action: "Capacity planning"

    step_change:
      definition: "Sudden 2x increase/decrease"
      severity: "High (likely deployment impact)"
      action: "Rollback or hotfix consideration"
```

## Pattern Library

### Known Error Patterns Catalog
```yaml
flutter_patterns:
  pattern_id: "FLT-001"
  name: "setState After Dispose"
  signature: "StateError + setState + async gap"
  frequency: "Very Common"
  severity: "Medium"
  first_observed: "Flutter 1.0+"
  fix_template: "Add mounted check before setState"

  pattern_id: "FLT-002"
  name: "Infinite Build Loop"
  signature: "performRebuild loop + setState in build"
  frequency: "Common"
  severity: "High"
  first_observed: "Flutter 1.0+"
  fix_template: "Move setState to event handlers"

firebase_patterns:
  pattern_id: "FB-001"
  name: "Firestore Timeout Under Load"
  signature: "DEADLINE_EXCEEDED + peak hours"
  frequency: "Common"
  severity: "High"
  first_observed: "All versions"
  fix_template: "Add pagination and caching"

  pattern_id: "FB-002"
  name: "Permission Denied After Role Change"
  signature: "PERMISSION_DENIED + role update correlation"
  frequency: "Occasional"
  severity: "Medium"
  first_observed: "All versions"
  fix_template: "Refresh auth token after role changes"

integration_patterns:
  pattern_id: "INT-001"
  name: "Network Loss Cascade"
  signature: "UNAVAILABLE across all Firebase services"
  frequency: "Common"
  severity: "High"
  first_observed: "All versions"
  fix_template: "Implement offline-first with sync"
```

## Output Format

### Pattern Recognition Report
```yaml
pattern_analysis:
  analysis_period: "2025-10-01 to 2025-11-01"
  total_errors_analyzed: 12456
  unique_error_types: 87
  identified_patterns: 15

discovered_patterns:
  pattern_1:
    id: "PAT-2025-11-001"
    name: "Profile Screen Load Timeout During Peak Hours"
    confidence: "95%"

    characteristics:
      error_signature:
        - exception: "FirebaseException: DEADLINE_EXCEEDED"
        - operation: "Firestore query in ProfileScreen.loadUserData"
        - stack_trace_hash: "a3f5e9c1b2d4"

      temporal_pattern:
        - peak_hours: ["12:00-14:00", "18:00-20:00"]
        - weekday_correlation: "Mon-Fri (not weekends)"
        - frequency: "45 occurrences/day during peaks"

      load_correlation:
        - concurrent_users: ">1000 active"
        - pearson_r: "0.87 (strong correlation)"
        - threshold: "Error probability >50% when users >1200"

      device_pattern:
        - no_device_correlation: true
        - platform_distribution: "50% iOS, 50% Android"

    supporting_evidence:
      - "Query fetching 500+ user posts per request"
      - "No pagination implemented"
      - "Cache hit rate <20% during peaks"
      - "Similar pattern in UserListScreen"

    impact_assessment:
      affected_users: "~120 users/day"
      user_experience: "Profile screen fails to load, shows error"
      workaround_available: "Retry usually succeeds"
      business_impact: "Medium - affects user engagement"

    remediation_recommendation:
      immediate:
        - "Implement query pagination (limit: 50 posts)"
        - "Enable aggressive caching (TTL: 5 minutes)"
        - "Add loading indicators and retry UI"

      long_term:
        - "Optimize data model to reduce query size"
        - "Implement virtual scrolling for large lists"
        - "Add capacity monitoring and auto-scaling"

    validation_plan:
      success_criteria: "Error rate <5 occurrences/day"
      monitoring_period: "14 days post-deployment"
      rollback_trigger: "Error rate increases >20%"

  pattern_2:
    id: "PAT-2025-11-002"
    name: "setState After Dispose in Multiple Screens"
    confidence: "100%"

    characteristics:
      error_signature:
        - exception: "StateError"
        - message: "Cannot call setState() after dispose()"
        - affected_screens: ["ProfileScreen", "SettingsScreen", "NotificationsScreen"]

      temporal_pattern:
        - no_time_correlation: true
        - constant_rate: "15-20 occurrences/day"

      user_pattern:
        - trigger: "Rapid navigation (screen exit <500ms)"
        - user_type: "Power users with fast interactions"

      code_pattern:
        - all_screens_v2_4_0: true
        - introduced_in_deployment: "2025-10-28"

    supporting_evidence:
      - "Same pattern across 3 screens added in v2.4.0"
      - "All screens use async HTTP requests in initState"
      - "No mounted checks before setState"
      - "No request cancellation in dispose"

    impact_assessment:
      affected_users: "~50 users/day"
      user_experience: "Silent error, no visible impact"
      crash_rate_contribution: "0% (non-fatal)"
      log_noise: "High - obscures other errors"

    remediation_recommendation:
      immediate:
        - "Add mounted checks before all setState calls"
        - "Cancel HTTP requests in dispose methods"
        - "Add lint rule to prevent pattern"

      long_term:
        - "Refactor to use StateNotifier with auto-dispose"
        - "Implement request lifecycle management"
        - "Update coding standards and templates"

trend_analysis:
  overall_error_trend:
    direction: "Increasing"
    rate: "+8% per week"
    current_rate: "42 errors per 1000 sessions"
    baseline_rate: "35 errors per 1000 sessions"

  trending_up:
    - error_type: "Firebase DEADLINE_EXCEEDED"
      growth_rate: "+15% per week"
      correlation: "User growth (+12% per week)"

    - error_type: "setState After Dispose"
      growth_rate: "+25% per week"
      correlation: "v2.4.0 deployment (2025-10-28)"

  trending_down:
    - error_type: "Navigation errors"
      decline_rate: "-10% per week"
      correlation: "Navigation refactor in v2.3.5"

  stable_patterns:
    - error_type: "Network connectivity errors"
      variation: "±3% (within normal range)"
      pattern: "Cyclical (higher during commute hours)"

emerging_patterns:
  - pattern: "Memory usage increasing in ImageGalleryScreen"
    observations: 5
    first_seen: "2025-10-29"
    confidence: "Low (needs more data)"
    action: "Monitor for 7 more days"

correlation_findings:
  deployment_correlation:
    deployments_analyzed: 4
    error_spike_correlation: "75% (3 out of 4)"
    avg_error_increase: "+45% within 24h of deployment"
    recommendation: "Implement canary deployments"

  user_load_correlation:
    metric: "Concurrent users vs error rate"
    pearson_r: "0.78 (strong positive correlation)"
    threshold: "Error rate doubles when users >1500"
    recommendation: "Add auto-scaling for >1200 users"

  time_of_day_correlation:
    peak_error_hours: ["12:00-14:00", "18:00-20:00"]
    error_rate_multiplier: "2.5x baseline"
    cause: "Coincides with peak user activity"
    recommendation: "Pre-scale infrastructure before peaks"

recommendations:
  priority_1_urgent:
    - "Fix Profile Screen timeout pattern (120 users/day affected)"
    - "Implement deployment monitoring and rollback triggers"

  priority_2_important:
    - "Fix setState After Dispose across all screens"
    - "Add auto-scaling for concurrent users >1200"

  priority_3_preventive:
    - "Implement lint rules for common patterns"
    - "Add pattern detection to CI/CD pipeline"
    - "Enhance monitoring for emerging patterns"
```

### Pattern Prediction Report
```yaml
prediction:
  forecast_period: "Next 7 days (2025-11-02 to 2025-11-08)"

  predicted_patterns:
    - pattern_id: "PAT-2025-11-001"
      name: "Profile Screen Timeout"
      predicted_frequency: "60-70 occurrences/day"
      confidence: "High (90%)"
      reasoning: "User growth trend continuing, no fix deployed"
      preventive_action: "Deploy pagination within 48 hours"

    - pattern_id: "PAT-2025-11-002"
      name: "setState After Dispose"
      predicted_frequency: "25-30 occurrences/day"
      confidence: "Medium (75%)"
      reasoning: "Linear growth trend, fix pending"
      preventive_action: "Deploy mounted checks within 72 hours"

  emerging_risk:
    - pattern: "Memory leak in ImageGalleryScreen"
      likelihood: "60%"
      impact: "High if confirmed"
      early_indicators:
        - "Memory usage +5MB per gallery view"
        - "GC frequency increasing"
        - "User reports of slowness"
      recommended_action: "Immediate profiling and investigation"

  seasonal_forecast:
    - event: "Weekend traffic increase"
      expected_impact: "-20% error rate"
      reasoning: "Historical weekend pattern (lower usage)"

    - event: "Monday morning spike"
      expected_impact: "+30% error rate (2025-11-03 9:00-10:00)"
      reasoning: "Historical Monday pattern (high engagement)"
```

## Integration with Other Skills

### Combines With
- **stack-trace-analysis**: Feed error signatures for pattern matching
- **root-cause-analysis**: Provide pattern context for hypothesis generation
- **proactive-monitoring**: Detect pattern trends for early warnings

### Feeds Into
- **auto-recovery**: Design recovery based on known patterns
- **optimization-strategy**: Prioritize optimizations by pattern frequency
- **graceful-degradation**: Implement fallbacks for common patterns

## Success Metrics

- **Pattern Detection Rate**: ≥80% of recurring errors identified as patterns
- **Prediction Accuracy**: ≥75% of predicted patterns materialize
- **False Pattern Rate**: <10% (patterns that don't recur)
- **Time to Pattern Detection**: <48 hours for patterns with ≥10 occurrences
- **Correlation Accuracy**: ≥70% of correlations represent true causation
