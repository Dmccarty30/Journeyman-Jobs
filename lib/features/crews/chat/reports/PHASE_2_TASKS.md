# Phase 2: Crew Features Implementation - Detailed Tasks

## 📅 Week 2 Overview

**Goal**: Implement complete crew chat functionality with member management and electrical worker-specific features
**Duration**: 5 working days
**Priority**: High - Essential for crew collaboration

---

## Day 6: Crew Channel Management

### Task 6.1: Crew Channel Service Extension

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Extend StreamChatService for Crews** (1 hour)
   - [ ] Add `createCrewChannel` method
   - [ ] Implement crew type validation
   - [ ] Add crew metadata handling
   - [ ] Create crew-specific channel configuration

2. **Crew Type System** (1 hour)
   - [ ] Implement CrewType enum values
   - [ ] Add crew type validation logic
   - [ ] Create crew type permissions
   - [ ] Add crew-specific features per type

3. **Crew Channel Configuration** (1 hour)
   - [ ] Set up crew channel permissions
   - [ ] Configure member roles
   - [ ] Add electrical features flags
   - [ ] Implement crew settings

**File: `stream_chat_service.dart` additions**

```dart
Future<Either<ChatException, Channel>> createCrewChannel({
  required String crewName,
  required List<String> memberIds,
  required CrewType crewType,
  String? description,
  Map<String, dynamic>? crewSettings,
}) async {
  try {
    final allMembers = {...memberIds, _currentUserId!}.toList();

    final extraData = {
      'name': 'IBEW $crewName',
      'description': description,
      'crew_type': crewType.value,
      'type': 'crew',
      'members': allMembers,
      'created_by': _currentUserId,
      'electrical_features': [
        'job_sharing',
        'safety_alerts',
        'location_sharing',
        'tool_inventory',
        'skill_tracking',
      ],
      'ibew_verified': true,
      'permissions': {
        'admin': [_currentUserId!],
        'members': allMembers,
        'settings': crewSettings ?? {},
      },
      'created_at': DateTime.now().toIso8601String(),
    };

    final channel = await _client.channel(
      'messaging',
      extraData: extraData,
    );

    // Set initial permissions
    await channel.update({
      'members': allMembers,
      'created_by': _currentUserId,
    });

    return Right(channel);
  } catch (e) {
    return Left(ChannelCreationException(e.toString()));
  }
}

Future<Either<ChatException, void>> updateCrewSettings({
  required String channelId,
  required Map<String, dynamic> settings,
}) async {
  try {
    final channel = _client.channel(
      channelType: 'messaging',
      id: channelId,
    );

    await channel.update({
      'permissions.settings': settings,
      'updated_at': DateTime.now().toIso8601String(),
    });

    return const Right(null);
  } catch (e) {
    return Left(ChannelUpdateException(e.toString()));
  }
}
```

**Acceptance Criteria**:

- Crew channels create with proper metadata
- Crew types enforce correct rules
- Permissions set correctly
- Electrical features enabled

---

### Task 6.2: Crew Permission System

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Permission Model** (1 hour)
   - [ ] Create CrewPermission model
   - [ ] Define role hierarchy
   - [ ] Implement permission checks
   - [ ] Add permission inheritance

2. **Role Management** (1 hour)
   - [ ] Implement Role enum (Owner, Admin, Member, Observer)
   - [ ] Create role assignment logic
   - [ ] Add role validation
   - [ ] Implement role promotion/demotion

3. **Permission Enforcement** (1 hour)
   - [ ] Add permission checks to all actions
   - [ ] Create permission middleware
   - [ ] Implement error messages for denied actions
   - [ ] Add permission indicators in UI

**File: `crew_permission.dart`**

```dart
enum CrewRole {
  owner('owner', 100),
  admin('admin', 80),
  member('member', 50),
  observer('observer', 20);

  const CrewRole(this.value, this.level);
  final String value;
  final int level;
}

enum CrewPermission {
  inviteMembers('invite_members', 80),
  removeMembers('remove_members', 80),
  changeSettings('change_settings', 80),
  postMessages('post_messages', 50),
  viewHistory('view_history', 50),
  shareJobs('share_jobs', 50),
  postSafetyAlerts('post_safety_alerts', 50),
  viewMemberInfo('view_member_info', 20);

  const CrewPermission(this.value, this.requiredLevel);
  final String value;
  final int requiredLevel;
}

class CrewPermissionManager {
  static bool hasPermission(CrewRole role, CrewPermission permission) {
    return role.level >= permission.requiredLevel;
  }

  static Set<CrewPermission> getPermissionsForRole(CrewRole role) {
    return CrewPermission.values
        .where((p) => hasPermission(role, p))
        .toSet();
  }

  static List<CrewRole> getRolesThatCanChangeRole(CrewRole targetRole) {
    return CrewRole.values
        .where((r) => r.level > targetRole.level)
        .toList();
  }
}
```

**Acceptance Criteria**:

- Permission system works correctly
- Roles enforce proper hierarchy
- Permission checks prevent unauthorized actions
- UI reflects user permissions

---

### Task 6.3: Crew Member Management

**Estimated Time**: 2 hours
**Priority**: High

#### Subtasks

1. **Member Management Service** (1 hour)
   - [ ] Add member invitation logic
   - [ ] Implement member removal
   - [ ] Create member role management
   - [ ] Add member profile access

2. **Member Validation** (1 hour)
   - [ ] Validate IBEW membership
   - [ ] Check union local compatibility
   - [ ] Verify skill classifications
   - [ ] Add member limits per crew

**Acceptance Criteria**:

- Members can be invited/removed
- Roles properly assigned
- Validation prevents invalid additions
- Member list updates in real-time

---

## Day 7: Crew UI Implementation

### Task 7.1: Crew Directory Screen

**Estimated Time**: 4 hours
**Priority**: High

#### Subtasks

1. **Screen Layout** (1.5 hours)
   - [ ] Create CrewDirectoryScreen scaffold
   - [ ] Implement crew list/grid view toggle
   - [ ] Add search and filter options
   - [ ] Create crew creation FAB
   - [ ] Add crew type filters

2. **Crew Card Component** (1.5 hours)
   - [ ] Design CrewCard widget
   - [ ] Add crew avatar with electrical theme
   - [ ] Display crew member count
   - [ ] Show crew type indicator
   - [ ] Add online member count
   - [ ] Display last activity

3. **Functionality** (1 hour)
   - [ ] Connect to CrewProvider
   - [ ] Implement search functionality
   - [ ] Add filter by crew type
   - [ ] Handle crew joining
   - [ ] Show pending invitations

**File: `crew_directory_screen.dart`**

```dart
class CrewDirectoryScreen extends StatefulWidget {
  const CrewDirectoryScreen({Key? key}) : super(key: key);

  @override
  State<CrewDirectoryScreen> createState() => _CrewDirectoryScreenState();
}

class _CrewDirectoryScreenState extends State<CrewDirectoryScreen> {
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();
  CrewType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(
          'Crew Directory',
          style: AppTheme.headingLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryNavy,
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppTheme.accentCopper,
            ),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: Consumer<CrewProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: JJElectricalLoader(
                      width: 200,
                      height: 60,
                      message: 'Loading crews...',
                    ),
                  );
                }

                final crews = _getFilteredCrews(provider.crews);

                if (crews.isEmpty) {
                  return _buildEmptyState();
                }

                return _isGridView
                    ? _buildCrewGrid(crews)
                    : _buildCrewList(crews);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCrew,
        backgroundColor: AppTheme.accentCopper,
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: const Text(
          'Create Crew',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          JJSearchBar(
            controller: _searchController,
            hintText: 'Search crews...',
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(null, 'All'),
                ...CrewType.values.map(
                  (type) => _buildFilterChip(type, type.name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(CrewType? type, String label) {
    final isSelected = _selectedFilter == type;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? type : null;
          });
          context.read<CrewProvider>().filterCrews(
            searchQuery: _searchController.text,
            crewType: _selectedFilter,
          );
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.accentCopper.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.textGrey,
        ),
      ),
    );
  }
}
```

**Acceptance Criteria**:

- Directory displays all accessible crews
- Search filters crews in real-time
- Grid/list toggle works
- Crew cards show relevant information
- Empty state guides user

---

### Task 7.2: Crew Creation Screen

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Creation Flow** (1.5 hours)
   - [ ] Create multi-step creation wizard
   - [ ] Step 1: Basic info (name, type, description)
   - [ ] Step 2: Member selection
   - [ ] Step 3: Settings configuration
   - [ ] Step 4: Review and create

2. **Member Selection** (1 hour)
   - [ ] Implement member search
   - [ ] Show IBEW member suggestions
   - [ ] Add union local filter
   - [ ] Create member preview cards

3. **Settings Configuration** (30 min)
   - [ ] Add crew visibility options
   - [ ] Configure member permissions
   - [ ] Set up notification preferences
   - [ ] Add safety protocols

**Acceptance Criteria**:

- Creation wizard guides user clearly
- Member selection works with search
- Settings save correctly
- Crew creates successfully

---

### Task 7.3: Crew Management Screen

**Estimated Time**: 3 hours
**Priority**: Medium

#### Subtasks

1. **Management Interface** (1.5 hours)
   - [ ] Create CrewManagementScreen
   - [ ] Show crew details and settings
   - [ ] Display member list with roles
   - [ ] Add management actions menu

2. **Member Management** (1 hour)
   - [ ] List all members with roles
   - [ ] Show member profiles
   - [ ] Implement role changes
   - [ ] Add member removal

3. **Settings Management** (30 min)
   - [ ] Edit crew details
   - [ ] Update notification settings
   - [ ] Manage privacy settings
   - [ ] Configure safety alerts

**Acceptance Criteria**:

- Management screen loads correctly
- Member list shows all members
- Roles can be changed (if permitted)
- Settings update successfully

---

## Day 8: Crew Chat Features

### Task 8.1: Crew Chat Screen Enhancement

**Estimated Time**: 4 hours
**Priority**: High

#### Subtasks

1. **Crew-Specific UI** (1.5 hours)
   - [ ] Enhance ChatScreen for crew context
   - [ ] Add crew header with member count
   - [ ] Show crew type indicator
   - [ ] Display crew status

2. **Member Status Panel** (1.5 hours)
   - [ ] Create sliding member panel
   - [ ] Show online/offline members
   - [ ] Display member roles
   - [ ] Add member quick actions

3. **Crew Actions** (1 hour)
   - [ ] Add crew-specific message types
   - [ ] Implement crew announcements
   - [ ] Add safety alert quick access
   - [ ] Create job sharing shortcut

**File: `crew_chat_screen.dart`**

```dart
class CrewChatScreen extends StatefulWidget {
  final String crewId;

  const CrewChatScreen({Key? key, required this.crewId}) : super(key: key);

  @override
  State<CrewChatScreen> createState() => _CrewChatScreenState();
}

class _CrewChatScreenState extends State<CrewChatScreen> {
  bool _showMemberPanel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: CrewChatHeader(crewId: widget.crewId),
        backgroundColor: AppTheme.primaryNavy,
        actions: [
          IconButton(
            icon: Icon(
              Icons.people_outline,
              color: AppTheme.accentCopper,
            ),
            onPressed: _toggleMemberPanel,
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.accentCopper,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'crew_info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Crew Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'safety_alert',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Safety Alert'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_job',
                child: Row(
                  children: [
                    Icon(Icons.work),
                    SizedBox(width: 8),
                    Text('Share Job'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          ChatScreen(
            channelId: widget.crewId,
            showCrewFeatures: true,
          ),
          if (_showMemberPanel)
            Positioned(
              right: 0,
              top: 0,
              bottom: 60,
              child: CrewMemberPanel(
                crewId: widget.crewId,
                onClose: () => setState(() => _showMemberPanel = false),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CrewActionBar(crewId: widget.crewId),
    );
  }

  void _toggleMemberPanel() {
    setState(() {
      _showMemberPanel = !_showMemberPanel;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'crew_info':
        context.push('/crew/${widget.crewId}/info');
        break;
      case 'safety_alert':
        _showSafetyAlertDialog();
        break;
      case 'share_job':
        context.push('/jobs/select?crewId=${widget.crewId}');
        break;
    }
  }
}
```

**Acceptance Criteria**:

- Crew chat shows crew-specific features
- Member panel slides smoothly
- Quick actions work correctly
- UI maintains electrical theme

---

### Task 8.2: Crew-Specific Message Types

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Safety Alert Messages** (1 hour)
   - [ ] Create SafetyAlertMessage widget
   - [ ] Implement alert severity levels
   - [ ] Add alert acknowledgment
   - [ ] Show alert status

2. **Job Posting Messages** (1 hour)
   - [ ] Create JobPostingMessage widget
   - [ ] Show job details card
   - [ ] Add quick apply button
   - [ ] Track job interactions

3. **Crew Announcement Messages** (30 min)
   - [ ] Create AnnouncementMessage widget
   - [ ] Add announcement styling
   - [ ] Show pinned status
   - [ ] Implement acknowledgment

**Acceptance Criteria**:

- All crew message types display correctly
- Interactions work properly
- Messages have appropriate styling
- Acknowledgments are tracked

---

### Task 8.3: Electrical Reactions System

**Estimated Time**: 2 hours
**Priority**: Medium

#### Subtasks

1. **Custom Reactions** (1 hour)
   - [ ] Define electrical reaction emojis
   - [ ] Create reaction picker widget
   - [ ] Implement reaction storage
   - [ ] Add reaction animations

2. **Reaction Display** (1 hour)
   - [ ] Show reactions on messages
   - [ ] Display reaction counts
   - [ ] Handle reaction addition/removal
   - [ ] Show reaction user list

**File: `electrical_reactions.dart`**

```dart
class ElectricalReactions {
  static const Map<String, String> reactions = {
    'power': '⚡', // Power/energy
    'tools': '🔧', // Tools/repair
    'safety': '⚠️', // Safety/warning
    'approved': '👍', // Approval
    'location': '📍', // Location
    'job': '⚙️', // Work/order
    'call': '📞', // Contact
    'work_zone': '🚧', // Work zone
  };

  static Widget buildReactionPicker({
    required Function(String) onReactionSelected,
  }) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
        ),
        itemCount: reactions.length,
        itemBuilder: (context, index) {
          final key = reactions.keys.elementAt(index);
          final emoji = reactions[key]!;

          return GestureDetector(
            onTap: () => onReactionSelected(key),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

**Acceptance Criteria**:

- Reaction picker shows all electrical emojis
- Reactions add/remove correctly
- Reaction counts update
- Animations are smooth

---

## Day 9: Crew Integration

### Task 9.1: Integration with Existing Crew System

**Estimated Time**: 4 hours
**Priority**: High

#### Subtasks

1. **Data Synchronization** (2 hours)
   - [ ] Connect to existing crew database
   - [ ] Sync crew memberships automatically
   - [ ] Update crew chat channels on changes
   - [ ] Handle crew data conflicts

2. **Auth Integration** (1 hour)
   - [ ] Verify IBEW membership
   - [ ] Check union local affiliations
   - [ ] Validate skill classifications
   - [ ] Map user roles

3. **Service Integration** (1 hour)
   - [ ] Integrate with CrewService
   - [ ] Sync with job assignments
   - [ ] Connect to scheduling system
   - [ ] Link to location tracking

**Acceptance Criteria**:

- Crew data syncs automatically
- Membership is verified
- No data conflicts occur
- All integrations work

---

### Task 9.2: Crew Discovery Features

**Estimated Time**: 2 hours
**Priority**: Medium

#### Subtasks

1. **Crew Search** (1 hour)
   - [ ] Implement crew search by name
   - [ ] Search by union local
   - [ ] Filter by crew type
   - [ ] Search by location

2. **Crew Recommendations** (1 hour)
   - [ ] Show suggested crews
   - [ ] Recommend based on location
   - [ ] Suggest by union local
   - [ ] Show similar crews

**Acceptance Criteria**:

- Search returns relevant results
- Filters work correctly
- Recommendations are helpful
- Discovery is intuitive

---

## Day 10: Testing & Polish

### Task 10.1: Comprehensive Testing

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Unit Tests** (1 hour)
   - [ ] Test all crew services
   - [ ] Test permission system
   - [ ] Test crew models
   - [ ] Test data conversion

2. **Widget Tests** (1 hour)
   - [ ] Test all crew screens
   - [ ] Test crew components
   - [ ] Test user interactions
   - [ ] Test error states

3. **Integration Tests** (1 hour)
   - [ ] Test crew creation flow
   - [ ] Test member management
   - [ ] Test message sending
   - [ ] Test permission enforcement

**Acceptance Criteria**:

- All tests pass
- Code coverage >80%
- Critical paths tested
- Error cases covered

---

### Task 10.2: Performance Optimization

**Estimated Time**: 2 hours
**Priority**: Medium

#### Subtasks

1. **UI Optimization** (1 hour)
   - [ ] Optimize list scrolling
   - [ ] Reduce unnecessary rebuilds
   - [ ] Implement lazy loading
   - [ ] Add image caching

2. **Network Optimization** (1 hour)
   - [ ] Reduce API calls
   - [ ] Implement caching
   - [ ] Optimize data fetching
   - [ ] Add retry logic

**Acceptance Criteria**:

- 60fps scrolling maintained
- Minimal network usage
- Fast load times
- Smooth animations

---

### Task 10.3: Polish & Documentation

**Estimated Time**: 1 hour
**Priority**: Low

#### Subtasks

1. **UI Polish** (30 min)
   - [ ] Add loading states
   - [ ] Improve error messages
   - [ ] Add empty states
   - [ ] Enhance transitions

2. **Documentation** (30 min)
   - [ ] Update code comments
   - [ ] Document new features
   - [ ] Update API docs
   - [ ] Create user guide

**Acceptance Criteria**:

- UI is polished and professional
- All features documented
- Code is well-commented
- User guide is clear

---

## 🎯 Week 2 Deliverables

### Completed Features

1. ✅ Crew channel creation and management
2. ✅ Member invitation and role management
3. ✅ Crew permission system
4. ✅ Crew directory with search and filters
5. ✅ Crew-specific chat features
6. ✅ Safety alert messages
7. ✅ Job posting integration
8. ✅ Electrical reaction system
9. ✅ Member status panel
10. ✅ Integration with existing crew system

### Working Components

- Users can create and manage crews
- Members can be invited with roles
- Permissions enforced properly
- Crew directory browsable
- Crew chats with special features
- Safety alerts functional
- Job sharing in crews
- Real-time member status

### Ready for Testing

- Complete crew creation flow
- Member management operations
- Crew chat with all features
- Permission enforcement
- Integration with existing systems

---

## ✅ Week 2 Completion Checklist

### Core Features

- [ ] Crew channels can be created
- [ ] Member management works
- [ ] Permission system active
- [ ] Crew directory functional
- [ ] Crew chat features working
- [ ] Safety alerts implemented
- [ ] Job sharing functional
- [ ] Integration complete

### Quality Assurance

- [ ] All unit tests passing
- [ ] Widget tests covering UI
- [ ] Integration tests working
- [ ] Performance optimized
- [ ] Code reviewed and approved

### Documentation

- [ ] API documentation updated
- [ ] User guide created
- [ ] Developer docs updated
- [ ] Changelog maintained

---

## 🚀 Next Week Preparation

### Before starting Phase 3

1. Get stakeholder approval on crew features
2. Review user feedback from testing
3. Fix any critical bugs found
4. Update project timeline if needed
5. Prepare design mockups for Phase 3

### Phase 3 Preview

- File attachments (images, documents)
- Message reactions and threading
- Feed system implementation
- Push notifications
- Offline support enhancement

This detailed task breakdown for Phase 2 provides comprehensive guidance for implementing all crew-related features with proper permissions, member management, and electrical worker-specific functionality.
