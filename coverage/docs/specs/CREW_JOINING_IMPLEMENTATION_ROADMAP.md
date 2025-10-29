# Crew Joining Feature - Implementation Roadmap

**Status:** Ready for Development
**Sprint Duration:** 5 weeks (MVP)
**Start Date:** TBD

---

## ✅ Completed (Pre-Implementation)

### Requirements Discovery

- [x] Systematic requirements exploration completed
- [x] All key questions answered by stakeholder
- [x] Technical specifications document created ([CREW_JOINING_SPECIFICATION.md](./CREW_JOINING_SPECIFICATION.md))

### Critical Fixes

- [x] **Fixed member limit from 50 to 10 members per crew** ([lib/utils/validation.dart:35](../../lib/utils/validation.dart#L35))
- [x] **Implemented max 3 crews per user validation** ([lib/utils/validation.dart:40](../../lib/utils/validation.dart#L40))
- [x] **Added validation to `acceptInvitation` method** ([lib/features/crews/services/crew_service.dart:768](../../lib/features/crews/services/crew_service.dart#L768))

---

## 📅 Implementation Phases

### **Phase 1: Invite Code System** (Week 1) 🔥 HIGH PRIORITY

#### Tasks

**1.1 Update Data Models**

- [ ] Update `Crew` model ([lib/features/crews/models/crew.dart](../../lib/features/crews/models/crew.dart))

  ```dart
  // Add fields:
  final CrewVisibility visibility;
  final int maxMembers;
  final String? activeInviteCode;
  final int inviteCodeCounter;
  ```

- [ ] Create `CrewVisibility` enum
- [ ] Create `InviteCode` model ([lib/features/crews/models/invite_code.dart](../../lib/features/crews/models/invite_code.dart))
- [ ] Update `toFirestore()` and `fromFirestore()` methods

**1.2 Implement Invite Code Generation**

- [ ] Add `generateInviteCode()` method to `CrewService`
- [ ] Implement code format: `CREWNAME-MM/YY-NNN`
- [ ] Add counter increment logic
- [ ] Store codes in `crews/{crewId}/inviteCodes/{codeId}` subcollection

**1.3 Implement Code Validation & Joining**

- [ ] Add `validateAndGetCrewByCode()` method
- [ ] Add `joinCrewWithCode()` method
- [ ] Check code expiration (7 days)
- [ ] Check single-use enforcement
- [ ] Mark code as used when successful

**1.4 Update Join Crew Screen**

- [ ] Connect form to `joinCrewWithCode()` method
- [ ] Add proper loading states
- [ ] Add error handling with user-friendly messages
- [ ] Navigate to Tailboard on success
- [ ] Test with various code formats

**1.5 Create Invite Code Management**

- [ ] Create `ManageInviteCodesScreen`
- [ ] Display list of generated codes
- [ ] Show code status (active/used/expired)
- [ ] Add "Generate New Code" button
- [ ] Add "Revoke Code" functionality
- [ ] Add "Share Code" functionality (copy to clipboard)

**1.6 Add Code Validation Helper**

- [ ] Add `validateInviteCode()` to `lib/utils/validation.dart`
- [ ] Use regex: `^[A-Z0-9-]+-\d{2}/\d{2}-\d{3}$`

**Deliverables:**

- ✅ Users can generate invite codes in format `CREWNAME-MM/YY-NNN`
- ✅ Users can join crews with valid invite codes
- ✅ Codes expire after 7 days
- ✅ Single-use enforcement working
- ✅ Code management screen functional

**Files to Create/Modify:**

- 🆕 `lib/features/crews/models/invite_code.dart`
- ✏️ `lib/features/crews/models/crew.dart`
- ✏️ `lib/features/crews/services/crew_service.dart`
- ✏️ `lib/features/crews/screens/join_crew_screen.dart`
- 🆕 `lib/features/crews/screens/manage_invite_codes_screen.dart`
- 🆕 `lib/features/crews/widgets/invite_code_card.dart`
- ✏️ `lib/utils/validation.dart`

---

### **Phase 2: Crew Discovery & Search** (Week 2) 🔥 HIGH PRIORITY

#### Tasks

**2.1 Add Crew Visibility**

- [ ] Update `create_crew_screen.dart` to include visibility selector
- [ ] Add public/private radio buttons
- [ ] Default to `private`
- [ ] Save visibility to Firestore

**2.2 Create Browse Crews Screen**

- [ ] Create `BrowseCrewsScreen` ([lib/features/crews/screens/browse_crews_screen.dart](../../lib/features/crews/screens/browse_crews_screen.dart))
- [ ] Add search bar for crew name
- [ ] Add member count filter chips
- [ ] Implement list view layout
- [ ] Add pull-to-refresh

**2.3 Implement Crew Cards**

- [ ] Create `CrewBrowseCard` widget ([lib/features/crews/widgets/crew_browse_card.dart](../../lib/features/crews/widgets/crew_browse_card.dart))
- [ ] Display: crew name, member count, privacy badge, foreman
- [ ] Add "Request to Join" button
- [ ] Add navigation to crew detail screen on tap

**2.4 Create Crew Detail Screen**

- [ ] Create `CrewDetailScreen` ([lib/features/crews/screens/crew_detail_screen.dart](../../lib/features/crews/screens/crew_detail_screen.dart))
- [ ] Show full crew information
- [ ] Display member list with avatars
- [ ] Show job preferences (read-only for non-members)
- [ ] Add "Request to Join" action button
- [ ] Add "Join with Code" alternative action

**2.5 Implement Search Methods**

- [ ] Add `searchPublicCrews()` to `CrewService`
- [ ] Implement filtering by name, member count, visibility
- [ ] Add pagination support (20 crews per page)
- [ ] Add `getPublicCrewsStream()` for real-time updates

**2.6 Test Multiple Display Modes**

- [ ] Test list view
- [ ] Test grid view (2-column)
- [ ] Test pagination
- [ ] Test infinite scroll
- [ ] Choose best performing option

**Deliverables:**

- ✅ Users can browse public crews
- ✅ Search by crew name working
- ✅ Filter by member count working
- ✅ Crew detail view shows all relevant info
- ✅ Display mode chosen and implemented

**Files to Create/Modify:**

- 🆕 `lib/features/crews/screens/browse_crews_screen.dart`
- 🆕 `lib/features/crews/screens/crew_detail_screen.dart`
- 🆕 `lib/features/crews/widgets/crew_browse_card.dart`
- ✏️ `lib/features/crews/services/crew_service.dart`
- ✏️ `lib/features/crews/screens/create_crew_screen.dart`
- ✏️ `lib/features/crews/screens/join_crew_screen.dart` (add navigation to browse)

**Firestore Indexes Required:**

```json
// Add to firestore.indexes.json
{
  "collectionGroup": "crews",
  "queryScope": "COLLECTION",
  "fields": [
    {"fieldPath": "visibility", "order": "ASCENDING"},
    {"fieldPath": "isActive", "order": "ASCENDING"},
    {"fieldPath": "name", "order": "ASCENDING"}
  ]
},
{
  "collectionGroup": "crews",
  "queryScope": "COLLECTION",
  "fields": [
    {"fieldPath": "visibility", "order": "ASCENDING"},
    {"fieldPath": "memberCount", "order": "ASCENDING"},
    {"fieldPath": "lastActivityAt", "order": "DESCENDING"}
  ]
}
```

---

### **Phase 3: Join Request Workflow** (Week 3) 🔶 MEDIUM PRIORITY

#### Tasks

**3.1 Create Join Request Model**

- [ ] Create `JoinRequest` model ([lib/features/crews/models/join_request.dart](../../lib/features/crews/models/join_request.dart))
- [ ] Define fields: id, crewId, userId, requestedAt, status, reviewedBy, reviewedAt, message
- [ ] Add `toFirestore()` and `fromFirestore()` methods

**3.2 Implement Join Request Methods**

- [ ] Add `submitJoinRequest()` to `CrewService`
  - Validate user not already a member
  - Validate user < 3 crews
  - Validate crew < 10 members
  - Check for existing pending request
- [ ] Add `approveJoinRequest()` method
  - Add user to crew as `member`
  - Update request status
  - Send notification
- [ ] Add `rejectJoinRequest()` method
  - Update request status
  - Send notification
- [ ] Add `getPendingJoinRequests()` method

**3.3 Update Tailboard Screen**

- [ ] Add "Join Requests" tab (foreman-only)
- [ ] Display pending requests
- [ ] Create `JoinRequestCard` widget
- [ ] Add approve/reject buttons
- [ ] Show notification badge on tab

**3.4 Implement Notifications**

- [ ] Send notification to foreman on new join request
- [ ] Send notification to user on approval
- [ ] Send notification to user on rejection
- [ ] Use existing notification system

**3.5 Add Request Submission to Browse Screen**

- [ ] Connect "Request to Join" button to `submitJoinRequest()`
- [ ] Show success message
- [ ] Disable button if request already pending
- [ ] Show appropriate message if crew full or user at limit

**Deliverables:**

- ✅ Users can submit join requests to public crews
- ✅ Foremen see pending requests in Tailboard
- ✅ Foremen can approve/reject requests
- ✅ Notifications sent for all actions
- ✅ Request limits enforced

**Files to Create/Modify:**

- 🆕 `lib/features/crews/models/join_request.dart`
- 🆕 `lib/features/crews/widgets/join_request_card.dart`
- ✏️ `lib/features/crews/services/crew_service.dart`
- ✏️ `lib/features/crews/screens/tailboard_screen.dart`
- ✏️ `lib/features/crews/screens/browse_crews_screen.dart`
- ✏️ `lib/features/crews/screens/crew_detail_screen.dart`

**Firestore Indexes Required:**

```json
// Add to firestore.indexes.json
{
  "collectionGroup": "joinRequests",
  "queryScope": "COLLECTION",
  "fields": [
    {"fieldPath": "crewId", "order": "ASCENDING"},
    {"fieldPath": "status", "order": "ASCENDING"},
    {"fieldPath": "requestedAt", "order": "DESCENDING"}
  ]
}
```

---

### **Phase 4: Role Simplification** (Week 4) 🔷 LOW PRIORITY

#### Tasks

**4.1 Remove Lead Role**

- [ ] Remove `MemberRole.lead` from enum ([lib/domain/enums/member_role.dart](../../lib/domain/enums/member_role.dart))
- [ ] Update all UI references
- [ ] Remove role selection options for "Lead"

**4.2 Create Migration Script**

- [ ] Create `migrate_lead_to_member.dart` in `/tools`
- [ ] Query all crews for members with `role: 'lead'`
- [ ] Update to `role: 'member'`
- [ ] Update permissions accordingly

**4.3 Test Migration**

- [ ] Test migration on development data
- [ ] Verify all leads converted to members
- [ ] Check permissions are correct
- [ ] Run on production (schedule with team)

**Deliverables:**

- ✅ Only Foreman and Member roles exist
- ✅ All existing "Lead" members migrated
- ✅ UI updated to reflect two-role system

**Files to Modify:**

- ✏️ `lib/domain/enums/member_role.dart`
- 🆕 `tools/migrate_lead_to_member.dart`
- ✏️ All UI components showing role selection

---

### **Phase 5: Testing & Polish** (Week 5) 🔶 MEDIUM PRIORITY

#### Tasks

**5.1 Unit Tests**

- [ ] Test invite code generation (format, counter increment)
- [ ] Test code validation (expired, used, invalid format)
- [ ] Test membership limits (10 per crew, 3 per user)
- [ ] Test join request workflow
- [ ] Test search and filter methods
- [ ] Aim for 80%+ coverage

**5.2 Integration Tests**

- [ ] Test complete invite code flow (generate → share → join)
- [ ] Test complete join request flow (request → approve → join)
- [ ] Test crew discovery flow (browse → search → view detail → request)
- [ ] Test error scenarios (limits reached, expired codes)

**5.3 Widget Tests**

- [ ] Test `JoinCrewScreen`
- [ ] Test `BrowseCrewsScreen`
- [ ] Test `CrewDetailScreen`
- [ ] Test `ManageInviteCodesScreen`
- [ ] Test `CrewBrowseCard`
- [ ] Test `JoinRequestCard`
- [ ] Test `InviteCodeCard`

**5.4 Manual QA Testing**

- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Test offline behavior
- [ ] Test with real data
- [ ] Verify notifications work
- [ ] Test rate limiting
- [ ] Test all error messages

**5.5 Performance Optimization**

- [ ] Profile crew search (should be < 500ms)
- [ ] Optimize crew list rendering
- [ ] Test with 100+ public crews
- [ ] Check memory usage
- [ ] Optimize Firestore reads

**5.6 Documentation**

- [ ] Update README with crew joining features
- [ ] Document new Firestore collections
- [ ] Add inline code comments
- [ ] Create user guide (optional)

**Deliverables:**

- ✅ 80%+ test coverage
- ✅ All flows tested end-to-end
- ✅ Performance benchmarks met
- ✅ No critical bugs
- ✅ Documentation updated

**Test Files to Create:**

- 🆕 `test/features/crews/services/invite_code_test.dart`
- 🆕 `test/features/crews/services/join_request_test.dart`
- ✏️ `test/features/crews/services/crew_service_test.dart`
- 🆕 `test/features/crews/screens/browse_crews_screen_test.dart`
- 🆕 `test/features/crews/screens/crew_detail_screen_test.dart`
- 🆕 `test/integration/crew_joining_flow_test.dart`

---

## 🔐 Security Checklist

Before deploying to production, ensure:

- [ ] Firestore security rules updated ([firestore.rules](../../firestore.rules))
- [ ] Rate limiting implemented for:
  - [ ] Invite code generation (5 per user per day)
  - [ ] Join requests (10 per user per day)
  - [ ] Crew creation (already limited to 3)
- [ ] Input validation for all user inputs
- [ ] Proper error handling (no sensitive data in errors)
- [ ] Analytics events added for monitoring
- [ ] Abuse reporting mechanism tested

---

## 📊 Success Metrics

Track these metrics to measure feature success:

- **Invite Code Adoption**
  - Total codes generated
  - Code usage rate (used / total)
  - Average time from generation to use

- **Crew Discovery**
  - Public crew browse sessions
  - Search queries performed
  - Crews viewed in detail

- **Join Requests**
  - Total requests submitted
  - Approval rate (%)
  - Average approval time

- **User Engagement**
  - New crew memberships via codes
  - New crew memberships via requests
  - Active crews (>5 members)

---

## 🚧 Known Limitations (MVP)

These features are **NOT** included in MVP but may be added later:

- ❌ Multi-use invite codes
- ❌ QR code generation for invite codes
- ❌ Location-based crew discovery
- ❌ Crew ratings and reviews
- ❌ Crew tags/specializations
- ❌ Automated crew recommendations
- ❌ Waitlist for full crews
- ❌ Direct messaging before joining
- ❌ Crew join history tracking

---

## 🆘 Troubleshooting Guide

### Common Issues

**Issue: Invite code validation fails**

- Check code format matches `^[A-Z0-9-]+-\d{2}/\d{2}-\d{3}$`
- Verify code exists in Firestore
- Check code hasn't expired (>7 days old)
- Verify code hasn't been used

**Issue: User can't join crew**

- Check user isn't already a member
- Verify user has < 3 crew memberships
- Verify crew has < 10 members
- Check crew is still active

**Issue: Join request not appearing**

- Verify user is authenticated
- Check Firestore security rules
- Verify crew is public
- Check for pending request already exists

**Issue: Search not returning results**

- Verify Firestore indexes are created
- Check visibility filter (public only)
- Verify crews exist with matching criteria
- Check isActive filter

---

## 📞 Next Steps

1. **Review** the [technical specification](./CREW_JOINING_SPECIFICATION.md)
2. **Schedule** sprint planning meeting
3. **Assign** tasks to developers
4. **Set up** development environment
5. **Create** Firestore indexes
6. **Start** with Phase 1 (Invite Code System)

---

## 📝 Notes

- All critical fixes have been implemented ✅
- Member limit: 10 per crew ✅
- User limit: 3 crews per user ✅
- Ready to begin Phase 1 implementation

**Estimated Total Time: 5 weeks (MVP)**

---

*Last Updated: 2025-10-25*
*Document Owner: Development Team*
