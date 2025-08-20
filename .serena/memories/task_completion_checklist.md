# Journeyman Jobs - Task Completion Checklist

## Pre-Development Setup
- [ ] Read project documentation (`README.md`, `CLAUDE.md`)
- [ ] Review current task status in `TASK.md` (create if missing)
- [ ] Check `guide/screens.md` for screen specifications
- [ ] Understand electrical theme requirements
- [ ] Verify Firebase configuration status

## Development Quality Gates

### 1. Code Implementation
- [ ] Follow Flutter 3.x and null safety standards
- [ ] Use `JJ` prefix for all custom components
- [ ] Implement electrical theme using `AppTheme` constants
- [ ] Follow feature-based architecture (screens/, widgets/, services/)
- [ ] Use appropriate state management (Riverpod preferred)
- [ ] Handle loading and error states properly

### 2. Code Quality Checks
```bash
# Run before considering task complete
flutter analyze                    # ✅ Must pass without errors
dart format .                      # ✅ Format all code
```

### 3. Testing Requirements
```bash
# Minimum testing requirements
flutter test                       # ✅ All tests must pass
flutter test test/widgets/         # ✅ Widget tests for new components
flutter test test/services/        # ✅ Service tests for business logic
```

#### Test Coverage Requirements
- [ ] **Widget Tests**: All new screens and components
- [ ] **Unit Tests**: All new services and business logic  
- [ ] **Integration Tests**: Critical user flows
- [ ] **Electrical Component Tests**: Custom JJ-prefixed components
- [ ] **Error Handling Tests**: Network failures, validation errors

#### Test Structure Example
```dart
testWidgets('JobCard displays job details correctly', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: JobCard(job: mockJob),
  ));
  
  expect(find.text('IBEW Local 123'), findsOneWidget);
  expect(find.byIcon(Icons.location_on), findsOneWidget);
});
```

### 4. Build Verification
```bash
# Ensure builds work on target platforms
flutter build apk --debug          # ✅ Android build succeeds
flutter build ios --debug          # ✅ iOS build succeeds (if available)
```

### 5. Documentation Updates

#### Code Documentation
- [ ] Add comprehensive Dart docs for new classes and methods
- [ ] Update component documentation with usage examples
- [ ] Document electrical industry-specific terminology

#### Project Documentation
- [ ] Update `README.md` if adding new features or changing setup
- [ ] Document Firebase collection schemas if modified
- [ ] Update electrical component integration guides

### 6. Electrical Theme Compliance
- [ ] Use official IBEW colors (Navy #1A202C, Copper #B45309)
- [ ] Incorporate electrical symbols and animations appropriately
- [ ] Follow electrical safety color schemes
- [ ] Maintain professional appearance for construction site use
- [ ] Test accessibility under various lighting conditions

### 7. Firebase Integration
- [ ] Verify Firebase rules allow required operations
- [ ] Test offline functionality for critical features
- [ ] Validate data models match Firestore collections
- [ ] Implement proper error handling for network failures
- [ ] Check Firebase performance monitoring integration

### 8. Task Documentation Update
- [ ] Mark completed tasks in `TASK.md` with completion date
- [ ] Add any new tasks discovered during development
- [ ] Document any technical decisions or architecture changes
- [ ] Note any performance optimizations or security considerations

## Task Completion Template

```markdown
## Completed
- [x] Implement unions screen with local directory - Completed: 2025-01-31
  - Added 797+ IBEW locals with contact integration
  - Implemented offline caching
  - Added electrical-themed animations
  - Created comprehensive widget tests

## Discovered During Work  
- [ ] Need to add offline caching for union data
- [ ] Performance optimization needed for large job lists
- [ ] Consider adding advanced search filters
```

## Performance Verification
- [ ] Test with realistic data volumes (797+ IBEW locals)
- [ ] Verify smooth animations on lower-end devices  
- [ ] Check memory usage during heavy operations
- [ ] Test offline functionality and sync behavior
- [ ] Validate battery usage during location services

## Security & Privacy Checklist
- [ ] No logging of personal information (SSN, ticket numbers)
- [ ] Secure API key management with environment variables
- [ ] Proper Firebase security rules implementation
- [ ] Location data handling follows privacy policies
- [ ] Union data sensitivity appropriately handled

## Platform-Specific Verification

### iOS
- [ ] Test on iOS simulator/device
- [ ] Verify iOS-specific permissions (location, notifications)
- [ ] Check iOS design guidelines compliance
- [ ] Test App Store submission requirements

### Android  
- [ ] Test on Android emulator/device
- [ ] Verify Android permissions and manifest
- [ ] Check Material Design compliance
- [ ] Test Google Play Store requirements

## Final Deployment Readiness
- [ ] All tests passing
- [ ] Code formatted and analyzed
- [ ] Documentation updated
- [ ] Build succeeds on all target platforms
- [ ] Performance meets requirements
- [ ] Security checklist completed
- [ ] Task documentation updated

## Post-Completion
- [ ] Create git commit with descriptive message
- [ ] Push changes to appropriate branch
- [ ] Update team on completion status
- [ ] Plan next development priorities

## Emergency/Storm Work Priority
For storm work and emergency restoration features:
- [ ] Extra testing for reliability under network stress
- [ ] Verify weather data integration accuracy
- [ ] Test push notifications for emergency alerts  
- [ ] Validate critical path functionality offline
- [ ] Ensure appropriate priority in UI/UX