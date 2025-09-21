import 'package:flutter/material.dart';
// For rootBundle
import '../../design_system/app_theme.dart' show AppTheme;
import '../../design_system/components/reusable_components.dart' show JJButton, JJButtonSize, JJButtonVariant;
import '../../models/storm_roster_signup.dart' show UnknownSignUp, MixedSignUp, RosterContractor, SignUpInfo, UrlSignUp, TextSignUp, PhoneSignUp, EmailSignUp;
import '../../services/roster_data_service.dart' show RosterDataService;
import 'package:url_launcher/url_launcher.dart';


class RosterSignupCarousel extends StatefulWidget {
  const RosterSignupCarousel({super.key});

  @override
  State<RosterSignupCarousel> createState() => _RosterSignupCarouselState();
}

class _RosterSignupCarouselState extends State<RosterSignupCarousel> {
  late PageController _pageController;
  List<RosterContractor> _contractors = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85, // Show adjacent cards partially
      initialPage: 0,
    );
    _loadContractorData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadContractorData() async {
    try {
      final data = await RosterDataService().loadRosterData();
      if (mounted) {
        setState(() {
          _contractors = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load contractor data: ${e.toString()}';
        });
      }
    }
  }

  // Helper to launch URLs, SMS, or phone calls
  Future<void> _launchAction(SignUpInfo signUpInfo) async {
    try {
      if (signUpInfo is UrlSignUp) {
        if (await canLaunchUrl(Uri.parse(signUpInfo.url))) {
          await launchUrl(Uri.parse(signUpInfo.url));
        } else {
          throw 'Could not launch ${signUpInfo.url}';
        }
      } else if (signUpInfo is TextSignUp) {
        final Uri smsLaunchUri = Uri(
          scheme: 'sms',
          path: signUpInfo.phoneNumber,
          queryParameters: {'body': signUpInfo.message},
        );
        if (await canLaunchUrl(smsLaunchUri)) {
          await launchUrl(smsLaunchUri);
        } else {
          throw 'Could not launch SMS to ${signUpInfo.phoneNumber}';
        }
      } else if (signUpInfo is PhoneSignUp) {
        final Uri phoneLaunchUri = Uri(scheme: 'tel', path: signUpInfo.phoneNumber);
        if (await canLaunchUrl(phoneLaunchUri)) {
          await launchUrl(phoneLaunchUri);
        } else {
          throw 'Could not launch phone call to ${signUpInfo.phoneNumber}';
        }
      } else if (signUpInfo is EmailSignUp) {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: signUpInfo.email,
        );
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        } else {
          throw 'Could not launch email to ${signUpInfo.email}';
        }
      } else if (signUpInfo is MixedSignUp) {
        // Handle mixed actions - prioritize URL if available, otherwise text
        if (signUpInfo.url != null && signUpInfo.url!.isNotEmpty) {
          if (await canLaunchUrl(Uri.parse(signUpInfo.url!))) {
            await launchUrl(Uri.parse(signUpInfo.url!));
          } else {
            throw 'Could not launch URL: ${signUpInfo.url}';
          }
        } else if (signUpInfo.text.isNotEmpty) {
          // For text-only mixed actions, we might need more specific parsing
          // or a default behavior like showing the text. For now, we'll just print.
          // Potentially show a dialog or snackbar with the text.
        }
      } else if (signUpInfo is UnknownSignUp) {
        // Show a dialog or snackbar indicating no specific action.
      }
    } catch (e) {
      ScaffoldMessenger.of(BuildContext as BuildContext).showSnackBar(
        SnackBar(content: Text('Could not perform action: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentCopper,
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_contractors.isEmpty) {
      return Center(
        child: Text(
          'No contractor sign-up information available.',
          style: AppTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Roster Sign-up',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SizedBox(
          height: 200, // Adjust height as needed for the cards
          child: PageView.builder(
            controller: _pageController,
            itemCount: _contractors.length,
            itemBuilder: (context, index) {
              final contractor = _contractors[index];
              return RosterContractorCard(contractor: contractor, onTap: () => _launchAction(contractor.signUpInfo));
            },
          ),
        ),
      ],
    );
  }
}

// Widget for a single flippable contractor card
class RosterContractorCard extends StatefulWidget {
  final RosterContractor contractor;
  final VoidCallback onTap;

  const RosterContractorCard({
    super.key,
    required this.contractor,
    required this.onTap,
  });

  @override
  State<RosterContractorCard> createState() => _RosterContractorCardState();
}

class _RosterContractorCardState extends State<RosterContractorCard> {
  bool _isFlipped = false;

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip, // Toggle flip on tap
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: Tween<double>(begin: 0.0, end: 0.5).animate(animation),
            child: child,
          );
        },
        child: _isFlipped ? _buildBackLayout(context) : _buildFrontLayout(context),
      ),
    );
  }

  Widget _buildFrontLayout(BuildContext context) {
    return Card(
      key: const ValueKey('front'),
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingMd),
      elevation: AppTheme.shadowSm.blurRadius, // Use shadow elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Company Name
            Text(
              widget.contractor.companyName,
              style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryNavy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            // Placeholder for logo if available
            Icon(
              Icons.business, // Placeholder icon
              size: 40,
              color: AppTheme.accentCopper,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Tap to see sign-up details',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackLayout(BuildContext context) {
    return Card(
      key: const ValueKey('back'),
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingMd),
      elevation: AppTheme.shadowSm.blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name
            Text(
              widget.contractor.companyName,
              style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryNavy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Sign-up Information
            _buildSignUpInfoSection(widget.contractor.signUpInfo),

            const Spacer(), // Pushes buttons to the bottom

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildActionButtons(widget.contractor.signUpInfo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpInfoSection(SignUpInfo info) {
    Widget content;
    if (info is UrlSignUp) {
      content = _buildInfoRow(Icons.link, 'Website', info.url);
    } else if (info is TextSignUp) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.phone, 'Phone', info.phoneNumber),
          const SizedBox(height: AppTheme.spacingSm),
          _buildInfoRow(Icons.message, 'Message', info.message),
        ],
      );
    } else if (info is PhoneSignUp) {
      content = _buildInfoRow(Icons.phone, 'Phone', info.phoneNumber);
    } else if (info is EmailSignUp) {
      content = _buildInfoRow(Icons.email, 'Email', info.email);
    } else if (info is MixedSignUp) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.text,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
          ),
          if (info.url != null && info.url!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingSm),
            _buildInfoRow(Icons.link, 'Website', info.url!),
          ],
        ],
      );
    } else if (info is UnknownSignUp) {
      content = _buildInfoRow(Icons.help_outline, 'Details', info.details);
    } else {
      content = const SizedBox.shrink(); // Should not happen
    }
    return content;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentCopper, size: AppTheme.iconSm),
        const SizedBox(width: AppTheme.spacingSm),
        Text('$label: ', style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary))),
      ],
    );
  }

  List<Widget> _buildActionButtons(SignUpInfo info) {
    List<Widget> buttons = [];

    if (info is UrlSignUp) {
      buttons.add(
        JJButton(
          text: 'Open Website',
          variant: JJButtonVariant.primary,
          icon: Icons.link,
          onPressed: () => widget.onTap(), // This will call _launchAction with UrlSignUp
          size: JJButtonSize.small,
        ),
      );
    } else if (info is TextSignUp) {
      buttons.add(
        JJButton(
          text: 'Text Us',
          variant: JJButtonVariant.primary,
          icon: Icons.message,
          onPressed: () => widget.onTap(), // This will call _launchAction with TextSignUp
          size: JJButtonSize.small,
        ),
      );
    } else if (info is PhoneSignUp) {
      buttons.add(
        JJButton(
          text: 'Call Now',
          variant: JJButtonVariant.primary,
          icon: Icons.phone,
          onPressed: () => widget.onTap(), // This will call _launchAction with PhoneSignUp
          size: JJButtonSize.small,
        ),
      );
    } else if (info is EmailSignUp) {
      buttons.add(
        JJButton(
          text: 'Email Us',
          variant: JJButtonVariant.primary,
          icon: Icons.email,
          onPressed: () => widget.onTap(), // This will call _launchAction with EmailSignUp
          size: JJButtonSize.small,
        ),
      );
    } else if (info is MixedSignUp && info.url != null && info.url!.isNotEmpty) {
      buttons.add(
        JJButton(
          text: 'Visit Website',
          variant: JJButtonVariant.primary,
          icon: Icons.link,
          onPressed: () => widget.onTap(), // This will call _launchAction with MixedSignUp (URL)
          size: JJButtonSize.small,
        ),
      );
    } else if (info is UnknownSignUp) {
      // No specific action button for unknown type
    }

    // Add a back button to flip the card
    buttons.add(
      JJButton(
        text: 'Back',
        variant: JJButtonVariant.secondary,
        icon: Icons.arrow_back,
        onPressed: _toggleFlip,
        size: JJButtonSize.small,
      ),
    );

    return buttons;
  }
}
