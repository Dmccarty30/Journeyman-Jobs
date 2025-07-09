import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../design_system/components/jj_electrical_toast.dart';
import '../../design_system/illustrations/electrical_illustrations.dart';
import '../../navigation/app_router.dart';
// import '../../../electrical_components/electrical_components.dart'; // Temporarily disabled
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.construction,
                  size: 20,
                  color: AppTheme.white,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Journeyman Jobs',
              style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.white),
            onPressed: () {
              context.push(AppRouter.notifications);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section with user data
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, authSnapshot) {
                if (!authSnapshot.hasData || authSnapshot.data == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: AppTheme.headlineMedium.copyWith(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        'Guest User',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  );
                }

                final user = authSnapshot.data!;
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String firstName = 'User';
                    String lastName = '';
                    String? photoUrl;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final userData = snapshot.data!.data() as Map<String, dynamic>?;
                      if (userData != null) {
                        firstName = userData['first_name'] ?? 'User';
                        lastName = userData['last_name'] ?? '';
                        photoUrl = userData['photo_url'];
                      }
                    }

                    return Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryNavy,
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null
                              ? Text(
                                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        // Welcome text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: AppTheme.headlineMedium.copyWith(
                                  color: AppTheme.primaryNavy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              Text(
                                '$firstName $lastName'.trim(),
                                style: AppTheme.bodyLarge.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notifications button
                        IconButton(
                          onPressed: () => context.push(AppRouter.notifications),
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.primaryNavy,
                            size: AppTheme.iconLg,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Quick actions
            Text(
              'Quick Actions',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Third row with electrical calc
            Row(
              children: [
                Expanded(
                  child: _buildElectricalActionCard(
                    'Electrical calc',
                    Icons.calculate_outlined,
                    () {
                      context.push(AppRouter.electricalCalculators);
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Container(), // Empty space to maintain grid layout
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Suggested Jobs
            Text(
              'Suggested Jobs',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Suggested job cards from Firestore
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, authSnapshot) {
                final user = authSnapshot.data;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('jobs')
                      .limit(10) // Limit initial query
                      .snapshots(),
                  builder: (context, jobSnapshot) {
                    if (jobSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!jobSnapshot.hasData || jobSnapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingLg),
                          child: Text(
                            'No jobs available at the moment',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    // Get user data for sorting
                    return StreamBuilder<DocumentSnapshot>(
                      stream: user != null
                          ? FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots()
                          : const Stream.empty(),
                      builder: (context, userSnapshot) {
                        Map<String, dynamic>? userData;
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        }

                        // Sort jobs based on user preferences
                        List<QueryDocumentSnapshot> sortedJobs = _sortJobsByUserPreferences(
                          jobSnapshot.data!.docs,
                          userData,
                        );

                        // Display sorted jobs
                        return Column(
                          children: sortedJobs.take(5).map((jobDoc) {
                            final jobData = jobDoc.data() as Map<String, dynamic>;
                            return GestureDetector(
                              onTap: () => _showJobDetailsDialog(context, jobData),
                              child: _buildSuggestedJobCard(
                                jobData['classification'] ?? 'General Electrical',
                                'Local ${jobData['local'] ?? 'N/A'}',
                                jobData['company'] ?? 'Company Name',
                                jobData['location'] ?? 'Location',
                                '\$${jobData['wage'] ?? '0'}/hr',
                                'Per Diem: \$${jobData['per_diem'] ?? '0'}/day',
                                isEmergency: jobData['construction_type'] == 'Emergency' ||
                                    jobData['construction_type'] == 'Storm',
                                isHighVoltage: jobData['classification']?.toString().toLowerCase().contains('transmission') ?? false,
                                hours: _parseHours(jobData['hours']),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: AppTheme.spacingXxl),
          ],
        ),
      ),
    );
  }

  /*
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppTheme.iconMd),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            value,
            style: AppTheme.displaySmall.copyWith(color: AppTheme.primaryNavy),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
  */

  /*
  Widget _buildJobCard(
    String title,
    String company,
    String location,
    String wage,
    String local, {
    bool isEmergency = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: JJCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEmergency) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: AppTheme.white,
                      size: AppTheme.iconXs,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      'STORM WORK',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
            ],
            Text(
              title,
              style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              company,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: AppTheme.iconSm,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  location,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                ),
                const Spacer(),
                Text(
                  wage,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.accentCopper,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    local,
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                JJSecondaryButton(
                  text: 'View Details',
                  onPressed: () {
                    // TODO: Navigate to job details
                  },
                  width: 120,
                  height: 36,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildElectricalActionCard(String title, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [AppTheme.shadowSm],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.white,
              size: AppTheme.iconLg,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedJobCard(
    String classification,
    String localNumber,
    String company,
    String location,
    String wage,
    String perDiem, {
    bool isEmergency = false,
    bool isHighVoltage = false,
    int hours = 40,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column with classification and local number
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEmergency) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingXs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isEmergency ? 'EMERGENCY' : 'STANDARD',
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingXs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCopper,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'STANDARD',
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      classification,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      localNumber,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Right column with location and wage info
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            location,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'Posted 2h ago',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'Hours: ${hours}hrs',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            perDiem,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningYellow,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Bid now',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sort jobs based on user preferences
  List<QueryDocumentSnapshot> _sortJobsByUserPreferences(
    List<QueryDocumentSnapshot> jobs,
    Map<String, dynamic>? userData,
  ) {
    if (userData == null) return jobs;

    final userClassification = userData['classification'] as String?;
    final preferredConstructionTypes = List<String>.from(userData['preferredConstructionTypes'] ?? []);
    final preferredHours = _parseHours(userData['preferredHours']);
    final perDiemRequired = _parseBool(userData['perDiemRequired']);

    // Create a list with sorting scores
    List<MapEntry<QueryDocumentSnapshot, int>> scoredJobs = jobs.map((job) {
      final jobData = job.data() as Map<String, dynamic>;
      int score = 0;

      // Priority 1: Classification match (highest weight)
      if (jobData['classification'] == userClassification) {
        score += 1000;
      }

      // Priority 2: Construction type match
      final jobConstructionType = jobData['constructionType'] as String?;
      if (jobConstructionType != null && preferredConstructionTypes.contains(jobConstructionType)) {
        score += 100;
      }

      // Priority 3: Hours match
      final jobHours = _parseHours(jobData['hours']);
      final hoursDifference = (jobHours - preferredHours).abs();
      score += math.max(0, 50 - hoursDifference);

      // Priority 4: Per diem match
      final jobHasPerDiem = _parseBool(jobData['perDiem']);
      if (perDiemRequired && jobHasPerDiem) {
        score += 25;
      } else if (!perDiemRequired && !jobHasPerDiem) {
        score += 10;
      }

      return MapEntry(job, score);
    }).toList();

    // Sort by score (descending)
    scoredJobs.sort((a, b) => b.value.compareTo(a.value));

    return scoredJobs.map((e) => e.key).toList();
  }

  // Show job details dialog
  void _showJobDetailsDialog(BuildContext context, Map<String, dynamic> jobData) {
    JJElectricalDialog.show(
      context: context,
      title: jobData['company'] ?? 'Job Details',
      subtitle: 'Local ${jobData['local'] ?? 'N/A'} • ${jobData['classification'] ?? 'N/A'}',
      illustration: ElectricalIllustration.jobSearch,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Local', jobData['local']?.toString() ?? 'N/A'),
            _buildDetailRow('Classification', jobData['classification'] ?? 'N/A'),
            _buildDetailRow('Location', jobData['location'] ?? 'N/A'),
            _buildDetailRow('Hours', '${jobData['hours'] ?? 'N/A'} hours/week'),
            _buildDetailRow('Wage', jobData['wage'] != null ? '\$${jobData['wage']}/hr' : 'N/A'),
            _buildDetailRow('Per Diem', _parseBool(jobData['perDiem']) ? 'Yes' : 'No'),
            _buildDetailRow('Construction Type', jobData['constructionType'] ?? 'N/A'),
            _buildDetailRow('Start Date', jobData['startDate'] ?? 'N/A'),
            _buildDetailRow('Duration', jobData['duration'] ?? 'N/A'),
            if (jobData['description'] != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Description',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                jobData['description'],
                style: AppTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showApplicationDialog(context, jobData);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryNavy,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  int _parseHours(dynamic hoursData) {
    if (hoursData is int) {
      return hoursData;
    } else if (hoursData is String) {
      return int.tryParse(hoursData) ?? 40;
    }
    return 40; // Default to 40 hours if data is null or unparseable
  }

  bool _parseBool(dynamic boolData) {
    if (boolData is bool) {
      return boolData;
    } else if (boolData is String) {
      return boolData.toLowerCase() == 'true' || boolData == '1';
    } else if (boolData is int) {
      return boolData == 1;
    }
    return false; // Default to false if data is null or unparseable
  }

  void _showApplicationDialog(BuildContext context, Map<String, dynamic> jobData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Apply for Job',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to apply for this position?',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobData['classification'] ?? 'Position',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      jobData['company'] ?? 'Company',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      jobData['location'] ?? 'Location',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitJobApplication(jobData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Submit Application'),
            ),
          ],
        );
      },
    );
  }

  void _submitJobApplication(Map<String, dynamic> jobData) {
    // Here you would typically submit the application to your backend
    // For now, we'll show a success message with electrical illustration
    JJSnackBar.showSuccess(
      context: context,
      message: 'Application submitted successfully for ${jobData['classification'] ?? 'the position'}!',
    );
  }
}