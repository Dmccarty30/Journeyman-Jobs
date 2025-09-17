import '../../../models/user_model.dart';

/// Extension methods for UserModel to provide backward compatibility
/// with job_sharing widgets that expect different property names.
extension UserModelExtensions on UserModel {
  /// Returns uid as id for backward compatibility
  String get id => uid;

  /// Returns fullName as name for backward compatibility
  String get name => fullName;

  /// Returns photoUrl as profileImageUrl for backward compatibility
  String get profileImageUrl => photoUrl ?? '';
}