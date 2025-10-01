import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';

/// Exception specific to messaging operations.
class MessagingException extends AppException {
  MessagingException(super.message, {super.code});
}
