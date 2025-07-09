# Repair Broken Features

## Report file: $ARGUMENTS

Systematically repair all broken features identified in the deep dive report. Follow established patterns and ensure comprehensive fixes.

## ULTRATHINK Phase

Analyze the deep dive report thoroughly. Create a strategic repair plan addressing root causes, not just symptoms. Consider dependencies between fixes and optimal execution order.

## Repair Process

### 1. **Report Analysis**

- Load and parse the deep dive report
- Categorize issues by type and severity
- Identify common failure patterns
- Map dependencies between broken components
- Prioritize fixes based on impact and complexity

### 2. **Pre-Repair Setup**

   ```bash
   # Create backup branch
   git checkout -b repair/deep-dive-fixes-$(date +%Y%m%d)
   
   # Ensure clean working directory
   git status
   
   # Update dependencies if needed
   npm install || yarn install || pip install -r requirements.txt
   ```

### 3. **Fix Categories & Strategies**

#### Navigation & Routing Fixes

- **Broken Routes**: Update route configurations, fix path parameters
- **Dead Links**: Correct href/to attributes, update navigation logic
- **Back Button Issues**: Implement proper history management
- **Deep Linking**: Ensure URL parameters are properly handled

#### Function & Feature Repairs

- **Event Handlers**: Rebind or fix broken click/change handlers
- **API Calls**: Update endpoints, fix authentication headers
- **Form Validation**: Correct validation rules and error handling
- **State Management**: Fix store mutations and data flow

#### Data Binding Issues

- **Two-way Binding**: Ensure proper v-model/ngModel implementation
- **Props/Attributes**: Fix type mismatches and missing props
- **Computed Properties**: Resolve dependency issues
- **Watchers/Observers**: Fix infinite loops and missing dependencies

#### UI/UX Repairs

- **Animations**: Fix timing issues, missing keyframes
- **Responsive Design**: Correct breakpoint problems
- **Overflow Issues**: Add proper scrolling, fix container constraints
- **Z-index Conflicts**: Resolve layering issues

### 4. **Implementation Workflow**

For each broken component:

1. **Understand the Issue**

   ```bash
   # Read the specific failure documentation
   # Reproduce the issue locally
   # Check related files for context
   ```

2. **Research Solution**
   - Check documentation for proper API usage
   - Look for similar working components as reference
   - Search for known issues in libraries
   - Consider framework migration guides if applicable

3. **Implement Fix**

   ```bash
   # Make minimal necessary changes
   # Follow existing code patterns
   # Add error handling if missing
   # Include helpful comments for complex fixes
   ```

4. **Verify Fix**

   ```bash
   # Test the specific feature
   # Check for regression in related features
   # Verify no new console errors
   # Test edge cases mentioned in report
   ```

5. **Document Change**

   ```markdown
   ## Fix: [Component Name]
   **Issue**: [Brief description]
   **Solution**: [What was changed and why]
   **Files Modified**: [List of files]
   **Testing**: [How fix was verified]
   ```

### 5. **Code Quality Patterns**

#### Error Handling Template

```javascript
try {
  // Risky operation
} catch (error) {
  console.error(`[ComponentName] Error:`, error);
  // Graceful fallback
  // User notification if needed
}
```

#### Null Safety Pattern

```javascript
// Before: component?.data?.value
// After: component?.data?.value ?? defaultValue
```

#### Event Handler Safety

```javascript
// Ensure cleanup in React/Vue
useEffect(() => {
  const handler = () => { /* ... */ };
  element.addEventListener('click', handler);
  return () => element.removeEventListener('click', handler);
}, [dependency]);
```

### 6. **Testing Each Fix**

```bash
# Unit tests for individual fixes
npm test -- --watch [test-file]

# Integration testing
npm run test:integration

# Manual testing checklist
- [ ] Feature works as expected
- [ ] No console errors
- [ ] Handles edge cases
- [ ] Performance acceptable
- [ ] Accessibility maintained
```

### 7. **Batch Testing After Multiple Fixes**

After every 5-10 fixes:

1. Run full test suite
2. Check for regression
3. Test interrelated features
4. Verify build still works
5. Commit progress with descriptive message

### 8. **Common Fix Patterns**

**Async/Await Issues**:

```javascript
// Add proper error handling
async function fetchData() {
  try {
    const response = await api.get('/endpoint');
    return response.data;
  } catch (error) {
    handleError(error);
    return fallbackData;
  }
}
```

**State Update Issues**:

```javascript
// Ensure immutable updates
setState(prevState => ({
  ...prevState,
  updatedField: newValue
}));
```

**Memory Leak Prevention**:

```javascript
// Clean up subscriptions/timers
const subscription = observable.subscribe();
return () => subscription.unsubscribe();
```

## Output Documentation

### Fix Summary Report

Save as: `repair-reports/{project-name}-fixes-{timestamp}.md`

Include:

1. **Executive Summary**
   - Total issues addressed
   - Success rate
   - Remaining issues with blockers

2. **Detailed Fix Log**
   - Each fix with before/after
   - Code snippets of solutions
   - Test results

3. **Recommendations**
   - Architecture improvements
   - Dependency updates needed
   - Refactoring opportunities

### Git Commit Strategy

```bash
# Commit related fixes together
git add [related-files]
git commit -m "fix: [component] - resolve [issue type]

- Fixed [specific issue 1]
- Fixed [specific issue 2]
- Added error handling for [scenario]

Refs: deep-dive-report.md#[section]"
```

## Quality Assurance

- [ ] All critical issues resolved
- [ ] High priority issues addressed
- [ ] No new errors introduced
- [ ] Tests passing
- [ ] Build successful
- [ ] Performance maintained or improved
- [ ] Code follows project conventions

**Success Metrics**:

- Percentage of issues fixed: X/Y (%)
- New test coverage: X%
- Performance impact: ±X%
- User experience improvement score: X/10

Remember: Fix root causes, not symptoms. Each repair should make the codebase more robust.
