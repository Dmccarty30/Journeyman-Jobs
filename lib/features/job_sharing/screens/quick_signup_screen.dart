import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../models/job_model.dart';
import '../../../services/analytics_service.dart';

class QuickSignupScreen extends StatefulWidget {
  final String shareId;
  final String jobId;
  final Job? preloadedJob;

  const QuickSignupScreen({
    super.key,
    required this.shareId,
    required this.jobId,
    this.preloadedJob,
  });

  @override
  State<QuickSignupScreen> createState() => _QuickSignupScreenState();
}

class _QuickSignupScreenState extends State<QuickSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  Job? _job;
  Map<String, dynamic>? _shareData;

  @override
  void initState() {
    super.initState();
    _loadShareAndJobData();
  }

  Future<void> _loadShareAndJobData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load share data
      final shareDoc = await FirebaseFirestore.instance
          .collection('shares')
          .doc(widget.shareId)
          .get();
      
      if (shareDoc.exists) {
        _shareData = shareDoc.data();
      }
      
      // Load job data if not preloaded
      if (widget.preloadedJob != null) {
        _job = widget.preloadedJob;
      } else {
        final jobDoc = await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .get();
        
        if (jobDoc.exists) {
          _job = Job.fromFirestore(jobDoc);
        }
      }
      
      // Pre-fill email if available from share link
      final uri = Uri.base;
      final email = uri.queryParameters['email'];
      if (email != null) {
        _emailController.text = email;
      }
      
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentCopper,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with job preview
                    _buildHeader(),
                    
                    const SizedBox(height: AppTheme.spacingXl),
                    
                    // Quick signup form
                    _buildSignupForm(),
                    
                    const SizedBox(height: AppTheme.spacingXl),
                    
                    // Already have account link
                    _buildLoginLink(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          padding: EdgeInsets.zero,
        ),
        
        const SizedBox(height: AppTheme.spacingMd),
        
        // Title with electrical theme
        Row(
          children: [
            Icon(
              Icons.bolt,
              color: AppTheme.accentCopper,
              size: AppTheme.iconLg,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Quick Signup',
              style: AppTheme.headingLarge.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingSm),
        
        // Subtitle with sharer info
        if (_shareData != null) ...[
          Text(
            '${_shareData!['sharerName']} shared this opportunity with you',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
        
        const SizedBox(height: AppTheme.spacingLg),
        
        // Job preview card
        if (_job != null) _buildJobPreview(),
      ],
    );
  }

  Widget _buildJobPreview() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentCopper.withValues(alpha: 0.1),
            AppTheme.accentCopper.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXs),
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: AppTheme.white,
                  size: AppTheme.iconSm,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  _job!.classification ?? 'Electrical Position',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          Text(
            '${_job!.company} • ${_job!.location}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Wage highlighting with electrical theme
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: AppTheme.iconXs,
                      color: AppTheme.white,
                    ),
                    Text(
                      '${_job!.wage?.toStringAsFixed(2) ?? 'TBD'}/hr',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_job!.perDiem != null) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.hotel,
                        size: AppTheme.iconXs,
                        color: AppTheme.white,
                      ),
                      Text(
                        '\$${_job!.perDiem} per diem',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.shadowMd],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Your Account',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Name fields
            Row(
              children: [
                Expanded(
                  child: JJTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Required';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: JJTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Required';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Email field
            JJTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Phone field (optional)
            JJTextField(
              controller: _phoneController,
              label: 'Phone (Optional)',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Password field
            JJTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: _obscurePassword,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Password is required';
                }
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword 
                      ? Icons.visibility_outlined 
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSignup(),
            ),
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Submit button with electrical theme
            JJPrimaryButton(
              text: 'Create Account & Apply',
              icon: Icons.rocket_launch_outlined,
              onPressed: _handleSignup,
              isLoading: _isLoading,
              isFullWidth: true,
              size: JJButtonSize.large,
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Terms text
            Text(
              'By creating an account, you agree to our Terms of Service and Privacy Policy',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Navigate to login screen with share context
          Navigator.pushReplacementNamed(
            context,
            '/auth',
            arguments: {
              'shareId': widget.shareId,
              'jobId': widget.jobId,
            },
          );
        },
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            children: [
              TextSpan(
                text: 'Sign In',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Create Firebase Auth account
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(
        '${_firstNameController.text} ${_lastNameController.text}',
      );
      
      // Create user profile with job interest
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'signupSource': 'job_share',
        'shareId': widget.shareId,
        'initialJobInterest': widget.jobId,
        'onboardingStatus': 'quick_signup',
      });
      
      // Track share conversion
      await _trackShareConversion();
      
      // Auto-apply to job
      await _autoApplyToJob(credential.user!.uid);
      
      // Navigate to job details or success page
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/jobs', // Navigate to jobs list where they can see their application
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Account created! You\'ve been automatically applied to this job.',
            ),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please sign in instead.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak. Please use a stronger password.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An error occurred. Please try again.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _trackShareConversion() async {
    try {
      // Update share status
      final shareRef = FirebaseFirestore.instance
          .collection('shares')
          .doc(widget.shareId);
      
      final shareDoc = await shareRef.get();
      if (shareDoc.exists) {
        final recipients = List<Map<String, dynamic>>.from(
          shareDoc.data()!['recipients'] ?? [],
        );
        
        // Find and update recipient status
        for (var recipient in recipients) {
          if (recipient['identifier'] == _emailController.text.trim()) {
            recipient['status'] = 'applied';
            recipient['appliedAt'] = Timestamp.now();
            recipient['userId'] = FirebaseAuth.instance.currentUser?.uid;
            break;
          }
        }
        
        await shareRef.update({'recipients': recipients});
      }
      
      // Track analytics
      await AnalyticsService.instance.logEvent('share_conversion', {
        'shareId': widget.shareId,
        'jobId': widget.jobId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      // Don't fail signup if analytics fail
    }
  }

  Future<void> _autoApplyToJob(String userId) async {
    try {
      // Create job application
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': userId,
        'jobId': widget.jobId,
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
        'source': 'job_share',
        'shareId': widget.shareId,
        'autoApplied': true,
        'applicationData': {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      });
    } catch (e) {
      // Don't fail signup if auto-apply fails
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Custom text field component that matches app theme
class JJTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const JJTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textSecondary,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.offWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
      ),
    );
  }
}
