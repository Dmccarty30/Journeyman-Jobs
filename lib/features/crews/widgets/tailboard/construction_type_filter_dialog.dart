import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tailboard_theme.dart';

// Notifier for construction type filter
class ConstructionTypeFilterNotifier extends Notifier<List<String>> {
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

// This provider will be created in a job_filter_provider.dart file
final constructionTypeFilterProvider = NotifierProvider<ConstructionTypeFilterNotifier, List<String>>(
  () => ConstructionTypeFilterNotifier(),
);

class ConstructionTypeFilterDialog extends ConsumerWidget {
  const ConstructionTypeFilterDialog({super.key});

  static const List<String> constructionTypes = [
    'Commercial',
    'Industrial',
    'Residential',
    'Institutional',
    'Infrastructure',
    'Renewable Energy',
    'Data Centers',
    'Transportation',
    'Healthcare',
    'Education',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(constructionTypeFilterProvider);

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
                  'Construction Type',
                  style: TailboardTheme.headingMedium,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        ref.read(constructionTypeFilterProvider.notifier).clear();
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
              itemCount: constructionTypes.length,
              itemBuilder: (context, index) {
                final type = constructionTypes[index];
                final isSelected = selectedTypes.contains(type);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: TailboardTheme.spacingS),
                  child: Material(
                    color: isSelected
                        ? TailboardTheme.copper.withValues(alpha: 0.1)
                        : TailboardTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
                    child: InkWell(
                      onTap: () {
                        final notifier = ref.read(constructionTypeFilterProvider.notifier);
                        if (isSelected) {
                          notifier.remove(type);
                        } else {
                          notifier.add(type);
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
                              child: Text(
                                type,
                                style: TailboardTheme.bodyMedium.copyWith(
                                  color: isSelected
                                      ? TailboardTheme.copper
                                      : TailboardTheme.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
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
                child: Text('Apply ${selectedTypes.isNotEmpty ? "(${selectedTypes.length})" : ""}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
