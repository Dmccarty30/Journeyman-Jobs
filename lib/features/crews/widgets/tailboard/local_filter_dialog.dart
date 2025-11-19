import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tailboard_theme.dart';

// Notifier for local filter
class LocalFilterNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [];

  void add(int value) {
    state = [...state, value];
  }

  void remove(int value) {
    state = state.where((item) => item != value).toList();
  }

  void clear() {
    state = [];
  }
}

// Provider for local filter
final localFilterProvider = NotifierProvider<LocalFilterNotifier, List<int>>(
  () => LocalFilterNotifier(),
);

class LocalFilterDialog extends ConsumerStatefulWidget {
  const LocalFilterDialog({super.key});

  @override
  ConsumerState<LocalFilterDialog> createState() => _LocalFilterDialogState();
}

class _LocalFilterDialogState extends ConsumerState<LocalFilterDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<int> _filteredLocals = [];

  // Sample popular locals (in production, load from database)
  static const List<int> popularLocals = [
    1, 3, 6, 26, 46, 77, 102, 134, 164, 292, 
    357, 429, 494, 573, 595, 697, 743, 876, 903, 1245,
  ];

  @override
  void initState() {
    super.initState();
    _filteredLocals = popularLocals;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocals(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocals = popularLocals;
      } else {
        _filteredLocals = popularLocals
            .where((local) => local.toString().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocals = ref.watch(localFilterProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'IBEW Local',
                      style: TailboardTheme.headingMedium,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            ref.read(localFilterProvider.notifier).clear();
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
                const SizedBox(height: TailboardTheme.spacingM),
                TextField(
                  controller: _searchController,
                  decoration: TailboardTheme.inputDecoration(
                    hintText: 'Search local number...',
                    prefixIcon: const Icon(Icons.search, color: TailboardTheme.copper),
                  ),
                  style: TailboardTheme.bodyMedium,
                  keyboardType: TextInputType.number,
                  onChanged: _filterLocals,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(TailboardTheme.spacingM),
              itemCount: _filteredLocals.length,
              itemBuilder: (context, index) {
                final local = _filteredLocals[index];
                final isSelected = selectedLocals.contains(local);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: TailboardTheme.spacingS),
                  child: Material(
                    color: isSelected
                        ? TailboardTheme.copper.withValues(alpha: 0.1)
                        : TailboardTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
                    child: InkWell(
                      onTap: () {
                        final notifier = ref.read(localFilterProvider.notifier);
                        if (isSelected) {
                          notifier.remove(local);
                        } else {
                          notifier.add(local);
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
                                'IBEW Local $local',
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
                child: Text('Apply ${selectedLocals.isNotEmpty ? "(${selectedLocals.length})" : ""}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
