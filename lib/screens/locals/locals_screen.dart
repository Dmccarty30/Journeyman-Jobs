import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '/models/locals_record.dart';
import '/design_system/app_theme.dart';
import '/providers/riverpod/locals_riverpod_provider.dart';
import 'dart:io' show Platform;
import '../../widgets/notification_badge.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/app_router.dart';

class LocalsScreen extends ConsumerStatefulWidget {
  const LocalsScreen({super.key});

  @override
  ConsumerState<LocalsScreen> createState() => _LocalsScreenState();
}

class _LocalsScreenState extends ConsumerState<LocalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(localsProvider.notifier).loadLocals();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(localsProvider.notifier).loadLocals(loadMore: true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('IBEW Locals Directory'),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        actions: [
          NotificationBadge(
            iconColor: AppTheme.white,
            showPopupOnTap: false,
            onTap: () {
              context.push(AppRouter.notifications);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: TextField(
              controller: _searchController,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'Search by local number, city, or state...',
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.white.withAlpha(179)
                ),
                prefixIcon: const Icon(Icons.search, color: AppTheme.white),
                filled: true,
                fillColor: AppTheme.white.withAlpha(26),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(
                    color: AppTheme.accentCopper, 
                    width: 2
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
                // Handle search on the UI side for now
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // State filter dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: DropdownButton<String>(
              value: _selectedState,
              hint: const Text('Filter by State'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All States'),
                ),
                // Common states - you can expand this list
                ...['CA', 'TX', 'NY', 'FL', 'PA', 'IL', 'OH', 'GA', 'NC', 'MI']
                    .map((state) => DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
                ref.read(localsProvider.notifier).loadLocals();
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Locals list
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final localsState = ref.watch(localsProvider);
                return _buildLocalsList(localsState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalsList(LocalsState localsState) {
    if (localsState.isLoading && localsState.locals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
        ),
      );
    }

    if (localsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppTheme.iconXxl,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Error loading locals',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.errorRed
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              localsState.error!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: () => ref.read(localsProvider.notifier).loadLocals(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter locals based on search query
    List<LocalsRecord> filteredLocals = localsState.locals;
    if (_searchQuery.isNotEmpty) {
      filteredLocals = localsState.locals.where((local) {
        return local.localUnion.toLowerCase().contains(_searchQuery) ||
               local.city.toLowerCase().contains(_searchQuery) ||
               local.state.toLowerCase().contains(_searchQuery) ||
               (local.classification?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    if (filteredLocals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: AppTheme.iconXxl,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              _searchQuery.isEmpty 
                  ? 'No locals found' 
                  : 'No results found',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.textLight
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Try adjusting your search',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textLight
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: filteredLocals.length,
      itemBuilder: (context, index) {

        final local = filteredLocals[index];
        return LocalCard(
          local: local,
          onTap: () => _showLocalDetails(context, local),
        );
      },
    );
  }

  void _showLocalDetails(BuildContext context, LocalsRecord local) {
    showDialog(
      context: context,
      builder: (context) => LocalDetailsDialog(local: local),
    );
  }
}

class LocalCard extends StatelessWidget {
  final LocalsRecord local;
  final VoidCallback onTap;

  const LocalCard({
    super.key,
    required this.local,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local ${local.localUnion}',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.primaryNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          '${local.city}, ${local.state}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: AppTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCopper.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: AppTheme.iconSm,
                      color: AppTheme.accentCopper,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (local.address?.isNotEmpty == true) ...[
                    _buildInfoRow(
                      context,
                      'Address',
                      local.address!,
                      Icons.location_on_outlined,
                      canTap: true,
                      onTap: () => _launchMaps(local.address!, local.city, local.state),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                  ],
                  if (local.phone.isNotEmpty) ...[
                    _buildInfoRow(
                      context,
                      'Phone',
                      local.phone,
                      Icons.phone_outlined,
                      canTap: true,
                      onTap: () => _launchPhone(local.phone),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                  ],
                  if (local.email.isNotEmpty) ...[
                    _buildInfoRow(
                      context,
                      'Email',
                      local.email,
                      Icons.email_outlined,
                      canTap: true,
                      onTap: () => _launchEmail(local.email),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                  ],
                  if (local.website?.isNotEmpty == true) ...[
                    _buildInfoRow(
                      context,
                      'Website',
                      local.website!,
                      Icons.language_outlined,
                      canTap: true,
                      onTap: () => _launchWebsite(local.website!),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                  ],
                  _buildInfoRow(
                    context,
                    'Classification',
                    local.classification ?? 'Unknown',
                    Icons.work_outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool canTap = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: canTap ? onTap : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppTheme.iconMd,
            color: AppTheme.textLight,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: AppTheme.bodyMedium.copyWith(
                      color: canTap ? AppTheme.accentCopper : AppTheme.textDark,
                      decoration: canTap ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final Uri webUri = Uri.parse(url);
    
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMaps(String address, String city, String state) async {
    final fullAddress = '$address, $city, $state';
    final encodedAddress = Uri.encodeComponent(fullAddress);
    
    Uri mapsUri;
    if (Platform.isIOS) {
      mapsUri = Uri.parse('maps://?q=$encodedAddress');
      if (!await canLaunchUrl(mapsUri)) {
        mapsUri = Uri.parse('https://maps.apple.com/?q=$encodedAddress');
      }
    } else {
      mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress'
      );
    }
    
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }
}

class LocalDetailsDialog extends StatelessWidget {
  final LocalsRecord local;

  const LocalDetailsDialog({super.key, required this.local});

  @override
  Widget build(BuildContext context) {
    // Check if this local has multiple offices
    final hasMultipleOffices = _hasMultipleOffices();
    
    return Dialog(
      backgroundColor: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Navy background
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: const BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLg),
                  topRight: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IBEW Local ${local.localUnion}',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          '${local.city}, ${local.state}',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.white.withAlpha(204),
                          ),
                        ),
                        if (local.classification != null) ...[
                          const SizedBox(height: AppTheme.spacingXs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: AppTheme.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCopper.withAlpha(51),
                              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                            ),
                            child: Text(
                              local.classification!,
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.white,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.white.withAlpha(26),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasMultipleOffices)
                      _buildMultipleOffices(context)
                    else
                      _buildSingleOffice(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasMultipleOffices() {
    if (local.data == null) return false;
    
    // Check for patterns indicating multiple offices
    final data = local.data!;
    return data.containsKey('office2_address') ||
           data.containsKey('office_2_address') ||
           data.containsKey('second_office') ||
           data.containsKey('additional_offices') ||
           (data.containsKey('offices') && data['offices'] is List);
  }

  Widget _buildSingleOffice(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Contact Information'),
        const SizedBox(height: AppTheme.spacingMd),
        _buildContactCard(
          context,
          address: local.address,
          phone: local.phone,
          email: local.email,
          website: local.website,
        ),
        if (local.data?.isNotEmpty == true && 
            !_shouldSkipAdditionalInfo()) ...[
          const SizedBox(height: AppTheme.spacingLg),
          _buildSectionHeader('Additional Information'),
          const SizedBox(height: AppTheme.spacingMd),
          _buildAdditionalInfo(),
        ],
      ],
    );
  }

  Widget _buildMultipleOffices(BuildContext context) {
    final offices = _extractOffices();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < offices.length; i++) ...[
          if (i > 0) const SizedBox(height: AppTheme.spacingLg),
          _buildSectionHeader(offices[i]['name'] ?? 'Office ${i + 1}'),
          const SizedBox(height: AppTheme.spacingMd),
          _buildContactCard(
            context,
            address: offices[i]['address'],
            phone: offices[i]['phone'],
            fax: offices[i]['fax'],
            email: offices[i]['email'],
            website: offices[i]['website'],
          ),
          if (offices[i]['meeting'] != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            _buildMeetingInfo(offices[i]['meeting']),
          ],
        ],
        if (local.data?.isNotEmpty == true && 
            !_shouldSkipAdditionalInfo()) ...[
          const SizedBox(height: AppTheme.spacingLg),
          _buildSectionHeader('Additional Information'),
          const SizedBox(height: AppTheme.spacingMd),
          _buildAdditionalInfo(),
        ],
      ],
    );
  }

  List<Map<String, String?>> _extractOffices() {
    final offices = <Map<String, String?>>[];
    final data = local.data ?? {};
    
    // Check for structured offices list
    if (data['offices'] is List) {
      for (var office in data['offices']) {
        if (office is Map<String, dynamic>) {
          offices.add({
            'name': office['name']?.toString(),
            'address': office['address']?.toString(),
            'phone': office['phone']?.toString(),
            'fax': office['fax']?.toString(),
            'email': office['email']?.toString(),
            'website': office['website']?.toString(),
            'meeting': office['meeting']?.toString(),
          });
        }
      }
      return offices;
    }
    
    // Main office
    offices.add({
      'name': 'Main Office',
      'address': local.address,
      'phone': local.phone,
      'fax': data['fax']?.toString(),
      'email': local.email,
      'website': local.website,
      'meeting': data['meeting']?.toString() ?? data['meeting_time']?.toString(),
    });
    
    // Check for additional offices with various naming patterns
    final officePatterns = [
      ['office2', 'Office 2'],
      ['office_2', 'Office 2'],
      ['second_office', 'Second Office'],
      ['branch_office', 'Branch Office'],
    ];
    
    for (var pattern in officePatterns) {
      final prefix = pattern[0];
      final name = pattern[1];
      
      if (data['${prefix}_address'] != null ||
          data['${prefix}_phone'] != null) {
        offices.add({
          'name': name,
          'address': data['${prefix}_address']?.toString(),
          'phone': data['${prefix}_phone']?.toString(),
          'fax': data['${prefix}_fax']?.toString(),
          'email': data['${prefix}_email']?.toString(),
          'website': data['${prefix}_website']?.toString(),
          'meeting': data['${prefix}_meeting']?.toString(),
        });
      }
    }
    
    return offices;
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.accentCopper,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    String? address,
    String? phone,
    String? fax,
    String? email,
    String? website,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.lightGray,
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Column(
        children: [
          if (address?.isNotEmpty == true)
            _buildClickableRow(
              context,
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: address!,
              iconColor: AppTheme.accentCopper,
              onTap: () => _launchMaps(address, local.city, local.state),
            ),
          if (phone?.isNotEmpty == true)
            _buildClickableRow(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: phone!,
              iconColor: AppTheme.accentCopper,
              onTap: () => _launchPhone(phone),
            ),
          if (fax?.isNotEmpty == true)
            _buildClickableRow(
              context,
              icon: Icons.print_outlined,
              label: 'Fax',
              value: fax!,
              iconColor: AppTheme.textLight,
            ),
          if (email?.isNotEmpty == true)
            _buildClickableRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: email!,
              iconColor: AppTheme.accentCopper,
              onTap: () => _launchEmail(email),
            ),
          if (website?.isNotEmpty == true)
            _buildClickableRow(
              context,
              icon: Icons.language_outlined,
              label: 'Website',
              value: website!,
              iconColor: AppTheme.accentCopper,
              onTap: () => _launchWebsite(website),
            ),
        ],
      ),
    );
  }

  Widget _buildClickableRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final isClickable = onTap != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingSm,
            horizontal: AppTheme.spacingXs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: AppTheme.iconMd,
                color: iconColor,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textLight,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isClickable ? AppTheme.accentCopper : AppTheme.textDark,
                        decoration: isClickable ? TextDecoration.underline : null,
                        decorationColor: AppTheme.accentCopper,
                        fontWeight: isClickable ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (isClickable)
                Icon(
                  Icons.open_in_new,
                  size: AppTheme.iconSm,
                  color: AppTheme.accentCopper.withAlpha(153),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingInfo(String? meetingInfo) {
    if (meetingInfo == null || meetingInfo.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.warningYellow.withAlpha(26),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.warningYellow.withAlpha(102),
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.event_outlined,
            size: AppTheme.iconMd,
            color: AppTheme.warningYellow,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meeting Times',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  meetingInfo,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldSkipAdditionalInfo() {
    if (local.data == null) return true;
    
    // Keys to skip in additional info (already displayed elsewhere)
    final skipKeys = [
      'address', 'phone', 'email', 'website', 'fax',
      'office2_address', 'office2_phone', 'office2_email', 'office2_website', 'office2_fax',
      'office_2_address', 'office_2_phone', 'office_2_email', 'office_2_website', 'office_2_fax',
      'offices', 'meeting', 'meeting_time', 'classification',
      'city', 'state', 'local_union', 'local_name',
    ];
    
    return !local.data!.entries.any((entry) => 
      !skipKeys.contains(entry.key.toLowerCase()) && 
      entry.value != null && 
      entry.value.toString().isNotEmpty
    );
  }

  Widget _buildAdditionalInfo() {
    final skipKeys = [
      'address', 'phone', 'email', 'website', 'fax',
      'office2_address', 'office2_phone', 'office2_email', 'office2_website', 'office2_fax',
      'office_2_address', 'office_2_phone', 'office_2_email', 'office_2_website', 'office_2_fax',
      'offices', 'meeting', 'meeting_time', 'classification',
      'city', 'state', 'local_union', 'local_name',
    ];
    
    final additionalEntries = local.data!.entries
        .where((entry) => !skipKeys.contains(entry.key.toLowerCase()))
        .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
        .toList();
    
    if (additionalEntries.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withAlpha(102),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.mediumGray.withAlpha(51),
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: additionalEntries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacingXs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${_formatKey(entry.key)}: ',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                        TextSpan(
                          text: entry.value.toString(),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final Uri webUri = Uri.parse(url);
    
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMaps(String address, String city, String state) async {
    final fullAddress = '$address, $city, $state';
    final encodedAddress = Uri.encodeComponent(fullAddress);
    
    Uri mapsUri;
    if (Platform.isIOS) {
      mapsUri = Uri.parse('maps://?q=$encodedAddress');
      if (!await canLaunchUrl(mapsUri)) {
        mapsUri = Uri.parse('https://maps.apple.com/?q=$encodedAddress');
      }
    } else {
      mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress'
      );
    }
    
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }
}