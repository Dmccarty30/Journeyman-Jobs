# Immutable Model Design Skill

**Skill Type**: Technical Pattern | **Domain**: State Management | **Complexity**: Intermediate

## Purpose

Master immutable data model design using Freezed and JsonSerializable for Journeyman Jobs. Create type-safe, immutable models with built-in equality, copyWith, serialization, and pattern matching for robust state management in the electrical trade platform.

## Core Capabilities

### 1. Freezed Fundamentals

```dart
// Basic freezed model
@freezed
class Job with _$Job {
  const factory Job({
    required String id,
    required String title,
    required String companyName,
    required Location location,
    required PayRange payRange,
    required DateTime postedDate,
    @Default(false) bool isStormWork,
    @Default(false) bool isFavorite,
  }) = _Job;

  // JSON serialization
  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}
```

### 2. Model Types in JJ Architecture

#### Entity Models (Domain Objects)

```dart
// Job entity - Core business object
@freezed
class Job with _$Job {
  const factory Job({
    required String id,
    required String title,
    required String companyName,
    required String description,
    required Location location,
    required PayRange payRange,
    required Set<String> tradeTypes,
    required JobStatus status,
    required DateTime postedDate,
    required DateTime? expiryDate,
    @Default(false) bool isStormWork,
    @Default(false) bool isUnionJob,
    @Default(false) bool isLocal,
    @Default([]) List<String> requiredCertifications,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Job;

  // Private constructor for custom methods
  const Job._();

  // JSON serialization
  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  // Business logic methods
  bool get isActive => status == JobStatus.active && !isExpired;

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool matchesFilter(JobFilter filter) {
    if (filter.stormWorkOnly && !isStormWork) return false;
    if (filter.unionOnly && !isUnionJob) return false;
    if (filter.tradeTypes.isNotEmpty &&
        !filter.tradeTypes.any((type) => tradeTypes.contains(type))) {
      return false;
    }
    return true;
  }

  int get relevanceScore {
    int score = 0;
    if (isLocal) score += 10;
    if (isStormWork) score += 5;
    if (isUnionJob) score += 3;
    return score;
  }
}

// Location value object
@freezed
class Location with _$Location {
  const factory Location({
    required String city,
    required String state,
    required String zipCode,
    required double latitude,
    required double longitude,
  }) = _Location;

  const Location._();

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  String get displayName => '$city, $state';

  double distanceFrom(Location other) {
    // Haversine formula for distance calculation
    const earthRadius = 6371.0; // km
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(latitude)) *
        cos(_toRadians(other.latitude)) *
        pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}

// Pay range value object
@freezed
class PayRange with _$PayRange {
  const factory PayRange({
    required double min,
    required double max,
    required PayUnit unit,
  }) = _PayRange;

  const PayRange._();

  factory PayRange.fromJson(Map<String, dynamic> json) =>
      _$PayRangeFromJson(json);

  String get displayString {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return '${formatter.format(min)} - ${formatter.format(max)}/${unit.abbreviation}';
  }

  bool isWithinRange(double amount) => amount >= min && amount <= max;
}

// Enums
enum JobStatus {
  active,
  filled,
  expired,
  draft;

  String get displayName => name.capitalize();
}

enum PayUnit {
  hour,
  day,
  week,
  month,
  year;

  String get abbreviation {
    switch (this) {
      case PayUnit.hour: return 'hr';
      case PayUnit.day: return 'day';
      case PayUnit.week: return 'wk';
      case PayUnit.month: return 'mo';
      case PayUnit.year: return 'yr';
    }
  }
}
```

#### State Models (UI State)

```dart
// Filter state
@freezed
class JobFilter with _$JobFilter {
  const factory JobFilter({
    @Default({}) Set<String> tradeTypes,
    @Default({}) Set<String> locations,
    @Default(null) PayRange? payRange,
    @Default(false) bool stormWorkOnly,
    @Default(false) bool unionOnly,
    @Default(false) bool localOnly,
    @Default(null) double? maxDistance,
    @Default(null) Location? centerLocation,
  }) = _JobFilter;

  const JobFilter._();

  factory JobFilter.fromJson(Map<String, dynamic> json) =>
      _$JobFilterFromJson(json);

  // Named constructors
  factory JobFilter.initial() => const JobFilter();

  factory JobFilter.stormWork() => const JobFilter(
    stormWorkOnly: true,
  );

  factory JobFilter.local(Location location) => JobFilter(
    localOnly: true,
    centerLocation: location,
    maxDistance: 50.0,
  );

  // Computed properties
  bool get hasActiveFilters =>
    tradeTypes.isNotEmpty ||
    locations.isNotEmpty ||
    payRange != null ||
    stormWorkOnly ||
    unionOnly ||
    localOnly;

  int get activeFilterCount {
    int count = 0;
    if (tradeTypes.isNotEmpty) count++;
    if (locations.isNotEmpty) count++;
    if (payRange != null) count++;
    if (stormWorkOnly) count++;
    if (unionOnly) count++;
    if (localOnly) count++;
    return count;
  }
}

// Search state
@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    required String query,
    required SearchStatus status,
    @Default([]) List<Job> results,
    @Default(null) String? error,
    @Default(null) DateTime? lastSearchedAt,
  }) = _SearchState;

  const SearchState._();

  factory SearchState.fromJson(Map<String, dynamic> json) =>
      _$SearchStateFromJson(json);

  factory SearchState.initial() => const SearchState(
    query: '',
    status: SearchStatus.idle,
  );

  bool get isSearching => status == SearchStatus.searching;
  bool get hasResults => results.isNotEmpty;
  bool get hasError => error != null;
}

enum SearchStatus {
  idle,
  searching,
  completed,
  error;
}
```

#### Configuration Models

```dart
// App settings
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    required ThemeMode themeMode,
    required bool notificationsEnabled,
    required bool highContrastMode,
    required bool locationServicesEnabled,
    required NotificationPreferences notificationPreferences,
    @Default('en_US') String locale,
    @Default(25.0) double maxJobSearchRadius,
  }) = _AppSettings;

  const AppSettings._();

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  factory AppSettings.initial() => AppSettings(
    themeMode: ThemeMode.system,
    notificationsEnabled: true,
    highContrastMode: false,
    locationServicesEnabled: false,
    notificationPreferences: NotificationPreferences.initial(),
  );
}

// Notification preferences
@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    required bool newJobAlerts,
    required bool stormWorkAlerts,
    required bool localJobAlerts,
    required bool messageNotifications,
    @Default({}) Set<String> mutedCompanies,
    @Default(null) TimeRange? quietHours,
  }) = _NotificationPreferences;

  const NotificationPreferences._();

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  factory NotificationPreferences.initial() => const NotificationPreferences(
    newJobAlerts: true,
    stormWorkAlerts: true,
    localJobAlerts: true,
    messageNotifications: true,
  );
}

// Time range value object
@freezed
class TimeRange with _$TimeRange {
  const factory TimeRange({
    required TimeOfDay start,
    required TimeOfDay end,
  }) = _TimeRange;

  const TimeRange._();

  factory TimeRange.fromJson(Map<String, dynamic> json) =>
      _$TimeRangeFromJson(json);

  bool isWithinRange(TimeOfDay time) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes < endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Wraps around midnight
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
}
```

### 3. Union Types (Sealed Classes)

```dart
// Result type for operations
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.error(String message, [Exception? exception]) = Error<T>;
  const factory Result.loading() = Loading<T>;

  const Result._();

  // Pattern matching helpers
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Exception? exception) error,
    required R Function() loading,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Error(:final message, :final exception) => error(message, exception),
      Loading() => loading(),
    };
  }

  // Convenience methods
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
  bool get isLoading => this is Loading<T>;

  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    _ => null,
  };
}

// Network request state
@freezed
sealed class NetworkState<T> with _$NetworkState<T> {
  const factory NetworkState.idle() = Idle<T>;
  const factory NetworkState.loading() = NetworkLoading<T>;
  const factory NetworkState.success(T data) = NetworkSuccess<T>;
  const factory NetworkState.failure(NetworkError error) = NetworkFailure<T>;

  const NetworkState._();

  bool get isLoading => this is NetworkLoading<T>;
}

// Network error types
@freezed
sealed class NetworkError with _$NetworkError {
  const factory NetworkError.timeout() = TimeoutError;
  const factory NetworkError.noConnection() = NoConnectionError;
  const factory NetworkError.serverError(int statusCode, String message) = ServerError;
  const factory NetworkError.unknown(String message) = UnknownError;

  const NetworkError._();

  String get displayMessage => switch (this) {
    TimeoutError() => 'Request timed out',
    NoConnectionError() => 'No internet connection',
    ServerError(:final message) => message,
    UnknownError(:final message) => 'An error occurred: $message',
  };
}
```

### 4. Nested Models & Composition

```dart
// User profile with nested models
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required String displayName,
    required UserPreferences preferences,
    required Location? currentLocation,
    required Set<String> certifications,
    required List<WorkHistory> workHistory,
    required DateTime createdAt,
    required DateTime lastLoginAt,
  }) = _UserProfile;

  const UserProfile._();

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  bool hasCertification(String cert) => certifications.contains(cert);

  int get yearsOfExperience {
    if (workHistory.isEmpty) return 0;
    final firstJob = workHistory.reduce((a, b) => a.startDate.isBefore(b.startDate) ? a : b);
    final years = DateTime.now().difference(firstJob.startDate).inDays / 365;
    return years.floor();
  }
}

// Work history
@freezed
class WorkHistory with _$WorkHistory {
  const factory WorkHistory({
    required String companyName,
    required String position,
    required DateTime startDate,
    required DateTime? endDate,
    required List<String> responsibilities,
  }) = _WorkHistory;

  const WorkHistory._();

  factory WorkHistory.fromJson(Map<String, dynamic> json) =>
      _$WorkHistoryFromJson(json);

  bool get isCurrent => endDate == null;

  Duration get duration => (endDate ?? DateTime.now()).difference(startDate);
}

// User preferences
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required Set<String> preferredTradeTypes,
    required Set<String> preferredLocations,
    required PayRange? preferredPayRange,
    required bool willingToRelocate,
    required bool willingToDoStormWork,
    required NotificationPreferences notificationPreferences,
  }) = _UserPreferences;

  const UserPreferences._();

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  factory UserPreferences.initial() => UserPreferences(
    preferredTradeTypes: {},
    preferredLocations: {},
    preferredPayRange: null,
    willingToRelocate: false,
    willingToDoStormWork: false,
    notificationPreferences: NotificationPreferences.initial(),
  );
}
```

### 5. Collection Models

```dart
// Paginated list
@freezed
class PaginatedList<T> with _$PaginatedList<T> {
  const factory PaginatedList({
    required List<T> items,
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required bool hasMore,
  }) = _PaginatedList<T>;

  const PaginatedList._();

  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedListFromJson(json, fromJsonT);

  factory PaginatedList.initial() => const PaginatedList(
    items: [],
    currentPage: 0,
    totalPages: 0,
    totalItems: 0,
    hasMore: false,
  );

  PaginatedList<T> appendPage(PaginatedList<T> nextPage) {
    return copyWith(
      items: [...items, ...nextPage.items],
      currentPage: nextPage.currentPage,
      hasMore: nextPage.hasMore,
    );
  }
}

// Grouped jobs
@freezed
class GroupedJobs with _$GroupedJobs {
  const factory GroupedJobs({
    required Map<String, List<Job>> byLocation,
    required Map<String, List<Job>> byTradeType,
    required List<Job> stormJobs,
    required List<Job> localJobs,
  }) = _GroupedJobs;

  const GroupedJobs._();

  factory GroupedJobs.fromJson(Map<String, dynamic> json) =>
      _$GroupedJobsFromJson(json);

  factory GroupedJobs.fromJobs(List<Job> jobs) {
    final byLocation = <String, List<Job>>{};
    final byTradeType = <String, List<Job>>{};
    final stormJobs = <Job>[];
    final localJobs = <Job>[];

    for (final job in jobs) {
      // Group by location
      final locationKey = '${job.location.city}, ${job.location.state}';
      byLocation.putIfAbsent(locationKey, () => []).add(job);

      // Group by trade type
      for (final trade in job.tradeTypes) {
        byTradeType.putIfAbsent(trade, () => []).add(job);
      }

      // Special categories
      if (job.isStormWork) stormJobs.add(job);
      if (job.isLocal) localJobs.add(job);
    }

    return GroupedJobs(
      byLocation: byLocation,
      byTradeType: byTradeType,
      stormJobs: stormJobs,
      localJobs: localJobs,
    );
  }

  int get totalLocations => byLocation.length;
  int get totalTradeTypes => byTradeType.length;
}
```

## Best Practices

### 1. Model Organization

```dart
// models/
//   ├─ entities/
//   │   ├─ job.dart
//   │   ├─ user.dart
//   │   └─ location.dart
//   ├─ state/
//   │   ├─ job_filter.dart
//   │   ├─ search_state.dart
//   │   └─ ui_state.dart
//   ├─ config/
//   │   ├─ app_settings.dart
//   │   └─ notification_preferences.dart
//   └─ common/
//       ├─ result.dart
//       ├─ paginated_list.dart
//       └─ network_state.dart
```

### 2. Private Constructor Pattern

```dart
@freezed
class Job with _$Job {
  const factory Job({...}) = _Job;

  // Private constructor enables custom methods
  const Job._();

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  // Custom methods
  bool isVisibleTo(UserProfile user) {
    // Business logic
  }
}
```

### 3. JSON Serialization with Converters

```dart
// Custom JSON converter for DateTime
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

// Usage in model
@freezed
class Job with _$Job {
  const factory Job({
    required String id,
    @TimestampConverter() required DateTime postedDate,
    @TimestampConverter() required DateTime? expiryDate,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}
```

### 4. Default Values & Validation

```dart
@freezed
class JobFilter with _$JobFilter {
  @Assert('maxDistance == null || maxDistance! > 0', 'Max distance must be positive')
  @Assert('payRange == null || payRange!.min <= payRange!.max', 'Invalid pay range')
  const factory JobFilter({
    @Default({}) Set<String> tradeTypes,
    @Default(false) bool stormWorkOnly,
    @Default(null) double? maxDistance,
    @Default(null) PayRange? payRange,
  }) = _JobFilter;

  const JobFilter._();

  factory JobFilter.fromJson(Map<String, dynamic> json) =>
      _$JobFilterFromJson(json);
}
```

## Common Pitfalls to Avoid

### ❌ Mistake 1: Mutable Collections

```dart
// BAD: Mutable list in immutable model
@freezed
class Job with _$Job {
  factory Job({
    required List<String> tags, // Mutable!
  }) = _Job;
}

// GOOD: Use immutable collection or @Default([])
@freezed
class Job with _$Job {
  const factory Job({
    @Default([]) List<String> tags, // Immutable
  }) = _Job;
}
```

### ❌ Mistake 2: Forgetting Private Constructor

```dart
// BAD: No custom methods
@freezed
class Job with _$Job {
  const factory Job({...}) = _Job;
}

// GOOD: Private constructor enables methods
@freezed
class Job with _$Job {
  const factory Job({...}) = _Job;
  const Job._(); // Enable custom methods

  bool get isActive => ...;
}
```

### ❌ Mistake 3: Complex Logic in Models

```dart
// BAD: Database queries in model
@freezed
class Job with _$Job {
  const Job._();

  Future<List<Application>> getApplications() async {
    return firestore.collection('applications').get(); // Don't do this!
  }
}

// GOOD: Keep models pure
@freezed
class Job with _$Job {
  const Job._();

  // Pure computation only
  bool matchesFilter(JobFilter filter) {
    return filter.tradeTypes.contains(tradeType);
  }
}
```

## Quality Standards

- **Immutability**: All models immutable by default
- **Type Safety**: Strong typing with no dynamic types
- **Serialization**: JSON serialization for all network models
- **Testing**: Unit tests for business logic methods
- **Documentation**: Document complex business rules

## Related Skills

- `dependency-injection` - Provide models through Riverpod
- `notifier-logic` - State mutations using copyWith
- `firebase-integration` - Firestore serialization patterns
- `hierarchical-initialization` - Model initialization order
