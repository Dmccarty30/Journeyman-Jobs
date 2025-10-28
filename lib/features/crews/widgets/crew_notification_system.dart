import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../electrical_components/jj_electrical_toast.dart';

/// Comprehensive notification system for crew updates, messages, and events.
/// 
/// Provides real-time notifications for:
/// - New crew messages
/// - Member invitations and joins
/// - Job shares and updates
/// - Crew activities and changes
class CrewNotificationSystem extends ConsumerStatefulWidget {
  final String crewId;
  
  const CrewNotificationSystem({
    Key? key,
    required this.crewId,
  }) : super(key: key);

  @override
  ConsumerState<CrewNotificationSystem> createState() => _CrewNotificationSystemState();
}

class _CrewNotificationSystemState extends ConsumerState<CrewNotificationSystem>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  List<CrewNotification> _notifications = [];
  bool _showNotificationPanel = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _listenForNotifications();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _listenForNotifications() {
    // Listen for real-time notifications from Firebase
    // This would connect to a notification service
    ref.listen(crewNotificationsProvider(widget.crewId), (previous, next) {
      if (next.hasValue) {
        final newNotifications = next.value!;
        if (newNotifications.isNotEmpty) {
          _handleNewNotifications(newNotifications);
        }
      }
    });
  }

  void _handleNewNotifications(List<CrewNotification> notifications) {
    setState(() {
      _notifications.addAll(notifications);
    });
    
    // Show toast notification for important notifications
    for (final notification in notifications) {
      if (notification.isImportant) {
        _showNotificationToast(notification);
      }
    }
    
    // Show brief notification panel preview
    _showNotificationPreview();
  }

  void _showNotificationToast(CrewNotification notification) {
    JJElectricalToast.showNotification(
      context: context,
      title: notification.title,
      message: notification.message,
      icon: notification.icon,
      color: notification.color,
    );
  }

  void _showNotificationPreview() {
    _fadeController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _fadeController.reverse();
      }
    });
  }

  void _toggleNotificationPanel() {
    setState(() {
      _showNotificationPanel = !_showNotificationPanel;
    });

    if (_showNotificationPanel) {
      _slideController.forward();
      // Mark notifications as read
      _markNotificationsAsRead();
    } else {
      _slideController.reverse();
    }
  }

  Future<void> _markNotificationsAsRead() async {
    // Mark all notifications as read in Firebase
    for (final notification in _notifications) {
      if (!notification.isRead) {
        await _markNotificationAsRead(notification.id);
      }
    }
    
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('crews')
          .doc(widget.crewId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (final notification in _notifications) {
        final docRef = FirebaseFirestore.instance
            .collection('crews')
            .doc(widget.crewId)
            .collection('notifications')
            .doc(notification.id);
        batch.delete(docRef);
      }
      
      await batch.commit();
      
      setState(() {
        _notifications.clear();
      });
    } catch (e) {
      JJElectricalToast.showError(
        context: context,
        message: 'Failed to clear notifications: $e',
      );
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Notification bell button
        Positioned(
          top: 16,
          right: 16,
          child: _buildNotificationBell(),
        ),
        
        // Notification panel
        if (_showNotificationPanel)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleNotificationPanel,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        
        if (_showNotificationPanel)
          Positioned(
            top: 80,
            right: 16,
            left: 16,
            bottom: 100,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildNotificationPanel(),
            ),
          ),
        
        // Notification preview
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Positioned(
                top: 80,
                right: 80,
                left: 80,
                child: _buildNotificationPreview(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationBell() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
    return GestureDetector(
      onTap: _toggleNotificationPanel,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.accentCopper.withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications,
                color: AppTheme.accentCopper,
                size: 24,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: AppTheme.primaryNavy,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNotificationHeader(),
          Expanded(
            child: _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.accentCopper.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications,
            color: AppTheme.accentCopper,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notifications',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAllNotifications,
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: AppTheme.accentCopper,
                ),
              ),
            ),
          IconButton(
            onPressed: _toggleNotificationPanel,
            icon: Icon(
              Icons.close,
              color: AppTheme.accentCopper,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: AppTheme.bodyText.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return NotificationCard(
          notification: notification,
          onTap: () {
            // Handle notification tap
            _markNotificationAsRead(notification.id);
            setState(() {
              _notifications = _notifications.map((n) => 
                  n.id == notification.id ? n.copyWith(isRead: true) : n
              ).toList();
            });
          },
        );
      },
    );
  }

  Widget _buildNotificationPreview() {
    if (_notifications.isEmpty) return const SizedBox.shrink();
    
    final latestNotification = _notifications.first;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            latestNotification.icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  latestNotification.title,
                  style: AppTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  latestNotification.message,
                  style: AppTheme.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying individual notifications.
class NotificationCard extends StatelessWidget {
  final CrewNotification notification;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? Colors.white.withOpacity(0.05)
            : AppTheme.accentCopper.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.isRead
              ? Colors.white.withOpacity(0.1)
              : AppTheme.accentCopper.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNotificationContent(),
                ),
                _buildNotificationTime(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: notification.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        notification.icon,
        color: notification.color,
        size: 20,
      ),
    );
  }

  Widget _buildNotificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: AppTheme.bodyText.copyWith(
                  color: Colors.white,
                  fontWeight: notification.isRead 
                      ? FontWeight.normal 
                      : FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          notification.message,
          style: AppTheme.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNotificationTime() {
    return Text(
      _formatTimestamp(notification.timestamp),
      style: AppTheme.caption.copyWith(
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Model for crew notifications.
class CrewNotification {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final bool isRead;
  final bool isImportant;
  final String? actionUrl;

  const CrewNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.timestamp,
    this.isRead = false,
    this.isImportant = false,
    this.actionUrl,
  });

  CrewNotification copyWith({
    String? id,
    String? title,
    String? message,
    IconData? icon,
    Color? color,
    DateTime? timestamp,
    bool? isRead,
    bool? isImportant,
    String? actionUrl,
  }) {
    return CrewNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isImportant: isImportant ?? this.isImportant,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'icon': icon.codePoint,
      'color': color.value,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'isImportant': isImportant,
      'actionUrl': actionUrl,
    };
  }

  factory CrewNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrewNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      icon: IconData(data['icon'] ?? 0xe7f5, fontFamily: 'MaterialIcons'),
      color: Color(data['color'] ?? 0xFFB45309),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      isImportant: data['isImportant'] ?? false,
      actionUrl: data['actionUrl'],
    );
  }
}

// Mock provider for notifications
final crewNotificationsProvider = StreamProvider.family<List<CrewNotification>, String>((ref, crewId) {
  // This would connect to Firebase Firestore for real-time notifications
  return Stream.value([]);
});
