/// Represents an invitation to join a crew, containing the code and its terms.
///
/// This model is a cornerstone of the crew joining feature, defining the structure
/// for an invite code. It directly supports the `Crew` model by providing a clear
/// link between a code and the crew it belongs to (`crewId`). The `expiresAt`
/// and `isUsed` fields are critical for enforcing the lifecycle and single-use
/// policy of an invite, which are key requirements of the feature.
class InviteCode {
  /// The unique identifier for the invite code document in Firestore.
  ///
  /// This ID ensures that each invite code can be uniquely identified, tracked,
  /// and managed within the database, which is essential for operations like
  /// marking a code as used or revoking it.
  final String id;

  /// The user-facing code string that is shared with potential new members.
  ///
  /// This is the actual token that users will input to join a crew. Its format
  /// is defined in the feature specification (`CREWNAME-MM/YY-NNN`) and is
  /// generated and validated by the `CrewService`.
  final String code;

  /// The ID of the `Crew` that this invite code belongs to.
  ///
  /// This field establishes a direct, non-negotiable link to the parent crew,
  /// ensuring that each code is only valid for one specific crew. It is the primary
  /// key for looking up the crew during the joining process.
  final String crewId;

  /// The timestamp indicating when the invite code is no longer valid.
  ///
  /// This property enforces the 7-day expiration policy for all invite codes.
  /// The `CrewService` is responsible for comparing this timestamp with the current
  /// time to determine if a code has expired.
  final DateTime expiresAt;

  /// A boolean flag to indicate whether the invite code has already been redeemed.
  ///
  /// This is central to enforcing the single-use requirement for invite codes.
  /// Once a user successfully joins a crew with a code, this flag is set to `true`
  /// to prevent it from being used again.
  final bool isUsed;

  /// Creates an instance of the [InviteCode] model.
  ///
  /// All parameters are required to ensure that an invite code is always in a valid
  /// state. This constructor is used throughout the application, from the
  /// generation of new codes in `CrewService` to the instantiation of `InviteCode`
  /// objects from Firestore data.
  const InviteCode({
    required this.id,
    required this.code,
    required this.crewId,
    required this.expiresAt,
    required this.isUsed,
  });
}
