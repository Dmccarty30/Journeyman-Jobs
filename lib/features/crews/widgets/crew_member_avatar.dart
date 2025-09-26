import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';

class CrewMemberAvatar extends StatelessWidget {
  final String memberName;
  final String? avatarUrl;
  final bool isOnline;
  final double size;
  final bool showStatus;

  const CrewMemberAvatar({
    super.key,
    required this.memberName,
    this.avatarUrl,
    this.isOnline = false,
    this.size = 48,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.accentCopper.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: AppTheme.accentCopper.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitials();
                    },
                  ),
                )
              : _buildInitials(),
        ),
        // Online Status Indicator
        if (showStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.successGreen : AppTheme.mediumGray,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(memberName);
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppTheme.accentCopper,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.35,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

class CrewMemberListItem extends StatelessWidget {
  final String memberName;
  final String? avatarUrl;
  final bool isOnline;
  final String role;
  final String? lastActive;
  final VoidCallback? onTap;

  const CrewMemberListItem({
    super.key,
    required this.memberName,
    this.avatarUrl,
    this.isOnline = false,
    required this.role,
    this.lastActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.borderLight.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CrewMemberAvatar(
              memberName: memberName,
              avatarUrl: avatarUrl,
              isOnline: isOnline,
              size: 48,
            ),
            const SizedBox(width: 12),
            // Member Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memberName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        role,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (lastActive != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lastActive!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Status
            Row(
              children: [
                if (isOnline)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Online',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.mediumGray.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Offline',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textLight,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}