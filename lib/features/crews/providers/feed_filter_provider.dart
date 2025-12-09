import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'feed_filter_provider.g.dart';

/// Feed filter state
class FeedFilter {
  final bool showMyPostsOnly;
  final FeedSortOption sortOption;
  final DateTime? startDate;
  final DateTime? endDate;

  const FeedFilter({
    this.showMyPostsOnly = false,
    this.sortOption = FeedSortOption.recent,
    this.startDate,
    this.endDate,
  });

  FeedFilter copyWith({
    bool? showMyPostsOnly,
    FeedSortOption? sortOption,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return FeedFilter(
      showMyPostsOnly: showMyPostsOnly ?? this.showMyPostsOnly,
      sortOption: sortOption ?? this.sortOption,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'showMyPostsOnly': showMyPostsOnly,
    'sortOption': sortOption.index,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory FeedFilter.fromJson(Map<String, dynamic> json) {
    return FeedFilter(
      showMyPostsOnly: json['showMyPostsOnly'] ?? false,
      sortOption: FeedSortOption.values[json['sortOption'] ?? 0],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

enum FeedSortOption {
  recent,
  popular,
  oldest,
}

/// Feed filter notifier with persistence (using Riverpod 3.0 pattern)
@Riverpod(keepAlive: true)
class FeedFilterNotifier extends _$FeedFilterNotifier {
  static const String _prefsKey = 'feed_filter_state';

  @override
  FeedFilter build() {
    _loadFromPreferences();
    return const FeedFilter();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null) {
        final json = Map<String, dynamic>.from(
          Uri.splitQueryString(jsonString).map((key, value) {
            if (value == 'true') return MapEntry(key, true);
            if (value == 'false') return MapEntry(key, false);
            if (int.tryParse(value) != null) return MapEntry(key, int.parse(value));
            return MapEntry(key, value);
          }),
        );
        state = FeedFilter.fromJson(json);
      }
    } catch (e) {
      // Ignore errors and use default state
    }
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = state.toJson();
      final queryString = json.entries
          .where((e) => e.value != null)
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      await prefs.setString(_prefsKey, queryString);
    } catch (e) {
      // Ignore save errors
    }
  }

  void toggleMyPostsOnly() {
    state = state.copyWith(showMyPostsOnly: !state.showMyPostsOnly);
    _saveToPreferences();
  }

  void setSortOption(FeedSortOption option) {
    state = state.copyWith(sortOption: option);
    _saveToPreferences();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
    _saveToPreferences();
  }

  void clearFilters() {
    state = const FeedFilter();
    _saveToPreferences();
  }
}


