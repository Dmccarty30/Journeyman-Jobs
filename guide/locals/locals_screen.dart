import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '/backend/schema/locals_record.dart';
import '/design_system/app_theme.dart';
import 'dart:io' show Platform;

class LocalsScreen extends StatefulWidget {
  const LocalsScreen({Key? key}) : super(key: key);

  @override
  State<LocalsScreen> createState() => _LocalsScreenState();
}

class _LocalsScreenState extends State<LocalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: AppTheme.white),
                filled: true,
                fillColor: AppTheme.white.withOpacity(0.1),
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
                  borderSide: const BorderSide(color: AppTheme.accentCopper, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<LocalsRecord>>(
        stream: FirebaseFirestore.instance
            .collection('locals')
            .orderBy('local_union')
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => LocalsRecord.fromSnapshot(doc))
                .where((local) {
                  if (_searchQuery.isEmpty) return true;
                  return local.localUnion.toLowerCase().contains(_searchQuery) ||
                      local.city.toLowerCase().contains(_searchQuery) ||
                      local.state.toLowerCase().contains(_searchQuery) ||
                      local.classification.toLowerCase().contains(_searchQuery);
                })
                .toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppTheme.iconXxl,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Error loading locals',
                    style: AppTheme.headlineSmall.copyWith(color: AppTheme.error),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Please try again later',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
            );
          }

          final locals = snapshot.data ?? [];

          if (locals.isEmpty) {
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
                    _searchQuery.isEmpty ? 'No locals found' : 'No results found',
                    style: AppTheme.headlineSmall.copyWith(color: AppTheme.textLight),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Try adjusting your search',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: locals.length,
            itemBuilder: (context, index) {
              final local = locals[index];
              return LocalCard(
                local: local,
                onTap: () => _showLocalDetails(context, local),
              );
            },
          );
        },
      ),
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
    Key? key,
    required this.local,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with local number and location
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
                      color: AppTheme.accentCopper.withOpacity(0.1),
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
              
              // Classification
              if (local.classification.isNotEmpty) ...[
                _buildInfoRow(
                  context,
                  'Classification',
                  local.classification,
                  Icons.work_outline,
                  canTap: false,
                ),
                const SizedBox(height: AppTheme.spacingSm),
              ],

              // Address
              if (local.address.isNotEmpty) ...[
                _buildInfoRow(
                  context,
                  'Address',
                  local.address,
                  Icons.location_on_outlined,
                  canTap: true,
                  onTap: () => _launchMaps(local.address, local.city, local.state),
                ),
                const SizedBox(height: AppTheme.spacingSm),
              ],

              // Phone
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

              // Website
              if (local.website.isNotEmpty) ...[
                _buildInfoRow(
                  context,
                  'Website',
                  local.website,
                  Icons.language_outlined,
                  canTap: true,
                  onTap: () => _launchWebsite(local.website),
                ),
              ],
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
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: canTap ? const EdgeInsets.all(AppTheme.spacingXs) : EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: AppTheme.iconSm,
              color: canTap ? AppTheme.accentCopper : AppTheme.textLight,
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

  Future<void> _launchWebsite(String url) async {
    Uri uri;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      uri = Uri.parse('https://$url');
    } else {
      uri = Uri.parse(url);
    }
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    }
    
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }
}

class LocalDetailsDialog extends StatelessWidget {
  final LocalsRecord local;

  const LocalDetailsDialog({
    Key? key,
    required this.local,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLg),
                  topRight: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local ${local.localUnion}',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          '${local.city}, ${local.state}',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.white),
                    onPressed: () => Navigator.of(context).pop(),
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
                    // Contact Information Section
                    _buildSectionHeader(context, 'Contact Information', Icons.contact_phone),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    if (local.address.isNotEmpty)
                      _buildDetailRow(
                        context,
                        'Address',
                        local.address,
                        canTap: true,
                        onTap: () => _launchMaps(local.address, local.city, local.state),
                      ),
                    
                    if (local.phone.isNotEmpty)
                      _buildDetailRow(
                        context,
                        'Phone',
                        local.phone,
                        canTap: true,
                        onTap: () => _launchPhone(local.phone),
                      ),
                    
                    if (local.fax.isNotEmpty)
                      _buildDetailRow(
                        context,
                        'Fax',
                        local.fax,
                      ),
                    
                    if (local.email.isNotEmpty)
                      _buildDetailRow(
                        context,
                        'Email',
                        local.email,
                        canTap: true,
                        onTap: () => _launchEmail(local.email),
                      ),
                    
                    if (local.website.isNotEmpty)
                      _buildDetailRow(
                        context,
                        'Website',
                        local.website,
                        canTap: true,
                        onTap: () => _launchWebsite(local.website),
                      ),
                    
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Classification Section
                    if (local.classification.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Classification', Icons.work_outline),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildDetailRow(context, 'Type', local.classification),
                      const SizedBox(height: AppTheme.spacingLg),
                    ],
                    
                    // Leadership Section
                    _buildSectionHeader(context, 'Leadership', Icons.groups),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    if (local.businessManager.isNotEmpty)
                      _buildDetailRow(context, 'Business Manager', local.businessManager),
                    
                    if (local.president.isNotEmpty)
                      _buildDetailRow(context, 'President', local.president),
                    
                    if (local.financialSecretary.isNotEmpty)
                      _buildDetailRow(context, 'Financial Secretary', local.financialSecretary),
                    
                    if (local.recordingSecretary.isNotEmpty)
                      _buildDetailRow(context, 'Recording Secretary', local.recordingSecretary),
                    
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Meeting Information Section
                    if (local.meetingSchedule.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Meeting Information', Icons.event),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildDetailRow(context, 'Schedule', local.meetingSchedule),
                      const SizedBox(height: AppTheme.spacingLg),
                    ],
                    
                    // Sign-in Information Section
                    if (local.initialSign.isNotEmpty || 
                        local.reSign.isNotEmpty || 
                        local.reSignProcedure.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Sign-in Information', Icons.login),
                      const SizedBox(height: AppTheme.spacingMd),
                      
                      if (local.initialSign.isNotEmpty)
                        _buildDetailRow(context, 'Initial Sign', local.initialSign),
                      
                      if (local.reSign.isNotEmpty)
                        _buildDetailRow(context, 'Re-sign', local.reSign),
                      
                      if (local.reSignProcedure.isNotEmpty)
                        _buildDetailRow(context, 'Re-sign Procedure', local.reSignProcedure),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: AppTheme.accentCopper.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            icon,
            size: AppTheme.iconMd,
            color: AppTheme.accentCopper,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Text(
          title,
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool canTap = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: canTap 
              ? const EdgeInsets.all(AppTheme.spacingXs)
              : const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppTheme.bodyLarge.copyWith(
                    color: canTap ? AppTheme.accentCopper : AppTheme.textDark,
                    decoration: canTap ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Future<void> _launchWebsite(String url) async {
    Uri uri;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      uri = Uri.parse('https://$url');
    } else {
      uri = Uri.parse(url);
    }
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    }
    
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }
}