import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';

/// Exception specific to crew-related operations.
class CrewException extends AppException {
  CrewException(String message, {String? code}) : super(message, code: code);
}
