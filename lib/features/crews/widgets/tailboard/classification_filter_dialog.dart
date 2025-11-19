import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tailboard_theme.dart';

// Notifier for classification filter
class ClassificationFilterNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String value) {
    state = [...state, value];
  }

  void remove(String value) {
    state = state.where((item) => item != value).toList();
  }

  void clear() {
    state = [];
  }
}

// Provider for classification filter
final classificationFilterProvider = NotifierProvider<ClassificationFilterNotifier, List<String>>(
  () => ClassificationFilterNotifier(),
);

class ClassificationFilterDialog extends ConsumerWidget {
  const ClassificationFilterDialog({super.key});

  static const List<Map<String, String>> classifications = [
    {'name': 'Journeyman Wireman', 'code': 'JW'},
    {'name': 'Journeyman Lineman', 'code': 'JL'},
    {'name': 'Apprentice Wireman', 'code': 'AW'},
    {'name': 'Apprentice Lineman', 'code': 'AL'},
    {'name': 'Residential Wireman', 'code': 'RW'},
    {'name': 'Sound & Communications', 'code': 'SC'},
    {'name': 'Telecommunications', 'code': 'TC'},
    {'name': 'VDV Installer Technician', 'code': 'VDV'},
    {'name': 'Limited Energy Technician', 'code': 'LET'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClassifications = ref.watch(classificationFilterProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: TailboardTheme.backgroundCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TailboardTheme.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(TailboardTheme.spacingL),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: TailboardTheme.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Classification',
                  style: TailboardTheme.headingMedium,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        ref.read(classificationFilterProvider.notifier).clear();
                      },
                      child: Text(
                        'Clear',
                        style: TailboardTheme.bodyMedium.copyWith(
                          color: TailboardTheme.copper,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: TailboardTheme.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(TailboardTheme.spacingM),
              itemCount: classifications.length,
              itemBuilder: (context, index) {
                final classification = classifications[index];
                final name = classification['name']!;
                final code = classification['code']!;
                final isSelected = selectedClassifications.contains(name);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: TailboardTheme.spacingS),
                  child: Material(
                    color: isSelected
                        ? TailboardTheme.copper.withValues(alpha: 0.1)
                        : TailboardTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
                    child: InkWell(
                      onTap: () {
                        final notifier = ref.read(classificationFilterProvider.notifier);
                        if (isSelected) {
                          notifier.remove(name);
                        } else {
                          notifier.add(name);
                        }
                      },
                      borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
                      child: Container(
                        padding: const EdgeInsets.all(TailboardTheme.spacingM),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
                          border: Border.all(
                            color: isSelected
                                ? TailboardTheme.copper
                                : TailboardTheme.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected
                                  ? TailboardTheme.copper
                                  : TailboardTheme.textTertiary,
                            ),
                            const SizedBox(width: TailboardTheme.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TailboardTheme.bodyMedium.copyWith(
                                      color: isSelected
                                          ? TailboardTheme.copper
                                          : TailboardTheme.textPrimary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    code,
                                    style: TailboardTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(TailboardTheme.spacingM),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: TailboardTheme.divider,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TailboardTheme.primaryButton,
                child: Text('Apply ${selectedClassifications.isNotEmpty ? "(${selectedClassifications.length})" : ""}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
