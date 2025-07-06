import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class SafetyCheckinScreen extends StatefulWidget {
  const SafetyCheckinScreen({super.key});

  @override
  State<SafetyCheckinScreen> createState() => _SafetyCheckinScreenState();
}

class _SafetyCheckinScreenState extends State<SafetyCheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isSubmitting = false;
  String _selectedStatus = 'Safe';
  
  final List<String> _safetyStatuses = [
    'Safe',
    'Minor Concern',
    'Major Concern',
    'Emergency',
  ];

  final List<Map<String, dynamic>> _safetyChecks = [
    {'label': 'PPE (Hard Hat, Safety Glasses, Gloves)', 'checked': false},
    {'label': 'Work Area Clear of Hazards', 'checked': false},
    {'label': 'Equipment Inspected', 'checked': false},
    {'label': 'Lockout/Tagout Procedures Followed', 'checked': false},
    {'label': 'Weather Conditions Acceptable', 'checked': false},
    {'label': 'Emergency Contacts Available', 'checked': false},
  ];

  Future<void> _submitCheckin() async {
    if (!_formKey.currentState!.validate()) return;

    // Verify at least one safety check is completed
    if (!_safetyChecks.any((check) => check['checked'])) {
      JJSnackBar.showError(
        context: context,
        message: 'Please complete at least one safety check.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final checkinData = {
        'userId': user?.uid,
        'userEmail': user?.email,
        'location': _locationController.text.trim(),
        'safetyStatus': _selectedStatus,
        'safetyChecks': _safetyChecks,
        'notes': _notesController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'checkinType': 'safety',
      };

      await FirebaseFirestore.instance
          .collection('safety_checkins')
          .add(checkinData);

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Safety check-in submitted successfully!',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to submit check-in. Please try again.',
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

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Safety Check-in',
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
                            color: AppTheme.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: JJElectricalIcons.hardHat(
                            size: AppTheme.iconLg,
                            color: AppTheme.successGreen,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Safety Check-in',
                                style: AppTheme.headlineSmall.copyWith(
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                'Ensure your safety and that of your crew members.',
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

              // Location and status
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location & Status',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    JJTextField(
                      label: 'Work Location',
                      controller: _locationController,
                      hintText: 'e.g., Main St Substation, Building 123',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your work location';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    Text(
                      'Safety Status',
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
                          value: _selectedStatus,
                          isExpanded: true,
                          items: _safetyStatuses.map((status) {
                            Color statusColor;
                            switch (status) {
                              case 'Safe':
                                statusColor = AppTheme.successGreen;
                                break;
                              case 'Minor Concern':
                                statusColor = Colors.orange;
                                break;
                              case 'Major Concern':
                                statusColor = AppTheme.errorRed;
                                break;
                              case 'Emergency':
                                statusColor = Colors.red.shade700;
                                break;
                              default:
                                statusColor = AppTheme.textPrimary;
                            }
                            
                            return DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSm),
                                  Text(
                                    status,
                                    style: AppTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
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

              // Safety checklist
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety Checklist',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      'Check all items that apply to your current work situation:',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    ..._safetyChecks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final check = entry.value;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        child: Row(
                          children: [
                            JJElectricalToggle(
                              isOn: check['checked'],
                              onChanged: (value) {
                                setState(() {
                                  _safetyChecks[index]['checked'] = value;
                                });
                              },
                              width: 50,
                              height: 30,
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Text(
                                check['label'],
                                style: AppTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Notes
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Notes',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    JJTextField(
                      label: 'Notes (Optional)',
                      controller: _notesController,
                      hintText: 'Any additional safety concerns or observations...',
                      maxLines: 4,
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    JJPrimaryButton(
                      text: 'Submit Check-in',
                      onPressed: _isSubmitting ? null : _submitCheckin,
                      isLoading: _isSubmitting,
                      isFullWidth: true,
                      icon: Icons.security,
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