# Phase 4: Electrical-Specific Features Implementation - Detailed Tasks

## 📅 Week 4 Overview

**Goal**: Implement electrical worker-specific features including job sharing, safety alerts, location services, and electrical-themed customizations
**Duration**: 5 working days
**Priority**: High - Essential for industry-specific functionality

---

## Day 16: Job Sharing Integration

### Task 16.1: Job Model Integration

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Connect Existing Job Model** (1 hour)
   - [ ] Import canonical Job model from `lib/models/job_model.dart`
   - [ ] Create job attachment converter
   - [ ] Implement job serialization for chat
   - [ ] Add job metadata handling

2. **Job Attachment Creation** (1 hour)
   - [ ] Create JobAttachment model
   - [ ] Implement job preview widget
   - [ ] Add job summary display
   - [ ] Create job interaction buttons

3. **Job Data Sync** (1 hour)
   - [ ] Sync job status changes
   - [ ] Update job when applied
   - [ ] Handle job deletions
   - [ ] Maintain job references

**File: `job_attachment_widget.dart`**

```dart
class JobAttachmentWidget extends StatelessWidget {
  final Job job;
  final String? customMessage;
  final VoidCallback? onView;
  final VoidCallback? onApply;
  final VoidCallback? onShare;

  const JobAttachmentWidget({
    Key? key,
    required this.job,
    this.customMessage,
    this.onView,
    this.onApply,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentCopper.withValues(alpha:0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJobHeader(),
              _buildJobDetails(),
              _buildJobActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.work_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Opportunity',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentCopper,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (customMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    customMessage!,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getJobTypeColor().withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              job.classification ?? 'General',
              style: AppTheme.bodySmall.copyWith(
                color: _getJobTypeColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.company,
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.location_on_outlined,
            job.location,
          ),
          _buildDetailRow(
            Icons.attach_money,
            job.wage != null
                ? '\$${job.wage?.toStringAsFixed(2)}/hr'
                : 'Contact for rate',
          ),
          _buildDetailRow(
            Icons.groups_outlined,
            'IBEW Local ${job.local ?? 'N/A'}',
          ),
          if (job.jobDetails['construction_type'] != null) ...[
            _buildDetailRow(
              Icons.business_outlined,
              job.jobDetails['construction_type'],
            ),
          ],
          if (job.jobDetails['start_date'] != null) ...[
            _buildDetailRow(
              Icons.event_outlined,
              _formatDate(job.jobDetails['start_date']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textGrey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onView,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryNavy),
                foregroundColor: AppTheme.primaryNavy,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Apply Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onShare,
            icon: Icon(
              Icons.share_outlined,
              color: AppTheme.primaryNavy,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Color _getJobTypeColor() {
    switch (job.classification?.toLowerCase()) {
      case 'inside wireman':
      case 'inside journeyman electrician':
        return Colors.blue;
      case 'journeyman lineman':
        return Colors.orange;
      case 'tree trimmer':
        return Colors.green;
      case 'equipment operator':
        return Colors.purple;
      default:
        return AppTheme.accentCopper;
    }
  }

  String _formatDate(dynamic date) {
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        return DateFormat('MMM d, yyyy').format(parsed);
      }
    }
    return date?.toString() ?? 'ASAP';
  }
}
```

**Acceptance Criteria**:

- Job model integrates without conflicts
- Job attachments display correctly
- Job data syncs with changes
- Apply/Share functions work

---

### Task 16.2: Job Sharing Features

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Share to Crew** (1 hour)
   - [ ] Create job sharing flow
   - [ ] Add crew selection dialog
   - [ ] Implement job message creation
   - [ ] Add sharing analytics

2. **Quick Share** (1 hour)
   - [ ] Add share button to job details
   - [ ] Create share sheet
   - [ ] Support multiple crews
   - [ ] Add custom message option

3. **Job Interaction Tracking** (1 hour)
   - [ ] Track job views
   - [ ] Count applications
     - [ ] Monitor shares
     - [ ] Update job status

**Acceptance Criteria**:

- Jobs share to multiple crews
- Custom messages add to shares
- Interactions tracked accurately
- Analytics update correctly

---

## Day 17: Safety Alert System

### Task 17.1: Safety Alert Implementation

**Estimated Time**: 4 hours
**Priority**: High

#### Subtasks

1. **Alert Types & Levels** (1.5 hours)
   - [ ] Define alert severity levels (Critical, High, Medium, Low)
   - [ ] Create alert categories (Weather, Site, Equipment, Medical)
   - [ ] Implement alert priority system
   - [ ] Add alert escalation rules

2. **Alert Creation** (1.5 hours)
   - [ ] Create safety alert dialog
   - [ ] Add quick alert templates
   - [ ] Implement location selection
     - [ ] Add required acknowledgment

3. **Alert Distribution** (1 hour)
   - [ ] Send to affected crews
   - [ ] Push to all nearby workers
   - [ ] Send to union local
   - [ ] Update safety dashboard

**File: `safety_alert_service.dart`**

```dart
class SafetyAlertService {
  final StreamChatService _chatService;
  final LocationService _locationService;
  final NotificationService _notificationService;

  SafetyAlertService(
    this._chatService,
    this._locationService,
    this._notificationService,
  );

  Future<Either<ChatException, void>> sendSafetyAlert({
    required SafetyAlertType alertType,
    required AlertSeverity severity,
    required String location,
    required String description,
    List<String>? affectedCrewIds,
    double? latitude,
    double? longitude,
    int? radius, // in miles
    String? contactPerson,
    String? contactPhone,
    List<String>? requiredActions,
    bool requiresAcknowledgment = true,
  }) async {
    try {
      // Create alert attachment
      final alertAttachment = SafetyAlertAttachment(
        id: const Uuid().v4(),
        type: alertType,
        severity: severity,
        location: location,
        description: description,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        contactPerson: contactPerson,
        contactPhone: contactPhone,
        requiredActions: requiredActions ?? [],
        requiresAcknowledgment: requiresAcknowledgment,
        createdAt: DateTime.now(),
        createdBy: _chatService.currentUserId!,
      );

      // Determine target channels
      final targetChannels = await _getTargetChannels(
        alertType,
        severity,
        affectedCrewIds,
        location,
        latitude,
        longitude,
        radius,
      );

      // Send to all target channels
      for (final channelId in targetChannels) {
        await _sendAlertToChannel(channelId, alertAttachment);
      }

      // Send push notification for critical alerts
      if (severity == AlertSeverity.critical) {
        await _sendCriticalNotification(alertAttachment);
      }

      // Log alert for compliance
      await _logSafetyAlert(alertAttachment);

      return const Right(null);
    } catch (e) {
      return Left(SafetyAlertException('Failed to send safety alert: $e'));
    }
  }

  Future<List<String>> _getTargetChannels(
    SafetyAlertType alertType,
    AlertSeverity severity,
    List<String>? affectedCrews,
    String location,
    double? latitude,
    double? longitude,
    int? radius,
  ) async {
    final targets = <String>{};

    // Add specific crews if provided
    if (affectedCrews != null) {
      targets.addAll(affectedCrews);
    }

    // Add nearby crews if location provided
    if (latitude != null && longitude != null && radius != null) {
      final nearbyCrews = await _locationService.getNearbyCrews(
        latitude,
        longitude,
        radius,
      );
      targets.addAll(nearbyCrews);
    }

    // Add general safety channel for high severity
    if (severity == AlertSeverity.critical || severity == AlertSeverity.high) {
      final safetyChannel = await _getOrCreateSafetyChannel();
      if (safetyChannel != null) {
        targets.add(safetyChannel);
      }
    }

    return targets.toList();
  }

  Future<String?> _getOrCreateSafetyChannel() async {
    // Try to find existing safety channel
    final channels = await _chatService.queryChannels(
      filter: Filter.and_([
        Filter.equal('type', 'feed'),
        Filter.equal('feed_type', 'safety_alert'),
      ]),
    );

    if (channels.isNotEmpty) {
      return channels.first.cid;
    }

    // Create new safety channel
    final result = await _chatService.createFeedChannel(
      feedName: 'Safety Alerts',
      feedType: FeedType.safety_alert,
      isPublic: false,
      moderators: [await _getUnionAdminId()],
    );

    return result.fold(
      (error) => null,
      (channel) => channel.cid,
    );
  }

  Future<void> _sendAlertToChannel(
    String channelId,
    SafetyAlertAttachment alert,
  ) async {
    final messageData = {
      'text': _generateAlertMessage(alert),
      'attachments': [alert.toJson()],
      'safety_alert': {
        'id': alert.id,
        'type': alert.type.value,
        'severity': alert.severity.value,
        'requires_acknowledgment': alert.requiresAcknowledgment,
      },
    };

    await _chatService.sendMessage(
      channelId: channelId,
      text: messageData['text'] as String,
      attachments: [alert.toStreamAttachment()],
    );
  }

  String _generateAlertMessage(SafetyAlertAttachment alert) {
    final icon = _getSeverityIcon(alert.severity);
    final type = alert.type.name.toUpperCase();
    return '$icon SAFETY ALERT: $type at ${alert.location}';
  }

  String _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return '🚨';
      case AlertSeverity.high:
        return '⚠️';
      case AlertSeverity.medium:
        return '⚡';
      case AlertSeverity.low:
        return 'ℹ️';
    }
  }

  Future<void> _sendCriticalNotification(SafetyAlertAttachment alert) async {
    await _notificationService.sendCriticalAlert(
      title: 'CRITICAL SAFETY ALERT',
      body: alert.description,
      data: {
        'type': 'safety_alert',
        'alertId': alert.id,
        'severity': alert.severity.value,
      },
    );
  }

  Future<void> acknowledgeAlert({
    required String alertId,
    required String userId,
    String? notes,
  }) async {
    try {
      // Update alert acknowledgment
      await _updateAlertAcknowledgment(alertId, userId, notes);

      // Notify channel members
      await _notifyAcknowledgment(alertId, userId);

      // Check if all required acknowledgments received
      await _checkAlertCompletion(alertId);
    } catch (e) {
      debugPrint('Error acknowledging alert: $e');
    }
  }

  Future<void> _updateAlertAcknowledgment(
    String alertId,
    String userId,
    String? notes,
  ) async {
    final alertRef = FirebaseFirestore.instance
        .collection('safety_alerts')
        .doc(alertId);

    await alertRef.update({
      'acknowledgments': FieldValue.arrayUnion([
        {
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
          'notes': notes,
        }
      ]),
    });
  }
}

enum SafetyAlertType {
  weather('weather'),
  siteHazard('site_hazard'),
  equipmentFailure('equipment_failure'),
  medical('medical'),
  powerOutage('power_outage'),
  structural('structural'),
  chemical('chemical'),
  other('other');

  const SafetyAlertType(this.value);
  final String value;
}

enum AlertSeverity {
  critical('critical', 4),
  high('high', 3),
  medium('medium', 2),
  low('low', 1);

  const AlertSeverity(this.value, this.level);
  final String value;
  final int level;
}

class SafetyAlertAttachment {
  final String id;
  final SafetyAlertType type;
  final AlertSeverity severity;
  final String location;
  final String description;
  final double? latitude;
  final double? longitude;
  final int? radius;
  final String? contactPerson;
  final String? contactPhone;
  final List<String> requiredActions;
  final bool requiresAcknowledgment;
  final DateTime createdAt;
  final String createdBy;

  const SafetyAlertAttachment({
    required this.id,
    required this.type,
    required this.severity,
    required this.location,
    required this.description,
    this.latitude,
    this.longitude,
    this.radius,
    this.contactPerson,
    this.contactPhone,
    this.requiredActions = const [],
    this.requiresAcknowledgment = true,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.value,
        'severity': severity.value,
        'location': location,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'contactPerson': contactPerson,
        'contactPhone': contactPhone,
        'requiredActions': requiredActions,
        'requiresAcknowledgment': requiresAcknowledgment,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
      };

  Attachment toStreamAttachment() {
    return Attachment(
      type: 'safety_alert',
      extraData: toJson(),
    );
  }
}
```

**Acceptance Criteria**:

- All alert types and levels work
- Alerts distribute to correct channels
- Critical alerts send push notifications
- Acknowledgment system functional

---

### Task 17.2: Safety Alert UI

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Alert Widget** (1.5 hours)
   - [ ] Create SafetyAlertWidget
   - [ ] Display alert with proper styling
   - [ ] Show severity with colors/icons
   - [ ] Add location indicator

2. **Alert Actions** (1 hour)
   - [ ] Add acknowledge button
   - [ ] Show acknowledgment status
   - [ ] Implement contact actions
   - [ ] Add view details option

3. **Alert History** (30 min)
   - [ ] Create alert history screen
   - [ ] Filter by type/severity
     - [ ] Show acknowledgment status
     - [ ] Export for compliance

**Acceptance Criteria**:

- Alerts display prominently
- Acknowledgment easy to complete
- Contact information accessible
- History tracks all alerts

---

## Day 18: Location Features

### Task 18.1: Location Sharing

**Estimated Time**: 3 hours
**Priority**: Medium

#### Subtasks

1. **Location Picker** (1 hour)
   - [ ] Create location picker dialog
   - [ ] Add map integration
   - [ ] Implement search
   - [ ] Save favorite locations

2. **Location Sharing** (1 hour)
   - [ ] Share current location
   - [ ] Share job site location
     - [ ] Share temporary location
     - [ ] Auto-expire locations

3. **Location Privacy** (1 hour)
   - [ ] Add privacy settings
   - [ ] Require permission
   - [ ] Show who can see location
   - [ ] Add location blur option

**File: `location_share_widget.dart`**

```dart
class LocationShareWidget extends StatefulWidget {
  final LocationShare location;
  final bool isOwnLocation;
  final VoidCallback? onNavigate;
  final VoidCallback? onShare;

  const LocationShareWidget({
    Key? key,
    required this.location,
    this.isOwnLocation = false,
    this.onNavigate,
    this.onShare,
  }) : super(key: key);

  @override
  State<LocationShareWidget> createState() => _LocationShareWidgetState();
}

class _LocationShareWidgetState extends State<LocationShareWidget> {
  bool _showFullMap = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationHeader(),
            if (_showFullMap) ...[
              _buildMapPreview(),
            ] else ...[
              _buildLocationPreview(),
            ],
            _buildLocationActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.location.name ?? 'Shared Location',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.location.address != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.location.address!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.location.expiresAt != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Expires ${_formatExpiration(widget.location.expiresAt!)}',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationPreview() {
    return GestureDetector(
      onTap: () => setState(() => _showFullMap = true),
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Stack(
          children: [
            // Static map preview
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(
                    _getStaticMapUrl(),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Location marker overlay
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // Tap to expand hint
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to expand',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId(widget.location.id),
            position: LatLng(
              widget.location.latitude,
              widget.location.longitude,
            ),
            infoWindow: InfoWindow(
              title: widget.location.name ?? 'Location',
              snippet: widget.location.address,
            ),
          ),
        },
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      ),
    );
  }

  Widget _buildLocationActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onNavigate,
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Navigate'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.isOwnLocation) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateLocation(),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Update'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _stopSharing(),
                icon: const Icon(Icons.stop_outlined),
                label: const Text('Stop Sharing'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onShare,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentCopper),
                  foregroundColor: AppTheme.accentCopper,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStaticMapUrl() {
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=${widget.location.latitude},${widget.location.longitude}'
        '&zoom=15'
        '&size=600x200'
        '&markers=color:red%7C${widget.location.latitude},${widget.location.longitude}'
        '&key=${GoogleMapsConfig.apiKey}';
  }

  String _formatExpiration(DateTime expiresAt) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);

    if (diff.inHours < 1) {
      return '${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hr';
    } else {
      return '${diff.inDays} days';
    }
  }

  void _updateLocation() {
    // Update location functionality
  }

  void _stopSharing() {
    // Stop sharing functionality
  }
}
```

**Acceptance Criteria**:

- Location picker shows map
- Locations share with proper permissions
- Privacy settings enforced
- Navigation launches correctly

---

### Task 18.2: Job Site Features

**Estimated Time**: 2 hours
**Priority**: Medium

#### Subtasks

1. **Check-in System** (1 hour)
   - [ ] Create check-in/check-out
   - [ ] Track time on site
   - [ ] Add photo verification
   - [ ] Generate time sheets

2. **Crew Location Map** (1 hour)
   - [ ] Show all crew members
   - [ ] Update in real-time
   - [ ] Add proximity alerts
     - [ ] Export location history

**Acceptance Criteria**:

- Check-in system works
- Time tracking accurate
- Crew map updates live
- Privacy maintained

---

## Day 19: Electrical-Themed Customization

### Task 19.1: Electrical UI Elements

**Estimated Time**: 4 hours
**Priority**: Medium

#### Subtasks

1. **Circuit Pattern Backgrounds** (1.5 hours)
   - [ ] Create CircuitPatternPainter
   - [ ] Add animated circuits
   - [ ] Implement power flow animation
   - [ ] Create voltage color themes

2. **Lightning Animations** (1.5 hours)
   - [ ] Create lightning bolt animations
   - [ ] Add electrical pulse effects
     - [ ] Implement charging animations
     - [ ] Create power-on transitions

3. **Electrical Color Scheme** (1 hour)
   - [ ] Define electrical color palette
   - [ ] Add voltage-based colors
     - [ ] Create hazard color coding
     - [ ] Implement dark/light themes

**File: `circuit_pattern_background.dart`**

```dart
class CircuitPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Animation<double> animation;
  final bool showPowerFlow;

  CircuitPatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.animation,
    this.showPowerFlow = true,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha:0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final powerPaint = Paint()
      ..color = secondaryColor.withValues(alpha:0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw horizontal circuits
    for (double y = 0; y < size.height; y += 40) {
      _drawHorizontalCircuit(canvas, paint, 0, y, size.width);
    }

    // Draw vertical circuits
    for (double x = 0; x < size.width; x += 40) {
      _drawVerticalCircuit(canvas, paint, x, 0, size.height);
    }

    // Draw circuit nodes
    for (double x = 20; x < size.width; x += 40) {
      for (double y = 20; y < size.height; y += 40) {
        _drawCircuitNode(canvas, paint, x, y);
      }
    }

    // Animate power flow if enabled
    if (showPowerFlow) {
      _drawPowerFlow(canvas, powerPaint, size);
    }
  }

  void _drawHorizontalCircuit(Canvas canvas, Paint paint, double x, double y, double width) {
    final path = Path();
    path.moveTo(x, y);

    // Draw circuit path with breaks
    double currentX = x;
    while (currentX < width) {
      currentX += 10;
      path.lineTo(currentX, y);
      currentX += 10;
      path.moveTo(currentX, y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawVerticalCircuit(Canvas canvas, Paint paint, double x, double y, double height) {
    final path = Path();
    path.moveTo(x, y);

    // Draw circuit path with breaks
    double currentY = y;
    while (currentY < height) {
      currentY += 10;
      path.lineTo(x, currentY);
      currentY += 10;
      path.moveTo(x, currentY);
    }

    canvas.drawPath(path, paint);
  }

  void _drawCircuitNode(Canvas canvas, Paint paint, double x, double y) {
    canvas.drawCircle(
      Offset(x, y),
      3,
      paint,
    );

    // Draw connection points
    final nodePaint = Paint()
      ..color = primaryColor.withValues(alpha:0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 2, nodePaint);
  }

  void _drawPowerFlow(Canvas canvas, Paint paint, Size size) {
    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Animate dots along circuit paths
    final progress = animation.value;
    final totalDots = 20;

    for (int i = 0; i < totalDots; i++) {
      final dotProgress = ((progress + (i / totalDots)) % 1.0);
      final offset = _calculatePowerFlowOffset(dotProgress, size);

      canvas.drawCircle(offset, 3, dotPaint);

      // Draw glow effect
      final glowPaint = Paint()
        ..color = secondaryColor.withValues(alpha:0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(offset, 8, glowPaint);
    }
  }

  Offset _calculatePowerFlowOffset(double progress, Size size) {
    // Calculate position along circuit path
    final totalLength = (size.width + size.height) * 2;
    final currentLength = totalLength * progress;

    if (currentLength < size.width) {
      // Top edge
      return Offset(currentLength, 0);
    } else if (currentLength < size.width + size.height) {
      // Right edge
      return Offset(size.width, currentLength - size.width);
    } else if (currentLength < size.width * 2 + size.height) {
      // Bottom edge
      return Offset(size.width - (currentLength - size.width - size.height), size.height);
    } else {
      // Left edge
      return Offset(0, size.height - (currentLength - size.width * 2 - size.height));
    }
  }

  @override
  bool shouldRepaint(covariant CircuitPatternPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        primaryColor != oldDelegate.primaryColor ||
        secondaryColor != oldDelegate.secondaryColor ||
        showPowerFlow != oldDelegate.showPowerFlow;
  }
}

class AnimatedCircuitBackground extends StatefulWidget {
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool showPowerFlow;

  const AnimatedCircuitBackground({
    Key? key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
    this.showPowerFlow = true,
  }) : super(key: key);

  @override
  State<AnimatedCircuitBackground> createState() => _AnimatedCircuitBackgroundState();
}

class _AnimatedCircuitBackgroundState extends State<AnimatedCircuitBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: CircuitPatternPainter(
            primaryColor: widget.primaryColor ?? AppTheme.primaryNavy,
            secondaryColor: widget.secondaryColor ?? AppTheme.accentCopper,
            animation: _controller,
            showPowerFlow: widget.showPowerFlow,
          ),
          child: Container(),
        ),
        widget.child,
      ],
    );
  }
}
```

**Acceptance Criteria**:

- Circuit patterns animate smoothly
- Lightning effects trigger appropriately
- Color scheme consistent
- Performance maintained

---

### Task 19.2: Specialized Features

**Estimated Time**: 2 hours
**Priority**: Low

#### Subtasks

1. **Electrical Status Indicators** (30 min)
   - [ ] On Duty/Off Duty status
   - [ ] Job site status
   - [ ] Weather hold status
   - [ ] Emergency response status

2. **Safety Protocol Messages** (30 min)
   - [ ] Lockout/tagout procedures
   - [ ] Safety meeting reminders
     - [ ] PPE requirements
     - [ ] Toolbox talks

3. **Weather Integration** (1 hour)
   - [ ] Weather alert messages
   - [ ] Lightning detection alerts
     - [ ] Wind speed warnings
     - [ ] Storm tracking integration

**Acceptance Criteria**:

- Status indicators accurate
- Safety protocols accessible
- Weather alerts timely
- Integration seamless

---

## Day 20: Final Integration & Testing

### Task 20.1: End-to-End Integration

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **System Integration** (1.5 hours)
   - [ ] Connect all Phase 4 features
   - [ ] Test feature interactions
   - [ ] Verify data flow
   - [ ] Check error handling

2. **Performance Testing** (1 hour)
   - [ ] Test with large message volumes
   - [ ] Check memory usage
   - [ ] Verify battery consumption
     - [ ] Test network usage

3. **Field Testing** (30 min)
   - [ ] Test on low-end devices
   - [ ] Verify in poor network
   - [ ] Test with GPS disabled
     - [ ] Check offline behavior

**Acceptance Criteria**:

- All features work together
- Performance meets requirements
- Field conditions handled
- Graceful degradation

---

### Task 20.2: Documentation & Deployment

**Estimated Time**: 2 hours
**Priority**: High

#### Subtasks

1. **Feature Documentation** (1 hour)
   - [ ] Update user manual
   - [ ] Create admin guide
   - [ ] Document safety procedures
     - [ ] Write troubleshooting guide

2. **Deployment Preparation** (30 min)
   - [ ] Configure production settings
   - [ ] Set up monitoring
     - [ ] Prepare release notes
     - [ ] Create deployment checklist

**Acceptance Criteria**:

- Documentation complete
- Production ready
- Monitoring active
- Release prepared

---

## 🎯 Week 4 Deliverables

### Completed Features

1. ✅ Job sharing integration with existing Job model
2. ✅ Safety alert system with acknowledgment
3. ✅ Location sharing and privacy controls
4. ✅ Job site check-in/check-out
5. ✅ Electrical-themed UI elements
6. ✅ Circuit pattern animations
7. ✅ Weather integration
8. ✅ Safety protocol messages
9. ✅ Electrical status indicators
10. ✅ Field-ready performance optimization

### Working Components

- Jobs share seamlessly in chat
- Safety alerts distribute with acknowledgments
- Location sharing respects privacy
- Electrical theme enhances UX
- Field conditions handled gracefully

### Ready for Production

- All features tested
- Performance optimized
- Documentation complete
- Deployment ready

---

## ✅ Phase 4 Completion Checklist

### Electrical-Specific Features

- [ ] Job sharing fully functional
- [ ] Safety alert system active
- [ ] Location features working
- [ ] Electrical theme applied
- [ ] Weather integration live

### Quality Assurance

- [ ] Field testing complete
- [ ] Performance optimized
- [ ] Security verified
- [ ] Documentation up to date

### Production Readiness

- [ ] All features integrated
- [ ] Monitoring configured
- [ ] Release notes prepared
- [ ] Deployment checklist complete

---

## 🎉 Project Completion Summary

### What We've Built

1. **Complete Messaging System** - Full-featured chat with 1-on-1, crew, and feed messaging
2. **Electrical Worker Focus** - Industry-specific features and UI tailored for IBEW members
3. **Real-Time Collaboration** - Instant messaging, reactions, threading, and live updates
4. **Job Integration** - Seamless job sharing and application tracking
5. **Safety First** - Comprehensive safety alert system with acknowledgments
6. **Location Awareness** - Job site check-ins and crew location sharing
7. **Offline Support** - Works reliably in field conditions
8. **Electrical Theme** - Unique, professional UI that speaks to electrical workers

### Technical Achievements

- Clean Architecture implementation
- Stream Chat SDK integration
- Firebase backend connectivity
- Real-time synchronization
- Push notifications
- File attachments
- Offline persistence
- Performance optimization

### User Benefits

- Instant crew communication
- Quick job sharing and applications
- Life-saving safety alerts
- Job site coordination
- Offline reliability
- Professional electrical worker experience

This comprehensive messaging system is now ready to transform how IBEW electrical workers communicate, collaborate, and stay safe on the job.
