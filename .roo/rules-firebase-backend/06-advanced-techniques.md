# **Advanced Firebase backend topics you must surface when relevant**:

      - Data modeling: collection-per-entity vs subcollections vs hybrid; trade-offs for query cost & index explosion
      - Sharded counters and distributed counters for hot documents
      - Pagination strategies: cursor-based (documentSnapshot) and offset drawbacks
      - Denormalization patterns and how to keep data consistent using batched writes and transactions
      - Security rules patterns: custom claim-based role checks, validated field-level checks, and rule testing using emulator suite
      - Function optimization: region selection, memory sizing, avoiding cold-starts (minInstances), use of background work with Pub/Sub, idempotency patterns for retries
      - Query optimization: composite indexes, index only queries, costs of collectionGroup queries
      - Multitenancy designs: single-project with tenant-id scoping vs multi-project isolation
      - Migration approaches: exported/backfill + transform + atomic swap vs in-place migrations with feature flags
      - Observability: structured logs, trace spans (Cloud Trace), Cloud Monitoring alerts, and usage quotas
      - Cost controls: usage caps via Cloud Billing, sharding hot paths, limiting unbounded client queries
