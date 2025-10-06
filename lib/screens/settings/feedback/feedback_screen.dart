import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';

/// A screen where users can submit feedback, bug reports, or feature requests.
///
/// This screen provides a structured form for users to provide valuable input,
/// which is then submitted to a Firestore collection for review.
class FeedbackScreen extends StatefulWidget {
  /// Creates a [FeedbackScreen].
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

/// The state for the [FeedbackScreen].
///
/// Manages the form state, controllers, and submission logic.
class _FeedbackScreenState extends State<FeedbackScreen> {
  /// A global key to uniquely identify the form and allow for validation.
  final _formKey = GlobalKey<FormState>();
  /// The controller for the subject input field.
  final _subjectController = TextEditingController();
  /// The controller for the main feedback message field.
  final _messageController = TextEditingController();
  /// The controller for the user's email address field.
  final _emailController = TextEditingController();
  
  /// The currently selected feedback category.
  String _selectedCategory = 'General';
  /// A flag to indicate if a submission is currently in progress.
  bool _isSubmitting = false;
  
  /// A list of predefined categories for the user to choose from.
  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'Job Search Issues',
    'App Performance',
    'User Interface',
    'Safety Features',
    'Local Union Support',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  /// Attempts to pre-fill the email field with the current user's email.
  void _loadUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!;
    }
  }

  /// Validates the form and submits the feedback data to Firestore.
  ///
  /// Handles the UI loading state and displays a success or error snackbar
  /// upon completion.
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final feedbackData = {
        'userId': user?.uid,
        'userEmail': _emailController.text.trim(),
        'category': _selectedCategory,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'open',
        'platform': 'mobile',
        'appVersion': '1.0.0', // In a real app, get this from package_info
      };

      await FirebaseFirestore.instance
          .collection('feedback')
          .add(feedbackData);

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Thank you! Your feedback has been submitted.',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to submit feedback. Please try again.',
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
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Send Feedback',
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
              // Header card with electrical theme
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCopper.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: JJElectricalIcons.hardHat(
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
                                'We Value Your Input',
                                style: AppTheme.headlineSmall.copyWith(
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                'Help us improve the Journeyman Jobs app for the IBEW community.',
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

              // Feedback form
              JJCard(
                backgroundColor: AppTheme.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback Details',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Category selection
                    Text(
                      'Category',
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
                          items: _categories.map((category) {
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

                    // Email field
                    JJTextField(
                      label: 'Your Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Subject field
                    JJTextField(
                      label: 'Subject',
                      controller: _subjectController,
                      hintText: 'Brief description of your feedback',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Message field
                    JJTextField(
                      label: 'Message',
                      controller: _messageController,
                      hintText: 'Please provide detailed feedback...',
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your feedback message';
                        }
                        if (value.trim().length < 10) {
                          return 'Please provide more detailed feedback (at least 10 characters)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Submit button
                    JJPrimaryButton(
                      text: 'Submit Feedback',
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      isLoading: _isSubmitting,
                      isFullWidth: true,
                      icon: Icons.send,
                      variant: JJButtonVariant.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Help card
              JJCard(
                backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.05),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryNavy,
                          size: AppTheme.iconMd,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Text(
                            'Your feedback helps us build better tools for electrical workers. We read every submission and use your input to prioritize improvements.',
                            style: AppTheme.bodyMedium.copyWith(
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
        ),
      ),
    );
  }
}