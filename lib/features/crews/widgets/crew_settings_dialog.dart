import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_toast.dart';
import '../../models/crew.dart';
import '../../models/crew_preferences.dart';
import '../../providers/crews_riverpod_provider.dart';

/// Dialog for managing crew settings and preferences.
/// 
/// Provides comprehensive configuration options for crew management including:
/// - Basic crew information (name, description)
/// - Privacy and visibility settings
/// - Job sharing preferences
/// - Notification settings
/// - Crew-specific rules and guidelines
class CrewSettingsDialog extends ConsumerStatefulWidget {
  final String crewId;

  const CrewSettingsDialog({
    Key? key,
    required this.crewId,
  }) : super(key: key);

  @override
  ConsumerState<CrewSettingsDialog> createState() => _CrewSettingsDialogState();
}

class _CrewSettingsDialogState extends ConsumerState<CrewSettingsDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Crew? _crew;
  CrewPreferences? _preferences;
  bool _isLoading = false;
  
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupAnimations();
    _loadCrewData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCrewData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final crewService = ref.read(crewServiceProvider);
      final crew = await crewService.getCrew(widget.crewId);
      final preferences = await crewService.getCrewPreferences(widget.crewId);

      if (mounted) {
        setState(() {
          _crew = crew;
          _preferences = preferences;
          _nameController.text = crew.name;
          _descriptionController.text = crew.description ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        JJElectricalToast.showError(
          context: context,
          message: 'Failed to load crew data: $e',
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final crewService = ref.read(crewServiceProvider);
        
        // Update crew basic info
        await crewService.updateCrewInfo(
          crewId: widget.crewId,
          name: _nameController.text,
          description: _descriptionController.text,
        );

        // Update preferences
        if (_preferences != null) {
          await crewService.updateCrewPreferences(
            crewId: widget.crewId,
            preferences: _preferences!,
          );
        }

        if (mounted) {
          JJElectricalToast.showSuccess(
            context: context,
            message: 'Crew settings updated successfully!',
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          JJElectricalToast.showError(
            context: context,
            message: 'Failed to save settings: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentCopper.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: _buildTabContent(),
                  ),
                  _buildActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryNavy,
            AppTheme.secondaryNavy,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings,
            color: AppTheme.accentCopper,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Crew Settings',
              style: AppTheme.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: AppTheme.accentCopper,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.accentCopper.withOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.accentCopper,
        labelColor: AppTheme.accentCopper,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(text: 'Basic Info', icon: Icon(Icons.info)),
          Tab(text: 'Preferences', icon: Icon(Icons.tune)),
          Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
        ),
      );
    }

    if (_crew == null || _preferences == null) {
      return const Center(
        child: Text(
          'Failed to load crew data',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildBasicInfoTab(),
        _buildPreferencesTab(),
        _buildNotificationsTab(),
      ],
    );
  }

  Widget _buildBasicInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crew Information',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.accentCopper,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: AppTheme.bodyText.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Crew Name',
                  hintText: 'Enter crew name',
                  labelStyle: TextStyle(color: AppTheme.accentCopper),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.accentCopper.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.accentCopper),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Crew name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: AppTheme.bodyText.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief crew description',
                  labelStyle: TextStyle(color: AppTheme.accentCopper),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.accentCopper.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.accentCopper),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildCrewStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrewStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crew Statistics',
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Members',
                  '${_crew?.memberCount ?? 0}',
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Active Jobs',
                  '${_crew?.activeJobsCount ?? 0}',
                  Icons.work,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Created',
                  _formatDate(_crew?.createdAt),
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Status',
                  _crew?.isActive == true ? 'Active' : 'Inactive',
                  Icons.circle,
                  _crew?.isActive == true ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? iconColor]) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor ?? AppTheme.accentCopper,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Preferences',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.accentCopper,
              ),
            ),
            const SizedBox(height: 20),
            _buildJobTypeSelection(),
            const SizedBox(height: 20),
            _buildConstructionTypeSelection(),
            const SizedBox(height: 20),
            _buildPrivacySettings(),
            const SizedBox(height: 20),
            _buildAutoShareSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Job Types',
          style: AppTheme.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Journeyman Lineman',
            'Journeyman Electrician',
            'Inside Wireman',
            'Journeyman Wireman',
            'Operator',
            'Tree Trimmer',
          ].map((jobType) {
            final isSelected = _preferences?.jobTypes.contains(jobType) ?? false;
            return FilterChip(
              label: Text(jobType),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (_preferences != null) {
                    if (selected) {
                      _preferences!.jobTypes.add(jobType);
                    } else {
                      _preferences!.jobTypes.remove(jobType);
                    }
                  }
                });
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: AppTheme.accentCopper.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.accentCopper : Colors.white,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConstructionTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Construction Types',
          style: AppTheme.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Commercial',
            'Industrial',
            'Residential',
            'Utility',
            'Maintenance',
          ].map((type) {
            final isSelected = _preferences?.constructionTypes.contains(type) ?? false;
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (_preferences != null) {
                    if (selected) {
                      _preferences!.constructionTypes.add(type);
                    } else {
                      _preferences!.constructionTypes.remove(type);
                    }
                  }
                });
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: AppTheme.accentCopper.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.accentCopper : Colors.white,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Settings',
          style: AppTheme.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: Text(
            'Public Crew Profile',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Allow others to find and request to join this crew',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          value: _crew?.isPublic ?? false,
          onChanged: (value) {
            setState(() {
              if (_crew != null) {
                _crew = _crew!.copyWith(isPublic: value);
              }
            });
          },
          activeColor: AppTheme.accentCopper,
        ),
        SwitchListTile(
          title: Text(
            'Require Approval',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Foreman approval required for new members',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          value: _crew?.requireApproval ?? true,
          onChanged: (value) {
            setState(() {
              if (_crew != null) {
                _crew = _crew!.copyWith(requireApproval: value);
              }
            });
          },
          activeColor: AppTheme.accentCopper,
        ),
      ],
    );
  }

  Widget _buildAutoShareSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Auto-Share Settings',
          style: AppTheme.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: Text(
            'Auto-share Matching Jobs',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Automatically share jobs that match crew preferences',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          value: _preferences?.autoShareEnabled ?? false,
          onChanged: (value) {
            setState(() {
              if (_preferences != null) {
                _preferences = _preferences!.copyWith(
                  autoShareEnabled: value,
                );
              }
            });
          },
          activeColor: AppTheme.accentCopper,
        ),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.accentCopper,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text(
                'New Member Notifications',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Get notified when new members join the crew',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              value: true, // TODO: Get from preferences
              onChanged: (value) {
                // TODO: Update preferences
              },
              activeColor: AppTheme.accentCopper,
            ),
            SwitchListTile(
              title: Text(
                'Job Share Notifications',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Get notified when jobs are shared with the crew',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              value: true, // TODO: Get from preferences
              onChanged: (value) {
                // TODO: Update preferences
              },
              activeColor: AppTheme.accentCopper,
            ),
            SwitchListTile(
              title: Text(
                'Message Notifications',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Get notified for new crew messages',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              value: true, // TODO: Get from preferences
              onChanged: (value) {
                // TODO: Update preferences
              },
              activeColor: AppTheme.accentCopper,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.accentCopper.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.accentCopper),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCopper,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }
}
