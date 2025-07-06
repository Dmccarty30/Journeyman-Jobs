import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/job_model.dart';

class JobApplicationScreen extends StatefulWidget {
  final JobModel job;

  const JobApplicationScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _experienceController = TextEditingController();
  
  bool _isSubmitting = false;
  bool _hasRequiredCertifications = false;
  bool _willingToRelocate = false;
  bool _hasTransportation = true;
  
  final List<String> _certifications = [
    'OSHA 10',
    'OSHA 30',
    'First Aid/CPR',
    'Scaffold Competent Person',
    'Confined Space',
    'Aerial Lift',
    'Forklift',
    'Crane Operator',
  ];
  
  final List<String> _selectedCertifications = [];

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final applicationData = {
        'userId': user?.uid,
        'userEmail': user?.email,
        'jobId': widget.job.id,
        'jobTitle': widget.job.title,
        'company': widget.job.company,
        'location': widget.job.location,
        'coverLetter': _coverLetterController.text.trim(),
        'availability': _availabilityController.text.trim(),
        'experienceYears': _experienceController.text.trim(),
        'certifications': _selectedCertifications,
        'hasRequiredCertifications': _hasRequiredCertifications,
        'willingToRelocate': _willingToRelocate,
        'hasTransportation': _hasTransportation,
        'applicationDate': FieldValue.serverTimestamp(),
        'status': 'submitted',
        'applicationId': user?.uid != null ? '${user!.uid}_${widget.job.id}_${DateTime.now().millisecondsSinceEpoch}' : null,
      };

      await FirebaseFirestore.instance
          .collection('job_applications')
          .add(applicationData);

      // Also update the job record to track applications
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.job.id)
          .update({
        'applicantCount': FieldValue.increment(1),
        'lastApplicationDate': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Application submitted successfully! You will be contacted if selected.',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to submit application. Please try again.',
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
    _coverLetterController.dispose();
    _availabilityController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Apply for Job',
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
              // Job summary card
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCopper.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: JJElectricalIcons.transmissionTower(
                            size: AppTheme.iconLg,
                            color: AppTheme.accentCopper,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.title,
                                style: AppTheme.headlineSmall.copyWith(
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                widget.job.company,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                widget.job.location,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.job.payRange != null) ...[
                      const SizedBox(height: AppTheme.spacingMd),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: AppTheme.iconSm,
                              color: AppTheme.successGreen,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              widget.job.payRange!,
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Personal information
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Details',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    JJTextField(
                      label: 'Cover Letter / Why are you interested?',
                      controller: _coverLetterController,
                      hintText: 'Tell us why you\'re interested in this position and what makes you a good fit...',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide a cover letter';
                        }
                        if (value.trim().length < 50) {
                          return 'Please provide more detail (at least 50 characters)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    JJTextField(
                      label: 'Years of Electrical Experience',
                      controller: _experienceController,
                      hintText: 'e.g., 5 years',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your years of experience';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    JJTextField(
                      label: 'Availability',
                      controller: _availabilityController,
                      hintText: 'When can you start? Any scheduling constraints?',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide your availability';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Certifications
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certifications',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Select all certifications you currently hold:',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    Wrap(
                      spacing: AppTheme.spacingSm,
                      runSpacing: AppTheme.spacingSm,
                      children: _certifications.map((cert) {
                        final isSelected = _selectedCertifications.contains(cert);
                        return JJChip(
                          label: cert,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedCertifications.remove(cert);
                              } else {
                                _selectedCertifications.add(cert);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Additional questions
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Required certifications
                    Row(
                      children: [
                        JJElectricalToggle(
                          isOn: _hasRequiredCertifications,
                          onChanged: (value) {
                            setState(() {
                              _hasRequiredCertifications = value;
                            });
                          },
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Text(
                            'I have all required certifications for this position',
                            style: AppTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Willing to relocate
                    Row(
                      children: [
                        JJElectricalToggle(
                          isOn: _willingToRelocate,
                          onChanged: (value) {
                            setState(() {
                              _willingToRelocate = value;
                            });
                          },
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Text(
                            'I am willing to relocate for this position',
                            style: AppTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Has transportation
                    Row(
                      children: [
                        JJElectricalToggle(
                          isOn: _hasTransportation,
                          onChanged: (value) {
                            setState(() {
                              _hasTransportation = value;
                            });
                          },
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Text(
                            'I have reliable transportation to the job site',
                            style: AppTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Disclaimer
              JJCard(
                backgroundColor: AppTheme.primaryNavy.withOpacity(0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryNavy,
                          size: AppTheme.iconMd,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Text(
                          'Application Notice',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      'By submitting this application, you agree that the information provided is accurate. The employer will contact you directly if selected for an interview. Applications are processed according to IBEW referral procedures.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Submit button
              JJPrimaryButton(
                text: 'Submit Application',
                onPressed: _isSubmitting ? null : _submitApplication,
                isLoading: _isSubmitting,
                isFullWidth: true,
                icon: Icons.send,
              ),

              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}