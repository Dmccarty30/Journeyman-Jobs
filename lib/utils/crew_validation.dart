import 'package:journeyman_jobs/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/utils/crew_error_handling.dart';

/// Comprehensive validation utilities for crew operations
///
/// This class provides validation methods for all crew-related operations
/// including invitations, messaging, and crew management.
class CrewValidation {
  // Constants
  static const int maxCrewNameLength = 50;
  static const int maxMessageContentLength = 1000;
  static const int maxInvitationMessageLength = 500;
  static const int maxUsernameLength = 30;
  static const int maxDisplayNameLength = 50;
  static const int maxClassificationLength = 50;
  static const int maxBioLength = 500;

  // ==================== CREW VALIDATION ====================

  /// Validate crew creation data
  static Map<String, String?> validateCrewCreation({
    String? name,
    String? foremanId,
    Map<String, dynamic>? jobPreferences,
  }) {
    final errors = <String, String?>{};

    // Validate crew name
    errors['name'] = validateCrewName(name);

    // Validate foreman ID
    errors['foremanId'] = validateUserId(foremanId, fieldName: 'Foreman');

    // Validate job preferences (optional)
    if (jobPreferences != null) {
      errors['jobPreferences'] = validateJobPreferences(jobPreferences);
    }

    return errors;
  }

  /// Validate crew update data
  static Map<String, String?> validateCrewUpdate({
    String? name,
    Map<String, dynamic>? jobPreferences,
  }) {
    final errors = <String, String?>{};

    // Validate crew name (optional)
    if (name != null && name.trim().isNotEmpty) {
      errors['name'] = validateCrewName(name);
    }

    // Validate job preferences (optional)
    if (jobPreferences != null) {
      errors['jobPreferences'] = validateJobPreferences(jobPreferences);
    }

    return errors;
  }

  /// Validate job preferences
  static String? validateJobPreferences(Map<String, dynamic>? preferences) {
    if (preferences == null || preferences.isEmpty) {
      return null; // Optional field
    }

    // Check for required job preference fields
    final requiredFields = ['preferredLocations', 'jobTypes', 'availability'];
    for (final field in requiredFields) {
      if (!preferences.containsKey(field)) {
        return 'Missing required job preference: $field';
      }
    }

    // Validate data types
    if (preferences['preferredLocations'] is! List) {
      return 'Preferred locations must be a list';
    }

    if (preferences['jobTypes'] is! List) {
      return 'Job types must be a list';
    }

    if (preferences['availability'] is! Map) {
      return 'Availability must be a map';
    }

    return null; // Valid
  }

  /// Validate crew member operations
  static String? validateCrewMemberOperation({
    required String crewId,
    required String foremanId,
    required String memberId,
    required List<String> currentMemberIds,
    String? operation, // 'add', 'remove', 'transfer'
  }) {
    // Validate IDs
    final crewIdError = validateCrewId(crewId);
    if (crewIdError != null) return crewIdError;

    final foremanIdError = validateUserId(foremanId, fieldName: 'Foreman');
    if (foremanIdError != null) return foremanIdError;

    final memberIdError = validateUserId(memberId, fieldName: 'Member');
    if (memberIdError != null) return memberIdError;

    // Validate operation
    switch (operation) {
      case 'remove':
        if (memberId == foremanId) {
          return 'Cannot remove the crew foreman';
        }
        if (!currentMemberIds.contains(memberId)) {
          return 'User is not a member of this crew';
        }
        break;

      case 'add':
        if (currentMemberIds.contains(memberId)) {
          return 'User is already a member of this crew';
        }
        break;

      case 'transfer':
        if (memberId == foremanId) {
          return 'Cannot transfer foreman role to yourself';
        }
        if (!currentMemberIds.contains(memberId)) {
          return 'User must be a member of the crew to become foreman';
        }
        break;
    }

    return null; // Valid
  }

  // ==================== INVITATION VALIDATION ====================

  /// Validate invitation creation
  static Map<String, String?> validateInvitationCreation({
    required Crew crew,
    required UserModel invitee,
    required UserModel inviter,
    String? message,
    List<CrewInvitation>? existingInvitations,
  }) {
    final errors = <String, String?>{};

    // Validate crew
    if (!crew.isValid) {
      errors['crew'] = 'Invalid crew data';
    }

    // Validate invitee
    errors['invitee'] = validateUser(invitee, fieldName: 'Invitee');

    // Validate inviter
    errors['inviter'] = validateUser(inviter, fieldName: 'Inviter');

    // Validate inviter is foreman
    if (crew.foremanId != inviter.uid) {
      errors['permission'] = 'Only the crew foreman can send invitations';
    }

    // Check if invitee is already a member
    if (crew.memberIds.contains(invitee.uid)) {
      errors['membership'] = 'User is already a member of this crew';
    }

    // Check for existing pending invitation
    if (existingInvitations != null) {
      final hasPendingInvitation = existingInvitations.any((invitation) =>
          invitation.crewId == crew.id &&
          invitation.inviteeId == invitee.uid &&
          invitation.status == CrewInvitationStatus.pending &&
          !invitation.isExpired);

      if (hasPendingInvitation) {
        errors['duplicate'] = 'User already has a pending invitation to this crew';
      }
    }

    // Validate message
    errors['message'] = validateInvitationMessage(message);

    return errors;
  }

  /// Validate invitation response
  static String? validateInvitationResponse({
    required CrewInvitation invitation,
    required String userId,
    required CrewInvitationStatus response,
  }) {
    // Validate user ID
    final userIdError = validateUserId(userId);
    if (userIdError != null) return userIdError;

    // Validate invitation ownership
    if (invitation.inviteeId != userId) {
      return 'You can only respond to your own invitations';
    }

    // Validate response status
    if (response != CrewInvitationStatus.accepted &&
        response != CrewInvitationStatus.declined) {
      return 'Invalid response status';
    }

    // Validate invitation can be responded to
    if (!invitation.canRespond) {
      if (invitation.isExpired) {
        return 'This invitation has expired';
      } else {
        return 'This invitation cannot be responded to';
      }
    }

    return null; // Valid
  }

  /// Validate invitation cancellation
  static String? validateInvitationCancellation({
    required CrewInvitation invitation,
    required String userId,
  }) {
    // Validate user ID
    final userIdError = validateUserId(userId);
    if (userIdError != null) return userIdError;

    // Validate inviter ownership
    if (invitation.inviterId != userId) {
      return 'Only the invitation sender can cancel it';
    }

    // Validate invitation status
    if (invitation.status != CrewInvitationStatus.pending) {
      return 'Only pending invitations can be cancelled';
    }

    return null; // Valid
  }

  // ==================== MESSAGING VALIDATION ====================

  /// Validate message creation
  static Map<String, String?> validateMessageCreation({
    required String crewId,
    required UserModel sender,
    required String content,
    CrewMessageType type = CrewMessageType.text,
    List<String>? mediaUrls,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    final errors = <String, String?>{};

    // Validate IDs
    errors['crewId'] = validateCrewId(crewId);
    errors['sender'] = validateUser(sender, fieldName: 'Sender');

    // Validate content based on message type
    switch (type) {
      case CrewMessageType.text:
        errors['content'] = validateMessageContent(content);
        break;
      case CrewMessageType.system:
        // System messages can have empty content
        break;
      default:
        // Other message types should have content or media
        if (content.trim().isEmpty && (mediaUrls == null || mediaUrls!.isEmpty)) {
          errors['content'] = 'Message content or media is required';
        }
    }

    // Validate media URLs if provided
    if (mediaUrls != null && mediaUrls.isNotEmpty) {
      for (int i = 0; i < mediaUrls.length; i++) {
        final url = mediaUrls[i];
        final urlError = validateUrl(url, fieldName: 'Media URL $i');
        if (urlError != null) {
          errors['media_$i'] = urlError;
        }
      }
    }

    // Validate metadata based on message type
    if (metadata != null) {
      errors['metadata'] = validateMessageMetadata(metadata, type);
    }

    return errors;
  }

  /// Validate message metadata
  static String? validateMessageMetadata(
    Map<String, dynamic> metadata,
    CrewMessageType type,
  ) {
    switch (type) {
      case CrewMessageType.location:
        if (!metadata.containsKey('latitude') || !metadata.containsKey('longitude')) {
          return 'Location messages must include latitude and longitude';
        }
        if (metadata['latitude'] is! num || metadata['longitude'] is! num) {
          return 'Invalid location coordinates';
        }
        break;

      case CrewMessageType.jobShare:
        if (!metadata.containsKey('jobId')) {
          return 'Job share messages must include job ID';
        }
        break;

      case CrewMessageType.voiceNote:
        if (!metadata.containsKey('duration')) {
          return 'Voice note messages must include duration';
        }
        if (metadata['duration'] is! num) {
          return 'Invalid voice note duration';
        }
        break;

      case CrewMessageType.image:
        if (!metadata.containsKey('width') || !metadata.containsKey('height')) {
          return 'Image messages should include dimensions';
        }
        break;

      default:
        // No validation required for other types
        break;
    }

    return null; // Valid
  }

  /// Validate message editing
  static String? validateMessageEdit({
    required CrewMessage message,
    required String userId,
    required String newContent,
  }) {
    // Validate user ID
    final userIdError = validateUserId(userId);
    if (userIdError != null) return userIdError;

    // Validate ownership
    if (message.senderId != userId) {
      return 'You can only edit your own messages';
    }

    // Validate message type
    if (message.type != CrewMessageType.text) {
      return 'Only text messages can be edited';
    }

    // Validate deleted status
    if (message.isDeleted) {
      return 'Cannot edit a deleted message';
    }

    // Validate new content
    final contentError = validateMessageContent(newContent);
    if (contentError != null) return contentError;

    return null; // Valid
  }

  /// Validate message deletion
  static String? validateMessageDeletion({
    required CrewMessage message,
    required String userId,
  }) {
    // Validate user ID
    final userIdError = validateUserId(userId);
    if (userIdError != null) return userIdError;

    // Validate ownership
    if (message.senderId != userId) {
      return 'You can only delete your own messages';
    }

    // Validate system messages
    if (message.type == CrewMessageType.system) {
      return 'System messages cannot be deleted';
    }

    return null; // Valid
  }

  /// Validate message reaction
  static String? validateMessageReaction({
    required CrewMessage message,
    required String userId,
    required String emoji,
  }) {
    // Validate user ID
    final userIdError = validateUserId(userId);
    if (userIdError != null) return userIdError;

    // Validate emoji
    if (emoji.trim().isEmpty) {
      return 'Reaction emoji cannot be empty';
    }

    // Check if emoji is valid (basic validation)
    if (emoji.length > 2) {
      return 'Invalid reaction emoji';
    }

    return null; // Valid
  }

  // ==================== USER VALIDATION ====================

  /// Validate user data
  static Map<String, String?> validateUser({
    required UserModel user,
    bool isNewUser = false,
  }) {
    final errors = <String, String?>{};

    // Validate required fields
    errors['uid'] = validateUserId(user.uid);
    errors['email'] = validateEmail(user.email);
    errors['username'] = validateUsername(user.username);
    errors['displayName'] = validateDisplayName(user.displayNameStr);
    errors['classification'] = validateClassification(user.classification);
    errors['homeLocal'] = validateHomeLocal(user.homeLocal);

    // Validate optional fields
    errors['firstName'] = validateName(user.firstName, fieldName: 'First name');
    errors['lastName'] = validateName(user.lastName, fieldName: 'Last name');
    errors['phoneNumber'] = validatePhoneNumber(user.phoneNumber);
    errors['ticketNumber'] = validateTicketNumber(user.ticketNumber);

    // Validate crew IDs if provided
    if (user.crewIds.isNotEmpty) {
      errors['crewIds'] = validateCrewIds(user.crewIds);
    }

    return errors;
  }

  /// Validate username
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required';
    }

    final trimmedUsername = username.trim();

    if (trimmedUsername.length > maxUsernameLength) {
      return 'Username must be less than $maxUsernameLength characters';
    }

    // Check for invalid characters
    if (trimmedUsername.contains(RegExp(r'[^\w\-_.]'))) {
      return 'Username can only contain letters, numbers, hyphens, underscores, and dots';
    }

    // Check for reserved names
    final reservedNames = ['admin', 'root', 'system', 'api', 'test', 'demo'];
    if (reservedNames.contains(trimmedUsername.toLowerCase())) {
      return 'Username is reserved';
    }

    return null; // Valid
  }

  /// Validate display name
  static String? validateDisplayName(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return 'Display name is required';
    }

    final trimmedDisplayName = displayName.trim();

    if (trimmedDisplayName.length > maxDisplayNameLength) {
      return 'Display name must be less than $maxDisplayNameLength characters';
    }

    // Check for potentially harmful content
    if (trimmedDisplayName.contains(RegExp(r'[<>{}[\]|\\]'))) {
      return 'Display name contains invalid characters';
    }

    return null; // Valid
  }

  /// Validate classification
  static String? validateClassification(String? classification) {
    if (classification == null || classification.trim().isEmpty) {
      return 'Classification is required';
    }

    final trimmedClassification = classification.trim();

    if (trimmedClassification.length > maxClassificationLength) {
      return 'Classification must be less than $maxClassificationLength characters';
    }

    // Validate against known classifications
    final validClassifications = [
      'Journeyman Lineman',
      'Journeyman Wireman',
      'Tree Trimmer',
      'Equipment Operator',
      'Inside Journeyman Electrician',
      'Apprentice',
      'Foreman',
    ];

    if (!validClassifications.contains(trimmedClassification)) {
      return 'Invalid classification';
    }

    return null; // Valid
  }

  /// Validate home local
  static String? validateHomeLocal(int homeLocal) {
    if (homeLocal <= 0) {
      return 'Home local must be a positive number';
    }

    if (homeLocal > 9999) {
      return 'Invalid local number';
    }

    return null; // Valid
  }

  /// Validate ticket number
  static String? validateTicketNumber(String? ticketNumber) {
    if (ticketNumber == null || ticketNumber.trim().isEmpty) {
      return 'Ticket number is required';
    }

    final trimmedTicketNumber = ticketNumber.trim();

    // Basic validation for IBEW ticket format
    if (!RegExp(r'^[A-Z]{2,4}\d{4,8}$').hasMatch(trimmedTicketNumber)) {
      return 'Invalid ticket number format';
    }

    return null; // Valid
  }

  // ==================== UTILITY VALIDATION ====================

  /// Validate user ID
  static String? validateUserId(String? userId, {String fieldName = 'User ID'}) {
    if (userId == null || userId.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmedUserId = userId.trim();

    if (trimmedUserId.length < 10) {
      return 'Invalid $fieldName format';
    }

    // Basic UID validation (should match Firebase auth UID format)
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmedUserId)) {
      return 'Invalid $fieldName format';
    }

    return null; // Valid
  }

  /// Validate crew ID
  static String? validateCrewId(String? crewId, {String fieldName = 'Crew ID'}) {
    if (crewId == null || crewId.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmedCrewId = crewId.trim();

    if (trimmedCrewId.length < 10) {
      return 'Invalid $fieldName format';
    }

    // Basic crew ID validation
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmedCrewId)) {
      return 'Invalid $fieldName format';
    }

    return null; // Valid
  }

  /// Validate name field
  static String? validateName(String? name, {String fieldName = 'Name'}) {
    if (name == null || name.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmedName = name.trim();

    if (trimmedName.length > 50) {
      return '$fieldName must be less than 50 characters';
    }

    // Check for valid characters
    if (trimmedName.contains(RegExp(r'[^\w\s\-\']'))) {
      return '$fieldName contains invalid characters';
    }

    return null; // Valid
  }

  /// Validate email
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedEmail = email.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Invalid email format';
    }

    return null; // Valid
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (trimmedPhone.length < 10 || trimmedPhone.length > 15) {
      return 'Invalid phone number format';
    }

    if (!RegExp(r'^\d+$').hasMatch(trimmedPhone)) {
      return 'Phone number must contain only digits';
    }

    return null; // Valid
  }

  /// Validate URL
  static String? validateUrl(String? url, {String fieldName = 'URL'}) {
    if (url == null || url.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedUrl = url.trim();
    final urlRegex = RegExp(r'^https?://.+');
    if (!urlRegex.hasMatch(trimmedUrl)) {
      return 'Invalid $fieldName format';
    }

    return null; // Valid
  }

  /// Validate list of IDs
  static String? validateCrewIds(List<String> crewIds) {
    if (crewIds.isEmpty) {
      return null; // Empty list is valid
    }

    for (int i = 0; i < crewIds.length; i++) {
      final error = validateCrewId(crewIds[i], fieldName: 'Crew ID $i');
      if (error != null) {
        return error;
      }
    }

    return null; // All IDs are valid
  }

  /// Validate message content
  static String? validateMessageContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return 'Message content is required';
    }

    final trimmedContent = content.trim();

    if (trimmedContent.length > maxMessageContentLength) {
      return 'Message must be less than $maxMessageContentLength characters';
    }

    // Check for potentially harmful content
    if (trimmedContent.contains(RegExp(r'<script|javascript:|data:'))) {
      return 'Message contains potentially harmful content';
    }

    return null; // Valid
  }

  /// Validate invitation message
  static String? validateInvitationMessage(String? message) {
    if (message == null || message.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedMessage = message.trim();

    if (trimmedMessage.length > maxInvitationMessageLength) {
      return 'Invitation message must be less than $maxInvitationMessageLength characters';
    }

    // Check for potentially harmful content
    if (trimmedMessage.contains(RegExp(r'<script|javascript:|data:'))) {
      return 'Invitation message contains potentially harmful content';
    }

    return null; // Valid
  }

  /// Check if all validation results are valid (no errors)
  static bool isValid(Map<String, String?> validationResults) {
    return validationResults.values.every((error) => error == null);
  }

  /// Get all error messages from validation results
  static List<String> getErrorMessages(Map<String, String?> validationResults) {
    return validationResults.entries
        .where((entry) => entry.value != null)
        .map((entry) => entry.value!)
        .toList();
  }
}