# Deep Dive Codebase Evaluation

## Codebase path: $ARGUMENTS

Perform exhaustive codebase analysis testing every navigation button, action, function, and feature. Document all failures in detail for repair phase.

## ULTRATHINK Phase

Think deeply about the codebase structure and create a comprehensive testing plan. Break down the evaluation into manageable sections using todo tracking. Identify all testable components before beginning.

## Research & Discovery Process

### 1. **Codebase Architecture Analysis**

- Map entire project structure
- Identify all entry points (main files, index files)
- Document framework/library versions
- Note build configuration and dependencies
- Create mental model of data flow

### 2. **Component Discovery**

- **Navigation Elements**
  - Routes/routing configuration
  - Menu items and navigation bars
  - Breadcrumbs and back buttons
  - Tab navigation and drawers
- **Interactive Features**
  - Forms and input validation
  - Buttons and click handlers
  - Modals, dialogs, popups
  - Drag and drop functionality
- **Data Operations**
  - API endpoints and integrations
  - Database queries and mutations
  - State management operations
  - Real-time data subscriptions
- **UI/UX Elements**
  - Animations and transitions
  - Responsive breakpoints
  - Accessibility features
  - Error boundaries and fallbacks

### 3. **Testing Methodology**

   For each discovered component:

- Test in isolation if possible
- Test integration with other components
- Test edge cases (empty data, large datasets, network failures)
- Test different user roles/permissions if applicable
- Test on different screen sizes/devices if web/mobile

### 4. **Failure Documentation Format**

   ```markdown
   ## Component: [Component Name]
   **Location**: [File path and line numbers]
   **Type**: Navigation | Feature | Data Binding | Animation | Other
   **Expected Behavior**: [What should happen]
   **Actual Behavior**: [What actually happens]
   **Error Messages**: [Console errors, stack traces]
   **Reproduction Steps**:
   1. [Step 1]
   2. [Step 2]
   **Severity**: Critical | High | Medium | Low
   **Dependencies**: [Related components affected]
   **Potential Fix**: [Initial assessment if obvious]
   ```

### 5. **Testing Execution Order**

   1. Core navigation and routing
   2. Authentication and authorization flows
   3. Primary user workflows
   4. Data CRUD operations
   5. Secondary features
   6. Edge cases and error handling
   7. Performance-critical paths
   8. Accessibility compliance

### 6. **Automated Testing Where Possible**

   ```bash
   # Run existing tests
   npm test || yarn test || pytest || go test ./...
   
   # Check for linting issues
   npm run lint || yarn lint || ruff check
   
   # Type checking
   npm run type-check || yarn type-check || mypy .
   
   # Build verification
   npm run build || yarn build || make build
   ```

## Deep Dive Process

### Phase 1: Static Analysis

- Read all configuration files
- Analyze dependency tree for conflicts
- Check for deprecated API usage
- Identify potential security issues
- Review error handling patterns

### Phase 2: Dynamic Testing

- Start development server/environment
- Systematically test each route/page
- Click every button and link
- Submit forms with valid/invalid data
- Test all user interactions
- Monitor console for errors
- Check network requests for failures

### Phase 3: Integration Testing

- Test data flow between components
- Verify state management consistency
- Check API integrations
- Test real-time features
- Verify file uploads/downloads

### Phase 4: Edge Case Testing

- Test with no data
- Test with massive datasets
- Test offline functionality
- Test concurrent user actions
- Test browser back/forward
- Test session timeout handling

## Output Structure

Save comprehensive report as: `deep-dive-reports/{project-name}-{timestamp}.md`

Include:

1. **Executive Summary**
   - Total components tested
   - Working vs broken breakdown
   - Critical issues requiring immediate attention

2. **Detailed Findings**
   - All broken components with full documentation
   - Patterns in failures (common causes)
   - Architecture concerns

3. **Repair Priority Matrix**
   - Critical: Blocks core functionality
   - High: Affects user experience significantly
   - Medium: Feature degradation
   - Low: Cosmetic or minor issues

4. **Resource Assessment**
   - Estimated repair complexity
   - Dependencies between fixes
   - Suggested fix order

## Quality Metrics

- [ ] Every navigable element tested
- [ ] All forms submitted with various inputs
- [ ] All API endpoints verified
- [ ] Error scenarios documented
- [ ] Performance bottlenecks identified
- [ ] Accessibility issues noted
- [ ] Security concerns flagged

**Confidence Score**: Rate the thoroughness of evaluation 1-10

Remember: The goal is to provide the repair phase with complete actionable intelligence.
