import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '/backend/schema/locals_record.dart';
import '/design_system/app_theme.dart';
import '/services/resilient_firestore_service.dart';
import 'dart:io' show Platform;

class LocalsScreen extends StatefulWidget {
  const LocalsScreen({super.key});

  @override
  State<LocalsScreen> createState() => _LocalsScreenState();
}

class _LocalsScreenState extends State<LocalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ResilientFirestoreService _firestoreService = ResilientFirestoreService();
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  List<LocalsRecord> _locals = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    _loadInitialLocals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8 && 
        !_isLoading && 
        _hasMore) {
      _loadMoreLocals();
    }
  }

  Future<void> _loadInitialLocals() async {
    setState(() {
      _isLoading = true;
      _locals.clear();
      _lastDocument = null;
      _hasMore = true;
    });

    try {
      final snapshot = await _firestoreService.getLocals(
        limit: 50,
        state: _selectedState,
      ).first;
      
      _locals = snapshot.docs.map((doc) => LocalsRecord.fromSnapshot(doc)).toList();
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length == 50;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading locals: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreLocals() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestoreService.getLocals(
        limit: 50,
        startAfter: _lastDocument,
        state: _selectedState,
      ).first;
      
      final newLocals = snapshot.docs.map((doc) => LocalsRecord.fromSnapshot(doc)).toList();
      
      setState(() {
        _locals.addAll(newLocals);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMore = snapshot.docs.length == 50;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more locals: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchLocals() async {
    if (_searchQuery.isEmpty) {
      _loadInitialLocals();
      return;
    }

    setState(() {
      _isLoading = true;
      _locals.clear();
    });

    try {
      final results = await _firestoreService.searchLocals(
        _searchQuery,
        limit: 50,
        state: _selectedState,
      );
      
      setState(() {
        _locals = results.docs.map((doc) => LocalsRecord.fromSnapshot(doc)).toList();
        _hasMore = false; // Search doesn't support pagination yet
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching locals: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                // Debounce search after 500ms
                if (_searchQuery.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchQuery == value.toLowerCase() && mounted) {
                      _searchLocals();
                    }
                  });
                } else {
                  _loadInitialLocals();
                }
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
                _loadInitialLocals();
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Locals list
          Expanded(
            child: _buildLocalsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalsList() {
    if (_isLoading && _locals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
        ),
      );
    }

    if (_locals.isEmpty) {
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
      itemCount: _locals.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _locals.length) {
          // Loading indicator at the bottom
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingMd),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
              ),
            ),
          );
        }

        final local = _locals[index];
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
                  if (local.website.isNotEmpty) ...[
                    _buildInfoRow(
                      context,
                      'Website',
                      local.website,
                      Icons.language_outlined,
                      canTap: true,
                      onTap: () => _launchWebsite(local.website),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                  ],
                  _buildInfoRow(
                    context,
                    'Classification',
                    local.classification,
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
                _buildDetailRow('Classification', local.classification),
                _buildDetailRow('Address', local.address),
                _buildDetailRow('Phone', local.phone),
                _buildDetailRow('Email', local.email),
                _buildDetailRow('Website', local.website),
                const SizedBox(height: AppTheme.spacingLg),
                // Additional Information
                if (local.rawData != null && local.rawData!.isNotEmpty) ...[
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
                      children: local.rawData!.entries.map((entry) {
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