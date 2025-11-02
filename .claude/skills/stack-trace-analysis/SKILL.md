# Stack Trace Analysis Skill

**Category**: Debug/Error Detection
**Complexity**: Medium (0.6)
**Primary Agents**: error-analyzer-agent
**Prerequisites**: Error logs, stack trace data

## Purpose

Flutter error parsing and stack trace interpretation to quickly identify error sources, affected code paths, and error classification for Flutter/Firebase applications.

## Core Methodology

### Stack Trace Anatomy
```yaml
stack_trace_components:
  exception_type:
    location: "First line of stack trace"
    information: "Error class name (e.g., StateError, RangeError)"
    use: "Initial error classification"

  error_message:
    location: "After exception type"
    information: "Human-readable error description"
    use: "Understanding error context"

  call_stack:
    location: "Subsequent lines (frames)"
    information: "Function call sequence leading to error"
    use: "Identifying code path and origin"

  frame_format:
    pattern: "#N ClassName.methodName (file.dart:line:column)"
    components:
      - frame_number: "Stack depth indicator"
      - class_name: "Class containing method"
      - method_name: "Function that was executing"
      - file_path: "Source file location"
      - line_number: "Exact line of code"
      - column_number: "Position in line"
```

### Flutter Stack Trace Patterns
```yaml
flutter_framework_patterns:
  widget_lifecycle_errors:
    pattern: "setState.*after.*dispose"
    stack_markers: ["StatefulElement", "ComponentElement"]
    classification: "Widget Lifecycle Violation"
    common_causes:
      - "Async operation completing after widget unmounted"
      - "Timer/subscription not cancelled in dispose"

  render_errors:
    pattern: "RenderBox.*not.*laid out"
    stack_markers: ["RenderBox", "RenderObject", "performLayout"]
    classification: "Layout Constraint Violation"
    common_causes:
      - "Unbounded constraints in Flex/ListView"
      - "Missing Expanded/Flexible wrapper"

  assertion_errors:
    pattern: "Failed assertion"
    stack_markers: ["assert", "_AssertionError"]
    classification: "Assertion Failure"
    common_causes:
      - "Invalid widget configuration"
      - "Framework contract violation"

  null_errors:
    pattern: "Null check operator used on a null value"
    stack_markers: ["!", "??"]
    classification: "Null Safety Violation"
    common_causes:
      - "Unexpected null from API"
      - "Missing null checks"

firebase_error_patterns:
  permission_denied:
    pattern: "PERMISSION_DENIED"
    stack_markers: ["FirebaseException", "Firestore"]
    classification: "Firebase Security Rules Violation"
    common_causes:
      - "Security rules misconfigured"
      - "Invalid authentication token"

  deadline_exceeded:
    pattern: "DEADLINE_EXCEEDED"
    stack_markers: ["FirebaseException", "GrpcError"]
    classification: "Firebase Timeout"
    common_causes:
      - "Large query without pagination"
      - "Network latency spike"

  unavailable:
    pattern: "UNAVAILABLE"
    stack_markers: ["FirebaseException", "NetworkException"]
    classification: "Firebase Service Unavailable"
    common_causes:
      - "Network connectivity lost"
      - "Firebase service outage"
```

## Parsing Algorithms

### Frame Extraction
```yaml
frame_parsing:
  regex_pattern: |
    #(?<number>\d+)\s+
    (?<class>[A-Za-z0-9_.<>]+)\.
    (?<method>[A-Za-z0-9_<>]+)\s+
    \((?<file>[^:]+):
    (?<line>\d+):
    (?<column>\d+)\)

  extracted_data:
    - frame_number: "Position in call stack"
    - class_name: "Containing class (empty if top-level)"
    - method_name: "Function name"
    - file_path: "Relative or absolute file path"
    - line_number: "Line in source file"
    - column_number: "Character position"

  special_cases:
    async_gap: "===== asynchronous gap ====="
    indicates: "Async operation boundary"
    handling: "Treat as context switch in async flow"
```

### Origin Detection
```yaml
origin_identification:
  app_code_markers:
    - "package:your_app/"
    - "lib/"
    - "dart:ui" (in some contexts)

  framework_code_markers:
    - "package:flutter/"
    - "dart:core"
    - "dart:async"

  plugin_code_markers:
    - "package:firebase_"
    - "package:provider/"
    - Other third-party packages

  origin_classification:
    app_error: "Error originated in application code"
    framework_error: "Flutter framework detected issue"
    plugin_error: "Third-party package error"
    platform_error: "Native platform error"

  responsibility_assignment:
    app_code_top: "Application bug - fix in app code"
    framework_code_top: "Framework issue - may need workaround"
    mixed_stack: "Analyze app frames leading to framework error"
```

### Error Grouping
```yaml
grouping_strategies:
  by_exception_type:
    key: "Exception class name"
    use_case: "Group similar error types"
    example: "All StateError instances together"

  by_error_location:
    key: "File + line number of origin"
    use_case: "Group errors from same code"
    example: "All errors from user_repository.dart:45"

  by_stack_signature:
    key: "Hash of top 5 app frames"
    use_case: "Group identical error paths"
    example: "All errors with same call sequence"

  by_error_message:
    key: "Error message (normalized)"
    use_case: "Group similar error contexts"
    example: "All 'User not found' errors"

signature_generation:
  algorithm: |
    1. Extract top 5 application frames
    2. Normalize: class.method (file:line)
    3. Hash: MD5 of normalized string
    4. Use hash as grouping key

  normalization_rules:
    - Remove column numbers (vary with formatting)
    - Trim whitespace
    - Lowercase for consistency
```

## Flutter-Specific Patterns

### Widget Error Analysis
```yaml
widget_error_patterns:
  setstate_after_dispose:
    stack_signature:
      - "setState (stateful_widget.dart)"
      - "Your widget update method"
      - "Async callback or timer"
    root_cause: "Widget disposed before async operation completed"
    fix_direction: "Add mounted check before setState"

  infinite_build_loop:
    stack_signature:
      - "build (your_widget.dart)"
      - "performRebuild (framework.dart)"
      - "build (your_widget.dart)" (repeated)
    root_cause: "setState called during build method"
    fix_direction: "Move setState to initState or event handlers"

  constraint_violation:
    stack_signature:
      - "performLayout (render_box.dart)"
      - "RenderFlex.performLayout"
      - "Your widget tree"
    root_cause: "Unbounded constraints in flex layout"
    fix_direction: "Wrap with Expanded or add explicit constraints"
```

### Firebase Error Analysis
```yaml
firebase_error_patterns:
  permission_denied_read:
    stack_signature:
      - "FirebaseException: PERMISSION_DENIED"
      - "DocumentReference.get"
      - "Your data fetch method"
    root_cause: "Security rules deny read access"
    fix_direction: "Check security rules and user authentication"

  permission_denied_write:
    stack_signature:
      - "FirebaseException: PERMISSION_DENIED"
      - "DocumentReference.set"
      - "Your data save method"
    root_cause: "Security rules deny write access"
    fix_direction: "Verify user permissions and data structure"

  timeout_large_query:
    stack_signature:
      - "FirebaseException: DEADLINE_EXCEEDED"
      - "Query.get"
      - "Your list fetch method"
    root_cause: "Query fetching too many documents"
    fix_direction: "Implement pagination or add query limits"
```

### Async Error Analysis
```yaml
async_error_patterns:
  unhandled_future:
    stack_signature:
      - "Unhandled exception"
      - "===== asynchronous gap ====="
      - "Your async function"
    root_cause: "Future not awaited or error not caught"
    fix_direction: "Add try-catch or use .catchError()"

  stream_error:
    stack_signature:
      - "Unhandled exception in stream"
      - "StreamController"
      - "Your stream method"
    root_cause: "Stream error not handled"
    fix_direction: "Add onError handler to stream listener"

  isolate_error:
    stack_signature:
      - "Unhandled exception in isolate"
      - "Isolate.spawn"
      - "Your isolate entry point"
    root_cause: "Error in isolate not communicated to main"
    fix_direction: "Add error handling in isolate"
```

## Analysis Workflow

### Quick Triage Process
```yaml
triage_steps:
  step_1_extract_exception:
    question: "What type of exception occurred?"
    extraction: "First line of stack trace"
    output: "Exception classification"

  step_2_locate_origin:
    question: "Where in my code did this originate?"
    extraction: "First application frame in stack"
    output: "File, line, method"

  step_3_identify_context:
    question: "What was the app trying to do?"
    extraction: "Error message + preceding app frames"
    output: "User action or operation"

  step_4_check_patterns:
    question: "Is this a known pattern?"
    extraction: "Match against pattern library"
    output: "Common cause or unique error"

  step_5_group_similar:
    question: "Are there related errors?"
    extraction: "Generate signature, find matches"
    output: "Error frequency and variations"
```

### Deep Dive Analysis
```yaml
deep_analysis_workflow:
  frame_by_frame_inspection:
    - "Start from exception point"
    - "Work up stack to app code"
    - "Identify state at each frame"
    - "Reconstruct execution path"

  variable_state_reconstruction:
    - "Examine error message for values"
    - "Check surrounding code for context"
    - "Identify likely variable states"
    - "Hypothesize trigger conditions"

  reproduction_planning:
    - "Extract user action from stack"
    - "Identify preconditions"
    - "Design reproduction steps"
    - "Specify test data requirements"
```

## Output Format

### Stack Trace Analysis Report
```yaml
error_summary:
  exception_type: "StateError"
  error_message: "Bad state: Cannot call setState() after dispose()"
  classification: "Widget Lifecycle Violation"
  severity: "High"
  frequency: "12 occurrences in last hour"

stack_analysis:
  origin:
    file: "lib/screens/profile_screen.dart"
    line: 145
    method: "_updateProfile"
    frame: "#3 ProfileScreenState._updateProfile (profile_screen.dart:145:5)"

  call_path:
    app_frames:
      - frame: "#3 ProfileScreenState._updateProfile"
        file: "profile_screen.dart:145"
        context: "setState called here"

      - frame: "#4 ProfileScreenState._fetchUserData.<anonymous>"
        file: "profile_screen.dart:98"
        context: "Async callback from HTTP request"

      - frame: "#7 ProfileScreenState.initState"
        file: "profile_screen.dart:55"
        context: "Initial data fetch triggered"

    framework_frames:
      - "#0 State.setState (framework.dart:1170)"
      - "#1 StatefulElement.state (framework.dart:5015)"
      - "#2 ComponentElement.performRebuild (framework.dart:4901)"

  async_boundaries:
    - location: "Between frame #4 and #5"
      marker: "===== asynchronous gap ====="
      significance: "HTTP request completed after widget disposed"

pattern_match:
  known_pattern: "setState After Dispose"
  confidence: "100%"
  pattern_signature: "setState -> async callback -> dispose race"

  historical_occurrences:
    count: 156
    first_seen: "2025-10-28T10:30:00Z"
    trend: "Increasing since v2.4.0 deployment"

root_cause_hypothesis:
  primary: "Profile screen disposed before HTTP request completed"
  supporting_evidence:
    - "User navigated away before fetch completed"
    - "No cancellation of pending request in dispose"
    - "Avg time between navigation and error: 350ms"

  trigger_conditions:
    - "User loads profile screen"
    - "User navigates away quickly (<500ms)"
    - "HTTP request completes after navigation"

remediation:
  immediate_fix:
    file: "lib/screens/profile_screen.dart"
    changes:
      - location: "Line 145 (_updateProfile method)"
        before: "setState(() => _user = user);"
        after: |
          if (mounted) {
            setState(() => _user = user);
          }

      - location: "Add dispose method"
        add: |
          @override
          void dispose() {
            _httpRequest?.cancel();
            super.dispose();
          }

  validation:
    - "Add unit test for quick navigation"
    - "Verify no setState after dispose in logs"
    - "Monitor error rate post-deployment"

related_errors:
  same_signature:
    count: 12
    screens: ["ProfileScreen", "SettingsScreen", "NotificationsScreen"]
    note: "Same pattern across multiple screens"

  similar_patterns:
    - "Timer firing after dispose (3 occurrences)"
    - "Stream subscription after dispose (5 occurrences)"
```

### Error Group Summary
```yaml
error_group:
  signature: "a3f5e9c1b2d4"
  title: "setState After Dispose in Profile Screens"
  total_occurrences: 156
  affected_users: 48
  first_occurrence: "2025-10-28T10:30:00Z"
  last_occurrence: "2025-11-01T14:45:00Z"

stack_trace_variations:
  variation_1:
    count: 120
    origin: "ProfileScreen._updateProfile"
    trigger: "HTTP request completion"

  variation_2:
    count: 28
    origin: "SettingsScreen._saveSettings"
    trigger: "Firestore write completion"

  variation_3:
    count: 8
    origin: "NotificationsScreen._markRead"
    trigger: "Timer firing"

common_characteristics:
  exception_type: "StateError"
  framework_version: "All errors on Flutter 3.16+"
  user_action: "Quick navigation away from screen"
  timing: "Error occurs 200-500ms after navigation"

impact_analysis:
  user_experience: "Minor - no data loss, error logged silently"
  crash_rate_contribution: "0% (non-fatal)"
  error_log_noise: "High - 156 logs for same root cause"

prioritization:
  priority: "Medium"
  rationale:
    - "Non-fatal but high frequency"
    - "Easy fix with mounted check"
    - "Affects multiple screens (systemic issue)"
    - "Log noise obscuring other errors"

  recommended_timeline: "Fix within 1 week"
```

## Integration with Other Skills

### Combines With
- **root-cause-analysis**: Provide initial error evidence for investigation
- **pattern-recognition**: Feed error signatures for pattern detection
- **auto-recovery**: Classify errors for recovery strategy selection

### Feeds Into
- **graceful-degradation**: Identify errors needing fallback handling
- **performance-profiling**: Correlate errors with performance metrics

## Success Metrics

- **Parsing Accuracy**: 100% (all valid stack traces parsed correctly)
- **Origin Identification**: ≥95% accuracy in locating error source
- **Pattern Matching**: ≥85% of errors matched to known patterns
- **Grouping Effectiveness**: ≥90% reduction in unique error instances
- **Analysis Speed**: <1s per stack trace for standard errors
