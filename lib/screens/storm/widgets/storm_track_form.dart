import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/widgets/design_system_widgets.dart';
import 'package:journeyman_jobs/electrical_components/electrical_components.dart';
import '../../../models/storm_track.dart';
import '../services/storm_tracking_service.dart';

class StormTrackForm extends StatefulWidget {
  final StormTrack? track;
  final ScrollController scrollController;

  const StormTrackForm({
    super.key,
    this.track,
    required this.scrollController,
  });

  @override
  State<StormTrackForm> createState() => _StormTrackFormState();
}

class _StormTrackFormState extends State<StormTrackForm> {
  final _formKey = GlobalKey<FormState>();
  final _trackingService = StormTrackingService();

  late TextEditingController _contractorController;
  late TextEditingController _utilityController;
  late TextEditingController _stormTypeController;
  late TextEditingController _payRateController;
  late TextEditingController _perDiemController;
  late TextEditingController _workingHoursController;
  late TextEditingController _hoursWorkedController;
  late TextEditingController _mobilizationHoursController;
  late TextEditingController _demobilizationHoursController;
  late TextEditingController _travelReimbursementController;
  late TextEditingController _completionBonusController;
  late TextEditingController _conditionsController;
  late TextEditingController _notesController;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final track = widget.track;
    _contractorController = TextEditingController(text: track?.contractor);
    _utilityController = TextEditingController(text: track?.utility);
    _stormTypeController = TextEditingController(text: track?.stormType);
    _payRateController =
        TextEditingController(text: track?.payRate.toString() ?? '');
    _perDiemController =
        TextEditingController(text: track?.perDiem.toString() ?? '');
    _workingHoursController =
        TextEditingController(text: track?.workingHours.toString() ?? '');
    _hoursWorkedController =
        TextEditingController(text: track?.hoursWorked.toString() ?? '');
    _mobilizationHoursController =
        TextEditingController(text: track?.mobilizationHours.toString() ?? '');
    _demobilizationHoursController = TextEditingController(
        text: track?.demobilizationHours.toString() ?? '');
    _travelReimbursementController = TextEditingController(
        text: track?.travelReimbursement.toString() ?? '');
    _completionBonusController =
        TextEditingController(text: track?.completionBonus.toString() ?? '');
    _conditionsController = TextEditingController(text: track?.conditions);
    _notesController = TextEditingController(text: track?.notes);

    if (track != null) {
      _startDate = track.startDate;
      _endDate = track.endDate;
    }
  }

  @override
  void dispose() {
    _contractorController.dispose();
    _utilityController.dispose();
    _stormTypeController.dispose();
    _payRateController.dispose();
    _perDiemController.dispose();
    _workingHoursController.dispose();
    _hoursWorkedController.dispose();
    _mobilizationHoursController.dispose();
    _demobilizationHoursController.dispose();
    _travelReimbursementController.dispose();
    _completionBonusController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrack() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final track = StormTrack(
        id: widget.track?.id ?? '',
        userId: '', // Service handles this
        startDate: _startDate,
        endDate: _endDate,
        contractor: _contractorController.text,
        utility: _utilityController.text,
        stormType: _stormTypeController.text,
        payRate: double.tryParse(_payRateController.text) ?? 0.0,
        perDiem: double.tryParse(_perDiemController.text) ?? 0.0,
        workingHours: double.tryParse(_workingHoursController.text) ?? 0.0,
        hoursWorked: double.tryParse(_hoursWorkedController.text) ?? 0.0,
        mobilizationHours:
            double.tryParse(_mobilizationHoursController.text) ?? 0.0,
        demobilizationHours:
            double.tryParse(_demobilizationHoursController.text) ?? 0.0,
        travelReimbursement:
            double.tryParse(_travelReimbursementController.text) ?? 0.0,
        completionBonus:
            double.tryParse(_completionBonusController.text) ?? 0.0,
        conditions: _conditionsController.text,
        notes: _notesController.text,
      );

      if (widget.track == null) {
        await _trackingService.addStormTrack(track);
      } else {
        await _trackingService.updateStormTrack(track);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving track: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: AppTheme.spacingMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.track == null ? 'Add Storm Track' : 'Edit Storm Track',
                style: AppTheme.headlineSmall,
              ),
              if (widget.track != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.errorRed),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Track'),
                        content: const Text(
                            'Are you sure you want to delete this storm track?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(color: AppTheme.errorRed)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      await _trackingService.deleteStormTrack(widget.track!.id);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          'Start Date',
                          _startDate,
                          () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: _buildDatePicker(
                          'End Date',
                          _endDate,
                          () => _selectDate(context, false),
                          placeholder: 'Ongoing',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Contractor & Utility
                  JJTextField(
                    controller: _contractorController,
                    label: 'Contractor',
                    hintText: 'e.g. Pike, Quanta',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  JJTextField(
                    controller: _utilityController,
                    label: 'Utility',
                    hintText: 'e.g. FPL, Duke',
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  JJTextField(
                    controller: _stormTypeController,
                    label: 'Storm Type',
                    hintText: 'e.g. Hurricane, Ice Storm',
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Financials
                  _buildSectionHeader('Financials'),
                  Row(
                    children: [
                      Expanded(
                        child: JJTextField(
                          controller: _payRateController,
                          label: 'Base Pay Rate (\$/hr)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: JJTextField(
                          controller: _perDiemController,
                          label: 'Per Diem (\$/day)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Hours Breakdown
                  _buildSectionHeader('Hours Breakdown'),
                  JJTextField(
                    controller: _mobilizationHoursController,
                    label: 'Mobilization Hours (2x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _workingHoursController,
                    label: 'Working Hours (2x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _demobilizationHoursController,
                    label: 'De-mobilization Hours (1.5x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Bonuses & Reimbursements
                  _buildSectionHeader('Bonuses & Reimbursements'),
                  JJTextField(
                    controller: _travelReimbursementController,
                    label: 'Travel Reimbursement',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _completionBonusController,
                    label: 'Storm Completion Bonus',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Details
                  _buildSectionHeader('Details'),
                  JJTextField(
                    controller: _conditionsController,
                    label: 'Conditions',
                    hintText: 'e.g. Flooded, Icy',
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _notesController,
                    label: 'Notes',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  JJPrimaryButton(
                    text: 'Save Track',
                    onPressed: _isSaving ? null : _saveTrack,
                    isLoading: _isSaving,
                    isFullWidth: true,
                    variant: JJButtonVariant.primary,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Text(
        title,
        style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap,
      {String? placeholder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderLight),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  date != null
                      ? DateFormat('MMM d, y').format(date)
                      : (placeholder ?? 'Select Date'),
                  style: AppTheme.bodyMedium.copyWith(
                    color: date != null
                        ? AppTheme.textPrimary
                        : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
