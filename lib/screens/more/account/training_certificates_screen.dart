import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';

class TrainingCertificatesScreen extends StatefulWidget {
  const TrainingCertificatesScreen({super.key});

  @override
  State<TrainingCertificatesScreen> createState() => _TrainingCertificatesScreenState();
}

class _TrainingCertificatesScreenState extends State<TrainingCertificatesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Certificate> _certificates = [
    Certificate(
      title: 'IBEW Journeyman Wireman',
      issuer: 'IBEW Local 46',
      issueDate: DateTime(2020, 3, 15),
      expiryDate: null,
      status: CertificateStatus.active,
      credentialId: 'JW-2020-1547',
      description: 'Inside Wireman Journeyman certification',
      category: 'IBEW Certifications',
    ),
    Certificate(
      title: 'OSHA 30-Hour Construction',
      issuer: 'OSHA Training Institute',
      issueDate: DateTime(2023, 1, 10),
      expiryDate: DateTime(2026, 1, 10),
      status: CertificateStatus.active,
      credentialId: 'OSHA30-2023-8821',
      description: 'Construction safety training certification',
      category: 'Safety Certifications',
    ),
    Certificate(
      title: 'Arc Flash Safety Training',
      issuer: 'NFPA Certified Instructor',
      issueDate: DateTime(2023, 6, 20),
      expiryDate: DateTime(2025, 6, 20),
      status: CertificateStatus.expiringSoon,
      credentialId: 'AFS-2023-4421',
      description: 'NFPA 70E Arc Flash and electrical safety',
      category: 'Safety Certifications',
    ),
    Certificate(
      title: 'First Aid/CPR',
      issuer: 'American Red Cross',
      issueDate: DateTime(2022, 8, 15),
      expiryDate: DateTime(2024, 8, 15),
      status: CertificateStatus.expired,
      credentialId: 'ARC-CPR-2022-9912',
      description: 'Basic life support and first aid training',
      category: 'Safety Certifications',
    ),
  ];

  final List<Course> _availableCourses = [
    Course(
      title: 'Advanced PLC Programming',
      provider: 'IBEW Training Center',
      duration: '40 hours',
      format: CourseFormat.inPerson,
      cost: '\$1,200',
      description: 'Advanced programmable logic controller programming and troubleshooting',
      category: 'Technical Training',
      startDate: DateTime(2024, 2, 15),
      location: 'Seattle Training Center',
      prerequisites: ['Basic PLC knowledge', 'Journeyman certification'],
    ),
    Course(
      title: 'Renewable Energy Systems',
      provider: 'NECA Education',
      duration: '24 hours',
      format: CourseFormat.online,
      cost: '\$800',
      description: 'Solar, wind, and battery storage system installation',
      category: 'Renewable Energy',
      startDate: DateTime(2024, 3, 1),
      location: 'Online',
      prerequisites: ['Basic electrical knowledge'],
    ),
    Course(
      title: 'Motor Control Fundamentals',
      provider: 'ABC Electrical Training',
      duration: '32 hours',
      format: CourseFormat.hybrid,
      cost: '\$950',
      description: 'Motor controls, VFDs, and industrial automation',
      category: 'Technical Training',
      startDate: DateTime(2024, 2, 28),
      location: 'Portland Training Facility',
      prerequisites: ['Journeyman certification'],
    ),
    Course(
      title: 'Code Update - NEC 2023',
      provider: 'IAEI',
      duration: '16 hours',
      format: CourseFormat.online,
      cost: '\$400',
      description: '2023 National Electrical Code changes and updates',
      category: 'Code Training',
      startDate: DateTime(2024, 1, 20),
      location: 'Online',
      prerequisites: ['Current electrical license'],
    ),
  ];

  final List<TrainingRecord> _trainingHistory = [
    TrainingRecord(
      courseName: 'Conduit Bending Mastery',
      completionDate: DateTime(2023, 11, 8),
      provider: 'IBEW Local 46',
      hoursCompleted: 16,
      grade: 'A',
      certificateEarned: true,
    ),
    TrainingRecord(
      courseName: 'High Voltage Safety',
      completionDate: DateTime(2023, 9, 22),
      provider: 'Safety Training Solutions',
      hoursCompleted: 8,
      grade: 'Pass',
      certificateEarned: true,
    ),
    TrainingRecord(
      courseName: 'Grounding and Bonding',
      completionDate: DateTime(2023, 7, 14),
      provider: 'Mike Holt Enterprises',
      hoursCompleted: 12,
      grade: 'B+',
      certificateEarned: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Training & Certificates',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCopper,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Certificates'),
            Tab(text: 'Courses'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCertificatesTab(),
          _buildCoursesTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildCertificatesTab() {
    final groupedCertificates = <String, List<Certificate>>{};
    for (final cert in _certificates) {
      groupedCertificates.putIfAbsent(cert.category, () => []).add(cert);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status summary
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [AppTheme.shadowSm],
            ),
            child: Row(
              children: [
                _buildStatusCard('Active', _certificates.where((c) => c.status == CertificateStatus.active).length, AppTheme.successGreen),
                const SizedBox(width: AppTheme.spacingMd),
                _buildStatusCard('Expiring', _certificates.where((c) => c.status == CertificateStatus.expiringSoon).length, AppTheme.warningYellow),
                const SizedBox(width: AppTheme.spacingMd),
                _buildStatusCard('Expired', _certificates.where((c) => c.status == CertificateStatus.expired).length, AppTheme.errorRed),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Certificates by category
          ...groupedCertificates.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: AppTheme.spacingSm, bottom: AppTheme.spacingSm),
                  child: Text(
                    entry.key,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: [AppTheme.shadowSm],
                  ),
                  child: Column(
                    children: entry.value.asMap().entries.map((certEntry) {
                      final index = certEntry.key;
                      final cert = certEntry.value;
                      final isLast = index == entry.value.length - 1;

                      return Column(
                        children: [
                          CertificateCard(certificate: cert),
                          if (!isLast) const Divider(height: 1, indent: AppTheme.spacingXl),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: AppTheme.headlineMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesTab() {
    final groupedCourses = <String, List<Course>>{};
    for (final course in _availableCourses) {
      groupedCourses.putIfAbsent(course.category, () => []).add(course);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.infoBlue, size: AppTheme.iconSm),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      'Available Training Courses',
                      style: AppTheme.titleMedium.copyWith(color: AppTheme.infoBlue),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Advance your skills with continuing education. Many courses qualify for CEU credits.',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.infoBlue),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Courses by category
          ...groupedCourses.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: AppTheme.spacingSm, bottom: AppTheme.spacingSm),
                  child: Text(
                    entry.key,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...entry.value.map((course) => CourseCard(course: course)),
                const SizedBox(height: AppTheme.spacingMd),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [AppTheme.shadowSm],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Statistics',
                  style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    _buildStatItem('Courses Completed', _trainingHistory.length.toString()),
                    const SizedBox(width: AppTheme.spacingLg),
                    _buildStatItem('Total Hours', _trainingHistory.fold(0, (sum, record) => sum + record.hoursCompleted).toString()),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Text(
            'Completed Training',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [AppTheme.shadowSm],
            ),
            child: Column(
              children: _trainingHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final record = entry.value;
                final isLast = index == _trainingHistory.length - 1;

                return Column(
                  children: [
                    TrainingHistoryCard(record: record),
                    if (!isLast) const Divider(height: 1, indent: AppTheme.spacingXl),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTheme.headlineLarge.copyWith(
            color: AppTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

enum CertificateStatus { active, expiringSoon, expired }
enum CourseFormat { inPerson, online, hybrid }

class Certificate {
  final String title;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final CertificateStatus status;
  final String credentialId;
  final String description;
  final String category;

  Certificate({
    required this.title,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    required this.status,
    required this.credentialId,
    required this.description,
    required this.category,
  });
}

class Course {
  final String title;
  final String provider;
  final String duration;
  final CourseFormat format;
  final String cost;
  final String description;
  final String category;
  final DateTime startDate;
  final String location;
  final List<String> prerequisites;

  Course({
    required this.title,
    required this.provider,
    required this.duration,
    required this.format,
    required this.cost,
    required this.description,
    required this.category,
    required this.startDate,
    required this.location,
    required this.prerequisites,
  });
}

class TrainingRecord {
  final String courseName;
  final DateTime completionDate;
  final String provider;
  final int hoursCompleted;
  final String grade;
  final bool certificateEarned;

  TrainingRecord({
    required this.courseName,
    required this.completionDate,
    required this.provider,
    required this.hoursCompleted,
    required this.grade,
    required this.certificateEarned,
  });
}

class CertificateCard extends StatelessWidget {
  final Certificate certificate;

  const CertificateCard({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCertificateDetails(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.verified,
                  color: _getStatusColor(),
                  size: AppTheme.iconMd,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.title,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      certificate.issuer,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: AppTheme.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: AppTheme.labelSmall.copyWith(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (certificate.expiryDate != null) ...[
                          const SizedBox(width: AppTheme.spacingSm),
                          Text(
                            'Expires: ${_formatDate(certificate.expiryDate!)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (certificate.status) {
      case CertificateStatus.active:
        return AppTheme.successGreen;
      case CertificateStatus.expiringSoon:
        return AppTheme.warningYellow;
      case CertificateStatus.expired:
        return AppTheme.errorRed;
    }
  }

  String _getStatusText() {
    switch (certificate.status) {
      case CertificateStatus.active:
        return 'Active';
      case CertificateStatus.expiringSoon:
        return 'Expiring Soon';
      case CertificateStatus.expired:
        return 'Expired';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showCertificateDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          certificate.title,
          style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Issuer', certificate.issuer),
            _buildDetailRow('Issue Date', _formatDate(certificate.issueDate)),
            if (certificate.expiryDate != null)
              _buildDetailRow('Expiry Date', _formatDate(certificate.expiryDate!)),
            _buildDetailRow('Credential ID', certificate.credentialId),
            _buildDetailRow('Description', certificate.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: certificate.credentialId));
              Navigator.pop(context);
              JJSnackBar.showSuccess(
                context: context,
                message: 'Credential ID copied to clipboard',
              );
            },
            child: const Text('Copy ID'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCourseDetails(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: _getFormatColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        _getFormatText(),
                        style: AppTheme.labelSmall.copyWith(
                          color: _getFormatColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  course.provider,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  course.description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: AppTheme.textLight),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      course.duration,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Icon(Icons.attach_money, size: 16, color: AppTheme.textLight),
                    Text(
                      course.cost,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                    ),
                    const Spacer(),
                    Text(
                      'Starts ${_formatDate(course.startDate)}',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getFormatColor() {
    switch (course.format) {
      case CourseFormat.inPerson:
        return AppTheme.primaryNavy;
      case CourseFormat.online:
        return AppTheme.successGreen;
      case CourseFormat.hybrid:
        return AppTheme.infoBlue;
    }
  }

  String _getFormatText() {
    switch (course.format) {
      case CourseFormat.inPerson:
        return 'In-Person';
      case CourseFormat.online:
        return 'Online';
      case CourseFormat.hybrid:
        return 'Hybrid';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  void _showCourseDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          course.title,
          style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.description,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _buildDetailRow('Provider', course.provider),
              _buildDetailRow('Duration', course.duration),
              _buildDetailRow('Format', _getFormatText()),
              _buildDetailRow('Cost', course.cost),
              _buildDetailRow('Start Date', '${course.startDate.month}/${course.startDate.day}/${course.startDate.year}'),
              _buildDetailRow('Location', course.location),
              if (course.prerequisites.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Prerequisites',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ...course.prerequisites.map((prereq) => Padding(
                  padding: const EdgeInsets.only(left: AppTheme.spacingSm),
                  child: Text(
                    '• $prereq',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              JJSnackBar.showSuccess(
                context: context,
                message: 'Course enrollment coming soon',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Enroll'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingHistoryCard extends StatelessWidget {
  final TrainingRecord record;

  const TrainingHistoryCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: record.certificateEarned ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.infoBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              record.certificateEarned ? Icons.verified : Icons.school,
              color: record.certificateEarned ? AppTheme.successGreen : AppTheme.infoBlue,
              size: AppTheme.iconSm,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.courseName,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  record.provider,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Row(
                  children: [
                    Text(
                      'Completed: ${record.completionDate.month}/${record.completionDate.day}/${record.completionDate.year}',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Text(
                      '${record.hoursCompleted}h',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Text(
                      'Grade: ${record.grade}',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}