import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQItem> _faqItems = [
    FAQItem(
      category: 'Account',
      question: 'How do I update my IBEW local information?',
      answer: 'Go to More → Profile → Professional tab. You can update your home local, ticket number, and classification. Make sure your information is current to receive relevant job opportunities.',
    ),
    FAQItem(
      category: 'Account',
      question: 'Can I change my job preferences after onboarding?',
      answer: 'Yes! Navigate to More → Profile → Professional tab. You can update your preferred construction types, hours per week, per diem requirements, and career goals at any time.',
    ),
    FAQItem(
      category: 'Jobs',
      question: 'How do I apply for storm work?',
      answer: 'Go to the Storm tab to view emergency restoration opportunities. These jobs are marked as "URGENT" and often have enhanced pay rates. Tap on any storm event to see details and express interest.',
    ),
    FAQItem(
      category: 'Jobs',
      question: 'What does "Books On" mean in my profile?',
      answer: '"Books on" refers to what books are you on what out of work books have you already signed in you\'re actively on SO that we know what locals and what jobs to present to you ahead of others so that we\'re not showing you jobs that you aren\'t able to bid for.',
    ),
    FAQItem(
      category: 'Jobs',
      question: 'How are job opportunities matched to me?',
      answer: 'Jobs are matched based on your classification, preferred construction types, location preferences, and experience level. Update your profile regularly for better matches.',
    ),
    FAQItem(
      category: 'Locals',
      question: 'How do I find IBEW locals in other areas?',
      answer: 'Use the Unions tab to browse IBEW locals by region. You can view contact information, jurisdiction areas, and current job opportunities for each local.',
    ),
    FAQItem(
      category: 'Locals',
      question: 'Can I work for a local other than my home local?',
      answer: 'Yes, as an IBEW member you can work in other local jurisdictions. Check with both your home local and the hiring local about any reciprocity agreements or procedures.',
    ),
    FAQItem(
      category: 'Technical',
      question: 'Why am I not receiving job notifications?',
      answer: 'Check More → Profile → Settings tab and ensure "Job Alerts" and "Push Notifications" are enabled. Also verify your device notification settings allow the app to send notifications.',
    ),
    FAQItem(
      category: 'Technical',
      question: 'The app is running slowly. What can I do?',
      answer: 'Try closing and reopening the app. If issues persist, restart your device. Make sure you have the latest app version installed from your app store.',
    ),
    FAQItem(
      category: 'Technical',
      question: 'I forgot my password. How do I reset it?',
      answer: 'On the sign-in screen, tap "Forgot Password?" and enter your email address. You\'ll receive a password reset link. If you don\'t see the email, check your spam folder.',
    ),
    FAQItem(
      category: 'Safety',
      question: 'What safety information should I know for storm work?',
      answer: 'Storm work involves additional hazards including downed lines, debris, and unstable structures. Always follow proper safety protocols, use appropriate PPE, and report unsafe conditions immediately.',
    ),
    FAQItem(
      category: 'Safety',
      question: 'How do I report unsafe working conditions?',
      answer: 'Contact your foreman or safety representative immediately. You can also contact your local\'s safety committee or OSHA if needed. Your safety is the top priority.',
    ),
  ];

  final List<ContactOption> _contactOptions = [
    ContactOption(
      icon: Icons.email_outlined,
      title: 'Email Support',
      subtitle: 'Get help via email within 24 hours',
      action: 'support@journeymanjobs.com',
      color: AppTheme.accentCopper,
    ),
    ContactOption(
      icon: Icons.phone_outlined,
      title: 'Phone Support',
      subtitle: 'Speak with support Monday-Friday 8AM-6PM EST',
      action: '1-800-JOURNEYMAN',
      color: AppTheme.successGreen,
    ),
    ContactOption(
      icon: Icons.chat_outlined,
      title: 'Live Chat',
      subtitle: 'Chat with support during business hours',
      action: 'Start Chat',
      color: AppTheme.infoBlue,
    ),
    ContactOption(
      icon: Icons.bug_report_outlined,
      title: 'Report a Bug',
      subtitle: 'Help us improve the app by reporting issues',
      action: 'Report Issue',
      color: AppTheme.warningYellow,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<FAQItem> get _filteredFAQs {
    if (_searchQuery.isEmpty) return _faqItems;
    return _faqItems.where((faq) =>
      faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      faq.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      faq.category.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Help & Support',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCopper,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact'),
            Tab(text: 'Guides'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildContactTab(),
          _buildGuidesTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return Column(
      children: [
        // Search bar
        Container(
          color: AppTheme.primaryNavy,
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            0,
            AppTheme.spacingMd,
            AppTheme.spacingMd,
          ),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search FAQ...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),

        // FAQ list
        Expanded(
          child: _filteredFAQs.isEmpty
              ? Center(
                  child: JJEmptyState(
                    title: 'No Results Found',
                    subtitle: 'Try searching with different keywords',
                    icon: Icons.search_off,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  itemCount: _filteredFAQs.length,
                  itemBuilder: (context, index) {
                    final faq = _filteredFAQs[index];
                    return FAQCard(faq: faq);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get in Touch',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Choose the best way to reach our support team',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          ..._contactOptions.map((option) => ContactCard(option: option)),

          const SizedBox(height: AppTheme.spacingLg),

          // Emergency contact info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: AppTheme.warningYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.warningYellow.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emergency,
                      color: AppTheme.warningYellow,
                      size: AppTheme.iconMd,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      'Emergency Safety Issues',
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.warningYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  'For immediate safety concerns or emergency situations on job sites, contact:',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  '• Your site supervisor immediately\n'
                  '• OSHA Hotline: 1-800-321-OSHA\n'
                  '• Emergency services: 911',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Start Guides',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          GuideCard(
            icon: Icons.person_add_outlined,
            title: 'Setting Up Your Profile',
            subtitle: 'Complete your profile for better job matches',
            steps: [
              'Go to More → Profile',
              'Fill in your personal information',
              'Add your IBEW local and classification',
              'Set your job preferences',
              'Enable notifications for alerts',
            ],
          ),

          GuideCard(
            icon: Icons.work_outline,
            title: 'Finding and Applying for Jobs',
            subtitle: 'How to search and apply for opportunities',
            steps: [
              'Browse jobs in the Jobs tab',
              'Use filters to narrow your search',
              'Tap on a job to view details',
              'Read requirements and benefits carefully',
              'Tap "Apply Now" to submit your interest',
            ],
          ),

          GuideCard(
            icon: Icons.flash_on_outlined,
            title: 'Storm Work Opportunities',
            subtitle: 'Understanding emergency restoration work',
            steps: [
              'Check the Storm tab for active events',
              'Review severity levels and pay rates',
              'Read safety requirements carefully',
              'Express interest for rapid deployment',
              'Wait for deployment contact information',
            ],
          ),

          GuideCard(
            icon: Icons.business_outlined,
            title: 'Working with Different Locals',
            subtitle: 'Understanding IBEW reciprocity',
            steps: [
              'Check the Unions tab for local information',
              'Contact your home local about reciprocity',
              'Verify any additional requirements',
              'Understand jurisdictional boundaries',
              'Maintain good standing with your home local',
            ],
          ),

          GuideCard(
            icon: Icons.notifications_outlined,
            title: 'Managing Notifications',
            subtitle: 'Stay updated on new opportunities',
            steps: [
              'Go to More → Profile → Settings',
              'Enable job alerts and storm alerts',
              'Set your device notification preferences',
              'Choose email vs push notifications',
              'Adjust notification frequency as needed',
            ],
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String category;
  final String question;
  final String answer;

  FAQItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class ContactOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final Color color;

  ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.color,
  });
}

class FAQCard extends StatefulWidget {
  final FAQItem faq;

  const FAQCard({super.key, required this.faq});

  @override
  State<FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCopper.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        widget.faq.category,
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.accentCopper,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  widget.faq.question,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    widget.faq.answer,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final ContactOption option;

  const ContactCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () {
            _handleContactAction(context, option);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: option.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    option.icon,
                    color: option.color,
                    size: AppTheme.iconMd,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        option.subtitle,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContactAction(BuildContext context, ContactOption option) {
    switch (option.title) {
      case 'Email Support':
        Clipboard.setData(ClipboardData(text: option.action));
        JJSnackBar.showSuccess(
          context: context,
          message: 'Email address copied to clipboard',
        );
        break;
      case 'Phone Support':
        Clipboard.setData(ClipboardData(text: option.action));
        JJSnackBar.showSuccess(
          context: context,
          message: 'Phone number copied to clipboard',
        );
        break;
      default:
JJSnackBar.showSuccess(
          context: context,
          message: '${option.title} feature coming soon',
        );
    }
  }
}

class GuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> steps;

  const GuideCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.accentCopper,
                    size: AppTheme.iconMd,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        subtitle,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.accentCopper,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Text(
                        step,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}