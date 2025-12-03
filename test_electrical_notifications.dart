import 'package:flutter/material.dart';
import 'lib/electrical_components/jj_electrical_notifications.dart';

/// Test widget to demonstrate the electrical notifications with circuit theming
class ElectricalNotificationsTest extends StatelessWidget {
  const ElectricalNotificationsTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electrical Notifications Test',
      theme: ThemeData.dark(),
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Electrical Notifications Test'),
              backgroundColor: const Color(0xFF1A202C),
            ),
            body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Toast Test
              ElevatedButton(
                onPressed: () {
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: 'Circuit breaker activated successfully!',
                    type: ElectricalNotificationType.success,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Test Success Toast'),
              ),
              const SizedBox(height: 16),
              
              // Warning Toast Test
              ElevatedButton(
                onPressed: () {
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: 'Voltage fluctuation detected!',
                    type: ElectricalNotificationType.warning,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Test Warning Toast'),
              ),
              const SizedBox(height: 16),
              
              // Error Toast Test
              ElevatedButton(
                onPressed: () {
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: 'Circuit overload detected!',
                    type: ElectricalNotificationType.error,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Test Error Toast'),
              ),
              const SizedBox(height: 16),
              
              // Info SnackBar Test
              ElevatedButton(
                onPressed: () {
                  JJElectricalNotifications.showElectricalSnackBar(
                    context: context,
                    message: 'System status: All circuits operational',
                    type: ElectricalNotificationType.info,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Test Info SnackBar'),
              ),
              const SizedBox(height: 32),
              
              // Tooltip Test
              JJElectricalNotifications.electricalTooltip(
                message: 'This is an electrical tooltip with circuit theming',
                type: ElectricalNotificationType.info,
                child: const Icon(
                  Icons.info_outline,
                  size: 32,
                  color: Color(0xFF00D4FF),
                ),
              ),
            ],
          ),
        ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const ElectricalNotificationsTest());
}