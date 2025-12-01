import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

// --------------------------------------------------------------------------
// IMPORT YOUR COMPONENT FILES HERE
// --------------------------------------------------------------------------
import 'jj_electrical_interactive_widgets.dart';
import 'jj_electrical_page_transitions.dart';

void main() {
  runApp(const ComponentTesterApp());
}

class ComponentTesterApp extends StatelessWidget {
  const ComponentTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Component Tester',
      // Using the app's dark theme which suits electrical components best
      theme: AppTheme.darkTheme, 
      home: const TestArea(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestArea extends StatefulWidget {
  const TestArea({super.key});

  @override
  State<TestArea> createState() => _TestAreaState();
}

class _TestAreaState extends State<TestArea> {
  // Add any state variables you need for testing here
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Component Test Bench'),
        backgroundColor: AppTheme.primaryNavy,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Test Area',
                style: TextStyle(
                  color: Colors.white54, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 40),

              // ============================================================
              // ADD YOUR COMPONENTS TO TEST BELOW
              // ============================================================

              // Example 1: Testing the Electrical Button
              JJElectricalButton(
                onPressed: () {
                  debugPrint('Test Button Pressed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Button Pressed!')),
                  );
                },
                child: const Text('Test Button'),
              ),
              
              const SizedBox(height: 32),
              
              // Example 2: Testing the Electrical Text Field
              JJElectricalTextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Test Field',
                  hintText: 'Type here to test current flow',
                ),
              ),

              const SizedBox(height: 32),

              // Example 3: Testing Page Transitions
              JJElectricalButton(
                onPressed: () {
                  Navigator.of(context).push(
                    JJElectricalPageTransitions.lightningTransition(
                      settings: const RouteSettings(name: '/test'),
                      child: Scaffold(
                        backgroundColor: AppTheme.primaryNavy,
                        appBar: AppBar(title: const Text('Transition Test')),
                        body: Center(
                          child: JJElectricalButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go Back'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Test Transition'),
              ),

              // ============================================================
              // END TEST COMPONENTS
              // ============================================================
            ],
          ),
        ),
      ),
    );
  }
}
