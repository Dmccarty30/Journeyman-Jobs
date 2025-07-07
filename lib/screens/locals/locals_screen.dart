import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/locals_record.dart';

class LocalsWidget extends StatefulWidget {
  const LocalsWidget({super.key});

  static String routeName = 'locals';
  static String routePath = '/locals';

  @override
  State<LocalsWidget> createState() => _LocalsWidgetState();
}

class _LocalsWidgetState extends State<LocalsWidget> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final List<LocalsRecord> _localsRecords = LocalsRecordMockData.getSampleData();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  List<LocalsRecord> _queryLocalsRecord() {
    // Simple search functionality - in a real app this would query a database
    final query = _emailController.text.toLowerCase();
    if (query.isEmpty) {
      return _localsRecords;
    }
    return _localsRecords.where((record) =>
        record.localName.toLowerCase().contains(query) ||
        record.location.toLowerCase().contains(query) ||
        record.localNumber.contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IBEW Locals'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            const Text(
              'Find Your IBEW Local',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            JJTextField(
              label: 'Search Locals',
              controller: _emailController,
              focusNode: _emailFocusNode,
              hintText: 'Enter local number, name, or location',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Expanded(
              child: ListView.builder(
                itemCount: _queryLocalsRecord().length,
                itemBuilder: (context, index) {
                  final local = _queryLocalsRecord()[index];
                  return JJCard(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Local ${local.localNumber}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingSm,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: local.isActive
                                      ? AppTheme.successGreen.withValues(alpha: 0.2)
                                      : AppTheme.mediumGray.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                ),
                                child: Text(
                                  local.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: local.isActive 
                                        ? AppTheme.successGreen
                                        : AppTheme.mediumGray,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            local.localName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                local.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${local.memberCount} members',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (local.specialties.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacingSm),
                            Wrap(
                              spacing: AppTheme.spacingXs,
                              runSpacing: AppTheme.spacingXs,
                              children: local.specialties.map((specialty) {
                                return JJChip(
                                  label: specialty,
                                  isSelected: false,
                                  onTap: () {},
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: AppTheme.spacingSm),
                          Row(
                            children: [
                              Expanded(
                                child: JJSecondaryButton(
                                  text: 'Contact',
                                  icon: Icons.phone,
                                  onPressed: () {
                                    // Handle contact action
                                  },
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingSm),
                              Expanded(
                                child: JJPrimaryButton(
                                  text: 'View Details',
                                  onPressed: () {
                                    // Handle view details action
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}