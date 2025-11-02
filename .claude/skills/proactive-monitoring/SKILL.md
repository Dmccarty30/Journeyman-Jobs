# Proactive Monitoring Skill

**Category**: Debug/Error Detection
**Complexity**: High (0.8)
**Primary Agents**: debug-orchestrator, performance-monitor-agent
**Prerequisites**: Baseline metrics, monitoring infrastructure

## Purpose

Degradation detection and predictive failure analysis to identify issues before they impact users in Flutter/Firebase applications.

## Core Methodology

### Baseline Establishment
```yaml
baseline_metrics:
  performance_baselines:
    - P50, P95, P99 latencies for key operations
    - Average frame render time (target: <16ms)
    - App startup time (cold/warm)
    - Memory usage patterns (idle/active)

  reliability_baselines:
    - Error rate by error type
    - Crash-free user percentage
    - Firebase operation success rates
    - Network request failure rates

  user_experience_baselines:
    - Time to interactive (TTI)
    - Screen load times
    - Animation smoothness (jank %)
    - Input responsiveness

baseline_calculation:
  data_collection_period: "7 days minimum, 30 days ideal"
  statistical_method: "Rolling median with outlier filtering"
  update_frequency: "Weekly recalculation"
  seasonality_adjustment: "Account for time-of-day, day-of-week patterns"
```

### Anomaly Detection Algorithms
```yaml
statistical_methods:
  standard_deviation:
    trigger: "Value exceeds mean ± 3σ"
    sensitivity: "Medium"
    use_case: "Stable metrics with normal distribution"

  percentile_based:
    trigger: "Value exceeds P95 baseline by >20%"
    sensitivity: "High"
    use_case: "Latency and performance metrics"

  rate_of_change:
    trigger: "Metric increases >15% in 1 hour"
    sensitivity: "High"
    use_case: "Error rates, resource usage"

  moving_average:
    trigger: "Current value >2x moving average"
    sensitivity: "Medium"
    use_case: "Request volumes, user activity"

machine_learning_methods:
  time_series_forecasting:
    algorithm: "ARIMA or Prophet"
    prediction_window: "1-24 hours ahead"
    use_case: "Capacity planning, trend prediction"

  clustering:
    algorithm: "K-means or DBSCAN"
    use_case: "Error pattern grouping, user behavior"

  classification:
    algorithm: "Random Forest or XGBoost"
    use_case: "Incident severity prediction"
```

## Flutter/Firebase Monitoring Patterns

### Performance Monitoring
```yaml
flutter_performance:
  widget_build_time:
    metric: "Build method execution time"
    threshold: ">10ms per widget"
    detection: "Profile mode measurement"
    alert: "Warning if >5 widgets exceed threshold"

  frame_rendering:
    metric: "Frame build + raster time"
    threshold: ">16ms (60 FPS target)"
    detection: "SchedulerBinding.instance.addTimingsCallback"
    alert: "Jank if >3% of frames dropped"

  memory_usage:
    metric: "Heap size, allocation rate"
    threshold: "Heap >80% of max, allocation >10MB/sec"
    detection: "Observatory service protocol"
    alert: "Memory leak suspected if sustained growth"

  app_startup:
    metric: "Time from launch to first frame"
    threshold: ">3s cold start, >1s warm start"
    detection: "Timeline events"
    alert: "Startup regression if >20% increase"

firebase_performance:
  network_requests:
    metric: "HTTP request duration"
    threshold: ">1s for API calls"
    detection: "Firebase Performance SDK"
    alert: "Latency spike if P95 >2x baseline"

  firestore_operations:
    metric: "Read/write latency"
    threshold: ">500ms"
    detection: "Firestore Performance Monitoring"
    alert: "Database slow if >10% exceed threshold"

  screen_rendering:
    metric: "Screen-specific render times"
    threshold: ">2s for initial render"
    detection: "Screen trace measurement"
    alert: "Screen slow if P95 >baseline + 1s"
```

### Error Rate Monitoring
```yaml
error_tracking:
  crash_rate:
    metric: "Crashes per user session"
    threshold: ">0.1% crash rate"
    detection: "Firebase Crashlytics"
    alert: "Stability issue if rate increases >50%"

  firebase_errors:
    metric: "Firebase operation failures"
    threshold: ">1% error rate"
    detection: "Error logging + Crashlytics"
    alert: "Firebase integration issue"

  network_errors:
    metric: "HTTP 4xx/5xx responses"
    threshold: ">5% error rate"
    detection: "HTTP client interceptor"
    alert: "API degradation"

  widget_errors:
    metric: "Widget build failures"
    threshold: ">0 uncaught exceptions"
    detection: "FlutterError.onError"
    alert: "UI stability issue"
```

### Resource Monitoring
```yaml
resource_tracking:
  network_usage:
    metric: "Data sent/received"
    threshold: ">100MB per session"
    detection: "NetworkInfo + traffic stats"
    alert: "Excessive bandwidth usage"

  battery_impact:
    metric: "Energy consumption rate"
    threshold: ">10% battery per hour"
    detection: "Platform channel to battery stats"
    alert: "Battery drain issue"

  cpu_usage:
    metric: "CPU utilization percentage"
    threshold: ">50% sustained"
    detection: "Platform-specific profiling"
    alert: "CPU-intensive operation detected"

  storage_usage:
    metric: "Local storage size"
    threshold: ">500MB for cache"
    detection: "File system inspection"
    alert: "Storage leak or cache bloat"
```

## Predictive Analysis

### Trend Detection
```yaml
trend_analysis:
  linear_trends:
    calculation: "Linear regression over 7-day window"
    prediction: "Extrapolate to 7 days ahead"
    use_cases:
      - "Memory usage growth (leak detection)"
      - "Error rate increase (regression detection)"
      - "Latency degradation (performance decay)"

  seasonal_patterns:
    calculation: "Decompose time series (STL)"
    components: [trend, seasonal, residual]
    use_cases:
      - "Daily usage patterns"
      - "Weekly load cycles"
      - "Holiday traffic spikes"

  change_point_detection:
    algorithm: "CUSUM or Bayesian change point"
    use_case: "Deployment impact detection"
    alert: "Significant behavior change detected"
```

### Failure Prediction
```yaml
predictive_models:
  memory_leak_prediction:
    indicators:
      - "Heap growth rate >1MB/hour sustained"
      - "GC frequency increasing (>2x baseline)"
      - "Allocation rate >deallocation rate"
    prediction: "Out of memory in X hours"
    confidence: "High if all indicators present"

  performance_degradation:
    indicators:
      - "Latency trend increasing >5%/day"
      - "Frame drop rate increasing"
      - "Widget rebuild count growing"
    prediction: "User-facing lag in X days"
    confidence: "Medium if 2/3 indicators present"

  error_rate_spike:
    indicators:
      - "Error rate increasing >10%/hour"
      - "New error types appearing"
      - "Error clustering on specific screens"
    prediction: "Critical error rate in X hours"
    confidence: "High if rate doubling time <2 hours"

  capacity_exhaustion:
    indicators:
      - "User growth rate >infrastructure capacity"
      - "Database query latency increasing with load"
      - "Connection pool utilization >80%"
    prediction: "Service degradation at X users"
    confidence: "Medium based on load testing data"
```

## Alerting Framework

### Alert Severity Levels
```yaml
alert_levels:
  info:
    criteria: "Metric outside normal range but no user impact"
    response_time: "Review within 24 hours"
    examples:
      - "Cache hit rate decreased 5%"
      - "Background sync slower than usual"

  warning:
    criteria: "Trend indicates potential issue in 6-24 hours"
    response_time: "Investigate within 4 hours"
    examples:
      - "Memory usage growing, leak predicted in 12 hours"
      - "Error rate increasing, may reach threshold tomorrow"

  error:
    criteria: "Threshold exceeded, limited user impact"
    response_time: "Investigate within 1 hour"
    examples:
      - "P95 latency exceeds 2x baseline"
      - "Error rate 1-5% on specific feature"

  critical:
    criteria: "Severe degradation or outage imminent"
    response_time: "Immediate response required"
    examples:
      - "Crash rate >1%"
      - "Primary feature unavailable"
      - "Memory exhaustion predicted in <1 hour"
```

### Alert Routing & Escalation
```yaml
routing_rules:
  performance_issues:
    initial: performance-monitor-agent
    escalate_to: debug-orchestrator
    escalate_if: "Degradation >50% or >1 hour"

  error_spikes:
    initial: error-analyzer-agent
    escalate_to: self-healing-agent
    escalate_if: "Error rate >5% or new error type"

  resource_exhaustion:
    initial: self-healing-agent
    escalate_to: debug-orchestrator
    escalate_if: "Critical resource <10% remaining"

  cascading_failures:
    initial: debug-orchestrator
    escalate_to: manual_intervention
    escalate_if: ">3 related services degraded"

alert_aggregation:
  grouping_window: "5 minutes"
  deduplication: "Same metric + threshold"
  correlation: "Related metrics grouped"
  suppression: "During maintenance windows"
```

## Monitoring Infrastructure

### Data Collection
```yaml
instrumentation:
  flutter_app:
    - Firebase Performance SDK
    - Custom performance traces
    - Error boundary logging
    - Widget lifecycle tracking

  firebase_backend:
    - Firestore performance monitoring
    - Cloud Functions execution metrics
    - Firebase Auth event logging
    - Storage operation tracking

  custom_metrics:
    - User flow completion rates
    - Feature usage analytics
    - Business metric tracking
    - Custom error categories

collection_frequency:
  real_time_metrics: "Every 1 second (in-memory)"
  aggregated_metrics: "Every 1 minute (sent to backend)"
  baseline_updates: "Hourly aggregation"
  historical_storage: "Daily snapshots for 90 days"
```

### Monitoring Dashboards
```yaml
dashboard_layouts:
  overview_dashboard:
    metrics:
      - Overall app health score
      - Active incidents count
      - Key performance indicators
      - Error rate trends
    refresh_rate: "30 seconds"

  performance_dashboard:
    metrics:
      - P50/P95/P99 latencies
      - Frame render time distribution
      - Memory usage graph
      - Network bandwidth
    refresh_rate: "10 seconds"

  reliability_dashboard:
    metrics:
      - Crash-free user percentage
      - Error rate by category
      - Firebase operation success
      - Alerts timeline
    refresh_rate: "1 minute"

  predictive_dashboard:
    metrics:
      - Trend forecasts (7 days)
      - Anomaly detection results
      - Capacity predictions
      - Health predictions
    refresh_rate: "5 minutes"
```

## Output Format

### Proactive Monitoring Alert
```yaml
alert:
  id: "PM-2025-11-01-1045"
  timestamp: "2025-11-01T10:45:00Z"
  severity: "Warning"
  type: "Performance Degradation Predicted"

detection:
  metric: "User profile screen render time"
  current_value: "1,850ms (P95)"
  baseline_value: "1,200ms (P95)"
  deviation: "+54%"
  trend: "Increasing 8%/day for 4 days"

prediction:
  forecast: "Will exceed 2,500ms P95 in 3 days (2025-11-04)"
  confidence: "85% (based on linear trend)"
  user_impact_forecast: "Noticeable lag for 15% of users"
  severity_prediction: "Will escalate to ERROR level in 72 hours"

root_cause_hypothesis:
  primary_hypothesis: "Widget rebuild rate increasing due to recent changes"
  supporting_evidence:
    - "Build time increased from 450ms to 720ms (P95)"
    - "Rebuild count per navigation: 8 → 13 (avg)"
    - "Correlated with v2.4.0 deployment (2025-10-28)"
  confidence: "Medium (correlation strong, causation needs validation)"

recommended_actions:
  immediate:
    - action: "Profile widget rebuild triggers"
      priority: "High"
      timeline: "Within 24 hours"

    - action: "Review v2.4.0 changes to profile screen"
      priority: "High"
      timeline: "Within 24 hours"

  preventive:
    - action: "Implement useMemoized for expensive computations"
      priority: "Medium"
      timeline: "Within 48 hours"

    - action: "Add const constructors where applicable"
      priority: "Medium"
      timeline: "Within 48 hours"

  monitoring:
    - action: "Increase profiling frequency for profile screen"
      priority: "Low"
      timeline: "Immediate"

    - action: "Set up alert for rebuild count >15"
      priority: "Low"
      timeline: "Within 12 hours"

historical_context:
  similar_incidents:
    - incident: "INC-2025-09-15-002"
      description: "Similar render time increase in user list screen"
      resolution: "Implemented memoization, reduced rebuilds by 40%"
      time_to_resolve: "2 days"

  trend_comparison:
    - "Current trend matches pattern from September incident"
    - "If unaddressed, expect 30-50% user complaints within 1 week"

validation_plan:
  success_criteria:
    - "P95 render time returns to <1,400ms"
    - "Rebuild count reduced to <10 per navigation"
    - "Trend slope changes from positive to neutral"

  monitoring_period: "7 days post-fix"
  validation_checkpoints: ["24h", "72h", "7d"]
```

### Health Score Report
```yaml
health_assessment:
  timestamp: "2025-11-01T12:00:00Z"
  overall_health_score: "82/100"
  status: "Good (with minor concerns)"

component_scores:
  performance_health: "78/100 (Fair)"
  reliability_health: "92/100 (Excellent)"
  resource_efficiency: "85/100 (Good)"
  user_experience: "80/100 (Good)"

detailed_analysis:
  performance:
    score: 78
    concerns:
      - "Profile screen render time trending up (Warning)"
      - "Memory usage 15% above baseline (Info)"
    strengths:
      - "API latency within SLA (P95: 450ms)"
      - "App startup time improved 12%"

  reliability:
    score: 92
    concerns: []
    strengths:
      - "Crash-free rate: 99.7%"
      - "Firebase operation success: 99.2%"
      - "Zero critical errors in 7 days"

  resource_efficiency:
    score: 85
    concerns:
      - "Network usage slightly elevated (Info)"
    strengths:
      - "Battery impact: 6% per hour (Good)"
      - "Storage usage stable at 180MB"

  user_experience:
    score: 80
    concerns:
      - "Jank percentage increased to 4.2% (Warning)"
    strengths:
      - "Time to interactive: 1.2s (Excellent)"
      - "Navigation smoothness: 96%"

predictions:
  7_day_forecast:
    - metric: "Overall health score"
      current: 82
      predicted: 76
      confidence: "Medium"
      reasoning: "Profile screen issue expected to worsen"

    - metric: "Performance health"
      current: 78
      predicted: 68
      confidence: "High"
      reasoning: "Render time trend continuing"

    - metric: "Reliability health"
      current: 92
      predicted: 91
      confidence: "High"
      reasoning: "No concerning trends"

recommended_focus_areas:
  priority_1: "Address profile screen performance degradation"
  priority_2: "Investigate and reduce jank percentage"
  priority_3: "Monitor network usage trend"
```

## Integration with Other Skills

### Combines With
- **root-cause-analysis**: Investigate predicted failures before they occur
- **pattern-recognition**: Identify patterns in degradation trends
- **performance-profiling**: Profile suspected performance issues

### Feeds Into
- **auto-recovery**: Trigger preventive recovery mechanisms
- **graceful-degradation**: Activate fallbacks before full failure
- **optimization-strategy**: Prioritize optimizations based on predictions

## Success Metrics

- **Early Detection Rate**: ≥85% of issues detected before user impact
- **Prediction Accuracy**: ≥80% of predictions materialized or prevented
- **False Positive Rate**: <15% (alerts that don't materialize)
- **Lead Time**: ≥30 minutes warning before user-facing degradation
- **Alert Response**: ≥90% of alerts addressed within SLA
