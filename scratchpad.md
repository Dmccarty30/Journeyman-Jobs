# SCRATCHPAD

i need for you to tell me exactly how to add these example widget/components/painters to this basic testing script:

```DART

import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';
import 'jj_electrical_interactive_widgets.dart';
import 'jj_electrical_page_transitions.dart';


void main() {
  runApp(const ElectricalComponentsShowcaseApp());
}

class ElectricalComponentsShowcaseApp extends StatelessWidget {
  const ElectricalComponentsShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electrical Components Showcase',
      theme: AppTheme.darkTheme,
      home: const ShowcaseHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  String? _dropdownValue;
  final TextEditingController _textController1 = TextEditingController();
  final TextEditingController _textController2 = TextEditingController();

  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Electrical Components'),
        backgroundColor: AppTheme.primaryNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Interactive Buttons'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                JJElectricalButton(
                  onPressed: () {
                    debugPrint('Standard Button Pressed');
                  },
                  child: const Text('Standard Button'),
                ),
                JJElectricalButton(
                  onPressed: () {},
                  enableSparks: false,
                  child: const Text('No Sparks'),
                ),
                JJElectricalButton(
                  onPressed: () {},
                  enableGlow: false,
                  child: const Text('No Glow'),
                ),
                JJElectricalButton(
                  onPressed: () {},
                  sparkColor: AppTheme.electricalSuccess,
                  glowColor: AppTheme.electricalSuccess,
                  child: const Text('Success Color'),
                ),
                JJElectricalButton(
                  onPressed: () {},
                  sparkColor: AppTheme.electricalError,
                  glowColor: AppTheme.electricalError,
                  child: const Text('Error Color'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Electrical Text Fields'),
            const SizedBox(height: 16),
            JJElectricalTextField(
              controller: _textController1,
              decoration: const InputDecoration(
                labelText: 'Standard Input',
                hintText: 'Type something...',
              ),
            ),
            const SizedBox(height: 16),
            JJElectricalTextField(
              controller: _textController2,
              currentColor: AppTheme.electricalWarning,
              traceColor: AppTheme.electricalWarning.withValues(alpha: 0.5),
              decoration: const InputDecoration(
                labelText: 'Warning Input',
                hintText: 'Current flows with warning color',
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Electrical Dropdown'),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: JJElectricalDropdown<String>(
                value: _dropdownValue,
                hint: const Text('Select Voltage', style: TextStyle(color: Colors.white70)),
                items: const [
                  DropdownMenuItem(value: '120V', child: Text('120V - Single Phase')),
                  DropdownMenuItem(value: '208V', child: Text('208V - Three Phase')),
                  DropdownMenuItem(value: '240V', child: Text('240V - Split Phase')),
                  DropdownMenuItem(value: '480V', child: Text('480V - Industrial')),
                ],
                onChanged: (value) {
                  setState(() {
                    _dropdownValue = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Page Transitions'),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                JJElectricalButton(
                  onPressed: () => _navigateToDemo(
                    context, 
                    'Lightning Transition',
                    (page) => page.withLightningTransition(const RouteSettings(name: '/lightning')),
                  ),
                  child: const Text('Lightning Strike'),
                ),
                JJElectricalButton(
                  onPressed: () => _navigateToDemo(
                    context, 
                    'Circuit Slide (Right)',
                    (page) => page.withCircuitSlideTransition(
                      const RouteSettings(name: '/circuit_right'),
                      direction: SlideDirection.fromRight
                    ),
                  ),
                  child: const Text('Circuit Slide'),
                ),
                JJElectricalButton(
                  onPressed: () => _navigateToDemo(
                    context, 
                    'Spark Reveal',
                    (page) => page.withSparkRevealTransition(const RouteSettings(name: '/spark')),
                  ),
                  child: const Text('Spark Reveal'),
                ),
                JJElectricalButton(
                  onPressed: () => _navigateToDemo(
                    context, 
                    'Power Surge',
                    (page) => page.withPowerSurgeTransition(const RouteSettings(name: '/surge')),
                  ),
                  child: const Text('Power Surge'),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.accentCopper),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 100,
          color: AppTheme.accentCopper,
        ),
      ],
    );
  }

  void _navigateToDemo(
    BuildContext context, 
    String title, 
    PageRouteBuilder Function(Widget) transitionBuilder
  ) {
    Navigator.of(context).push(
      transitionBuilder(TransitionDemoPage(title: title)),
    );
  }
}

class TransitionDemoPage extends StatelessWidget {
  final String title;

  const TransitionDemoPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentCopper, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentCopper.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.bolt, 
                size: 80, 
                color: AppTheme.electricalInfo,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Transition Complete!',
              style: AppTheme.headlineMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textLight),
            ),
            const SizedBox(height: 48),
            JJElectricalButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}


```
