/// Defines the visibility of a Crew, controlling its discoverability and joinability.
///
/// This enum is used by the `Crew` model to determine whether a crew should be
/// publicly listed or accessible only through a direct invitation. It plays a
/// critical role in search, discovery, and access control features.
enum CrewVisibility {
  /// Indicates that the Crew is publicly discoverable.
  ///
  /// Public crews may appear in search results, browse lists, and other discovery
  /// features. Depending on the crew's settings, they may be joinable by anyone,
  /// require an application, or still need an invite code.
  public,

  /// Indicates that the Crew is private and not discoverable.
  ///
  /// Private crews are hidden from all public-facing discovery UIs. Access is
  /// strictly controlled, typically requiring a valid `InviteCode` to join. This
  /// ensures that only invited members can find and become part of the crew.
  private,
}
