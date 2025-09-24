import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No account found with this email address.';
            break;
          case 'invalid-email':
            _errorMessage = 'Please enter a valid email address.';
            break;
          case 'too-many-requests':
            _errorMessage = 'Too many requests. Please try again later.';
            break;
          default:
            _errorMessage = 'An error occurred. Please try again.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Reset Password',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingXl),
              
              // Header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: [AppTheme.shadowMd],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                        size: AppTheme.iconXl,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      _emailSent ? 'Check Your Email' : 'Forgot Your Password?',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      _emailSent
                          ? 'We\'ve sent password reset instructions to ${_emailController.text}'
                          : 'Don\'t worry! Enter your email address and we\'ll send you reset instructions.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              if (!_emailSent) ...[
                // Reset form
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: [AppTheme.shadowSm],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        JJTextField(
                          label: 'Email Address',
                          controller: _emailController,
                          focusNode: _emailFocus,
                          hintText: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email address is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _resetPassword(),
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppTheme.spacingMd),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorRed,
                                  size: AppTheme.iconSm,
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.errorRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: AppTheme.spacingXl),
                        
                        JJPrimaryButton(
                          text: 'Send Reset Instructions',
                          icon: Icons.send,
                          onPressed: _isLoading ? null : _resetPassword,
                          isFullWidth: true,
                          isLoading: _isLoading,
                          variant: JJButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Success state
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: [AppTheme.shadowSm],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: AppTheme.successGreen,
                                  size: AppTheme.iconSm,
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Expanded(
                                  child: Text(
                                    'Reset instructions sent successfully!',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.successGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              'Please check your email inbox and spam folder. Click the link in the email to reset your password.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      JJPrimaryButton(
                        text: 'Back to Sign In',
                        icon: Icons.login,
                        onPressed: () => Navigator.pop(context),
                        isFullWidth: true,
                        variant: JJButtonVariant.primary,
                      ),

                      const SizedBox(height: AppTheme.spacingMd),

                      JJSecondaryButton(
                        'Resend Email', // Added required positional argument
                        text: 'Resend Email',
                        icon: Icons.refresh,
                        onPressed: _isLoading ? null : () {
                          setState(() {
                            _emailSent = false;
                            _errorMessage = null;
                          });
                        },
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacingXl),

              // Help section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: AppTheme.infoBlue,
                          size: AppTheme.iconSm,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Need Help?',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.infoBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      '• Check your spam/junk folder for the reset email\n'
                      '• Make sure you entered the correct email address\n'
                      '• Reset links expire after 1 hour for security\n'
                      '• Contact support if you continue having issues',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.infoBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
        ),
      ),
    );
  }
}