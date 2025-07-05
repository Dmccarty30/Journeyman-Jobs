import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/safety_incident.dart';
import 'dart:math' as math;

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _reporterNameController = TextEditingController();
  final _reporterEmailController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _immediateActionsController = TextEditingController();
  final _equipmentInvolvedController = TextEditingController();
  final _witnessNamesController = TextEditingController();
  final _injuryDetailsController = TextEditingController();
  
  // Form state
  DateTime? _selectedIncidentDate;
  TimeOfDay? _selectedIncidentTime;
  IncidentType _selectedType = IncidentType.electrical;
  IncidentSeverity _selectedSeverity = IncidentSeverity.low;
  VoltageLevel? _selectedVoltageLevel;
  bool _injuryOccurred = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedIncidentDate = DateTime.now();
    _selectedIncidentTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _reporterNameController.dispose();
    _reporterEmailController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _immediateActionsController.dispose();
    _equipmentInvolvedController.dispose();
    _witnessNamesController.dispose();
    _injuryDetailsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.errorRed,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.report_problem,
                size: 20,
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Report Incident',
              style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.white),
            onPressed: () => _showReportingGuidelines(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency notice
              _buildEmergencyNotice(),
              
              const SizedBox(height: AppTheme.spacingLg),

              // Reporter Information
              _buildSectionCard(
                title: 'Reporter Information',
                icon: Icons.person_outline,
                children: [
                  JJTextField(
                    label: 'Full Name',
                    controller: _reporterNameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    label: 'Email Address',
                    controller: _reporterEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Incident Details
              _buildSectionCard(
                title: 'Incident Details',
                icon: Icons.warning_outlined,
                children: [
                  // Date and Time Selection
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTimePicker(
                          label: 'Incident Date',
                          value: _selectedIncidentDate != null
                              ? '${_selectedIncidentDate!.day}/${_selectedIncidentDate!.month}/${_selectedIncidentDate!.year}'
                              : 'Select Date',
                          onTap: () => _selectIncidentDate(),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: _buildDateTimePicker(
                          label: 'Incident Time',
                          value: _selectedIncidentTime != null
                              ? _selectedIncidentTime!.format(context)
                              : 'Select Time',
                          onTap: () => _selectIncidentTime(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  JJTextField(
                    label: 'Location',
                    hintText: 'e.g., Building A, Floor 2, Room 205',
                    controller: _locationController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the incident location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // Incident Type Dropdown
                  _buildDropdownField<IncidentType>(
                    label: 'Incident Type',
                    value: _selectedType,
                    items: IncidentType.values,
                    onChanged: (value) => setState(() => _selectedType = value!),
                    itemBuilder: (type) => type.displayName,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // Severity Dropdown
                  _buildDropdownField<IncidentSeverity>(
                    label: 'Severity Level',
                    value: _selectedSeverity,
                    items: IncidentSeverity.values,
                    onChanged: (value) => setState(() => _selectedSeverity = value!),
                    itemBuilder: (severity) => '${severity.displayName} - ${severity.description}',
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // Voltage Level (optional)
                  _buildDropdownField<VoltageLevel?>(
                    label: 'Voltage Level (if applicable)',
                    value: _selectedVoltageLevel,
                    items: [null, ...VoltageLevel.values],
                    onChanged: (value) => setState(() => _selectedVoltageLevel = value),
                    itemBuilder: (level) => level?.displayName ?? 'Not Applicable',
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Incident Description
              _buildSectionCard(
                title: 'Incident Description',
                icon: Icons.description_outlined,
                children: [
                  JJTextField(
                    label: 'Detailed Description',
                    hintText: 'Describe what happened, including sequence of events...',
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a detailed description';
                      }
                      if (value.trim().length < 20) {
                        return 'Please provide more details (minimum 20 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  JJTextField(
                    label: 'Immediate Actions Taken',
                    hintText: 'Describe what actions were taken immediately after the incident...',
                    controller: _immediateActionsController,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please describe immediate actions taken';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  JJTextField(
                    label: 'Equipment Involved',
                    hintText: 'List any equipment, tools, or materials involved (comma separated)',
                    controller: _equipmentInvolvedController,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  JJTextField(
                    label: 'Witness Names',
                    hintText: 'Names of any witnesses (comma separated)',
                    controller: _witnessNamesController,
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Injury Information
              _buildSectionCard(
                title: 'Injury Information',
                icon: Icons.local_hospital_outlined,
                children: [
                  CheckboxListTile(
                    title: const Text('Injury occurred'),
                    subtitle: const Text('Check if anyone was injured during this incident'),
                    value: _injuryOccurred,
                    onChanged: (value) => setState(() => _injuryOccurred = value ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_injuryOccurred) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    JJTextField(
                      label: 'Injury Details',
                      hintText: 'Describe the nature and extent of injuries...',
                      controller: _injuryDetailsController,
                      maxLines: 3,
                      validator: (value) {
                        if (_injuryOccurred && (value == null || value.trim().isEmpty)) {
                          return 'Please provide injury details';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Submit Button
              JJPrimaryButton(
                text: _isSubmitting ? 'Submitting Report...' : 'Submit Incident Report',
                onPressed: _isSubmitting ? null : _submitReport,
                isLoading: _isSubmitting,
                isFullWidth: true,
                icon: Icons.send,
              ),

              const SizedBox(height: AppTheme.spacingXl),
              
              // Emergency Contact Info
              _buildEmergencyContactInfo(),

              const SizedBox(height: AppTheme.spacingXxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyNotice() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.errorRed,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emergency,
            color: AppTheme.white,
            size: AppTheme.iconLg,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMERGENCY?',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Call 911 immediately for medical emergencies or immediate danger',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryNavy,
                  size: AppTheme.iconMd,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Text(
                title,
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  label.contains('Date') ? Icons.calendar_today : Icons.access_time,
                  color: AppTheme.textLight,
                  size: AppTheme.iconSm,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Text(
                  value,
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.white,
            contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: const BorderSide(color: AppTheme.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: const BorderSide(color: AppTheme.lightGray),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEmergencyContactInfo() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone,
                color: AppTheme.infoBlue,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Emergency Contacts',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.infoBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          const Text(
            '• Emergency Services: 911\n'
            '• Safety Manager: (555) 987-6543\n'
            '• Site Security: (555) 123-4567\n'
            '• Electrical Emergency: (555) 111-2222',
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _selectIncidentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedIncidentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedIncidentDate = date);
    }
  }

  Future<void> _selectIncidentTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedIncidentTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedIncidentTime = time);
    }
  }

  void _showReportingGuidelines() {
    JJBottomSheet.show(
      context: context,
      title: 'Incident Reporting Guidelines',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What to Report:',
            style: AppTheme.titleMedium,
          ),
          SizedBox(height: AppTheme.spacingSm),
          Text(
            '• All electrical accidents and near misses\n'
            '• Equipment failures or malfunctions\n'
            '• Arc flash incidents\n'
            '• Electrical shock events\n'
            '• PPE-related safety issues\n'
            '• Lockout/tagout violations',
            style: AppTheme.bodyMedium,
          ),
          SizedBox(height: AppTheme.spacingMd),
          Text(
            'Reporting Timeline:',
            style: AppTheme.titleMedium,
          ),
          SizedBox(height: AppTheme.spacingSm),
          Text(
            '• Immediate: Life-threatening incidents\n'
            '• Within 24 hours: All other incidents\n'
            '• As soon as possible: Near misses',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      // Scroll to first error
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create incident object
      final reportId = 'INC-${DateTime.now().millisecondsSinceEpoch}';
      final incident = SafetyIncident(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reporterName: _reporterNameController.text.trim(),
        reporterEmail: _reporterEmailController.text.trim(),
        incidentDate: DateTime(
          _selectedIncidentDate!.year,
          _selectedIncidentDate!.month,
          _selectedIncidentDate!.day,
          _selectedIncidentTime!.hour,
          _selectedIncidentTime!.minute,
        ),
        location: _locationController.text.trim(),
        type: _selectedType,
        severity: _selectedSeverity,
        voltageLevel: _selectedVoltageLevel,
        description: _descriptionController.text.trim(),
        immediateActions: _immediateActionsController.text.trim(),
        equipmentInvolved: _equipmentInvolvedController.text.trim().split(',')
            .map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        witnessNames: _witnessNamesController.text.trim().split(',')
            .map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        injuryOccurred: _injuryOccurred,
        injuryDetails: _injuryOccurred ? _injuryDetailsController.text.trim() : null,
        reportedDate: DateTime.now(),
        reportId: reportId,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Incident report submitted successfully! Report ID: $reportId',
          duration: const Duration(seconds: 5),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to submit report. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
