import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '/models/locals_record.dart';
import '/design_system/app_theme.dart';
import '/providers/app_state_provider.dart';
import 'dart:io' show Platform;

class LocalsScreen extends StatefulWidget {
  const LocalsScreen({super.key});

  @override
  State<LocalsScreen> createState() => _LocalsScreenState();
}

class _LocalsScreenState extends State<LocalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().refreshLocals();
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
    final appStateProvider = context.read<AppStateProvider>();
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8 && 
        !appStateProvider.isLoadingLocals && 
        appStateProvider.hasMoreLocals) {
      appStateProvider.loadMoreLocals();
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
                // Note: Search functionality would need to be implemented in AppStateProvider
                // For now, we'll handle search on the UI side in the Consumer
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
                context.read<AppStateProvider>().refreshLocals();
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Locals list
          Expanded(
            child: Consumer<AppStateProvider>(
              builder: (context, appStateProvider, child) {
                return _buildLocalsList(appStateProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalsList(AppStateProvider appStateProvider) {
    if (appStateProvider.isLoadingLocals && appStateProvider.locals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
        ),
      );
    }

    if (appStateProvider.localsError != null) {
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
              appStateProvider.localsError!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: () => appStateProvider.refreshLocals(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter locals based on search query
    List<LocalsRecord> filteredLocals = appStateProvider.locals;
    if (_searchQuery.isNotEmpty) {
      filteredLocals = appStateProvider.locals.where((local) {
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
      itemCount: filteredLocals.length + (appStateProvider.hasMoreLocals ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredLocals.length) {
          // Loading indicator at the bottom
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: appStateProvider.isLoadingLocals
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                    )
                  : ElevatedButton(
                      onPressed: () => appStateProvider.loadMoreLocals(),
                      child: const Text('Load More'),
                    ),
            ),
          );
        }

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
                  if (local.phone?.isNotEmpty == true) ...[
                    _buildInfoRow(
                      context,
                      'Phone',
                      local.phone!,
                      Icons.phone_outlined,
                      canTap: true,
                      onTap: () => _launchPhone(local.phone!),
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
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppTheme.primaryNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            '${local.city}, ${local.state}',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: AppTheme.textLight,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),
                // Details
                _buildDetailRow('Classification', local.classification ?? 'Unknown'),
                _buildDetailRow('Address', local.address ?? 'Not specified'),
                _buildDetailRow('Phone', local.phone ?? 'Not specified'),
                _buildDetailRow('Email', local.email),
                _buildDetailRow('Website', local.website ?? 'Not specified'),
                const SizedBox(height: AppTheme.spacingLg),
                // Additional Information
                if (local.data?.isNotEmpty == true) ...[
                  Text(
                    'Additional Information',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.mediumGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: local.data!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingXs,
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${entry.key}: ',
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
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
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
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}