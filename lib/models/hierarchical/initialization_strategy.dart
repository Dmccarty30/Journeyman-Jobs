/// Initialization strategies to control how the app performs startup work.
/// This is the single canonical enum shared across the hierarchical initialization
/// components. It includes legacy-style names (sequential/parallel/criticalOnly)
/// mapped into higher-level strategies so older modules can still switch on them.
enum InitializationStrategy {
  /// Legacy: execute stages sequentially (one at a time).
  sequential,

  /// Legacy: execute stages in parallel when possible.
  parallel,

  /// Load only critical infrastructure and essential user data.
  minimal,

  /// Prioritize the user's home local and related data.
  homeLocalFirst,

  /// Run all stages fully using maximal parallelism.
  comprehensive,

  /// Pick a strategy at runtime based on device/network/usage.
  adaptive,

  /// Run only critical stages.
  criticalOnly,
}