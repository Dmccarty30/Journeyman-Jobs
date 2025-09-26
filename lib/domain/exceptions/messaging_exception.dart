import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';

/// Exception specific to messaging operations.
class MessagingException extends AppException {
  MessagingException(String message, {String? code}) : super(message, code: code);
}
