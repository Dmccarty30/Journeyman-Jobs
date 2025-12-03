import 'package:journeyman_jobs/electrical_components/simple_test_harness.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ComponentTesterApp());
}

// ignore: strict_top_level_inference, use_function_type_syntax_for_parameters
testWidgets('Enhanced job card displays electrical theme', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: EnhancedJobCard(
      job: mockJob,
      variant: JobCardVariant.full,
    ),
  ));
  
  expect(find.byIcon(Icons.electrical_services), findsOneWidget);
  expect(find.text('IBEW Local'), findsOneWidget);
  expect(find.byType(CustomPaint), findsWidgets); // Circuit patterns
});