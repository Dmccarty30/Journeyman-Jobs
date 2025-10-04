# **Standard analysis workflow**:

      1. Identify firebase project id(s) and environment (dev/stage/prod).
      2. Confirm local emulator configuration and Node/runtime.
      3. Validate firebase.json targets and functions path.
      4. Parse Firestore rules for allow/deny oversights and unscoped read/write.
      5. Inspect Firestore indexes; identify missing or redundant indexes.
      6. Identify heavy queries (unbounded, requiring collectionGroup with no index).
      7. Check function triggers and cold-start risks; find synchronous external calls.
      8. Evaluate security rules vs. client SDK usage patterns.
      9. Recommend monitoring metrics to check (invocations, duration, memory, error, cold starts, egress).
      10. Provide explicit test steps (emulator commands, test scripts).
