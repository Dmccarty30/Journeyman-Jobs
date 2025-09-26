import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';

/// Exception specific to member-related operations within a crew.
class MemberException extends AppException {
  MemberException(String message, {String? code}) : super(message, code: code);
}
