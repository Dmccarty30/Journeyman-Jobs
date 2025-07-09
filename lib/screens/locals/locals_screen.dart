import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../design_system/illustrations/electrical_illustrations.dart';
import '../../models/locals_record.dart';

class LocalsWidget extends StatefulWidget {
  const LocalsWidget({super.key});

  @override
  State<LocalsWidget> createState() => _LocalsWidgetState();
}

class _LocalsWidgetState extends State<LocalsWidget> {
  // State variables
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<LocalsRecord> _localsRecords = [];
  List<LocalsRecord> _filteredRecords = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 20;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    
    // Load mock data immediately
    _localsRecords = LocalsRecordMockData.getSampleData();
    _filteredRecords = _localsRecords;
    
    // Then try to load from Firestore
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterLocals();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _filterLocals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _localsRecords;
      } else {
        _filteredRecords = _localsRecords.where((local) {
          return local.localNumber.toLowerCase().contains(query) ||
              local.localName.toLowerCase().contains(query) ||
              local.location.toLowerCase().contains(query) ||
              local.specialties.any((s) => s.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Removed print statement
      
      // Check if Firebase is initialized
      try {
        // Skipped awaiting non-Future; removed or corrected as it's not a Future
        // Removed print statement
      } catch (e) {
        // Removed print statement
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('locals')
          // .orderBy('localNumber')  // Commented out as it might cause issues if field doesn't exist
          .limit(_pageSize)
          .get();

      // Removed print statement
      
      if (querySnapshot.docs.isEmpty) {
        // Removed print statement
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final newLocals = querySnapshot.docs
          .map((doc) => LocalsRecord.fromFirestore(doc))
          .toList();

      setState(() {
        _localsRecords = newLocals;
        _filteredRecords = newLocals;
        _lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
        _hasMore = querySnapshot.docs.length == _pageSize;
        _isLoading = false;
      });
      
    } catch (e) {
      // Removed print statement
      // Removed print statement
      setState(() {
        _errorMessage = 'Failed to load locals: ${e.toString()}';
        _isLoading = false;
        // Mock data should already be loaded from initState
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('locals')
          // .orderBy('localNumber')  // Commented out to match _loadInitialData
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      final newLocals = querySnapshot.docs
          .map((doc) => LocalsRecord.fromFirestore(doc))
          .toList();

      setState(() {
        _localsRecords.addAll(newLocals);
        _filterLocals();
        _lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
        _hasMore = querySnapshot.docs.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      // Removed print statement
      
      // Just try to launch without checking canLaunchUrl
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        // Removed print statement
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open phone app for $phoneNumber')),
          );
        }
      } catch (e) {
        // Removed print statement
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening phone app: ${e.toString()}')),
          );
        }
      }
    } catch (e) {
      // Removed print statement
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid phone number format')),
        );
      }
    }
  }

  Future<void> _launchWebsite(String url) async {
    try {
      // Ensure URL has proper scheme
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }
      
      final uri = Uri.parse(finalUrl);
      // Removed print statement
      
      // Just try to launch without checking canLaunchUrl
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        // Removed print statement
        if (!launched && mounted) {
          // Try in-app browser as fallback
          try {
            final inAppLaunched = await launchUrl(
              uri,
              mode: LaunchMode.inAppBrowserView,
            );
            // Removed print statement
            if (!inAppLaunched && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open $finalUrl')),
              );
            }
          } catch (e) {
            // Removed print statement
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No browser found to open $finalUrl')),
              );
            }
          }
        }
      } catch (e) {
        // Removed print statement
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening browser: ${e.toString()}')),
          );
        }
      }
    } catch (e) {
      // Removed print statement
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid website URL')),
        );
      }
    }
  }

  Future<void> _launchMaps(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      
      // Try Google Maps URL first
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
      final uri = Uri.parse(googleMapsUrl);
      // Removed print statement
      
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        // Removed print statement
        if (!launched && mounted) {
          // Try geo: URI as fallback
          final geoUri = Uri.parse('geo:0,0?q=$encodedAddress');
          // Removed print statement
          
          try {
            final geoLaunched = await launchUrl(
              geoUri,
              mode: LaunchMode.externalApplication,
            );
            // Removed print statement
            if (!geoLaunched && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open maps for $address')),
              );
            }
          } catch (e) {
            // Removed print statement
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No maps app found')),
              );
            }
          }
        }
      } catch (e) {
        // Removed print statement
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening maps: ${e.toString()}')),
          );
        }
      }
    } catch (e) {
      // Removed print statement
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid address format')),
        );
      }
    }
  }

  void _showLocalDetails(LocalsRecord local) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocalDetailsSheet(
        local: local,
        onLaunchPhone: _launchPhone,
        onLaunchWebsite: _launchWebsite,
        onLaunchMaps: _launchMaps,
      ),
    );
  }

  Widget _buildLocalCard(LocalsRecord local) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: JJCard(
        child: InkWell(
          onTap: () => _showLocalDetails(local),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Local info
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Local ${local.localNumber}',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        local.localName,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.textLight.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              local.address ?? local.location,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (local.classification != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCopper.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            local.classification!,
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.accentCopper,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column - Contact info
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              local.contactPhone,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 16,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              local.contactEmail,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (local.website != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              size: 16,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                local.website!,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.accentCopper,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Members row removed per requirements
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: JJElectricalLoader(
          width: 100,
          height: 30,
          message: 'Loading locals...',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const JJEmptyState(
      title: 'No locals found',
      subtitle: 'Try adjusting your search',
      illustration: ElectricalIllustration.noResults,
      context: 'search',
    );
  }

  Widget _buildErrorState() {
    return JJEmptyState(
      title: 'Error loading locals',
      subtitle: _errorMessage ?? 'An unexpected error occurred',
      illustration: ElectricalIllustration.maintenance,
      action: JJPrimaryButton(
        text: 'Retry',
        onPressed: _loadInitialData,
        icon: Icons.refresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('IBEW Locals'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppTheme.lightGray,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: JJTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              label: 'Search locals',
              prefixIcon: Icons.search,
              suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
              onSuffixIconPressed: _searchController.text.isNotEmpty
                  ? () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    }
                  : null,
            ),
          ),
          // Content
          Expanded(
            child: _errorMessage != null && _localsRecords.isEmpty
                ? _buildErrorState()
                : _filteredRecords.isEmpty && !_isLoading
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _filteredRecords.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredRecords.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildLocalCard(_filteredRecords[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Local Details Bottom Sheet
class LocalDetailsSheet extends StatelessWidget {
  final LocalsRecord local;
  final Function(String) onLaunchPhone;
  final Function(String) onLaunchWebsite;
  final Function(String) onLaunchMaps;

  const LocalDetailsSheet({
    super.key,
    required this.local,
    required this.onLaunchPhone,
    required this.onLaunchWebsite,
    required this.onLaunchMaps,
  });

  Widget _buildDetailRow(String label, String? value,
      {bool isClickable = false, VoidCallback? onTap, IconData? icon}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: isClickable ? onTap : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isClickable ? AppTheme.accentCopper : AppTheme.textPrimary,
                        decoration: isClickable ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      size: 20,
                      color: AppTheme.accentCopper,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataSection() {
    if (local.rawData == null || local.rawData!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Additional Information',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.mediumGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: local.rawData!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${entry.key}:',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          // Add electrical illustration
                          ElectricalIllustrationWidget(
                            illustration: ElectricalIllustration.ibewLogo,
                            width: 60,
                            height: 60,
                            animate: true,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Local ${local.localNumber}',
                                  style: AppTheme.headlineLarge.copyWith(
                                    color: AppTheme.primaryNavy,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  local.localName,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: local.isActive
                                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                                  : AppTheme.textLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              local.isActive ? 'Active' : 'Inactive',
                              style: AppTheme.labelMedium.copyWith(
                                color: local.isActive
                                    ? AppTheme.successGreen
                                    : AppTheme.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Details
                      _buildDetailRow('Classification', local.classification),
                      _buildDetailRow('Location', local.location),
                      _buildDetailRow(
                        'Address',
                        local.address,
                        isClickable: true,
                        onTap: () => onLaunchMaps(local.address ?? local.location),
                        icon: Icons.directions,
                      ),
                      _buildDetailRow(
                        'Phone',
                        local.contactPhone,
                        isClickable: true,
                        onTap: () => onLaunchPhone(local.contactPhone),
                        icon: Icons.phone,
                      ),
                      _buildDetailRow('Email', local.contactEmail),
                      _buildDetailRow(
                        'Website',
                        local.website,
                        isClickable: local.website != null,
                        onTap: local.website != null
                            ? () => onLaunchWebsite(local.website!)
                            : null,
                        icon: local.website != null ? Icons.open_in_new : null,
                      ),
                      _buildDetailRow('Members', '${local.memberCount}'),
                      // Specialties
                      if (local.specialties.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Specialties',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: local.specialties.map((specialty) {
                            return JJChip(
                              label: specialty,
                              onTap: () {},  // Corrected to onTap based on context
                            );
                          }).toList(),
                        ),
                      ],
                      // Raw data
                      _buildRawDataSection(),
                      const SizedBox(height: 24),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: JJSecondaryButton(
                              text: 'Call',
                              icon: Icons.phone,
                              onPressed: () => onLaunchPhone(local.contactPhone),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: JJPrimaryButton(
                              text: 'View Details',
                              icon: Icons.open_in_new,
                              onPressed: local.website != null
                                  ? () => onLaunchWebsite(local.website!)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}