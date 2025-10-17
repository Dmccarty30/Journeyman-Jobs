import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../navigation/app_router.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../../electrical_components/jj_snack_bar.dart';
import '../../services/firestore_service.dart';

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
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text,
      );

      final User? user = userCredential.user;
      if (user != null) {
        try {
          final FirestoreService firestoreService = FirestoreService();
          await firestoreService.createUser(
            uid: user.uid,
            userData: {
              'email': user.email,
            },
          );
        } catch (firestoreError) {
          if (mounted) {
            JJSnackBar.showError(
              context: context,
              message: 'Account created but profile setup failed. Please complete onboarding.',
            );
          }
        }
      }

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

      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final FirestoreService firestoreService = FirestoreService();
          final DocumentSnapshot userDoc = await firestoreService.getUser(user.uid);
          
          if (!userDoc.exists) {
            await firestoreService.createUser(
              uid: user.uid,
              userData: {
                'email': user.email,
              },
            );
            if (mounted) {
              _navigateToOnboarding();
            }
          } else {
            final String? onboardingStatus = userDoc.get('onboardingStatus');
            if (onboardingStatus == 'incomplete' || onboardingStatus == null) {
              if (mounted) {
                _navigateToOnboarding();
              }
            } else if (onboardingStatus == 'complete') {
              if (mounted) {
                context.go(AppRouter.home);
              }
            }
          }
        } catch (firestoreError) {
          if (mounted) {
            JJSnackBar.showError(
              context: context,
              message: 'Sign in successful but profile check failed. Please complete onboarding.',
            );
            _navigateToOnboarding();
          }
        }
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

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        try {
          final FirestoreService firestoreService = FirestoreService();
          final bool userExists = await firestoreService.userProfileExists(user.uid);
          
          if (!userExists) {
            await firestoreService.createUser(
              uid: user.uid,
              userData: {
                'email': user.email,
              },
            );
          }
        } catch (firestoreError) {
          if (mounted) {
            JJSnackBar.showError(
              context: context,
              message: 'Google sign in successful but profile setup failed. Please complete onboarding.',
            );
          }
        }
      }

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

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final User? user = userCredential.user;

      if (user != null) {
        try {
          final FirestoreService firestoreService = FirestoreService();
          final bool userExists = await firestoreService.userProfileExists(user.uid);
          
          if (!userExists) {
            await firestoreService.createUser(
              uid: user.uid,
              userData: {
                'email': user.email,
              },
            );
          }
        } catch (firestoreError) {
          if (mounted) {
            JJSnackBar.showError(
              context: context,
              message: 'Apple sign in successful but profile setup failed. Please complete onboarding.',
            );
          }
        }
      }

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
      backgroundColor: AppTheme.primaryNavy,
      body: Stack(
        children: [
          // Enhanced electrical circuit background
          const Positioned.fill(
            child: ElectricalCircuitBackground(
              opacity: 0.08,
              componentDensity: ComponentDensity.high,
              enableCurrentFlow: true,
              enableInteractiveComponents: true,
            ),
          ),
          SafeArea(
        child: Column(
          children: [
            // Enhanced header with electrical theming
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  // Enhanced logo with copper borders and glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentCopper,
                        width: AppTheme.borderWidthCopper,
                      ),
                      boxShadow: [
                        AppTheme.shadowElectricalSuccess,
                        BoxShadow(
                          color: AppTheme.accentCopper.withValues(alpha: 0.4),
                          blurRadius: 25,
                          spreadRadius: 3,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.electrical_services,
                      size: 50,
                      color: AppTheme.white,
                      shadows: [
                        Shadow(
                          color: AppTheme.accentCopper.withValues(alpha: 0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  Text(
                    'Join Journeyman Jobs',
                    style: AppTheme.displaySmall.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.8),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingSm),

                  Text(
                    'Connect with electrical opportunities',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Enhanced tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.accentCopper,
                  width: AppTheme.borderWidthCopperThin,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: [
                  AppTheme.shadowElectricalInfo,
                ],
              ),
              child: SegmentedTabBar(
                controller: _tabController,
                onTabChanged: (index) {
                  setState(() {
                    // Update any state if needed
                  });
                },
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
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: AppTheme.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: AppTheme.accentCopper,
            width: AppTheme.borderWidthCopperThin,
          ),
          boxShadow: [
            AppTheme.shadowElectricalInfo,
            BoxShadow(
              color: AppTheme.primaryNavy.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
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

              // Sign Up Button with electrical theming
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.accentCopper,
                    width: AppTheme.borderWidthCopper,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: [
                    AppTheme.shadowElectricalSuccess,
                  ],
                ),
                child: JJPrimaryButton(
                  text: 'Create Account',
                  onPressed: _signUpWithEmail,
                  isLoading: _isSignUpLoading,
                  isFullWidth: true,
                  variant: JJButtonVariant.primary,
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              _buildSocialSignInButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: AppTheme.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: AppTheme.accentCopper,
            width: AppTheme.borderWidthCopperThin,
          ),
          boxShadow: [
            AppTheme.shadowElectricalInfo,
            BoxShadow(
              color: AppTheme.primaryNavy.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
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
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.accentCopper.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Sign In Button with electrical theming
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.accentCopper,
                    width: AppTheme.borderWidthCopper,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: [
                    AppTheme.shadowElectricalSuccess,
                  ],
                ),
                child: JJPrimaryButton(
                  text: 'Sign In',
                  onPressed: _signInWithEmail,
                  isLoading: _isSignInLoading,
                  isFullWidth: true,
                  variant: JJButtonVariant.primary,
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              _buildSocialSignInButtons(),
            ],
          ),
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

// Add this new widget class to your file (place it after the _AuthScreenState class)
class SegmentedTabBar extends StatefulWidget {
  final TabController controller;
  final Function(int) onTabChanged;

  const SegmentedTabBar({
    Key? key,
    required this.controller,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  State<SegmentedTabBar> createState() => _SegmentedTabBarState();
}

class _SegmentedTabBarState extends State<SegmentedTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.controller.index;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurveTween(curve: Curves.easeInOut).animate(_animationController));

    widget.controller.addListener(_handleTabControllerTick);
  }

  void _handleTabControllerTick() {
    if (widget.controller.index != _currentIndex) {
      setState(() {
        _currentIndex = widget.controller.index;
      });
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_handleTabControllerTick);
    super.dispose();
  }

  LinearGradient _getGradient(int index) {
    if (index == 0) {
      // Sign Up: Orange on left, Navy on right
      return const LinearGradient(
        colors: [AppTheme.accentCopper, AppTheme.secondaryCopper, AppTheme.primaryNavy],
      );
    } else {
      // Sign In: Navy on left, Orange on right
      return const LinearGradient(
        colors: [AppTheme.primaryNavy, AppTheme.secondaryCopper, AppTheme.accentCopper],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
        boxShadow: [
          AppTheme.shadowElectricalInfo,
          BoxShadow(
            color: AppTheme.accentCopper.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd - 4),
            ),
          ),

          // Animated indicator
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double position = _currentIndex.toDouble();
              return Transform.translate(
                offset: Offset(position * (MediaQuery.of(context).size.width - 72) / 2, 0),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 72) / 2,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _getGradient(_currentIndex),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd - 4),
                    border: Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.3),
                        blurRadius: 35,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: AppTheme.accentCopper.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget.controller.animateTo(0);
                    widget.onTabChanged(0);
                  },
                  child: Text(
                    'Sign Up',
                    style: _currentIndex == 0
                        ? AppTheme.labelLarge.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: AppTheme.primaryNavy.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : AppTheme.labelLarge.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.accentCopper.withValues(alpha: 0.3),
                      AppTheme.accentCopper.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget.controller.animateTo(1);
                    widget.onTabChanged(1);
                  },
                  child: Text(
                    'Sign In',
                    style: _currentIndex == 1
                        ? AppTheme.labelLarge.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: AppTheme.primaryNavy.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : AppTheme.labelLarge.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
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
}