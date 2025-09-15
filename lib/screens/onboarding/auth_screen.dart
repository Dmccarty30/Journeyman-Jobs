import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../navigation/app_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();
  
  // Sign Up Controllers
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();
  
  // Sign In Controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  
  bool _obscureSignUpPassword = true;
  bool _obscureSignUpConfirmPassword = true;
  bool _obscureSignInPassword = true;
  bool _isSignUpLoading = false;
  bool _isSignInLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    super.dispose();
  }

  // Validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _signUpPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }


  // Authentication Methods
  Future<void> _signUpWithEmail() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() => _isSignUpLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text,
      );

      // User profile will be set up in onboarding steps

      if (mounted) {
        _navigateToOnboarding();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'An error occurred during sign up';
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account already exists for this email.';
        } else if (e.code == 'invalid-email') {
          message = 'Please enter a valid email address.';
        }
        JJSnackBar.showError(context: context, message: message);
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSignUpLoading = false);
      }
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() => _isSignInLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text,
      );

      if (mounted) {
        _navigateToOnboarding();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Invalid email or password';
        if (e.code == 'user-not-found') {
          message = 'No account found for this email.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password.';
        } else if (e.code == 'invalid-email') {
          message = 'Please enter a valid email address.';
        } else if (e.code == 'user-disabled') {
          message = 'This account has been disabled.';
        }
        JJSnackBar.showError(context: context, message: message);
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSignInLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      // Initialize GoogleSignIn if not already done
      await GoogleSignIn.instance.initialize();
      
      // Try to authenticate the user
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        _navigateToOnboarding();
      }
    } on GoogleSignInException catch (e) {
      if (mounted) {
        String message = 'Failed to sign in with Google.';
        if (e.code == GoogleSignInExceptionCode.canceled) {
          message = 'Google sign in was canceled.';
        } else if (e.code == GoogleSignInExceptionCode.interrupted) {
          message = 'Sign in was interrupted. Please try again.';
        } else if (e.code == GoogleSignInExceptionCode.clientConfigurationError) {
          message = 'Configuration error. Please contact support.';
        }
        JJSnackBar.showError(
          context: context,
          message: message,
        );
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isAppleLoading = true);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      if (mounted) {
        _navigateToOnboarding();
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to sign in with Apple. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  void _navigateToOnboarding() {
    context.go(AppRouter.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      shape: BoxShape.circle,
                      boxShadow: [AppTheme.shadowMd],
                    ),
                    child: const Icon(
                      Icons.electrical_services,
                      size: 40,
                      color: AppTheme.white,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  Text(
                    'Join Journeyman Jobs',
                    style: AppTheme.displaySmall.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingSm),
                  
                  Text(
                    'Connect with electrical opportunities',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: [AppTheme.shadowSm],
                ),
                labelColor: AppTheme.primaryNavy,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: AppTheme.labelLarge,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Sign Up'),
                  Tab(text: 'Sign In'),
                ],
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSignUpForm(),
                  _buildSignInForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.spacingXl),
            
            // Email
            JJTextField(
              label: 'Email',
              controller: _signUpEmailController,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Password
            JJTextField(
              label: 'Password',
              controller: _signUpPasswordController,
              validator: _validatePassword,
              obscureText: _obscureSignUpPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureSignUpPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              onSuffixIconPressed: () {
                setState(() {
                  _obscureSignUpPassword = !_obscureSignUpPassword;
                });
              },
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Confirm Password
            JJTextField(
              label: 'Confirm Password',
              controller: _signUpConfirmPasswordController,
              validator: _validateConfirmPassword,
              obscureText: _obscureSignUpConfirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureSignUpConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              onSuffixIconPressed: () {
                setState(() {
                  _obscureSignUpConfirmPassword = !_obscureSignUpConfirmPassword;
                });
              },
            ),
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Sign Up Button
            JJPrimaryButton(
              text: 'Create Account',
              onPressed: _signUpWithEmail,
              isLoading: _isSignUpLoading,
              size: JJButtonSize.medium,
              isFullWidth: true,
              variant: JJButtonVariant.primary,
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            _buildSocialSignInButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.spacingXl),
            
            // Email
            JJTextField(
              label: 'Email',
              controller: _signInEmailController,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Password
            JJTextField(
              label: 'Password',
              controller: _signInPasswordController,
              validator: _validatePassword,
              obscureText: _obscureSignInPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureSignInPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              onSuffixIconPressed: () {
                setState(() {
                  _obscureSignInPassword = !_obscureSignInPassword;
                });
              },
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                  JJSnackBar.showError(
                    context: context,
                    message: 'Forgot password feature coming soon',
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.accentCopper,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Sign In Button
            JJPrimaryButton(
              text: 'Sign In',
              onPressed: _signInWithEmail,
              isLoading: _isSignInLoading,
              size: JJButtonSize.medium,
              isFullWidth: true,
              variant: JJButtonVariant.primary,
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            _buildSocialSignInButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSignInButtons() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Text(
                'or continue with',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingLg),
        
        // Google Sign In
        JJSocialSignInButton(
          text: 'Continue with Google',
          icon: const Icon(
            Icons.g_mobiledata,
            size: 24,
            color: AppTheme.errorRed,
          ),
          onPressed: _signInWithGoogle,
          isLoading: _isGoogleLoading,
        ),
        
        const SizedBox(height: AppTheme.spacingMd),
        
        // Apple Sign In (iOS only)
        if (Theme.of(context).platform == TargetPlatform.iOS)
          JJSocialSignInButton(
            text: 'Continue with Apple',
            icon: const Icon(
              Icons.apple,
              size: 24,
              color: AppTheme.black,
            ),
            onPressed: _signInWithApple,
            isLoading: _isAppleLoading,
          ),
      ],
    );
  }
}
