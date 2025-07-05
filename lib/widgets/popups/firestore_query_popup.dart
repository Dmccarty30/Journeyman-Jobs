import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

/// Generic query popup that can query any Firestore collection
class FirestoreQueryPopup<T> extends StatefulWidget {
  /// The Firestore collection to query
  final CollectionReference collection;
  
  /// Function to convert Firestore document to type T
  final T Function(DocumentSnapshot) fromDocument;
  
  /// Function to build the display widget for each item
  final Widget Function(BuildContext, T) itemBuilder;
  
  /// Function to get the search text from an item (for filtering)
  final String Function(T) getSearchableText;
  
  /// Callback when an item is selected
  final void Function(T) onItemSelected;
  
  /// Callback when multiple items are selected (if multiSelect is true)
  final void Function(List<T>)? onMultipleItemsSelected;
  
  /// Title of the popup
  final String title;
  
  /// Subtitle of the popup
  final String? subtitle;
  
  /// Placeholder text for search field
  final String searchHint;
  
  /// Whether to allow multiple selections
  final bool multiSelect;
  
  /// Pre-selected items (for multiSelect mode)
  final List<T>? selectedItems;
  
  /// Query builder for custom queries
  final Query Function(Query)? queryBuilder;
  
  /// Maximum number of items to load at once
  final int pageSize;
  
  /// Whether to show a loading indicator while fetching data
  final bool showLoadingIndicator;

  const FirestoreQueryPopup({
    super.key,
    required this.collection,
    required this.fromDocument,
    required this.itemBuilder,
    required this.getSearchableText,
    required this.onItemSelected,
    this.onMultipleItemsSelected,
    required this.title,
    this.subtitle,
    this.searchHint = 'Search...',
    this.multiSelect = false,
    this.selectedItems,
    this.queryBuilder,
    this.pageSize = 20,
    this.showLoadingIndicator = true,
  }) : assert(
          !multiSelect || onMultipleItemsSelected != null,
          'onMultipleItemsSelected must be provided when multiSelect is true',
        );

  static Future<T?> showSingle<T>({
    required BuildContext context,
    required CollectionReference collection,
    required T Function(DocumentSnapshot) fromDocument,
    required Widget Function(BuildContext, T) itemBuilder,
    required String Function(T) getSearchableText,
    required String title,
    String? subtitle,
    String searchHint = 'Search...',
    Query Function(Query)? queryBuilder,
    int pageSize = 20,
  }) async {
    T? selectedItem;
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FirestoreQueryPopup<T>(
        collection: collection,
        fromDocument: fromDocument,
        itemBuilder: itemBuilder,
        getSearchableText: getSearchableText,
        onItemSelected: (item) {
          selectedItem = item;
          Navigator.of(context).pop();
        },
        title: title,
        subtitle: subtitle,
        searchHint: searchHint,
        queryBuilder: queryBuilder,
        pageSize: pageSize,
      ),
    );
    
    return selectedItem;
  }

  static Future<List<T>?> showMultiple<T>({
    required BuildContext context,
    required CollectionReference collection,
    required T Function(DocumentSnapshot) fromDocument,
    required Widget Function(BuildContext, T) itemBuilder,
    required String Function(T) getSearchableText,
    required String title,
    String? subtitle,
    String searchHint = 'Search...',
    List<T>? initialSelection,
    Query Function(Query)? queryBuilder,
    int pageSize = 20,
  }) async {
    List<T>? selectedItems;
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FirestoreQueryPopup<T>(
        collection: collection,
        fromDocument: fromDocument,
        itemBuilder: itemBuilder,
        getSearchableText: getSearchableText,
        onItemSelected: (_) {},
        onMultipleItemsSelected: (items) {
          selectedItems = items;
          Navigator.of(context).pop();
        },
        title: title,
        subtitle: subtitle,
        searchHint: searchHint,
        multiSelect: true,
        selectedItems: initialSelection,
        queryBuilder: queryBuilder,
        pageSize: pageSize,
      ),
    );
    
    return selectedItems;
  }

  @override
  State<FirestoreQueryPopup<T>> createState() => _FirestoreQueryPopupState<T>();
}

class _FirestoreQueryPopupState<T> extends State<FirestoreQueryPopup<T>> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<T> _items = [];
  List<T> _filteredItems = [];
  Set<T> _selectedItems = {};
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect && widget.selectedItems != null) {
      _selectedItems = Set.from(widget.selectedItems!);
    }
    _loadItems();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filterItems();
    });
  }

  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = _items;
    } else {
      _filteredItems = _items.where((item) {
        final searchableText = widget.getSearchableText(item).toLowerCase();
        return searchableText.contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _loadItems() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      Query query = widget.collection;
      
      if (widget.queryBuilder != null) {
        query = widget.queryBuilder!(query);
      }
      
      query = query.limit(widget.pageSize);
      
      final snapshot = await query.get();
      
      final items = snapshot.docs
          .map((doc) => widget.fromDocument(doc))
          .toList();
      
      setState(() {
        _items = items;
        _filterItems();
        _hasMore = snapshot.docs.length == widget.pageSize;
        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
        }
      });
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to load data: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      Query query = widget.collection;
      
      if (widget.queryBuilder != null) {
        query = widget.queryBuilder!(query);
      }
      
      query = query.startAfterDocument(_lastDocument!).limit(widget.pageSize);
      
      final snapshot = await query.get();
      
      final items = snapshot.docs
          .map((doc) => widget.fromDocument(doc))
          .toList();
      
      setState(() {
        _items.addAll(items);
        _filterItems();
        _hasMore = snapshot.docs.length == widget.pageSize;
        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
        }
      });
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to load more data: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleSelection(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _confirmSelection() {
    if (widget.multiSelect) {
      widget.onMultipleItemsSelected!(_selectedItems.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: AppTheme.headlineSmall,
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: AppTheme.spacingXs),
                                Text(
                                  widget.subtitle!,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.multiSelect) ...[
                          TextButton(
                            onPressed: _selectedItems.isNotEmpty
                                ? _confirmSelection
                                : null,
                            child: Text(
                              'Done (${_selectedItems.length})',
                              style: AppTheme.labelLarge.copyWith(
                                color: _selectedItems.isNotEmpty
                                    ? AppTheme.accentCopper
                                    : AppTheme.textLight,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading && _items.isEmpty) {
      return const Center(
        child: JJLoadingIndicator(
          message: 'Loading...',
        ),
      );
    }
    
    if (_filteredItems.isEmpty) {
      return Center(
        child: JJEmptyState(
          title: _searchQuery.isEmpty
              ? 'No items found'
              : 'No results for "$_searchQuery"',
          subtitle: _searchQuery.isEmpty
              ? 'There are no items to display'
              : 'Try adjusting your search',
          icon: Icons.search_off,
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXl),
      itemCount: _filteredItems.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredItems.length) {
          return const Padding(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Center(
              child: JJLoadingIndicator(),
            ),
          );
        }
        
        final item = _filteredItems[index];
        final isSelected = _selectedItems.contains(item);
        
        return Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentCopper.withOpacity(0.1)
                : AppTheme.white,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.lightGray.withOpacity(0.5),
              ),
            ),
          ),
          child: InkWell(
            onTap: () {
              if (widget.multiSelect) {
                _toggleSelection(item);
              } else {
                widget.onItemSelected(item);
              }
            },
            child: Row(
              children: [
                if (widget.multiSelect) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(item),
                    activeColor: AppTheme.accentCopper,
                  ),
                ],
                Expanded(
                  child: widget.itemBuilder(context, item),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: (index * 50).ms,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          delay: (index * 50).ms,
        );
      },
    );
  }
}

/// Example usage widget builders
class QueryPopupBuilders {
  /// Builder for displaying IBEW locals
  static Widget localItemBuilder(BuildContext context, Map<String, dynamic> local) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Center(
          child: Text(
            local['number']?.toString() ?? '',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        'Local ${local['number']} - ${local['name']}',
        style: AppTheme.titleMedium,
      ),
      subtitle: Text(
        '${local['city']}, ${local['state']}',
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: local['members'] != null
          ? Text(
              '${local['members']} members',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textLight,
              ),
            )
          : null,
    );
  }
  
  /// Builder for displaying companies
  static Widget companyItemBuilder(BuildContext context, Map<String, dynamic> company) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.accentCopper.withOpacity(0.1),
        child: Text(
          company['name']?.substring(0, 1).toUpperCase() ?? 'C',
          style: AppTheme.titleMedium.copyWith(
            color: AppTheme.accentCopper,
          ),
        ),
      ),
      title: Text(
        company['name'] ?? 'Unknown Company',
        style: AppTheme.titleMedium,
      ),
      subtitle: company['location'] != null
          ? Text(
              company['location'],
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: company['jobCount'] != null
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: Text(
                '${company['jobCount']} jobs',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.successGreen,
                ),
              ),
            )
          : null,
    );
  }
}