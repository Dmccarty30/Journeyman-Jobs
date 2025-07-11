/// Represents the data model for a notification.
///
/// Each notification has a unique [id], a [title], and a [message].
/// The [timestamp] indicates when the notification was created, and [isRead]
/// tracks whether the user has viewed it. The [type] field categorizes the
/// notification (e.g., 'system', 'alert'), and an optional [actionUrl]
/// can provide a deep link for further action.
class NotificationModel {
  /// Unique identifier for each notification.
  /// This is essential for distinguishing between different notifications and
  /// for operations like marking a specific notification as read or deleting it.
  final String id;

  /// The title text of the notification.
  /// This is a short, descriptive string that summarizes the notification's purpose.
  final String title;

  /// The main body content of the notification.
  /// This provides more detailed information about the notification.
  final String message;

  /// The date and time when the notification was created.
  /// This helps in ordering notifications chronologically.
  final DateTime timestamp;

  /// The read/unread status of the notification.
  /// This is mutable and can be changed, for instance, when a user views the notification.
  /// Defaults to `false` (unread).
  bool isRead;

  /// The category of the notification.
  /// This can be used to filter notifications or to display them differently in the UI.
  /// Examples include 'system', 'alert', 'update'.
  final String type;

  /// An optional deep link for notification actions.
  /// If provided, this URL can be used to navigate the user to a specific
  /// screen or content within the app when the notification is tapped.
  final String? actionUrl;

  /// Creates an instance of [NotificationModel].
  ///
  /// All parameters are required except for [isRead] which defaults to `false`,
  /// and [actionUrl] which is optional.
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.actionUrl,
  });
}

