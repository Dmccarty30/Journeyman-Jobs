import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../design_system/app_theme.dart';
import 'notification_popup.dart';

/// A notification icon with badge counter that can be used in app bars
class NotificationBadge extends StatelessWidget {
  /// Optional color for the icon
  final Color? iconColor;
  
  /// Size of the icon
  final double iconSize;
  
  /// Whether to show the popup on tap
  final bool showPopupOnTap;
  
  /// Custom onTap callback (overrides showPopupOnTap)
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    this.iconColor,
    this.iconSize = 24,
    this.showPopupOnTap = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Show icon without badge if not authenticated
      return IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor ?? AppTheme.white,
          size: iconSize,
        ),
        onPressed: () {
          // Could show a message to sign in
        },
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        int unreadCount = 0;
        
        if (snapshot.hasData) {
          unreadCount = snapshot.data!.docs.length;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                unreadCount > 0 
                    ? Icons.notifications_active 
                    : Icons.notifications_outlined,
                color: iconColor ?? AppTheme.white,
                size: iconSize,
              ),
              onPressed: onTap ?? (showPopupOnTap 
                  ? () => showNotificationPopup(context)
                  : null),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: _buildBadge(unreadCount),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: AppTheme.white,
            fontSize: count > 99 ? 8 : 10,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// A larger notification button with label for use in custom app bars
class NotificationButtonWithLabel extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const NotificationButtonWithLabel({
    super.key,
    this.label = 'Notifications',
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildButton(context, 0);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        int unreadCount = 0;
        
        if (snapshot.hasData) {
          unreadCount = snapshot.data!.docs.length;
        }

        return _buildButton(context, unreadCount);
      },
    );
  }

  Widget _buildButton(BuildContext context, int unreadCount) {
    return Material(
      color: backgroundColor ?? AppTheme.accentCopper.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        onTap: onTap ?? () => showNotificationPopup(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                unreadCount > 0 
                    ? Icons.notifications_active 
                    : Icons.notifications_outlined,
                color: textColor ?? AppTheme.accentCopper,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: textColor ?? AppTheme.accentCopper,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}