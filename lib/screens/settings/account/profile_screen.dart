import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../electrical_components/jj_circuit_breaker_switch.dart';
import '../../../services/avatar_service.dart';
import '../../../navigation/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _editButtonKey = GlobalKey();
  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  
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
  String _selectedHoursPerWeek = 'Open to overtime';
  String _selectedPerDiem = 'Yes, required';
  final _preferredLocalsController = TextEditingController(text: 'Local 369, Local 77, Local 613');
  final _careerGoalsController = TextEditingController(text: 'Advance to foreman position, gain more storm restoration experience');
  
  // Additional onboarding fields that were missing
  bool _networkWithOthers = true;
  bool _careerAdvancements = false;
  bool _betterBenefits = true;
  bool _higherPayRate = true;
  bool _learnNewSkill = false;
  bool _travelToNewLocation = true;
  bool _findLongTermWork = false;
  final _howHeardAboutUsController = TextEditingController(text: 'Referred by IBEW Local 369');
  final _lookingToAccomplishController = TextEditingController(text: 'Find steady work with good benefits and advancement opportunities');

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
    '40',
    '40-50', 
    '50-60',
    '60-70',
    '>70',
    'Open to overtime',
    'Standard hours only',
  ];

  final List<String> _perDiemOptions = [
    '100-150',
    '150-200', 
    '200+',
    'Yes, required',
    'Preferred but not required',
    'Not needed',
  ];

  final List<String> _usStates = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _hideTooltip();
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
    _howHeardAboutUsController.dispose();
    _lookingToAccomplishController.dispose();
    super.dispose();
  }

  bool _isKeyboardVisible() {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          
          // Personal Information
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = data['phone'] ?? '';
          _address1Controller.text = data['address1'] ?? '';
          _address2Controller.text = data['address2'] ?? '';
          _cityController.text = data['city'] ?? '';
          _stateController.text = data['state'] ?? '';
          _zipcodeController.text = data['zipcode'] ?? '';
          _avatarUrl = data['avatarUrl'];
          
          // Professional Information
          _homeLocalController.text = data['home_local'] ?? '';
          _ticketNumberController.text = data['ticket_number'] ?? '';
          _booksOnController.text = data['books_on'] ?? '';
          _selectedClassification = data['classification'] ?? 'Journeyman Lineman';
          _isWorking = data['is_working'] ?? true;
          
          // Job Preferences
          final constructionTypes = List<String>.from(data['construction_types'] ?? []);
          if (constructionTypes.isNotEmpty) {
            _selectedConstructionTypes.clear();
            _selectedConstructionTypes.addAll(constructionTypes);
          }
          _selectedHoursPerWeek = data['hours_per_week'] ?? 'Open to overtime';
          _selectedPerDiem = data['per_diem'] ?? 'Yes, required';
          _preferredLocalsController.text = data['preferred_locals'] ?? '';
          _careerGoalsController.text = data['career_goals'] ?? '';
          
          // Goals
          _networkWithOthers = data['networkWithOthers'] ?? false;
          _careerAdvancements = data['careerAdvancements'] ?? false;
          _betterBenefits = data['betterBenefits'] ?? false;
          _higherPayRate = data['higherPayRate'] ?? false;
          _learnNewSkill = data['learnNewSkill'] ?? false;
          _travelToNewLocation = data['travelToNewLocation'] ?? false;
          _findLongTermWork = data['findLongTermWork'] ?? false;
          
          // Additional Information
          _howHeardAboutUsController.text = data['how_heard_about_us'] ?? '';
          _lookingToAccomplishController.text = data['lookingToAccomplish'] ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error loading profile data: ${e.toString()}',
        );
      }
    }
  }

  void _toggleEditing() {
    _hideTooltip();
    setState(() {
      _isEditing = !_isEditing;
    });
  }
  

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Disable editing mode immediately to prevent double-saves
      setState(() {
        _isEditing = false;
      });

      // Basic validation
      if (_firstNameController.text.trim().isEmpty || 
          _lastNameController.text.trim().isEmpty) {
        JJSnackBar.showError(
          context: context,
          message: 'Please enter your first and last name',
        );
        setState(() {
          _isEditing = true; // Re-enable editing on validation error
        });
        return;
      }

      // Show loading indicator (removed unused widget creation)

      // Prepare data for Firestore
      final profileData = {
        // Personal Information
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'address1': _address1Controller.text.trim().isEmpty ? null : _address1Controller.text.trim(),
        'address2': _address2Controller.text.trim().isEmpty ? null : _address2Controller.text.trim(),
        'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        'state': _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        'zipcode': _zipcodeController.text.trim().isEmpty ? null : _zipcodeController.text.trim(),
        
        // Professional Information
        'home_local': _homeLocalController.text.trim().isEmpty ? null : _homeLocalController.text.trim(),
        'ticket_number': _ticketNumberController.text.trim().isEmpty ? null : _ticketNumberController.text.trim(),
        'books_on': _booksOnController.text.trim().isEmpty ? null : _booksOnController.text.trim(),
        'classification': _selectedClassification,
        'is_working': _isWorking,
        
        // Job Preferences
        'construction_types': _selectedConstructionTypes.toList(),
        'hours_per_week': _selectedHoursPerWeek,
        'per_diem': _selectedPerDiem,
        'preferred_locals': _preferredLocalsController.text.trim().isEmpty ? null : _preferredLocalsController.text.trim(),
        'career_goals': _careerGoalsController.text.trim().isEmpty ? null : _careerGoalsController.text.trim(),
        
        // Goals
        'networkWithOthers': _networkWithOthers,
        'careerAdvancements': _careerAdvancements,
        'betterBenefits': _betterBenefits,
        'higherPayRate': _higherPayRate,
        'learnNewSkill': _learnNewSkill,
        'travelToNewLocation': _travelToNewLocation,
        'findLongTermWork': _findLongTermWork,
        
        // Additional Information
        'how_heard_about_us': _howHeardAboutUsController.text.trim().isEmpty ? null : _howHeardAboutUsController.text.trim(),
        'lookingToAccomplish': _lookingToAccomplishController.text.trim().isEmpty ? null : _lookingToAccomplishController.text.trim(),
        
        // Metadata
        'updated_time': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      // Update Firebase Auth display name if needed
      final newDisplayName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      if (user.displayName != newDisplayName) {
        await user.updateDisplayName(newDisplayName);
      }

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Profile updated successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEditing = true; // Re-enable editing on error
        });
        JJSnackBar.showError(
          context: context,
          message: 'Error saving profile: ${e.toString()}',
        );
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
    _loadUserData(); // Reset to original values from Firestore
  }

  Future<void> _handleAvatarTap() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);

              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);

              },
            ),
            if (_avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorRed),
                title: const Text('Remove Photo', style: TextStyle(color: AppTheme.errorRed)),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      final avatarService = AvatarService();
      final avatarUrl = await avatarService.uploadAvatar(source);

      if (avatarUrl != null) {
        setState(() {
          _avatarUrl = avatarUrl;
          _isUploadingAvatar = false;
        });

        if (mounted) {
          JJSnackBar.showSuccess(
            context: context,
            message: 'Profile photo updated successfully!',
          );
        }
      } else {
        setState(() {
          _isUploadingAvatar = false;
        });

        if (mounted) {
          JJSnackBar.showError(
            context: context,
            message: 'Failed to upload photo',
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });

      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to upload photo: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    try {
      final avatarService = AvatarService();
      await avatarService.deleteOldAvatar(_avatarUrl);

      // Update Firestore to remove avatar URL
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'avatarUrl': FieldValue.delete()});
      }

      setState(() {
        _avatarUrl = null;
      });

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Profile photo removed',
        );
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to remove photo: ${e.toString()}',
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.errorRed,
              size: AppTheme.iconMd,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              'Delete Account?',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          JJPrimaryButton(
            text: 'Delete',
            onPressed: () {
              Navigator.of(context).pop();
              JJSnackBar.showSuccess(
                context: context,
                message: 'Account deletion feature coming soon',
              );
            },
            width: 100,
            variant: JJButtonVariant.danger,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'My Profile',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.white),
        actions: [
          IconButton(
            key: _editButtonKey,
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _isEditing ? _cancelEditing : _toggleEditing,
            color: AppTheme.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile header with avatar
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              boxShadow: [AppTheme.shadowMd],
            ),
            child: Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: _isEditing ? _handleAvatarTap : null,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.lightGray,
                        backgroundImage: _avatarUrl != null
                            ? CachedNetworkImageProvider(_avatarUrl!)
                            : null,
                        child: _avatarUrl == null
                            ? Text(
                                '${_firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : ''}${_lastNameController.text.isNotEmpty ? _lastNameController.text[0].toUpperCase() : ''}',
                                style: AppTheme.headlineMedium.copyWith(
                                  color: AppTheme.primaryNavy,
                                ),
                              )
                            : null,
                      ),
                      if (_isUploadingAvatar)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCopper,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? '${_firstNameController.text} ${_lastNameController.text}',
                        style: AppTheme.headlineMedium.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        user?.email ?? _emailController.text,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.white.withValues(alpha: 0.8),
                        ),
                      ),
                      if (_homeLocalController.text.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          _homeLocalController.text,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.accentCopper,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            color: AppTheme.primaryNavy,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentCopper,
              labelColor: AppTheme.white,
              unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
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
          // Save button (when editing and keyboard is not visible)
          if (_isEditing && !_isKeyboardVisible())
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: JJPrimaryButton(
                  text: 'Save Changes',
                  icon: Icons.save,
                  onPressed: _saveProfile,
                  isFullWidth: true,
                  variant: JJButtonVariant.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
 
  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd + MediaQuery.of(context).padding.bottom + (_isEditing && !_isKeyboardVisible() ? 80 : 0),
      ),
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
            label: 'Apartment, suite, etc.',
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
              SizedBox(
                width: 100,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.lightGray),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _stateController.text.isEmpty ? null : _stateController.text,
                    decoration: InputDecoration(
                      labelText: 'State',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      enabled: _isEditing,
                    ),
                    items: _usStates.map((state) {
                      return DropdownMenuItem(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: _isEditing
                        ? (value) => setState(() => _stateController.text = value ?? '')
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          JJTextField(
            label: 'ZIP Code',
            controller: _zipcodeController,
            enabled: _isEditing,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'What brings you to Journeyman Jobs?',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildGoalChip('Network with Others', _networkWithOthers, 
            (value) => setState(() => _networkWithOthers = value)),
          _buildGoalChip('Career Advancements', _careerAdvancements,
            (value) => setState(() => _careerAdvancements = value)),
          _buildGoalChip('Better Benefits', _betterBenefits,
            (value) => setState(() => _betterBenefits = value)),
          _buildGoalChip('Higher Pay Rate', _higherPayRate,
            (value) => setState(() => _higherPayRate = value)),
          _buildGoalChip('Learn New Skill', _learnNewSkill,
            (value) => setState(() => _learnNewSkill = value)),
          _buildGoalChip('Travel to New Location', _travelToNewLocation,
            (value) => setState(() => _travelToNewLocation = value)),
          _buildGoalChip('Find Long Term Work', _findLongTermWork,
            (value) => setState(() => _findLongTermWork = value)),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Additional Information',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          JJTextField(
            label: 'How did you hear about us?',
            controller: _howHeardAboutUsController,
            enabled: _isEditing,
            prefixIcon: Icons.campaign_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          JJTextField(
            label: 'What are you looking to accomplish?',
            controller: _lookingToAccomplishController,
            enabled: _isEditing,
            prefixIcon: Icons.track_changes_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd + MediaQuery.of(context).padding.bottom + (_isEditing && !_isKeyboardVisible() ? 80 : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Information',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          JJTextField(
            label: 'Home Local',
            controller: _homeLocalController,
            enabled: _isEditing,
            prefixIcon: Icons.location_city_outlined,
            hintText: 'e.g., IBEW Local 369',

          ),
          const SizedBox(height: AppTheme.spacingMd),
          JJTextField(
            label: 'Ticket Number',
            controller: _ticketNumberController,
            enabled: _isEditing,
            prefixIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedClassification,
              decoration: const InputDecoration(
                labelText: 'Classification',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                prefixIcon: Icon(Icons.work_outline),
              ),
              items: _classifications.map((classification) {
                return DropdownMenuItem(
                  value: classification,
                  child: Text(classification),
                );
              }).toList(),
              onChanged: _isEditing
                  ? (value) => setState(() => _selectedClassification = value!)
                  : null,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildStatusToggle(),
          const SizedBox(height: AppTheme.spacingMd),
          JJTextField(
            label: 'Books On',
            controller: _booksOnController,
            enabled: _isEditing,
            prefixIcon: Icons.menu_book_outlined,
            hintText: 'e.g., Book 1, Book 2',

          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Job Preferences',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Construction types with electrical icons
          Text(
            'Construction Types',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          // Show chips in edit mode, static display otherwise
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
                  side: isSelected 
                    ? BorderSide(color: AppTheme.primaryNavy, width: AppTheme.borderWidthThick)
                    : null,
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
                    color: AppTheme.accentCopper.withValues(alpha: 0.1),
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
                initialValue: _selectedHoursPerWeek,
                decoration: const InputDecoration(
                  labelText: 'Hours per Week',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: _hoursOptions.map((hours) {
                  return DropdownMenuItem(
                    value: hours,
                    child: Text(hours),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedHoursPerWeek = value!),
              ),
            )
          else
            _buildReadOnlyField('Hours per Week', _selectedHoursPerWeek, Icons.schedule),

          const SizedBox(height: AppTheme.spacingMd),

          // Per diem
          if (_isEditing)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPerDiem,
                decoration: const InputDecoration(
                  labelText: 'Per Diem',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                items: _perDiemOptions.map((perDiem) {
                  return DropdownMenuItem(
                    value: perDiem,
                    child: Text(perDiem),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPerDiem = value!),
              ),
            )
          else
            _buildReadOnlyField('Per Diem', _selectedPerDiem, Icons.attach_money),

          const SizedBox(height: AppTheme.spacingMd),
          JJTextField(
            label: 'Preferred Locals',
            controller: _preferredLocalsController,
            enabled: _isEditing,
            prefixIcon: Icons.star_outline,
            hintText: 'e.g., Local 369, Local 77',

            maxLines: 2,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          JJTextField(
            label: 'Career Goals',
            controller: _careerGoalsController,
            enabled: _isEditing,
            prefixIcon: Icons.trending_up,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd + MediaQuery.of(context).padding.bottom + (_isEditing && !_isKeyboardVisible() ? 80 : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings & Preferences',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Quick Settings Navigation
          _buildNavigationTile(
            'App Settings',
            'Appearance, language, units, and more',
            Icons.settings,
            () {
              context.push('/settings/app');
            },
          ),
          _buildNavigationTile(
            'Notification Settings',
            'Manage alerts and notification preferences',
            Icons.notifications_outlined,
            () {
              context.go('${AppRouter.notifications}?tab=settings');
            },
          ),
          _buildNavigationTile(
            'Privacy & Security',
            'Manage your privacy and security settings',
            Icons.security,
            () {
              context.push('/settings/app');
            },
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
            'Support & About',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildNavigationTile(
            'Help & Support',
            'Get help or contact support',
            Icons.help_outline,
            () {
              // Navigate to help
            },
          ),
          _buildNavigationTile(
            'Terms of Service',
            'View terms and conditions',
            Icons.description,
            () {
              // Navigate to terms
            },
          ),
          _buildNavigationTile(
            'Privacy Policy',
            'View privacy policy',
            Icons.privacy_tip,
            () {
              // Navigate to privacy
            },
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

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: AppTheme.accentCopper.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentCopper,
            size: AppTheme.iconMd,
          ),
        ),
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
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textLight,
        ),
        onTap: onTap,
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
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalChip(String label, bool isSelected, Function(bool) onSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: _isEditing ? onSelected : null,
        backgroundColor: AppTheme.lightGray,
        selectedColor: AppTheme.accentCopper,
        side: isSelected 
            ? BorderSide(color: AppTheme.primaryNavy, width: AppTheme.borderWidthThick)
            : null,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.white : AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Row(
        children: [
          Icon(
            Icons.work_history,
            color: AppTheme.accentCopper,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employment Status',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  _isWorking ? 'Currently Working' : 'On the Books',
                  style: AppTheme.bodySmall.copyWith(
                    color: _isWorking ? AppTheme.successGreen : AppTheme.accentCopper,
                  ),
                ),
              ],
            ),
          ),
          JJCircuitBreakerSwitch(
            value: _isWorking,
            onChanged: _isEditing
                ? (value) => setState(() => _isWorking = value)
                : null,
            size: JJCircuitBreakerSize.small,
            showElectricalEffects: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Arrow painter for tooltip
class ArrowPainter extends CustomPainter {
  final Color color;
  
  ArrowPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center (point of arrow)
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
