import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  
  // Personal Information Controllers
  final _firstNameController = TextEditingController(text: 'John');
  final _lastNameController = TextEditingController(text: 'Smith');
  final _emailController = TextEditingController(text: 'john.smith@email.com');
  final _phoneController = TextEditingController(text: '(555) 123-4567');
  final _address1Controller = TextEditingController(text: '123 Electrician Ave');
  final _address2Controller = TextEditingController(text: 'Apt 4B');
  final _cityController = TextEditingController(text: 'Louisville');
  final _stateController = TextEditingController(text: 'KY');
  final _zipcodeController = TextEditingController(text: '40203');
  
  // Professional Information Controllers
  final _homeLocalController = TextEditingController(text: 'IBEW Local 369');
  final _ticketNumberController = TextEditingController(text: 'J123456789');
  final _booksOnController = TextEditingController(text: 'Book 1');
  String _selectedClassification = 'Journeyman Lineman';
  bool _isWorking = true;
  
  // Job Preferences
  final Set<String> _selectedConstructionTypes = {'Distribution', 'Transmission'};
  String _selectedHoursPerWeek = '40+ hours';
  String _selectedPerDiem = 'Yes, required';
  final _preferredLocalsController = TextEditingController(text: 'Local 369, Local 77, Local 613');
  final _careerGoalsController = TextEditingController(text: 'Advance to foreman position, gain more storm restoration experience');
  
  // Notification Settings
  bool _jobAlerts = true;
  bool _stormAlerts = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _weeklyDigest = false;

  final List<String> _classifications = [
    'Journeyman Lineman',
    'Journeyman Electrician',
    'Journeyman Wireman',
    'Journeyman Tree Trimmer',
    'Operator',
  ];

  final List<String> _constructionTypes = [
    'Distribution',
    'Transmission',
    'SubStation',
    'Residential',
    'Industrial',
    'Data Center',
    'Commercial',
    'Underground',
  ];

  final List<String> _hoursOptions = [
    '40+ hours',
    '50+ hours',
    '60+ hours',
    'Open to overtime',
    'Standard hours only',
  ];

  final List<String> _perDiemOptions = [
    'Yes, required',
    'Preferred but not required',
    'Not needed',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _homeLocalController.dispose();
    _ticketNumberController.dispose();
    _booksOnController.dispose();
    _preferredLocalsController.dispose();
    _careerGoalsController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      if (user.displayName != null) {
        final nameParts = user.displayName!.split(' ');
        if (nameParts.isNotEmpty) {
          _firstNameController.text = nameParts.first;
          if (nameParts.length > 1) {
            _lastNameController.text = nameParts.skip(1).join(' ');
          }
        }
      }
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    // TODO: Implement profile saving to backend
    setState(() {
      _isEditing = false;
    });
    JJSnackBar.showSuccess(
      context: context,
      message: 'Profile updated successfully!',
    );
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
    _loadUserData(); // Reset to original values
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _cancelEditing,
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.white),
              onPressed: _toggleEditing,
            ),
        ],
      ),
      body: Column(
        children: [
          // Profile header
          Container(
            color: AppTheme.primaryNavy,
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              0,
              AppTheme.spacingLg,
              AppTheme.spacingLg,
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper,
                    shape: BoxShape.circle,
                    boxShadow: [AppTheme.shadowMd],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_firstNameController.text} ${_lastNameController.text}',
                        style: AppTheme.headlineMedium.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        _selectedClassification,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.accentCopper,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        _homeLocalController.text,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color: AppTheme.primaryNavy,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentCopper,
              labelColor: AppTheme.white,
              unselectedLabelColor: AppTheme.white.withOpacity(0.7),
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Professional'),
                Tab(text: 'Settings'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalTab(),
                _buildProfessionalTab(),
                _buildSettingsTab(),
              ],
            ),
          ),

          // Save button (when editing)
          if (_isEditing)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: JJPrimaryButton(
                text: 'Save Changes',
                icon: Icons.save,
                onPressed: _saveProfile,
                isFullWidth: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Name fields
          Row(
            children: [
              Expanded(
                child: JJTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  enabled: _isEditing,
                  prefixIcon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: JJTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  enabled: _isEditing,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Contact information
          JJTextField(
            label: 'Email',
            controller: _emailController,
            enabled: false, // Email shouldn't be editable
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Phone Number',
            controller: _phoneController,
            enabled: _isEditing,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Text(
            'Address',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Street Address',
            controller: _address1Controller,
            enabled: _isEditing,
            prefixIcon: Icons.home_outlined,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Apartment, suite, etc. (optional)',
            controller: _address2Controller,
            enabled: _isEditing,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: JJTextField(
                  label: 'City',
                  controller: _cityController,
                  enabled: _isEditing,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: JJTextField(
                  label: 'State',
                  controller: _stateController,
                  enabled: _isEditing,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: JJTextField(
                  label: 'ZIP Code',
                  controller: _zipcodeController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IBEW Information',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Home Local',
            controller: _homeLocalController,
            enabled: _isEditing,
            prefixIcon: Icons.business_outlined,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Ticket Number',
            controller: _ticketNumberController,
            enabled: _isEditing,
            prefixIcon: Icons.badge_outlined,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Classification dropdown
          if (_isEditing)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedClassification,
                decoration: const InputDecoration(
                  labelText: 'Classification',
                  prefixIcon: Icon(Icons.work_outline),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingMd,
                  ),
                ),
                items: _classifications.map((classification) {
                  return DropdownMenuItem(
                    value: classification,
                    child: Text(classification),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassification = value!;
                  });
                },
              ),
            )
          else
            JJTextField(
              label: 'Classification',
              controller: TextEditingController(text: _selectedClassification),
              enabled: false,
              prefixIcon: Icons.work_outline,
            ),

          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Books On',
            controller: _booksOnController,
            enabled: _isEditing,
            prefixIcon: Icons.menu_book_outlined,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Working status
          if (_isEditing)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline, color: AppTheme.textSecondary),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    'Currently Working:',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isWorking,
                    onChanged: (value) {
                      setState(() {
                        _isWorking = value;
                      });
                    },
                    activeColor: AppTheme.successGreen,
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline, color: AppTheme.textSecondary),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    'Currently Working:',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: AppTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: _isWorking ? AppTheme.successGreen : AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                    child: Text(
                      _isWorking ? 'Yes' : 'No',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppTheme.spacingLg),

          Text(
            'Job Preferences',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Construction types
          Text(
            'Preferred Construction Types:',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),

          if (_isEditing)
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: _constructionTypes.map((type) {
                final isSelected = _selectedConstructionTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedConstructionTypes.add(type);
                      } else {
                        _selectedConstructionTypes.remove(type);
                      }
                    });
                  },
                  backgroundColor: AppTheme.lightGray,
                  selectedColor: AppTheme.accentCopper,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            )
          else
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: _selectedConstructionTypes.map((type) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    type,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accentCopper,
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: AppTheme.spacingMd),

          // Hours per week
          if (_isEditing)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedHoursPerWeek,
                decoration: const InputDecoration(
                  labelText: 'Preferred Hours per Week',
                  prefixIcon: Icon(Icons.schedule),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingMd,
                  ),
                ),
                items: _hoursOptions.map((hours) {
                  return DropdownMenuItem(
                    value: hours,
                    child: Text(hours),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHoursPerWeek = value!;
                  });
                },
              ),
            )
          else
            JJTextField(
              label: 'Preferred Hours per Week',
              controller: TextEditingController(text: _selectedHoursPerWeek),
              enabled: false,
              prefixIcon: Icons.schedule,
            ),

          const SizedBox(height: AppTheme.spacingMd),

          // Per diem preference
          if (_isEditing)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedPerDiem,
                decoration: const InputDecoration(
                  labelText: 'Per Diem Preference',
                  prefixIcon: Icon(Icons.hotel),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingMd,
                  ),
                ),
                items: _perDiemOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPerDiem = value!;
                  });
                },
              ),
            )
          else
            JJTextField(
              label: 'Per Diem Preference',
              controller: TextEditingController(text: _selectedPerDiem),
              enabled: false,
              prefixIcon: Icons.hotel,
            ),

          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Preferred Locals',
            controller: _preferredLocalsController,
            enabled: _isEditing,
            prefixIcon: Icons.location_on_outlined,
            maxLines: 2,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          JJTextField(
            label: 'Career Goals',
            controller: _careerGoalsController,
            enabled: _isEditing,
            prefixIcon: Icons.flag_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Preferences',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          _buildSettingsTile(
            'Job Alerts',
            'Get notified about new job opportunities',
            Icons.work_outline,
            _jobAlerts,
            (value) => setState(() => _jobAlerts = value),
          ),

          _buildSettingsTile(
            'Storm Work Alerts',
            'Emergency storm restoration notifications',
            Icons.flash_on,
            _stormAlerts,
            (value) => setState(() => _stormAlerts = value),
          ),

          _buildSettingsTile(
            'Email Notifications',
            'Receive notifications via email',
            Icons.email_outlined,
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),

          _buildSettingsTile(
            'Push Notifications',
            'Receive push notifications on your device',
            Icons.notifications_outlined,
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
          ),

          _buildSettingsTile(
            'Weekly Digest',
            'Summary of job opportunities each week',
            Icons.summarize_outlined,
            _weeklyDigest,
            (value) => setState(() => _weeklyDigest = value),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Text(
            'Account Actions',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          _buildActionTile(
            'Change Password',
            'Update your account password',
            Icons.lock_outline,
            () {
              JJSnackBar.showSuccess(
                context: context,
                message: 'Password change feature coming soon',
              );
            },
          ),

          _buildActionTile(
            'Download My Data',
            'Download a copy of your profile data',
            Icons.download_outlined,
            () {
              JJSnackBar.showSuccess(
                context: context,
                message: 'Data download feature coming soon',
              );
            },
          ),

          _buildActionTile(
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_outline,
            () {
              _showDeleteAccountDialog();
            },
            isDestructive: true,
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Text(
            'App Information',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          _buildInfoTile('Version', '1.0.0'),
          _buildInfoTile('Build', '2024.1'),
          _buildInfoTile('Last Updated', 'Today'),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        secondary: Icon(icon, color: AppTheme.accentCopper),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.successGreen,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppTheme.errorRed : AppTheme.accentCopper,
        ),
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: isDestructive ? AppTheme.errorRed : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textLight,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: AppTheme.errorRed,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Delete Account',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.errorRed,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                JJSnackBar.showError(
                  context: context,
                  message: 'Account deletion feature coming soon',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}