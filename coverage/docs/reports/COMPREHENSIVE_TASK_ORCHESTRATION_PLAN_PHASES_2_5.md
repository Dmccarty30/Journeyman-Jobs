# Journeyman Jobs - Task Orchestration Plan: Phases 2-5

**Continuation**: COMPREHENSIVE_TASK_ORCHESTRATION_PLAN.md
**Total Remaining Tasks**: 14 major tasks across 4 phases
**Orchestration Approach**: Task-Orchestrator Method with Parallel Execution

---

## 🚀 Phase 2: High-Impact Consolidation (Weeks 3-4)

### Phase Overview
**Priority**: P1 - Major Code Reduction
**Parallel Execution**: 12/12 tasks can run concurrently
**Total Effort**: 50-70 hours
**Expected Impact**: -7,500 lines of code (-70%)

---

### Task 2.1: Unified Firestore Service Creation [P]

**Agent**: backend-architect
**Complexity**: Complex
**Parallel Execution**: Yes (can run with other consolidations)

**Description**:
Create a UnifiedFirestoreService using the strategy pattern to replace 4 overlapping Firestore services, eliminating 1,116 lines of duplicate code and providing a clean, extensible architecture.

**Report Context**:
- Section: "Backend Service Redundancy"
- Current Services: firestore_service.dart (306 lines), resilient_firestore_service.dart (575 lines), search_optimized_firestore_service.dart (449 lines), geographic_firestore_service.dart (486 lines)
- Duplication: 85% code duplication across services
- Reduction Target: 1,816 → 700 lines (61% reduction)

**Technical Implementation**:
```dart
// Strategy pattern for Firestore operations
abstract class FirestoreStrategy {
  Future<void> apply(FirestoreRequest request);
}

class ResilienceStrategy implements FirestoreStrategy {
  @override
  Future<void> apply(FirestoreRequest request) async {
    // Add retry logic, exponential backoff
  }
}

class SearchStrategy implements FirestoreStrategy {
  @override
  Future<void> apply(FirestoreRequest request) async {
    // Add search optimization, indexing
  }
}

class ShardingStrategy implements FirestoreStrategy {
  @override
  Future<void> apply(FirestoreRequest request) async {
    // Add geographic sharding logic
  }
}

// Unified service
class UnifiedFirestoreService {
  final List<FirestoreStrategy> strategies;
  final FirebaseFirestore _firestore;

  UnifiedFirestoreService({
    required this.strategies,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<DocumentSnapshot> getDocument(String path) async {
    final request = FirestoreRequest.get(path);

    // Apply all strategies
    for (final strategy in strategies) {
      await strategy.apply(request);
    }

    return await _firestore.doc(path).get();
  }
}
```

**Subtasks**:
1. Design strategy pattern architecture
2. Create base FirestoreStrategy interface
3. Implement ResilienceStrategy (retry logic)
4. Implement SearchStrategy (query optimization)
5. Implement ShardingStrategy (geographic distribution)
6. Create UnifiedFirestoreService
7. Build migration plan for existing services
8. Implement comprehensive tests

**Validation Criteria**:
- [ ] Strategy pattern properly implemented
- [ ] All 4 existing service functionalities preserved
- [ ] Code reduction achieved (>60%)
- [ ] Service is easily extensible with new strategies
- [ ] Migration from old services is seamless
- [ ] All existing tests pass with new service

**Dependencies**: None (but requires Phase 1 completion)
**Estimated Hours**: 16-20

---

### Task 2.2: Notification Manager Implementation [P]

**Agent**: backend-architect
**Complexity**: Complex
**Parallel Execution**: Yes

**Description**:
Create a NotificationManager using the provider pattern to consolidate 3 overlapping notification services, reducing 844 lines of duplicate code and providing unified notification handling.

**Report Context**:
- Section: "Backend Service Redundancy"
- Current Services: notification_service.dart (524 lines), enhanced_notification_service.dart (418 lines), local_notification_service.dart (402 lines)
- Duplication: 70% code duplication between services
- Reduction Target: 1,344 → 500 lines (63% reduction)

**Technical Implementation**:
```dart
// Provider pattern for notifications
abstract class NotificationProvider {
  Future<void> send(NotificationMessage message);
  Future<List<NotificationMessage>> getHistory();
}

class FCMNotificationProvider implements NotificationProvider {
  final FirebaseMessaging _messaging;

  @override
  Future<void> send(NotificationMessage message) async {
    // Firebase Cloud Messaging implementation
  }
}

class LocalNotificationProvider implements NotificationProvider {
  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> send(NotificationMessage message) async {
    // Local notification implementation
  }
}

// IBEW-specific notification rules
class IBEWNotificationRules {
  bool shouldSend(NotificationMessage message, UserContext context) {
    // IBEW-specific business logic
    // Union notifications, job alerts, crew messages
    return true;
  }
}

// Unified notification manager
class NotificationManager {
  final List<NotificationProvider> providers;
  final IBEWNotificationRules rules;

  NotificationManager({
    required this.providers,
    required this.rules,
  });

  Future<void> send(NotificationMessage message, UserContext context) async {
    if (!rules.shouldSend(message, context)) {
      return;
    }

    // Send via appropriate providers
    for (final provider in providers) {
      await provider.send(message);
    }
  }
}
```

**Subtasks**:
1. Define NotificationProvider interface
2. Implement FCMNotificationProvider
3. Implement LocalNotificationProvider
4. Create IBEWNotificationRules system
5. Build NotificationManager with provider pattern
6. Implement notification routing logic
7. Create migration strategy for existing services
8. Add comprehensive testing

**Validation Criteria**:
- [ ] Provider pattern properly implemented
- [ ] FCM and local notifications work correctly
- [ ] IBEW-specific rules applied correctly
- [ ] Code reduction achieved (>60%)
- [ ] All notification types supported
- [ ] Migration from old services is seamless

**Dependencies**: None
**Estimated Hours**: 14-18

---

### Task 2.3: Analytics Hub Creation [P]

**Agent**: backend-architect
**Complexity**: Complex
**Parallel Execution**: Yes

**Description**:
Create an AnalyticsHub using the event router pattern to consolidate 3 analytics services, eliminating 938 lines of duplicate code and providing unified analytics tracking.

**Report Context**:
- Section: "Backend Service Redundancy"
- Current Services: analytics_service.dart (318 lines), user_analytics_service.dart (703 lines), search_analytics_service.dart (617 lines)
- Duplication: 60% duplication - all use Firebase Analytics similarly
- Reduction Target: 1,638 → 700 lines (57% reduction)

**Technical Implementation**:
```dart
// Event router pattern for analytics
abstract class AnalyticsEvent {
  String get name;
  Map<String, dynamic> get parameters;
}

class UserActionEvent implements AnalyticsEvent {
  final String action;
  final String context;
  final Map<String, dynamic> additionalData;

  UserActionEvent({
    required this.action,
    required this.context,
    this.additionalData = const {},
  });

  @override
  String get name => 'user_action';

  @override
  Map<String, dynamic> get parameters => {
    'action': action,
    'context': context,
    ...additionalData,
  };
}

class SearchEvent implements AnalyticsEvent {
  final String query;
  final int resultCount;
  final Duration searchTime;

  // Implementation...
}

// Event router
class AnalyticsEventRouter {
  final Map<String, List<AnalyticsHandler>> _handlers = {};

  void registerHandler(String eventName, AnalyticsHandler handler) {
    _handlers.putIfAbsent(eventName, () => []).add(handler);
  }

  Future<void> route(AnalyticsEvent event) async {
    final handlers = _handlers[event.name] ?? [];

    for (final handler in handlers) {
      await handler.handle(event);
    }
  }
}

// Analytics hub
class AnalyticsHub {
  final AnalyticsEventRouter _router;
  final FirebaseAnalytics _firebaseAnalytics;

  AnalyticsHub(this._router, this._firebaseAnalytics) {
    _registerDefaultHandlers();
  }

  void _registerDefaultHandlers() {
    _router.registerHandler('user_action', FirebaseAnalyticsHandler(_firebaseAnalytics));
    _router.registerHandler('search_event', SearchAnalyticsHandler());
    _router.registerHandler('user_action', UserAnalyticsHandler());
  }

  Future<void> track(AnalyticsEvent event) async {
    await _router.route(event);
  }
}
```

**Subtasks**:
1. Define AnalyticsEvent interface hierarchy
2. Implement AnalyticsEventRouter
3. Create FirebaseAnalyticsHandler
4. Implement specialized handlers (User, Search)
5. Build AnalyticsHub with event routing
6. Define standard event types for Journeyman Jobs
7. Create migration strategy for existing analytics
8. Add comprehensive event testing

**Validation Criteria**:
- [ ] Event router pattern properly implemented
- [ ] All existing analytics functionality preserved
- [ ] Code reduction achieved (>55%)
- [ ] Event tracking is consistent across app
- [ ] Firebase Analytics integration works
- [ ] Migration from old services is seamless

**Dependencies**: None
**Estimated Hours**: 12-16

---

### Task 2.4: Job Card Component Consolidation [P]

**Agent**: flutter-expert
**Complexity**: Complex
**Parallel Execution**: Yes

**Description**:
Consolidate 6 redundant job card components (1,978 lines) into a single configurable JobCard component with multiple variants, dramatically reducing code duplication and improving maintainability.

**Report Context**:
- Section: "Excessive Code Duplication"
- Current Components: job_card.dart (452 lines), optimized_job_card.dart (296 lines), enhanced_job_card.dart (654 lines), condensed_job_card.dart (196 lines), rich_text_job_card.dart (277 lines)
- Total Lines: ~1,978 lines serving the SAME purpose
- Reduction Target: 1,978 → 350 lines (82% reduction)

**Technical Implementation**:
```dart
// Job card variants
enum JobCardVariant {
  compact,
  full,
  enhanced,
  rich,
  minimal,
  detailed,
}

// Configurable job card
class JobCard extends StatelessWidget {
  final Job job;
  final JobCardVariant variant;
  final bool showActions;
  final VoidCallback? onTap;
  final Function(Job)? onSave;
  final Function(Job)? onShare;

  const JobCard({
    Key? key,
    required this.job,
    this.variant = JobCardVariant.full,
    this.showActions = true,
    this.onTap,
    this.onSave,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _getElevation(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: _getPadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildContent(),
              if (showActions) _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    switch (variant) {
      case JobCardVariant.compact:
        return _buildCompactHeader();
      case JobCardVariant.enhanced:
        return _buildEnhancedHeader();
      case JobCardVariant.rich:
        return _buildRichHeader();
      default:
        return _buildStandardHeader();
    }
  }

  // Variant-specific implementations...
}
```

**Subtasks**:
1. Analyze all 6 existing job card implementations
2. Define JobCardVariant enum with all needed variations
3. Create configurable JobCard component
4. Implement variant-specific rendering logic
5. Preserve all existing functionality
6. Create migration plan for existing usages
7. Build comprehensive widget tests
8. Update all screens to use new JobCard

**Validation Criteria**:
- [ ] Single JobCard component supports all variants
- [ ] All existing functionality preserved
- [ ] Code reduction achieved (>80%)
- [ ] Widget is highly configurable and reusable
- [ ] All screens successfully migrated
- [ ] Visual consistency maintained across variants

**Dependencies**: None
**Estimated Hours**: 20-24

---

### Task 2.5: Base JJCard Component Creation [P]

**Agent**: flutter-expert
**Complexity**: Complex
**Parallel Execution**: Yes

**Description**:
Create a base JJCard component to replace 26+ different card components across the app, establishing a consistent design system and reducing code duplication by 80%.

**Report Context**:
- Section: "UI Component Proliferation"
- Current Cards: 26+ different card types without reusable base
- Categories: Job Cards (6), Entity Cards (14), Utility Cards (6)
- Problem: Each card is separate widget with duplicated layout logic
- Reduction Target: 26 components → 1 base + 5 specialized (80% reduction)

**Technical Implementation**:
```dart
// Base card configuration
class JJCardConfig {
  final Widget? header;
  final Widget content;
  final Widget? footer;
  final CardVariant variant;
  final bool electricalTheme;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const JJCardConfig({
    this.header,
    required this.content,
    this.footer,
    this.variant = CardVariant.elevated,
    this.electricalTheme = true,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });
}

enum CardVariant {
  elevated,
  flat,
  outlined,
  electrical, // Custom with circuit patterns
  minimal,
}

// Base JJ card component
class JJCard extends StatelessWidget {
  final JJCardConfig config;

  const JJCard({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: config.elevation ?? _getDefaultElevation(),
      shape: _getCardShape(),
      color: config.backgroundColor ?? _getDefaultColor(),
      child: Container(
        decoration: config.electricalTheme
          ? _buildElectricalDecoration()
          : null,
        child: Padding(
          padding: config.padding ?? _getDefaultPadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (config.header != null) ...[
                config.header!,
                const SizedBox(height: 8),
              ],
              config.content,
              if (config.footer != null) ...[
                const SizedBox(height: 8),
                config.footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Electrical theme decoration
  Decoration _buildElectricalDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.accentCopper.withOpacity(0.3),
        width: 1,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          AppTheme.primaryNavy.withOpacity(0.02),
        ],
      ),
    );
  }
}

// Specialized card examples
class UnionCard extends StatelessWidget {
  final Union union;
  final VoidCallback? onTap;

  const UnionCard({
    Key? key,
    required this.union,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JJCard(
      config: JJCardConfig(
        header: _buildHeader(),
        content: _buildContent(),
        variant: CardVariant.electrical,
        electricalTheme: true,
      ),
    );
  }
}
```

**Subtasks**:
1. Analyze all 26+ existing card implementations
2. Define JJCardConfig with comprehensive options
3. Create base JJCard component with electrical theme
4. Implement specialized cards for common patterns
5. Create CardVariant enum for different styles
6. Build migration strategy for existing cards
7. Add electrical theme consistently
8. Create comprehensive widget tests

**Validation Criteria**:
- [ ] Base JJCard supports all required configurations
- [ ] Electrical theme consistently applied
- [ ] Code reduction achieved (>75%)
- [ ] Design system is consistent across app
- [ ] All existing card types successfully recreated
- [ ] Migration maintains visual consistency

**Dependencies**: None
**Estimated Hours**: 18-22

---

### Task 2.6: Circuit Pattern Painter Consolidation [P]

**Agent**: flutter-expert
**Complexity**: Moderate
**Parallel Execution**: Yes

**Description**:
Consolidate 5 nearly identical circuit pattern painter implementations (~400 lines) into a single canonical version with configurable options.

**Report Context**:
- Section: "Excessive Code Duplication"
- Current Implementations: circuit_pattern_painter.dart (58 lines), enhanced_backgrounds.dart:224, splash_screen.dart:378, jj_skeleton_loader.dart:132, circuit_board_background.dart:279
- Duplication: 5 nearly identical implementations
- Reduction Target: ~400 → 80 lines (80% reduction)

**Technical Implementation**:
```dart
// Circuit pattern configuration
class CircuitPatternConfig {
  final double density;
  final Color primaryColor;
  final Color secondaryColor;
  final double opacity;
  final bool animate;
  final Animation<double>? animation;
  final CircuitStyle style;

  const CircuitPatternConfig({
    this.density = 0.5,
    this.primaryColor = AppTheme.accentCopper,
    this.secondaryColor = AppTheme.primaryNavy,
    this.opacity = 0.3,
    this.animate = false,
    this.animation,
    this.style = CircuitStyle.modern,
  });
}

enum CircuitStyle {
  modern,
  vintage,
  minimalist,
  industrial,
}

// Canonical circuit pattern painter
class CircuitPatternPainter extends CustomPainter {
  final CircuitPatternConfig config;

  CircuitPatternPainter({required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = config.primaryColor.withOpacity(config.opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw circuit traces
    _drawCircuitTraces(canvas, size, paint);

    // Draw nodes
    _drawCircuitNodes(canvas, size, paint);

    // Draw components
    _drawCircuitComponents(canvas, size, paint);
  }

  void _drawCircuitTraces(Canvas canvas, Size size, Paint paint) {
    final traceCount = (size.width * size.height * config.density / 10000).round();

    for (int i = 0; i < traceCount; i++) {
      final start = Offset(
        _random.nextDouble() * size.width,
        _random.nextDouble() * size.height,
      );

      final path = Path();
      path.moveTo(start.dx, start.dy);

      // Create circuit-like path
      _createCircuitPath(path, start, size);

      canvas.drawPath(path, paint);
    }
  }

  // Other drawing methods...

  @override
  bool shouldRepaint(covariant CircuitPatternPainter oldDelegate) {
    return config != oldDelegate.config;
  }
}
```

**Subtasks**:
1. Analyze all 5 circuit pattern implementations
2. Define CircuitPatternConfig with all needed options
3. Create canonical CircuitPatternPainter
4. Implement different circuit styles
5. Add animation support
6. Replace all existing implementations
7. Create performance optimizations
8. Add comprehensive painter tests

**Validation Criteria**:
- [ ] Single CircuitPatternPainter supports all use cases
- [ ] All existing visual effects preserved
- [ ] Code reduction achieved (>75%)
- [ ] Performance is optimized for multiple screen usage
- [ ] Animation support works correctly
- [ ] All screens updated to use canonical painter

**Dependencies**: None
**Estimated Hours**: 10-14

---

### Task 2.7: Loader Component Consolidation [P]

**Agent**: flutter-expert
**Complexity**: Moderate
**Parallel Execution**: Yes

**Description**:
Consolidate 7 loader components into 3 optimized loaders (JJPowerLineLoader, ThreePhaseSineWaveLoader, JJSkeletonLoader), eliminating redundant implementations and improving performance.

**Report Context**:
- Section: "Excessive Code Duplication"
- Current Loaders: JJElectricalLoader, JJPowerLineLoader (duplicate), ElectricalLoader, ThreePhaseSineWaveLoader, PowerLineLoader, JJSkeletonLoader
- Duplication: JJPowerLineLoader exists in 2 files
- Target: 7 → 3 components (57% reduction)

**Technical Implementation**:
```dart
// Primary loader for general use
class JJPowerLineLoader extends StatelessWidget {
  final double width;
  final double height;
  final String? message;
  final Color? color;
  final double strokeWidth;

  const JJPowerLineLoader({
    Key? key,
    this.width = 200,
    this.height = 60,
    this.message,
    this.color,
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            height: height * 0.7,
            child: CustomPaint(
              painter: PowerLinePainter(
                color: color ?? AppTheme.accentCopper,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Electrical-specific loader
class ThreePhaseSineWaveLoader extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;

  const ThreePhaseSineWaveLoader({
    Key? key,
    this.width = 150,
    this.height = 100,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: ThreePhasePainter(
          color: color ?? AppTheme.primaryNavy,
        ),
      ),
    );
  }
}

// Skeleton loader for content placeholders
class JJSkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool showCircuitPattern;

  const JJSkeletonLoader({
    Key? key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 8,
    this.showCircuitPattern = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceLight,
            AppTheme.surfaceDark,
          ],
        ),
      ),
      child: showCircuitPattern
        ? CustomPaint(
            painter: CircuitPatternPainter(
              config: CircuitPatternConfig(
                density: 0.2,
                opacity: 0.1,
                animate: false,
              ),
            ),
          )
        : null,
    );
  }
}
```

**Subtasks**:
1. Analyze all 7 existing loader implementations
2. Define loader usage patterns and requirements
3. Optimize JJPowerLineLoader as primary loader
4. Enhance ThreePhaseSineWaveLoader for electrical theme
5. Improve JJSkeletonLoader for content placeholders
6. Remove duplicate JJPowerLineLoader implementation
7. Update all screens to use consolidated loaders
8. Create loader performance tests

**Validation Criteria**:
- [ ] Only 3 loader components remain
- [ ] All loader use cases covered
- [ ] Code reduction achieved (>50%)
- [ ] Performance improved with optimized implementations
- [ ] Electrical theme consistent across loaders
- [ ] All screens successfully migrated

**Dependencies**: None
**Estimated Hours**: 8-12

---

### Task 2.8: Performance Quick Wins Implementation [P]

**Agent**: performance-benchmarker
**Complexity**: Moderate
**Parallel Execution**: Yes

**Description**:
Implement quick performance wins including const constructors, ListView optimizations, and debouncing to achieve immediate 30-40% performance improvement.

**Report Context**:
- Section: "Performance Bottlenecks"
- Issues: Missing const constructors (25-40% CPU waste), ListView inefficiencies, no debouncing
- Impact: Only 2,603 const constructors out of ~5,000 widget instances
- Target: +30% performance with const additions

**Technical Implementation**:
```dart
// Add const constructors to common widgets
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const FilterChipWidget({  // ✅ Const constructor
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

// Optimize ListView for large lists
class OptimizedUnionListView extends StatelessWidget {
  final List<Union> unions;

  const OptimizedUnionListView({
    Key? key,
    required this.unions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: unions.length,
      itemExtent: 120, // ✅ Height hint for recycling
      cacheExtent: 500, // ✅ Cache extent for performance
      itemBuilder: (context, index) {
        return UnionCard(
          key: ValueKey(unions[index].id), // ✅ Stable key
          union: unions[index],
        );
      },
    );
  }
}

// Debounced search implementation
class DebouncedSearch extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSearch;
  final Duration delay;

  const DebouncedSearch({
    Key? key,
    required this.onSearch,
    this.initialValue = '',
    this.delay = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _DebouncedSearchState createState() => _DebouncedSearchState();
}

class _DebouncedSearchState extends State<DebouncedSearch> {
  Timer? _debounceTimer;
  String _currentValue = '';

  void _onSearchChanged(String value) {
    _currentValue = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.delay, () {
      widget.onSearch(_currentValue);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search unions...',
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
```

**Subtasks**:
1. Identify all widgets that can use const constructors
2. Add const constructors to 500+ widget instances
3. Optimize ListView.builder implementations with itemExtent and keys
4. Implement debounced search for all search inputs
5. Add RepaintBoundary widgets strategically
6. Optimize image loading with caching
7. Add performance monitoring
8. Create performance benchmarks

**Validation Criteria**:
- [ ] Const constructors added to all eligible widgets
- [ ] ListView implementations optimized with itemExtent and keys
- [ ] Debounced search implemented for all search inputs
- [ ] RepaintBoundary widgets added to prevent unnecessary rebuilds
- [ ] Performance improvement measured and validated (>30%)
- [ ] Memory usage reduced

**Dependencies**: None
**Estimated Hours**: 12-16

---

### Task 2.9: Message Service Conflict Resolution [P]

**Agent**: backend-architect
**Complexity**: Complex
**Parallel Execution**: Yes

**Description**:
Resolve the conflict between three message services (ChatService, MessageService, CrewMessageService) by defining clear boundaries and consolidating overlapping functionality.

**Report Context**:
- Section: "Architectural Contradictions"
- Issue: Three Message Services with unclear boundaries
- Overlap: ChatService, MessageService, CrewMessageService
- Problem: Overlapping responsibilities, duplicate code

**Technical Implementation**:
```dart
// Unified message service architecture
abstract class MessageService {
  Future<void> sendMessage(Message message);
  Future<List<Message>> getMessages(String conversationId);
  Stream<List<Message>> getMessageStream(String conversationId);
}

class ChatMessageService implements MessageService {
  final FirebaseFirestore _firestore;

  ChatMessageService(this._firestore);

  @override
  Future<void> sendMessage(Message message) async {
    // Handle 1-on-1 chat messages
    await _firestore
        .collection('chats')
        .doc(message.conversationId)
        .collection('messages')
        .add(message.toMap());
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Message.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<List<Message>> getMessageStream(String conversationId) {
    return _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc))
            .toList());
  }
}

class CrewMessageService implements MessageService {
  final FirebaseFirestore _firestore;

  CrewMessageService(this._firestore);

  @override
  Future<void> sendMessage(Message message) async {
    // Handle crew-specific messages with crew permissions
    await _firestore
        .collection('crews')
        .doc(message.crewId)
        .collection('messages')
        .add(message.toMap());
  }

  // Implementation for crew messages...
}

// Message service factory
class MessageServiceFactory {
  static MessageService createService(MessageType type) {
    switch (type) {
      case MessageType.chat:
        return ChatMessageService(FirebaseFirestore.instance);
      case MessageType.crew:
        return CrewMessageService(FirebaseFirestore.instance);
      default:
        throw ArgumentError('Unknown message type: $type');
    }
  }
}
```

**Subtasks**:
1. Analyze all three message service implementations
2. Define clear service boundaries and responsibilities
3. Create unified MessageService interface
4. Implement specialized services for different message types
5. Create MessageServiceFactory for service selection
6. Migrate all message-related code to new architecture
7. Implement comprehensive message testing
8. Update all screens and providers

**Validation Criteria**:
- [ ] Clear separation of concerns between message services
- [ ] Unified interface for all message operations
- [ ] No duplicate code between services
- [ ] All existing message functionality preserved
- [ ] Service factory properly routes to correct implementation
- [ ] All screens successfully migrated

**Dependencies**: None
**Estimated Hours**: 16-20

---

### Task 2.10: Collection Naming Standardization [P]

**Agent**: database-optimizer
**Complexity**: Moderate
**Parallel Execution**: Yes

**Description**:
Standardize Firestore collection naming between crew_messages_{crewId} and crews/{crewId}/messages patterns to resolve query confusion and improve data organization.

**Report Context**:
- Section: "Architectural Contradictions"
- Issue: Firestore Collection Naming Inconsistency
- Conflict: `crew_messages_{crewId}` vs `crews/{crewId}/messages`
- Problem: Causes query confusion

**Technical Implementation**:
```dart
// Collection naming standardization
class CollectionPaths {
  // Standardized collection paths
  static String crews() => 'crews';
  static String crew(String crewId) => 'crews/$crewId';
  static String crewMessages(String crewId) => 'crews/$crewId/messages';
  static String crewMembers(String crewId) => 'crews/$crewId/members';

  static String jobs() => 'jobs';
  static String users() => 'users';
  static String notifications() => 'notifications';
}

// Migration service for collection standardization
class CollectionMigrationService {
  final FirebaseFirestore _firestore;

  CollectionMigrationService(this._firestore);

  Future<void> migrateCrewMessages() async {
    // Get all collections with old naming pattern
    final collections = await _firestore.getCollections();
    final oldCollections = collections
        .where((ref) => ref.path.startsWith('crew_messages_'))
        .toList();

    for (final oldCollection in oldCollections) {
      // Extract crew ID from old collection name
      final crewId = oldCollection.path.split('_').last;

      // Create new collection path
      final newCollection = _firestore
          .collection('crews')
          .doc(crewId)
          .collection('messages');

      // Migrate all documents
      final snapshot = await oldCollection.get();
      for (final doc in snapshot.docs) {
        await newCollection.doc(doc.id).set(doc.data());
      }

      // Delete old collection after successful migration
      await _deleteCollection(oldCollection);
    }
  }

  Future<void> _deleteCollection(CollectionReference reference) async {
    final snapshot = await reference.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
```

**Subtasks**:
1. Analyze current collection naming patterns
2. Define standardized collection path conventions
3. Create CollectionPaths utility class
4. Implement CollectionMigrationService
5. Migrate data from old collections to new structure
6. Update all queries to use new collection paths
7. Create migration tests to ensure data integrity
8. Update all related services and providers

**Validation Criteria**:
- [ ] All collections follow standardized naming convention
- [ ] Data migration completed without data loss
- [ ] All queries updated to use new collection paths
- [ ] Collection paths utility consistently used
- [ ] Migration tests validate data integrity
- [ ] All services work with new collection structure

**Dependencies**: None
**Estimated Hours**: 10-14

---

### Task 2.11: Theme System Decoupling [P]

**Agent**: flutter-expert
**Complexity**: Moderate
**Parallel Execution**: Yes

**Description**:
Fix the theme system coupling issue where dark theme depends on light theme causing circular dependencies, and establish independent theme variants.

**Report Context**:
- Section: "Architectural Contradictions"
- Issue: Theme System Coupling
- Problem: Dark theme depends on light theme (circular dependency)
- Requirement: Should be independent

**Technical Implementation**:
```dart
// Independent theme system
abstract class ThemeConfiguration {
  Color get primaryColor;
  Color get accentColor;
  Color get backgroundColor;
  Color get surfaceColor;
  Color get textColor;
  Brightness get brightness;
}

class LightThemeConfiguration implements ThemeConfiguration {
  @override
  Color get primaryColor => AppTheme.primaryNavy;

  @override
  Color get accentColor => AppTheme.accentCopper;

  @override
  Color get backgroundColor => Colors.white;

  @override
  Color get surfaceColor => Colors.grey[50]!;

  @override
  Color get textColor => Colors.black87;

  @override
  Brightness get brightness => Brightness.light;
}

class DarkThemeConfiguration implements ThemeConfiguration {
  @override
  Color get primaryColor => AppTheme.primaryNavyLight;

  @override
  Color get accentColor => AppTheme.accentCopperDark;

  @override
  Color get backgroundColor => AppTheme.surfaceDark;

  @override
  Color get surfaceColor => AppTheme.primaryNavy;

  @override
  Color get textColor => Colors.white;

  @override
  Brightness get brightness => Brightness.dark;
}

// Theme builder without circular dependencies
class AppThemeBuilder {
  static ThemeData buildTheme(ThemeConfiguration config) {
    return ThemeData(
      brightness: config.brightness,
      primaryColor: config.primaryColor,
      accentColor: config.accentColor,
      backgroundColor: config.backgroundColor,
      scaffoldBackgroundColor: config.backgroundColor,
      cardColor: config.surfaceColor,
      textTheme: _buildTextTheme(config),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(config.primaryColor),
        brightness: config.brightness,
      ),
    );
  }

  static TextTheme _buildTextTheme(ThemeConfiguration config) {
    return TextTheme(
      headlineLarge: TextStyle(
        color: config.textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: config.textColor,
        fontSize: 16,
      ),
      // More text styles...
    );
  }
}

// Theme provider
class ThemeProvider extends ChangeNotifier {
  ThemeConfiguration _currentTheme = LightThemeConfiguration();

  ThemeConfiguration get currentTheme => _currentTheme;

  void setLightTheme() {
    _currentTheme = LightThemeConfiguration();
    notifyListeners();
  }

  void setDarkTheme() {
    _currentTheme = DarkThemeConfiguration();
    notifyListeners();
  }

  ThemeData get themeData => AppThemeBuilder.buildTheme(_currentTheme);
}
```

**Subtasks**:
1. Analyze current theme system dependencies
2. Define ThemeConfiguration interface
3. Create independent theme configurations
4. Implement AppThemeBuilder without circular dependencies
5. Create ThemeProvider with proper state management
6. Update all theme usage throughout app
7. Add theme switching functionality
8. Create comprehensive theme tests

**Validation Criteria**:
- [ ] Theme configurations are independent
- [ ] No circular dependencies between themes
- [ ] Theme switching works properly
- [ ] All UI components correctly use theme colors
- [ ] Light and dark themes are visually distinct
- [ ] Theme provider properly notifies listeners

**Dependencies**: None
**Estimated Hours**: 8-12

---

### Task 2.12: State Management Pattern Standardization [P]

**Agent**: backend-architect
**Complexity**: Complex
**Parallel Execution**: Yes

**Description**:
Standardize on Riverpod as the sole state management solution, removing Provider and StatefulWidget state management inconsistencies.

**Report Context**:
- Section: "Architectural Contradictions"
- Issue: Multiple State Management Patterns
- Current: Provider, Riverpod, StatefulWidget all used
- Note: provider package unused but still in dependencies
- Problem: Inconsistent state management across app

**Technical Implementation**:
```dart
// Riverpod provider standardization
// Counter example using Riverpod
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// User state management
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.watch(authServiceProvider));
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this._authService) : super(const UserState.initial());

  final AuthService _authService;

  Future<void> signIn(String email, String password) async {
    state = const UserState.loading();

    try {
      final user = await _authService.signIn(email, password);
      state = UserState.authenticated(user);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const UserState.initial();
  }
}

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.authenticated(User user) = _Authenticated;
  const factory UserState.error(String message) = _Error;
}

// Complex state example - Job search
final jobSearchProvider = StateNotifierProvider<JobSearchNotifier, JobSearchState>((ref) {
  return JobSearchNotifier(ref.watch(jobServiceProvider));
});

class JobSearchNotifier extends StateNotifier<JobSearchState> {
  JobSearchNotifier(this._jobService) : super(const JobSearchState.initial());

  final JobService _jobService;

  Future<void> searchJobs(JobSearchCriteria criteria) async {
    state = const JobSearchState.loading();

    try {
      final jobs = await _jobService.searchJobs(criteria);
      state = JobSearchState.loaded(jobs);
    } catch (e) {
      state = JobSearchState.error(e.toString());
    }
  }

  void updateCriteria(JobSearchCriteria criteria) {
    state = state.whenOrNull(
      loaded: (jobs) => JobSearchState.loaded(jobs, criteria: criteria),
    ) ?? const JobSearchState.initial();
  }
}

@freezed
class JobSearchState with _$JobSearchState {
  const factory JobSearchState.initial() = _Initial;
  const factory JobSearchState.loading() = _Loading;
  const factory JobSearchState.loaded(
    List<Job> jobs, {
    @Default(JobSearchCriteria.empty()) JobSearchCriteria criteria,
  }) = _Loaded;
  const factory JobSearchState.error(String message) = _Error;
}
```

**Subtasks**:
1. Audit all state management usage across app
2. Identify all Provider and StatefulWidget state usage
3. Create Riverpod providers for all application state
4. Implement proper state classes with freezed
5. Update all screens to use Riverpod providers
6. Remove provider dependency (already done in Phase 1)
7. Add comprehensive state management tests
8. Create Riverpod best practices documentation

**Validation Criteria**:
- [ ] All state management uses Riverpod exclusively
- [ ] No Provider pattern usage remaining
- [ ] StatefulWidget state properly converted to Riverpod
- [ ] State is properly immutable and testable
- [ ] Provider dependencies are correctly wired
- [ ] All state transitions are properly handled

**Dependencies**: Task 1.6 (Dependency Cleanup)
**Estimated Hours**: 20-24

---

## 📊 Phase 2 Summary

**Parallel Execution Capability**: 12/12 tasks can run concurrently (100% parallel)
**Total Estimated Hours**: 150-190 hours
**Expected Impact**:
- -7,500 lines of code (-70%)
- +30-40% performance improvement
- Dramatically improved maintainability

**Key Success Metrics**:
- All backend services consolidated with strategy pattern
- All UI components follow unified design system
- Performance optimizations implemented
- Architectural contradictions resolved

---

*Continue with Phase 3-5 in next message...*