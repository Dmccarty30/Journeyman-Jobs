import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class HazardReportScreen extends StatefulWidget {
  const HazardReportScreen({super.key});

  @override
  State<HazardReportScreen> createState() => _HazardReportScreenState();
}

class _HazardReportScreenState extends State<HazardReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _actionsTakenController = TextEditingController();
  
  bool _isSubmitting = false;
  String _selectedSeverity = 'Low';
  String _selectedCategory = 'Electrical';
  
  final List<String> _severityLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  final List<String> _hazardCategories = [
    'Electrical',
    'Fall Protection',
    'Equipment',
    'Environmental',
    'Chemical',
    'Fire/Explosion',
    'Other',
  ];

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final reportData = {
        'userId': user?.uid,
        'userEmail': user?.email,
        'location': _locationController.text.trim(),
        'category': _selectedCategory,
        'severity': _selectedSeverity,
        'description': _descriptionController.text.trim(),
        'actionsTaken': _actionsTakenController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'reported',
        'reportType': 'hazard',
      };

      await FirebaseFirestore.instance
          .collection('hazard_reports')
          .add(reportData);

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Hazard report submitted successfully. Safety team will be notified.',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to submit report. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Low':
        return AppTheme.successGreen;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return AppTheme.errorRed;
      case 'Critical':
        return Colors.red.shade700;
      default:
        return AppTheme.textPrimary;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _actionsTakenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Report Hazard',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(
                            Icons.warning,
                            size: AppTheme.iconLg,
                            color: AppTheme.errorRed,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hazard Reporting',
                                style: AppTheme.headlineSmall.copyWith(
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                'Report safety hazards to protect yourself and your crew.',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Basic information
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hazard Information',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    JJTextField(
                      label: 'Location',
                      controller: _locationController,
                      hintText: 'Specific location where hazard was observed',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the hazard location';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Category selection
                    Text(
                      'Hazard Category',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.mediumGray),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _hazardCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: AppTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Severity selection
                    Text(
                      'Severity Level',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.mediumGray),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSeverity,
                          isExpanded: true,
                          items: _severityLevels.map((severity) {
                            return DropdownMenuItem(
                              value: severity,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getSeverityColor(severity),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSm),
                                  Text(
                                    severity,
                                    style: AppTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSeverity = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Description
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    JJTextField(
                      label: 'Hazard Description',
                      controller: _descriptionController,
                      hintText: 'Provide detailed description of the hazard...',
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe the hazard';
                        }
                        if (value.trim().length < 20) {
                          return 'Please provide more detailed description (at least 20 characters)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    JJTextField(
                      label: 'Immediate Actions Taken (Optional)',
                      controller: _actionsTakenController,
                      hintText: 'What immediate actions were taken to address the hazard?',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Submit button
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  children: [
                    if (_selectedSeverity == 'Critical')
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emergency,
                              color: Colors.red.shade700,
                              size: AppTheme.iconMd,
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Text(
                                'Critical hazards require immediate attention. Consider contacting emergency services if there is immediate danger.',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    JJPrimaryButton(
                      text: 'Submit Hazard Report',
                      onPressed: _isSubmitting ? null : _submitReport,
                      isLoading: _isSubmitting,
                      isFullWidth: true,
                      icon: Icons.report_problem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}