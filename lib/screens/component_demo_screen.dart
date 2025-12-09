import 'package:flutter/material.dart';
import 'package:journeyman_jobs/widgets/jj_text.dart';
import '../design_system/widgets/design_system_widgets.dart';
import '../design_system/design_system.dart';

class ComponentDemoScreen extends StatefulWidget {
  const ComponentDemoScreen({super.key});

  @override
  State<ComponentDemoScreen> createState() => _ComponentDemoScreenState();
}

class _ComponentDemoScreenState extends State<ComponentDemoScreen> {
  final _textCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _toggleLoading() {
    setState(() => _isLoading = !_isLoading);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JJ Component Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // Toggle theme logic would go here if available
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Typography Section
            const _SectionHeader('Typography (JJText)'),
            JJText.h1('Header 1 - Large Title'),
            const SizedBox(height: 8),
            JJText.h2('Header 2 - Section Title'),
            const SizedBox(height: 8),
            JJText.h3('Header 3 - Subsection'),
            const SizedBox(height: 8),
            JJText.body(
              'This is body text using JJText.body(). It adheres to the AppTheme bodyMedium style. '
              'It is designed for readability and consistency across the app.',
            ),
            const SizedBox(height: 8),
            JJText.caption('This is a caption text (labelSmall).'),

            const SizedBox(height: 32),

            // 2. Text Fields Section
            const _SectionHeader('Text Fields (JJTextField)'),
            JJTextField(
              label: 'Standard Field',
              hintText: 'Type something...',
              controller: _textCtrl,
            ),
            const SizedBox(height: 16),
            JJTextField(
              label: 'Email Address',
              hintText: 'worker@ibew.org',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            JJTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: _passwordCtrl,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              suffixIcon: Icons.visibility_off,
            ),

            const SizedBox(height: 32),

            // 3. Buttons Section
            const _SectionHeader('Buttons (JJButton)'),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                JJButton(
                  text: 'Primary Button',
                  onPressed: _toggleLoading,
                  isLoading: _isLoading,
                ),
                JJButton(
                  text: 'Secondary Button',
                  variant: JJButtonVariant.secondary,
                  onPressed: () {},
                ),
                JJButton(
                  text: 'Outline Button',
                  variant: JJButtonVariant.outline,
                  onPressed: () {},
                ),
                JJButton(
                  text: 'Danger Button',
                  variant: JJButtonVariant.danger,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Button Sizes:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                JJButton(
                  text: 'Small',
                  size: JJButtonSize.small,
                  onPressed: () {},
                ),
                JJButton(
                  text: 'Medium',
                  size: JJButtonSize.medium,
                  onPressed: () {},
                ),
                JJButton(
                  text: 'Large',
                  size: JJButtonSize.large,
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 4. Cards Section (from Barrel)
            const _SectionHeader('Cards (Barrel Export)'),
            // Using a generic container to simulate a card since JJCard might be in a different file
            // or we can use one of the exported cards like ContractorCard if available
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentCopper),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JJText.h3('Contractor Card Example'),
                  const SizedBox(height: 8),
                  JJText.body(
                      'This card demonstrates the copper border styling used in the app.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }
}
