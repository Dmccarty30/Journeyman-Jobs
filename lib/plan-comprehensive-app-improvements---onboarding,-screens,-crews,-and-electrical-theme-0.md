# THE PLAN

## Observations

I've explored the comprehensive Journeyman Jobs Flutter application codebase. The app has a well-established electrical theme with circuit board backgrounds, copper accents, and navy colors. Key findings:

- Electrical notification components exist (`jj_electrical_notifications.dart`, `jj_electrical_toast.dart`, `jj_snack_bar.dart`) but aren't consistently used app-wide
- Onboarding has 3 steps with existing save methods but needs proper user document creation flow
- Classification and ConstructionTypes enums already exist in `domain/enums/enums.dart`
- Text formatting utilities exist in `text_formatting_wrapper.dart`
- Job cards, storm screen, and crew features have established structures
- Feed, chat, and messaging infrastructure exists but tabs show placeholder content
- The app uses Riverpod for state management and Firebase/Firestore for backend

### Approach

This plan implements comprehensive app-wide improvements across 15 merged phases:

**App-Wide**: Migrate all notifications to electrical theme with circuit backgrounds, copper borders, and color-coded types. Apply Title Case formatting consistently.

**Onboarding**: Fix welcome screen button font, auth screen tab bar alignment, and implement proper user document creation flow with electrical-themed error handling.

**Home/Jobs**: Add Title Case formatting, remove colored fonts, add copper dividers, implement strict left-to-right data flow with RichText, add dummy Quick Actions placeholders.

**Storm**: Remove specified sections, update emergency container styling, implement PowerOutage.us toggle/accordion, add admin-only video placeholders.

**Tailboard/Crews**: Update header based on membership, refactor create crew steps with electrical theme, fix crew preferences dialog, implement Feed/Chat/Members tabs with full functionality.

### Reasoning

I listed the repository structure and read all relevant files mentioned in the merged TODO. I explored the electrical notification components to understand the visual reference from `electrical_demo_screen.dart`. I read the onboarding screens to understand the step structure and button placement. I examined the enums file to discover that classifications and construction types are already defined. I searched for all usages of `JJSnackBar`, `JJElectricalToast`, and `Tooltip` to understand the scope of changes. I reviewed the feed, chat, and messaging providers to understand existing infrastructure. I examined the storm screen to identify sections to remove and understand the PowerOutage.us integration.

## Proposed File Changes

### lib\electrical_components\jj_snack_bar.dart(MODIFY)

References:

- lib\electrical_components\jj_electrical_notifications.dart(MODIFY)
- lib\electrical_components\circuit_board_background.dart
- lib\design_system\app_theme.dart

**Update JJSnackBar to use electrical circuit theme:**

1. Import `ElectricalCircuitBackground` from `circuit_board_background.dart` and `ElectricalNotificationType` from `jj_electrical_notifications.dart`

2. Modify the `_show` method to wrap the SnackBar content in a Stack with `ElectricalCircuitBackground` as the base layer:
   - Set `opacity: 0.08` and `componentDensity: ComponentDensity.high` to match the demo screen
   - Add thick copper border using `Border.all(color: backgroundColor, width: AppTheme.borderWidthCopper)`
   - Make background slightly transparent: `backgroundColor.withValues(alpha: AppTheme.opacityElectricalBackground)`

3. Update color coding to match electrical theme:
   - `showSuccess`: Use `AppTheme.electricalSuccess` (green) for success notifications
   - `showError`: Use `AppTheme.electricalError` (red) for error/warning/permanent notifications
   - `showWarning`: Use `AppTheme.electricalWarning` (yellow) for caution notifications
   - `showInfo`: Use `AppTheme.electricalInfo` (blue) for info notifications

4. Add electrical glow effect to the box shadow:
   - Include a second BoxShadow with the notification color at reduced opacity for glow effect
   - Use `color.withValues(alpha: AppTheme.opacityElectricalGlow)` with `blurRadius: 12`

5. Ensure the shape uses `RoundedRectangleBorder` with `borderRadius: AppTheme.radiusElectricalSnackBar`

6. Keep the existing API (showSuccess, showError, showInfo, showWarning) unchanged to maintain backward compatibility

### lib\electrical_components\jj_electrical_toast.dart(MODIFY)

References:

- lib\electrical_components\circuit_board_background.dart
- lib\design_system\app_theme.dart
- lib\screens\home\electrical_demo_screen.dart

**Enhance JJElectricalToast to match electrical_demo_screen styling:**

1. Update the toast container decoration (lines 302-323) to ensure it matches the demo screen:
   - Verify thick copper border is using `AppTheme.borderWidthCopper` (2.5px)
   - Ensure background uses `theme.backgroundColor.withValues(alpha: AppTheme.opacityElectricalBackground)` for slight transparency
   - Confirm electrical glow effect in boxShadow uses the theme's border color with proper opacity

2. Verify the `ElectricalCircuitBackground` integration in `_ToastOverlay` (lines 217-229):
   - Ensure `opacity: 0.08` matches the demo screen
   - Confirm `componentDensity: ComponentDensity.high` for dense circuit pattern
   - Verify `enableCurrentFlow` and `enableInteractiveComponents` are set based on toast type

3. Update `_ToastTheme` configurations (lines 240-284) to use AppTheme electrical colors:
   - Success: `AppTheme.electricalSuccess` (green)
   - Error: `AppTheme.electricalError` (red)
   - Warning: `AppTheme.electricalWarning` (yellow)
   - Info: `AppTheme.electricalInfo` (blue)
   - Power: `AppTheme.accentCopper`

4. Ensure the `_ElectricalProgressIndicator` (lines 447-500) uses the correct color from the theme

5. Verify animation timings match the demo screen for smooth entrance/exit effects

### lib\electrical_components\jj_electrical_notifications.dart(MODIFY)

References:

- lib\electrical_components\circuit_board_background.dart
- lib\design_system\app_theme.dart

**Enhance ElectricalTooltip to complement mood and situations:**

1. Update the `ElectricalTooltip` widget (lines 451-581) to ensure it has:
   - Thick copper border matching the toast/snackbar theme
   - Slightly transparent background with circuit board pattern
   - Color coding based on type (green for success, red for error, yellow for warning, blue for info)

2. Enhance the tooltip decoration (lines 502-519) to match the electrical theme:
   - Use `AppTheme.borderWidthCopper` for border width
   - Ensure background color uses `themeConfig['backgroundColor'].withValues(alpha: AppTheme.opacityElectricalBackground)`
   - Add electrical glow effect to boxShadow

3. Update the `ElectricalCircuitBackground` integration (lines 532-543):
   - Ensure `opacity: 0.08` and `componentDensity: ComponentDensity.high`
   - Set `enableCurrentFlow: false` and `enableInteractiveComponents: false` for tooltips (they should be static)

4. Add contextual tooltip messages that complement the mood:
   - For success tooltips: Use encouraging, positive language
   - For warning tooltips: Use cautionary but helpful language
   - For error tooltips: Use clear, actionable language
   - For info tooltips: Use informative, educational language

5. Ensure the `_SparkEffectPainter` (lines 692-727) creates appropriate visual feedback on hover/tap

### lib\design_system\components\reusable_components.dart(MODIFY)

References:

- lib\electrical_components\jj_electrical_notifications.dart(MODIFY)
- lib\electrical_components\jj_electrical_toast.dart(MODIFY)
- lib\design_system\app_theme.dart

**Update JJSnackBar in reusable_components to use electrical theme:**

1. Update the `JJSnackBar` class (lines 1056-1153) to delegate to the electrical-themed version:
   - Import `JJElectricalNotifications` from `../../electrical_components/jj_electrical_notifications.dart`
   - Import `ElectricalNotificationType` enum

2. Modify `showSuccess` method (lines 1057-1094):
   - Replace the current SnackBar implementation with a call to `JJElectricalNotifications.showElectricalSnackBar`
   - Pass `type: ElectricalNotificationType.success`
   - Maintain the same method signature for backward compatibility

3. Modify `showError` method (lines 1096-1123):
   - Replace with `JJElectricalNotifications.showElectricalSnackBar`
   - Pass `type: ElectricalNotificationType.error`

4. Modify `showInfo` method (lines 1125-1152):
   - Replace with `JJElectricalNotifications.showElectricalSnackBar`
   - Pass `type: ElectricalNotificationType.info`

5. Add a comment at the top of the JJSnackBar class (line 1056) noting:
   - "This class now delegates to JJElectricalNotifications for consistent electrical theming"
   - "All snackbars now feature circuit board backgrounds, copper borders, and electrical animations"

6. Keep the method signatures identical to avoid breaking existing call sites across the app

### lib\screens\onboarding\welcome_screen.dart(MODIFY)

References:

- lib\design_system\components\reusable_components.dart(MODIFY)
- lib\design_system\app_theme.dart

**Reduce font size of complete/next button on third step by 15%:**

1. Locate the button rendering logic in the bottom navigation section (lines 236-270)

2. The button text is determined by the condition at line 260: `_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'`

3. Modify the `JJPrimaryButton` widget (lines 259-268) to conditionally apply font size reduction:
   - Check if `_currentPage == _pages.length - 1` (which is page index 2, the third screen)
   - When true, wrap the button text or modify the button's text style to reduce font size by 15%

4. Implementation approach:
   - Calculate the reduced font size: `AppTheme.buttonMedium.fontSize * 0.85`
   - Pass a custom text style to the button when on the last page
   - OR modify the `text` parameter to use a `Text` widget with custom style instead of a String

5. Ensure the button functionality and other styling (gradient, icon, padding) remain unchanged

6. Test that the font size reduction only applies to the "Get Started" button on the third page, not the "Next" buttons on pages 1 and 2

### lib\screens\onboarding\auth_screen.dart(MODIFY)

References:

- lib\design_system\app_theme.dart

**Fix SegmentedTabBar alignment gap to match tab bar container height:**

Reference the screenshot at `assets/tab-bar-gap.png` to understand the visual issue.

1. Locate the `SegmentedTabBar` widget (lines 661-840)

2. Identify the height mismatch:
   - The outer container has `height: 56` (line 731)
   - The inner container has `margin: const EdgeInsets.all(4)` (line 741)
   - The animated indicator has `height: 48` (line 757)
   - This creates a gap between the tabs and the tab bar container

3. Fix the alignment by adjusting heights:
   - **Option A (Make tabs bigger)**: Change the animated indicator height from 48 to 52 (56 - 4 margin on each side = 48, but we need 56 - 2*2 = 52)
   - **Option B (Make tab bar smaller)**: Reduce the outer container height from 56 to 52 or adjust margins
   - **Recommended**: Use Option A - increase the animated indicator height to fill the available space

4. Update the animated indicator container (lines 755-776):
   - Change `height: 48` to `height: 52` or calculate dynamically as `56 - 4` to account for the 4px margin

5. Ensure the tab buttons (lines 781-834) fill the entire height:
   - Verify the TextButton widgets expand to fill the parent height
   - Remove any padding that might create gaps

6. Test the alignment by checking that the bottom border of the tabs aligns perfectly with the bottom border of the tab bar container

7. Verify the gradient and shadow effects still render correctly after the height adjustment

### lib\screens\onboarding\onboarding_steps_screen.dart(MODIFY)

References:

- lib\services\firestore_service.dart
- lib\electrical_components\jj_electrical_notifications.dart(MODIFY)
- lib\navigation\app_router.dart

**Implement proper user document creation and navigation flow with electrical-themed feedback:**

1. **Step 1 (index 0) - Personal Information**:
   - The `_saveStep1Data` method (lines 191-233) already creates/updates the user document
   - Currently uses `JJSnackBar.showSuccess` (line 214) and `JJSnackBar.showError` (line 222)
   - Replace these with electrical-themed notifications:
     - Success: `JJElectricalNotifications.showElectricalToast(context: context, message: 'Basic information saved', type: ElectricalNotificationType.success)`
     - Error: `JJElectricalNotifications.showElectricalToast(context: context, message: 'Error saving data. Please try again.', type: ElectricalNotificationType.error)`
   - The method already calls `firestoreService.setUserWithMerge` with the correct data
   - Navigation to step 2 happens in `_nextStep` (lines 156-180) after successful save

2. **Step 2 (index 1) - Professional Details**:
   - The `_saveStep2Data` method (lines 235-274) already saves professional data
   - Replace `JJSnackBar.showSuccess` (line 254) with electrical toast: `type: ElectricalNotificationType.success`
   - Replace `JJSnackBar.showError` (line 263) with electrical toast: `type: ElectricalNotificationType.error`
   - The method saves: homeLocal, ticketNumber, classification, isWorking, booksOn
   - Navigation to step 3 happens in `_nextStep` after successful save

3. **Step 3 (index 2) - Preferences & Feedback**:
   - The `_completeOnboarding` method (lines 276-337) already saves step 3 data and navigates to home
   - Replace `JJSnackBar.showSuccess` (line 316) with electrical toast: `type: ElectricalNotificationType.success, message: 'Profile setup complete! Welcome to Journeyman Jobs.'`
   - Replace `JJSnackBar.showError` (line 331) with electrical toast: `type: ElectricalNotificationType.error`
   - The method already sets `onboardingStatus: 'complete'` and navigates to `AppRouter.home`

4. **Error Handling Enhancements**:
   - In all three save methods, wrap the Firestore operations in try-catch blocks (already done)
   - Add more specific error messages based on the exception type
   - For network errors, use warning toast: `type: ElectricalNotificationType.warning, message: 'Network issue. Please check your connection.'`
   - For validation errors, use error toast with specific field information

5. **Loading State**:
   - The `_isSaving` boolean (line 69) is already used to disable buttons during save
   - Ensure the loading indicator on the button shows during all save operations

6. **Import Updates**:
   - Add import for `JJElectricalNotifications`: `import '../../electrical_components/jj_electrical_notifications.dart';`
   - Remove or keep the existing `JJSnackBar` import from `reusable_components.dart` (it will delegate to electrical version)

### lib\screens\home\home_screen.dart(MODIFY)

References:

- lib\utils\text_formatting_wrapper.dart(MODIFY)
- lib\widgets\condensed_job_card.dart(MODIFY)
- lib\design_system\app_theme.dart

**Apply Title Case formatting, add dummy Quick Actions, and remove colored fonts:**

1. **Title Case Formatting**:
   - The file already imports `text_formatting_wrapper.dart` (line 1)
   - Apply `toTitleCase()` to all displayed text in cards, containers, and dialogs:
     - User display name (line 149): Wrap with `toTitleCase(displayName)`
     - Active crews text (line 389): Already using proper formatting
     - Any other text that displays user-generated or database content
   - The `_convertJobsRecordToJob` method (lines 471-501) already uses `toTitleCase` for company, location, classification, and typeOfWork

2. **Add Two Dummy Containers in Quick Actions**:
   - Locate the Quick Actions section (lines 164-207)
   - Currently has one action card for "Electrical calc" (lines 195-207)
   - Add two more `_buildElectricalActionCard` widgets in the Row:
     - First dummy: `_buildElectricalActionCard('Coming Soon', Icons.construction, () { /* TODO: Future feature */ })`
     - Second dummy: `_buildElectricalActionCard('More Tools', Icons.build, () { /* TODO: Future feature */ })`
   - Wrap the Row in a GridView or use multiple Rows to accommodate 3 cards with proper spacing
   - Alternatively, create a 2-column grid layout for better responsiveness

3. **Remove Colored Fonts from Cards and Dialogs**:
   - Review the `_buildActiveCrewsWidget` (lines 365-430):
     - Remove any color styling from text that isn't part of the theme (currently looks clean)
   - Review the `_buildElectricalActionCard` (lines 328-363):
     - Ensure all text uses `AppTheme.primaryNavy` or `AppTheme.textPrimary` (already correct)
   - The `CondensedJobCard` widget is used for job display (line 309)
     - This widget is defined in `condensed_job_card.dart` and will be updated separately
   - Remove any grey tint on local number if present in the card styling

4. **Clean Up Job Cards Display**:
   - The job cards are rendered using `CondensedJobCard` (lines 308-314)
   - Ensure consistent spacing between cards
   - Verify the cards use the updated `condensed_job_card.dart` with proper formatting

5. **Dialog Popups**:
   - The `_showJobDetailsDialog` (lines 433-439) uses `JobDetailsDialog`
   - Ensure this dialog applies Title Case formatting to all displayed text
   - Remove any colored fonts from the dialog content

### lib\widgets\condensed_job_card.dart(MODIFY)

References:

- lib\utils\text_formatting_wrapper.dart(MODIFY)
- lib\design_system\app_theme.dart
- lib\models\job_model.dart

**Remove colored fonts and ensure Title Case formatting:**

1. **Remove Grey Tint on Local Number**:
   - Locate the local badge container (lines 46-62)
   - Currently uses `AppTheme.primaryNavy.withValues(alpha: 26/255)` for background color
   - Change the background to white or remove the tinted background entirely
   - Update the text color to `AppTheme.primaryNavy` (already correct at line 58)
   - Keep the copper border for consistency

2. **Remove Colored Fonts**:
   - Review the `_buildTwoColumnRow` method (lines 132-191)
   - Line 92 has a conditional color for wages: `rightValueColor: job.wage != null && job.wage! > 0 ? AppTheme.successGreen : null`
   - Remove this conditional coloring - set `rightValueColor: null` or `AppTheme.textLight` for all values
   - Ensure all text uses neutral colors: `AppTheme.textDark` for labels, `AppTheme.textLight` for values

3. **Verify Title Case Formatting**:
   - The card already uses `JobDataFormatter.formatClassification` (line 67)
   - The card already uses `JobDataFormatter.formatCompany` (line 89)
   - The card already uses `JobDataFormatter.formatLocation` (line 99)
   - Ensure all displayed text goes through the formatter

4. **Update RichText Styling**:
   - In `_buildTwoColumnRow`, ensure the label text (Span1) uses `fontWeight: FontWeight.bold` and `color: AppTheme.textDark`
   - Ensure the value text (Span2) uses regular font weight and `color: AppTheme.textLight`
   - Remove any color overrides passed via parameters

5. **Maintain Copper Border**:
   - Keep the copper border on the card container (lines 34-37)
   - Keep the copper divider (lines 80-83)

### lib\screens\jobs\jobs_screen.dart(MODIFY)

References:

- lib\widgets\rich_text_job_card.dart(MODIFY)
- lib\utils\text_formatting_wrapper.dart(MODIFY)
- lib\design_system\app_theme.dart

**Apply Title Case formatting and ensure proper card rendering:**

1. **Title Case Formatting**:
   - The file already uses `RichTextJobCard` (line 416) which should handle formatting
   - Ensure all filter categories (lines 32-41) use Title Case when displayed
   - Apply `toTitleCase()` to any search results or filter labels

2. **Verify Job Card Integration**:
   - The `RichTextJobCard` widget is used in the ListView.builder (lines 416-421)
   - This card will be updated separately in `rich_text_job_card.dart`
   - Ensure the card receives proper job data with all fields populated

3. **Error Messages**:
   - Update error state messages (lines 234-270) to use Title Case
   - Update empty state messages (lines 272-319) to use Title Case

4. **Filter Chips**:
   - The filter categories (lines 32-41) should display in Title Case
   - Update the FilterChip labels to use `toTitleCase(category)` if needed

5. **Import Updates**:
   - Ensure `text_formatting_wrapper.dart` is imported
   - The file already imports `jj_electrical_toast.dart` (line 11)

6. **Maintain Electrical Theme**:
   - The screen already uses `ElectricalCircuitBackground` (lines 372-378)
   - Keep the copper-themed UI elements and electrical styling

### lib\widgets\rich_text_job_card.dart(MODIFY)

References:

- lib\utils\text_formatting_wrapper.dart(MODIFY)
- lib\design_system\app_theme.dart
- lib\models\job_model.dart

**Remove colored fonts, add copper divider, improve spacing, and enforce LEFT-TO-RIGHT data flow:**

1. **Remove Grey Tint on Local Number**:
   - Review the card to ensure there's no tinted background on the local number display
   - If a local badge exists similar to `condensed_job_card.dart`, remove the grey/navy tinted background
   - Use white background with copper border only

2. **Add Copper Divider Between Local/Classification and Other Values**:
   - After the first row showing Local and Classification (lines 42-47), add a copper divider
   - Insert a `Divider` widget with `color: AppTheme.accentCopper, height: 1, thickness: 1.5`
   - Add spacing above and below the divider (8px each) to separate sections visually

3. **Remove Colored Fonts**:
   - Locate line 58 where wage color is conditionally set: `rightValueColor: job.wage != null && job.wage! > 0 ? AppTheme.successGreen : null`
   - Remove this conditional - set all value colors to `AppTheme.textLight` or null
   - Ensure NO colored text anywhere in the card except for the copper border and theme colors

4. **Improve Card Spacing for Even Distribution**:
   - Review spacing between rows (currently 8px at lines 48, 60, 69, 78)
   - Ensure consistent spacing throughout the card
   - Add proper padding around the entire card content

5. **Enforce Strict LEFT-TO-RIGHT, then TOP-TO-BOTTOM Data Flow**:
   - The `_buildTwoColumnRow` method (lines 174-233) already implements left-to-right layout
   - Verify NO vertical stacking of Span1 above Span2
   - Each row should have: Left column (Label: Value) | Right column (Label: Value)
   - Example structure:
     - Row 1: Local: [111] | Classification: [Journeyman Lineman]
     - Row 2: Contractor: [ABC Electric] | Wages: [$45.50/hr]
     - Row 3: Location: [New York, NY] | Hours: [40/week]
     - Row 4: Start Date: [ASAP] | Per Diem: [$125/day]

6. **Implement RichText with Proper Spans**:
   - The `_buildTwoColumnRow` method already uses RichText (lines 185-205, 210-230)
   - Ensure Span1 (label) has: `fontWeight: FontWeight.bold, color: AppTheme.textDark, text: '$label: '`
   - Ensure Span2 (value) has: `fontWeight: FontWeight.normal, color: AppTheme.textLight, text: value`
   - The colon and space should be part of Span1

7. **Minimize N/A Values with Better Formatting**:
   - Add null-safe operators and fallbacks for all job fields
   - For wage: If null or 0, show 'Contact for Rate' instead of 'N/A'
   - For hours: If null, show 'Varies' instead of 'N/A'
   - For per diem: If null or empty, show 'Not Specified' instead of 'N/A'
   - For start date: If null, show 'Flexible' instead of 'N/A'

8. **Apply Title Case Formatting**:
   - The file already imports `text_formatting_wrapper.dart` (line 5)
   - Ensure `toTitleCase()` is applied to all displayed values (already done at lines 46, 53, 65, 83)
   - Verify company, location, classification, and typeOfWork all use the formatter

---
---
---
---

### lib\screens\storm\storm_screen.dart(MODIFY)

References:

- lib\services\power_outage_service.dart
- lib\widgets\storm\power_outage_card.dart(MODIFY)
- lib\widgets\contractor_card.dart(MODIFY)
- lib\design_system\app_theme.dart
- lib\electrical_components\circuit_board_background.dart
- lib\electrical_components\jj_electrical_notifications.dart(MODIFY)

**Remove sections, update styling, implement PowerOutage.us toggle, and add video placeholders:**

1. **Remove "Current Storm Activity" Section (lines 353-405)**:
   - Delete the entire section including the heading "Current Storm Activity" (line 353)
   - Delete the two stat cards showing "Active Storms" and "Open Positions" (lines 361-381)
   - Delete the second row of stat cards showing "Avg Pay Rate" and "Avg Per Diem" (lines 385-405)
   - This will free up space for the power outage integration

2. **Remove "Active Storm Events" Section (lines 481-490)**:
   - Delete the heading "Active Storm Events" (lines 482-488)
   - Delete the section that maps `_filteredStorms` to `StormEventCard` widgets (line 490)
   - Keep the `StormEventCard` class definition (lines 799-991) as it may be used elsewhere
   - Keep the `_activeStorms` data and `_filteredStorms` getter for potential future use

3. **Update Emergency Work Available Container Color**:
   - Locate the emergency alert banner (lines 297-348)
   - Currently uses gradient: `LinearGradient(colors: [AppTheme.warningYellow, AppTheme.errorRed])`
   - Replace with navy/copper gradient: `LinearGradient(colors: [AppTheme.primaryNavy, AppTheme.accentCopper], begin: Alignment.topLeft, end: Alignment.bottomRight)`
   - Keep the warning icon and text styling
   - Ensure the button uses the electrical theme

4. **Button Up Storm Contractors Card**:
   - Locate the Storm Contractors section (lines 494-573)
   - The section already has proper styling with white background and copper border
   - Ensure the `ContractorCard` widgets render properly within the fixed height container
   - Verify the electrical circuit background is applied (already present via `ElectricalCircuitBackground` at line 284)
   - Add proper error handling for empty contractor list

5. **Implement PowerOutage.us API Integration with Toggle/Accordion**:
   - The power outage section already exists (lines 410-435)
   - Currently displays `PowerOutageSummary` and maps outages to `PowerOutageCard` widgets
   - Add a toggle/accordion widget to minimize/expand the outage display:
     - Create a stateful boolean `_isPowerOutageExpanded = true`
     - Wrap the power outage cards in an `AnimatedContainer` or `ExpansionTile`
     - Add a header row with toggle icon and "Power Outages by State" title
     - When collapsed, show only the `PowerOutageSummary` with total counts
     - When expanded, show the full list of `PowerOutageCard` widgets
   - The `PowerOutageService` is already initialized and used (lines 100, 179-196)
   - Ensure states are displayed in order: Ohio, Michigan, New York, Texas, etc. (sorted by outage count or alphabetically)
   - Add loading state handling for when outages are being fetched

6. **Set Up Foundation for Real-Time Emergency Declaration Videos (Admin Only)**:
   - Add a new section after the power outage section
   - Create a placeholder container with:
     - Title: "Emergency Declarations" (admin only)
     - Subtitle: "Real-time video updates from emergency management"
     - Icon: `Icons.video_library` or `Icons.emergency`
   - Add commented-out code for video player:

     ```dart
     // TODO: Implement video player widget
     // Use video_player package or chewie for video playback
     // Videos should be uploaded by admins via Firebase Storage
     // Display in a ListView with thumbnail, title, timestamp
     // Example:
     // VideoPlayerWidget(
     //   videoUrl: 'https://storage.googleapis.com/...',
     //   thumbnail: 'https://...',
     //   title: 'Governor Emergency Declaration - Hurricane Milton',
     //   timestamp: DateTime.now(),
     // )
     ```

   - Add admin-only access control placeholder:

     ```dart
     // TODO: Check if current user is admin
     // final isAdmin = await _checkAdminStatus(currentUser.uid);
     // if (!isAdmin) return SizedBox.shrink();
     ```

   - Add TODO comments for future implementation:
     - "TODO: Add video upload functionality for admins"
     - "TODO: Implement video player with controls"
     - "TODO: Add video metadata (title, description, timestamp)"
     - "TODO: Implement video list with pagination"

7. **Maintain Power Outage Section Functionality**:
   - Keep the existing `_loadPowerOutages` method (lines 179-196)
   - Keep the `_showOutageDetails` modal bottom sheet (lines 648-774)
   - Ensure the `PowerOutageCard` widgets remain interactive with onTap handlers
**Add PowerOutage.us toggle/accordion widget:**

1. **Add State Variable for Toggle**:
   - Add a boolean state variable: `bool _isPowerOutageExpanded = true;`
   - This controls whether the power outage section is expanded or collapsed

2. **Create Toggle Header**:
   - Before the power outage cards section (around line 414), add a toggle header:
     - Row with:
       - Icon: `Icons.power_off` or `Icons.electrical_services`
       - Title: "Power Outages by State"
       - Subtitle: "${_powerOutages.length} states affected"
       - Toggle icon: `Icons.expand_more` when collapsed, `Icons.expand_less` when expanded
     - Make the entire row tappable to toggle expansion
     - Style with copper border and white background

3. **Implement Accordion Behavior**:
   - Wrap the power outage cards list (lines 429-432) in an `AnimatedContainer` or `AnimatedSize`
   - When `_isPowerOutageExpanded` is false:
     - Show only the `PowerOutageSummary` widget (line 411)
     - Hide the individual `PowerOutageCard` widgets
   - When `_isPowerOutageExpanded` is true:
     - Show both summary and individual cards
   - Add smooth animation (300-400ms duration) for expand/collapse

4. **Sort States for Easy Viewing**:
   - The power outages are already sorted by outage count (descending) in the service
   - To allow users to easily see specific states (Ohio, Michigan, New York, Texas, etc.):
     - Add a secondary sort option: alphabetical by state name
     - Add a toggle or dropdown to switch between "Most Affected" and "Alphabetical" sorting
     - Implement: `_powerOutages.sort((a, b) => a.stateName.compareTo(b.stateName))` for alphabetical

5. **Add State Filter/Search**:
   - Add a search field or filter chips to quickly find specific states
   - Allow users to type "Ohio" and jump to that state's card
   - Implement using a `TextField` with `onChanged` that filters the list

6. **Enhance Loading and Error States**:
   - The `_isLoadingOutages` boolean (line 102) controls loading state
   - Show a loading indicator when fetching outages (lines 422-427)
   - Add error state handling if the API fails
   - Use electrical-themed loading indicator

7. **Update Notification Usage**:
   - Replace `JJSnackBar.showSuccess` (line 274) with `JJElectricalNotifications.showElectricalToast`
   - Use appropriate notification types for different scenarios

### lib\features\crews\screens\tailboard_screen.dart(MODIFY)

References:

- lib\features\crews\providers\crews_riverpod_provider.dart
- lib\design_system\app_theme.dart
- lib\features\crews\widgets\tab_widgets.dart(MODIFY)
- lib\features\crews\providers\feed_provider.dart
- lib\features\crews\providers\messaging_riverpod_provider.dart(MODIFY)
- lib\services\feed_service.dart

**Update header display based on crew membership and fix horizontal overflow:**

1. **Replace Welcome Header with Compact Crew Header**:
   - The `_buildNoCrewHeader` method (lines 146-201) shows when no crew is selected
   - The `_buildHeader` method (lines 203-305) shows when a crew is selected
   - Currently, the crew header shows full crew name, member count, and stats
   - Update `_buildHeader` to use a more compact layout:
     - Reduce the crew name font size from `titleLarge` to `titleMedium`
     - Reduce the member count font size from `bodySmall` to `labelSmall`
     - Reduce the overall padding from `fromLTRB(16, 48, 16, 16)` to `fromLTRB(16, 40, 16, 12)`
     - Keep the crew icon but reduce size from 40x40 to 32x32
   - This creates more room for the tab bar and messages below

2. **Fix Horizontal Overflow Error**:
   - The overflow likely occurs in the header row (lines 209-276)
   - The row contains: avatar (40px) + crew name (flexible) + dropdown (flexible) + time (flexible) + menu button
   - Wrap the crew name Text widget (lines 236-243) in a `Flexible` widget with `flex: 2`
   - Wrap the `CrewSelectionDropdown` (line 246) in a `Flexible` widget with `flex: 1`
   - Ensure the time text (lines 261-266) uses `Flexible` or has a fixed width
   - Add `overflow: TextOverflow.ellipsis` to the crew name Text widget
   - Test in landscape orientation to ensure no overflow

3. **Optimize Quick Stats Row**:
   - The stats row (lines 278-301) might also overflow in landscape
   - Ensure each `_buildStatItem` widget is wrapped in `Flexible` or `Expanded`
   - Consider reducing font sizes or padding in landscape mode
   - Use `LayoutBuilder` to detect orientation and adjust accordingly

4. **Maintain Existing Functionality**:
   - Keep the crew selection dropdown functionality
   - Keep the quick actions menu (lines 427-463)
   - Keep the stats display (jobs, applications, score)
   - Ensure the tab bar (lines 341-379) remains fully functional
**Implement dialog methods for Feed, Chat, and Members tabs:**

1. **Implement _showCreatePostDialog Method (line 465)**:
   - Create a dialog using `showDialog` or `showModalBottomSheet`
   - Dialog should contain:
     - Title: "Create Post"
     - Multiline text field for post content (max 1000 characters)
     - Character counter showing remaining characters
     - Optional: Media upload button (placeholder for now)
     - Cancel and Submit buttons
   - On submit:
     - Validate content is not empty
     - Get selected crew ID from `ref.read(selectedCrewProvider)`
     - Get current user from `ref.read(currentUserProvider)`
     - Call `ref.read(postCreationNotifierProvider).createPost(crewId: selectedCrew.id, content: content)`
     - Show success toast on completion
     - Close dialog
   - Style with electrical theme (copper borders, circuit background)

2. **Implement _showShareJobDialog Method (line 469)**:
   - Create a dialog for sharing jobs with the crew
   - Dialog should contain:
     - Title: "Share Job with Crew"
     - Job selection dropdown or search field
     - Optional: Add custom message about the job
     - Share button
   - On submit:
     - Create a post with job details
     - Use `MessageType.jobShare` for the message type
     - Include job ID and details in the post
   - Style with electrical theme

3. **Implement _showNewMessageDialog Method (line 473)**:
   - This might not be needed if chat input is always visible
   - Alternatively, use this for starting a new direct message conversation
   - Show a member selection dialog
   - On member selection, navigate to chat with that member

4. **Update FAB Logic**:
   - The `_buildFloatingActionButton` method (lines 381-425) already switches based on selected tab
   - Ensure each FAB calls the correct dialog method
   - Tab 0 (Feed): Calls `_showCreatePostDialog` ✓
   - Tab 1 (Jobs): Calls `_showShareJobDialog` ✓
   - Tab 2 (Chat): Calls `_showNewMessageDialog` ✓
   - Tab 3 (Members): No FAB needed

5. **Add Error Handling**:
   - Wrap all dialog operations in try-catch blocks
   - Show electrical-themed error toasts on failure
   - Use `JJElectricalNotifications.showElectricalToast` for feedback

### lib\features\crews\screens\crew_onboarding_screen.dart(MODIFY)

References:

- lib\navigation\app_router.dart
- lib\design_system\app_theme.dart

**Update Step 1: Remove 'Join a Crew' button and change 'Create a Crew' text to 'Next':**

1. **Remove Join a Crew Button**:
   - Locate the "Join a Crew" button (lines 132-152)
   - Delete the entire `OutlinedButton` widget and its surrounding `SizedBox`
   - Remove the spacing between buttons (line 129)

2. **Change Create a Crew Button Text**:
   - Locate the "Create a Crew" button (lines 106-127)
   - Change the button text from `'Create a Crew'` to `'Next'`
   - Change the icon from `Icons.add` to `Icons.arrow_forward`
   - Update the onPressed handler to navigate to the create crew screen (already does this)

3. **Update Layout**:
   - Since we're removing one button, the remaining button should be full-width
   - Ensure the button uses `width: double.infinity` or is wrapped in `SizedBox(width: double.infinity)`
   - Adjust spacing to center the single button properly

4. **Maintain Animations**:
   - Keep the fade-in animation on the button (lines 124-127)
   - Ensure the animation timing remains smooth

5. **Update Screen Description**:
   - Consider updating the description text (lines 86-101) to reflect that this is now a step to create a crew
   - Change from "Join the team or build your own" to "Build your crew and start collaborating"
   - Update the description to focus on crew creation benefits

### lib\features\crews\screens\create_crew_screen.dart(MODIFY)

References:

- lib\electrical_components\circuit_board_background.dart
- lib\electrical_components\jj_circuit_breaker_switch.dart
- lib\domain\enums\enums.dart(MODIFY)
- lib\design_system\app_theme.dart

**Refactor Step 2: Add all classifications, copper borders, circuit background, and circuit breaker switch:**

1. **Add All Classifications**:
   - Currently the dropdown (lines 117-128) only shows 'Inside Wireman' and 'Journeyman Lineman'
   - Import the Classification enum: `import '../../../domain/enums/enums.dart';`
   - Replace the hardcoded dropdown items with all classifications from `Classification.all`
   - Map each classification to a DropdownMenuItem:

     ```dart
     items: Classification.all.map((classification) {
       return DropdownMenuItem(
         value: classification,
         child: Text(toTitleCase(classification)),
       );
     }).toList()
     ```

   - This will include: journeymanLineman, journeymanWireman, journeymanElectrician, journeymanTreeTrimmer, operator
   - Apply Title Case formatting to display names

2. **Add Copper Borders Around All Input Fields**:
   - Update the crew name TextFormField (lines 103-115):
     - Add `decoration: InputDecoration` with copper border
     - Use `enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper))`
     - Use `focusedBorder` with same copper color but thicker width
   - Update the description TextFormField (lines 130-143):
     - Add same copper border styling
   - Update the dropdown button (lines 117-128):
     - Wrap in a Container with copper border decoration
     - Use `BoxDecoration(border: Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper), borderRadius: BorderRadius.circular(AppTheme.radiusMd))`

3. **Add Electrical Circuit Background**:
   - Wrap the entire body in a Stack
   - Add `ElectricalCircuitBackground` as the first child:

     ```dart
     Stack(
       children: [
         ElectricalCircuitBackground(
           opacity: 0.08,
           componentDensity: ComponentDensity.high,
           enableCurrentFlow: true,
           enableInteractiveComponents: true,
         ),
         // Existing Padding widget with form content
       ],
     )
     ```

4. **Change Switch to JJ Circuit Breaker Switch**:
   - Locate the SwitchListTile (lines 146-154)
   - Replace with `JJCircuitBreakerSwitchListTile` or custom implementation using `JJCircuitBreakerSwitch`
   - Import: `import '../../../electrical_components/jj_circuit_breaker_switch.dart';`
   - Implementation:

     ```dart
     Row(
       children: [
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Auto-share matching jobs', style: AppTheme.titleMedium),
               Text('Automatically share jobs with crew', style: AppTheme.bodySmall),
             ],
           ),
         ),
         JJCircuitBreakerSwitch(
           value: _autoShareEnabled,
           onChanged: (value) => setState(() => _autoShareEnabled = value),
           size: JJCircuitBreakerSize.medium,
           showElectricalEffects: true,
         ),
       ],
     )
     ```

5. **Add Persistent Animation/Gradient/Shadow to Create Crew Button**:
   - Locate the "Create Crew" button (lines 156-163)
   - Wrap the button in an `AnimatedContainer` or use `flutter_animate` package
   - Add a pulsing glow effect:
     - Use `AnimatedBuilder` with a repeating `AnimationController`
     - Animate the box shadow to pulse between normal and enhanced glow
     - Use `AppTheme.accentCopper` for the glow color
   - Add gradient background (already present via `Theme.of(context).primaryColor`)
   - Enhance the shadow with electrical glow:

     ```dart
     boxShadow: [
       BoxShadow(
         color: AppTheme.accentCopper.withValues(alpha: 0.4),
         blurRadius: 20,
         spreadRadius: 2,
       ),
       BoxShadow(
         color: AppTheme.primaryNavy.withValues(alpha: 0.2),
         blurRadius: 10,
         offset: Offset(0, 4),
       ),
     ]
     ```

   - Add a shimmer or pulse animation that repeats every 2-3 seconds

6. **Maintain Consistency with App Design Schema**:
   - Ensure all colors use AppTheme constants
   - Ensure all spacing uses AppTheme spacing constants
   - Ensure all border radius uses AppTheme radius constants

### lib\features\crews\widgets\crew_preferences_dialog.dart(MODIFY)

References:

- lib\domain\enums\enums.dart(MODIFY)
- lib\features\crews\services\crew_service.dart(MODIFY)
- lib\design_system\app_theme.dart

**Fix overflow, replace job types with construction types, update button text, and fix permission error:**

1. **Fix Overflow on Top Right Corner**:
   - Locate the dialog header (lines 84-120)
   - The overflow is likely caused by the title text and close button competing for space
   - Wrap the title Text widget (lines 101-107) in an `Expanded` widget to prevent overflow
   - Ensure the IconButton (lines 109-116) has fixed constraints
   - Reduce the title font size if needed or use `overflow: TextOverflow.ellipsis`
   - Test with long crew names to ensure no overflow

2. **Replace Job Types with Construction Types**:
   - Locate the `_availableJobTypes` list (lines 31-42)
   - This list contains classifications like 'Inside Wireman', 'Journeyman Lineman', 'Apprentice Lineman', etc.
   - **Remove these classifications**: Apprentice Lineman, Electrical Foreman, Project Manager, Electrical Engineer, Safety Coordinator, Journeyman Lineman, Inside Wireman
   - **Replace with construction types** from the `ConstructionTypes` enum:
     - Import: `import '../../../domain/enums/enums.dart';`
     - Replace the list with: `final List<String> _availableConstructionTypes = ConstructionTypes.all.map((e) => toTitleCase(e)).toList();`
     - This will include: Transmission, Distribution, Substation (note: enum has 'subStation'), Underground, Industrial, Commercial, Residential, Data Center (note: enum has 'dataCenter')
   - Update the section title from "Job Types" to "Construction Types" (line 182)
   - Update the description from "Select the types of electrical jobs your crew is interested in" to "Select the construction types your crew works on"

3. **Update the FilterChip Implementation**:
   - Locate the `_buildJobTypesSection` method (lines 178-238)
   - Rename to `_buildConstructionTypesSection`
   - Update the Wrap widget (lines 197-235) to use `_availableConstructionTypes` instead of `_availableJobTypes`
   - Update the preferences model to use construction types instead of job types
   - Change `_preferences.jobTypes` to `_preferences.constructionTypes` throughout

4. **Change Save Button Text**:
   - Locate the footer section (lines 594-660)
   - Find the "Save Preferences" button (lines 628-656)
   - Change the button text from `'Save Preferences'` (line 649) to `'Save'` or `'Continue'`
   - Keep the button styling and loading state logic

5. **Fix Permission Error When Saving**:
   - The error "caller does not have permission" suggests Firestore security rules are blocking the write
   - Locate the `_savePreferences` method (lines 662-715)
   - The method calls `widget.crewService.updateCrew` (lines 682-685)
   - Review the data being saved to ensure it matches the expected schema
   - Add error handling to catch permission errors specifically:

     ```dart
     catch (e) {
       if (e.toString().contains('permission')) {
         // Show specific permission error message
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('You do not have permission to update crew preferences. Please contact the crew admin.'),
             backgroundColor: AppTheme.errorRed,
           ),
         );
       } else {
         // Show generic error
       }
     }
     ```

   - Verify that the current user has the correct role/permissions to update crew preferences
   - Check if the crew service method requires admin/foreman role
   - If security rules need updating, add a TODO comment:

     ```dart
     // TODO: Update Firestore security rules to allow crew members to update preferences
     // Current rule may be too restrictive - should allow admins/foremans to update
     ```

6. **Update CrewPreferences Model**:
   - Ensure the model has a `constructionTypes` field instead of or in addition to `jobTypes`
   - Update the `copyWith` method to handle construction types
   - Update the `toMap` and `fromMap` methods to serialize construction types correctly

### lib\features\crews\widgets\tab_widgets.dart(MODIFY)

References:

- lib\features\crews\providers\feed_provider.dart
- lib\features\crews\providers\global_feed_riverpod_provider.dart
- lib\services\feed_service.dart
- lib\features\crews\widgets\post_card.dart(MODIFY)
- lib\features\crews\widgets\message_bubble.dart(MODIFY)
- lib\features\crews\widgets\chat_input.dart(MODIFY)
- lib\features\crews\widgets\crew_member_avatar.dart(MODIFY)
- lib\features\crews\services\chat_service.dart
- lib\features\crews\providers\messaging_riverpod_provider.dart(MODIFY)

**Implement Feed, Chat, and Members tabs with full functionality:**

## Feed Tab (FeedTab widget, lines 10-191)

1. **Update Access Control**:
   - Currently shows empty state when no crew is selected (lines 18-37)
   - Change to allow access for ALL users regardless of crew membership
   - Update the condition to check for `currentUser != null` instead of `selectedCrew != null`
   - Show global feed when no crew is selected, crew feed when crew is selected

2. **Add Post Creation FAB/Input Window**:
   - The FAB is already defined in `tailboard_screen.dart` (lines 384-395)
   - Implement the `_showCreatePostDialog` method in tailboard_screen
   - Create a dialog with:
     - Text input field for post content (multiline, max 1000 characters)
     - Optional media upload button (placeholder for now)
     - Submit button to create the post
   - Use `PostCreationNotifier` from `feed_provider.dart` to handle post creation
   - Call `ref.read(postCreationNotifierProvider).createPost(crewId: selectedCrew.id, content: content)`

3. **Display Posts with 50-Post Limit**:
   - The feed already uses `crewPostsProvider` which fetches posts (lines 41-42)
   - Update the `FeedService.getCrewPosts` query to enforce `limit: 50`
   - Sort posts by timestamp descending (most recent at top) - already implemented
   - The ListView.builder (lines 86-187) already renders posts using `PostCard`

4. **Auto-Populate Prior Posts**:
   - The stream provider already fetches posts in real-time
   - Ensure the RefreshIndicator (lines 79-187) allows manual refresh
   - Posts are automatically updated via Firestore snapshots

5. **Style with Electrical Theme**:
   - The `PostCard` widget already uses electrical theme colors (defined in `post_card.dart`)
   - Ensure the feed background uses `ElectricalCircuitBackground` (add to parent if not present)
   - Verify copper borders and navy colors are consistent

## Chat Tab (ChatTab widget, lines 224-253)

1. **Implement Crew Members Only Access**:
   - Update the access check to verify user is a member of the selected crew
   - Use `ref.watch(isUserInCrewProvider((selectedCrew.id, currentUser.uid)))` to check membership
   - Show "Join a crew to access chat" message if not a member

2. **Design Chat Box with Proper Colors**:
   - Replace the placeholder content (lines 231-250) with actual chat implementation
   - Use `ListView.builder` to render messages
   - Fetch messages using `ref.watch(crewMessagesProvider(selectedCrew.id))` from `messaging_riverpod_provider.dart`
   - For each message, use the `MessageBubble` widget from `message_bubble.dart`

3. **Implement Message Alignment**:
   - User messages (where `message.senderId == currentUser.uid`) should align right
   - Incoming messages (where `message.senderId != currentUser.uid`) should align left
   - The `MessageBubble` widget already handles this with the `isCurrentUser` parameter

4. **Newest Messages at Bottom**:
   - Sort messages chronologically (oldest first) so newest appear at bottom
   - Use `ref.watch(chronologicalMessagesProvider(selectedCrew.id))` from messaging provider
   - Auto-scroll to bottom when new messages arrive using `ScrollController`
   - Implement: `WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(_scrollController.position.maxScrollExtent))`

5. **Single Line Text Input with Send Button**:
   - Add the `ChatInput` widget at the bottom of the chat (from `chat_input.dart`)
   - The widget already implements:
     - Single line text input that expands as needed
     - Send button that activates when text is entered
     - Keyboard activation on tap
   - Wire up the `onSendMessage` callback to send messages via `MessageService`
   - Use: `ref.read(messageServiceProvider).sendMessage(crewId: selectedCrew.id, content: text, senderId: currentUser.uid)`

6. **Implement Circular Avatar with Initials**:
   - The `MessageBubble` widget already uses `CrewMemberAvatar` (line 248 in message_bubble.dart)
   - The avatar shows initials if no image is available
   - Ensure each message bubble displays the sender's avatar
   - Fetch sender name from user document or crew member data

7. **Style with Electrical Theme**:
   - Ensure message bubbles use electrical theme colors (already implemented in `message_bubble.dart`)
   - User messages: Navy background with white text
   - Incoming messages: Light grey background with dark text
   - Add copper accents to the chat input border

## Members Tab (MembersTab widget, lines 255-284)

1. **List All Members in Active Crew**:
   - Replace the placeholder content (lines 262-280) with actual member list
   - Fetch crew members using `ref.watch(crewMembersProvider(selectedCrew.id))` from crews provider
   - Use `ListView.builder` to render each member

2. **Display Member Information**:
   - For each member, show:
     - Name (from user document)
     - Home local (from user document)
     - Books on (from user document)
     - Work preferences (construction types, hours per week, per diem from user document)
   - Use the `CrewMemberListItem` widget from `crew_member_avatar.dart` (lines 93-224)
   - The widget already displays: name, avatar, role, online status, last active

3. **Implement Member Selection**:
   - The `CrewMemberListItem` already has an `onTap` callback (line 99)
   - When a member is tapped, show a bottom sheet or dialog with options:
     - "Send Direct Message"
     - "View Profile"
     - "Cancel"
   - Use `showModalBottomSheet` to display the options

4. **Create Member Profile View**:
   - Create a basic profile view that shows:
     - Member avatar and name
     - Home local and classification
     - Books on and working status
     - Construction type preferences
     - Join date and last active
   - Use a modal bottom sheet or navigate to a new screen
   - Style with electrical theme (copper borders, circuit background)

5. **Integrate with Direct Messaging**:
   - When "Send Direct Message" is selected:
     - Navigate to the Chat tab
     - Set up a direct message conversation with the selected member
     - Use the messaging provider to create/fetch the conversation
     - Display the chat interface with the selected member
   - Use the existing `directMessagesProvider` from `messaging_riverpod_provider.dart`

6. **Use CrewMemberAvatar for Consistent Display**:
   - Import `crew_member_avatar.dart`
   - Use `CrewMemberAvatar` widget for all member avatars
   - The widget already handles:
     - Circular avatar with initials fallback
     - Online status indicator
     - Customizable size
     - Border styling

7. **Style with Electrical Theme**:
   - Use copper borders on member list items
   - Use electrical circuit background for the members list
   - Ensure consistent spacing and typography

### lib\domain\enums\enums.dart(MODIFY)

**Add missing classifications and ensure proper formatting:**

1. **Review Current Classifications**:
   - Current enum values (lines 3-11): journeymanLineman, journeymanWireman, journeymanElectrician, journeymanTreeTrimmer, operator
   - These are already comprehensive for the main electrical trades

2. **Add Additional Classifications if Needed**:
   - Based on the TODO requirements, add any missing classifications:
     - `cableSplicer` (if needed for cable splicing work)
     - `groundman` (if needed for ground crew work)
     - `apprentice` (if needed for apprentice positions)
   - Add these as new enum values before the semicolon

3. **Ensure Title Case Display**:
   - The enum uses camelCase names (e.g., `journeymanLineman`)
   - When displayed in UI, these should be converted to Title Case (e.g., "Journeyman Lineman")
   - The `toTitleCase()` function from `text_formatting_wrapper.dart` handles this
   - Ensure all UI components use `toTitleCase(classification)` when displaying

4. **Verify ConstructionTypes Enum**:
   - Current values (lines 13-24): distribution, transmission, subStation, residential, industrial, dataCenter, commercial, underground
   - These match the TODO requirements exactly
   - Note the camelCase: `subStation` displays as "Sub Station", `dataCenter` displays as "Data Center"
   - No changes needed to this enum

5. **Update the `all` Getter**:
   - The `all` getter (line 10) returns enum names as strings
   - This is correct for serialization
   - UI components should apply `toTitleCase()` when displaying these values

### lib\features\crews\models\crew_preferences.dart(MODIFY)

References:

- lib\domain\enums\enums.dart(MODIFY)

**Update CrewPreferences model to use construction types instead of job types:**

1. **Add or Update Construction Types Field**:
   - Add a `List<String> constructionTypes` field to the model
   - This should replace or supplement the existing `jobTypes` field
   - Initialize as empty list in the default constructor

2. **Update Constructor**:
   - Add `this.constructionTypes = const []` parameter
   - Keep backward compatibility by maintaining `jobTypes` if it exists elsewhere

3. **Update fromMap/fromFirestore Method**:
   - Add parsing for `constructionTypes` field:

     ```dart
     constructionTypes: List<String>.from(map['constructionTypes'] ?? []),
     ```

   - Handle migration from old `jobTypes` field if needed:

     ```dart
     constructionTypes: List<String>.from(map['constructionTypes'] ?? map['jobTypes'] ?? []),
     ```

4. **Update toMap/toFirestore Method**:
   - Add serialization for `constructionTypes`:

     ```dart
     'constructionTypes': constructionTypes,
     ```

   - Optionally keep `jobTypes` for backward compatibility during migration

5. **Update copyWith Method**:
   - Add `List<String>? constructionTypes` parameter
   - Return new instance with: `constructionTypes: constructionTypes ?? this.constructionTypes`

6. **Validation**:
   - Add validation to ensure construction types are from the valid enum values
   - Use `ConstructionTypes.all` to validate against allowed values

### lib\features\crews\services\crew_service.dart(MODIFY)

References:

- lib\features\crews\models\crew_preferences.dart(MODIFY)
- lib\domain\enums\enums.dart(MODIFY)

**Update crew service to handle construction types and fix permission issues:**

1. **Update Crew Creation Method**:
   - Locate the `createCrew` method (based on the file summary, around lines 212-304)
   - Ensure it accepts and saves `constructionTypes` in the crew preferences
   - Validate that construction types are from the valid enum values

2. **Update Crew Update Method**:
   - Locate the `updateCrew` method
   - Ensure it properly handles `constructionTypes` updates
   - Add permission check to verify the user has rights to update preferences:

     ```dart
     // Check if user is admin or foreman
     final userRole = await getUserRole(userId: currentUserId, crewId: crewId);
     if (userRole != MemberRole.admin && userRole != MemberRole.foreman) {
       throw Exception('Only admins and foremans can update crew preferences');
     }
     ```

3. **Fix Permission Error**:
   - Review the Firestore write operation in the update method
   - Ensure the data structure matches what Firestore security rules expect
   - Add proper error handling for permission denied errors
   - Log the exact error for debugging:

     ```dart
     catch (e) {
       if (kDebugMode) {
         print('Error updating crew preferences: $e');
         print('User ID: $currentUserId, Crew ID: $crewId');
       }
       rethrow;
     }
     ```

4. **Add Migration Logic**:
   - If crews have old `jobTypes` data, migrate to `constructionTypes`:

     ```dart
     // During crew fetch, check if constructionTypes is empty but jobTypes exists
     if (constructionTypes.isEmpty && jobTypes.isNotEmpty) {
       // Migrate jobTypes to constructionTypes
       constructionTypes = jobTypes;
     }
     ```

5. **Update Job Matching Logic**:
   - If the service has job matching functionality, update it to use `constructionTypes`
   - Match jobs based on construction type instead of job classification
   - Update any filters or queries that reference job types

### lib\widgets\dialogs\job_details_dialog.dart(MODIFY)

References:

- lib\utils\text_formatting_wrapper.dart(MODIFY)
- lib\design_system\app_theme.dart

**Apply Title Case formatting and remove colored fonts from job details dialog:**

1. **Apply Title Case to All Text**:
   - Import `text_formatting_wrapper.dart` if not already imported
   - Apply `toTitleCase()` to all job fields displayed in the dialog:
     - Company name
     - Location
     - Classification
     - Type of work
     - Any other text fields from the job model
   - Use `JobDataFormatter` methods where appropriate

2. **Remove Colored Fonts**:
   - Review all Text widgets in the dialog
   - Remove any conditional color styling (e.g., green for high wages, red for low wages)
   - Use only neutral theme colors:
     - Labels: `AppTheme.textDark` or `AppTheme.textPrimary`
     - Values: `AppTheme.textLight` or `AppTheme.textSecondary`
   - Remove any grey tint on local number display

3. **Ensure Consistent Styling**:
   - Use RichText for label-value pairs with bold labels and regular values
   - Maintain copper borders and electrical theme elements
   - Ensure proper spacing between sections

4. **Update Dialog Decoration**:
   - Ensure the dialog uses electrical theme styling
   - Add copper border if not present
   - Use white or off-white background
   - Add subtle circuit background pattern if appropriate

### lib\widgets\storm\power_outage_card.dart(MODIFY)

References:

- lib\services\power_outage_service.dart
- lib\design_system\app_theme.dart

**Enhance PowerOutageCard for toggle/accordion integration:**

1. **Verify Current Implementation**:
   - The card already displays state name, outage count, severity, and percentage (lines 18-203)
   - The card is tappable and shows details in a modal (via `onTap` callback)
   - Styling already uses copper borders and electrical theme

2. **Ensure Proper Data Display**:
   - State name should be displayed prominently (line 83)
   - Outage count should use formatted numbers (line 99): `formatOutageCount()`
   - Severity badge should use color coding (lines 115-131)
   - Percentage should be displayed with progress bar (lines 148-164)

3. **Add Expandable Details**:
   - Consider adding an expandable section within the card to show:
     - List of affected utilities
     - Estimated restoration time
     - IBEW locals in the area
   - Use `ExpansionTile` or custom animation to expand/collapse

4. **Optimize for List Display**:
   - Ensure the card works well in a scrollable list
   - Add proper margins and spacing (already present at line 24)
   - Ensure tap targets are large enough for easy interaction

5. **Maintain Electrical Theme**:
   - Keep copper borders (lines 29-32)
   - Keep severity color coding
   - Ensure all text uses theme colors

### lib\widgets\contractor_card.dart(MODIFY)

References:

- lib\utils\text_formatting_wrapper.dart(MODIFY)
- lib\design_system\app_theme.dart

**Apply Title Case formatting and ensure proper styling:**

1. **Apply Title Case to Company Name**:
   - Line 45 already uses `toTitleCase(contractor.company)`
   - Verify this is working correctly

2. **Remove Colored Fonts**:
   - Review all Text widgets in the card
   - Ensure all text uses neutral theme colors
   - Labels should use `AppTheme.textPrimary` or `AppTheme.textDark`
   - Values should use `AppTheme.textPrimary` or `AppTheme.textLight`
   - Links should use `AppTheme.primaryNavy` with underline (already correct at lines 167-168)

3. **Verify Copper Border**:
   - The card already has copper border (lines 25-27)
   - Ensure the border width uses `AppTheme.borderWidthMedium`

4. **Ensure Proper Button Styling**:
   - The action buttons (lines 103-136) use theme colors
   - "Visit Website" button uses `AppTheme.primaryNavy` background
   - "Call" button uses copper border
   - Keep this styling consistent

5. **Maintain Electrical Theme**:
   - Keep the copper border and shadow effects
   - Ensure the card integrates well with the storm screen's electrical background

### lib\features\crews\widgets\post_card.dart(MODIFY)

References:

- lib\features\crews\widgets\crew_member_avatar.dart(MODIFY)
- lib\design_system\app_theme.dart
- lib\electrical_components\jj_electrical_notifications.dart(MODIFY)

**Enhance post card with electrical theme and proper functionality:**

1. **Verify Electrical Theme Styling**:
   - The card already uses `AppTheme.electricalSurface` for background (line 579)
   - The card has copper border (lines 582-585)
   - Ensure all colors use electrical theme constants

2. **Update Notification Usage**:
   - Line 190 uses `AppTheme.electricalSuccess` for snackbar
   - Replace all SnackBar usage with electrical toasts:
     - Import `JJElectricalNotifications`
     - Replace `ScaffoldMessenger.of(context).showSnackBar` with `JJElectricalNotifications.showElectricalToast`
     - Use appropriate notification types (success, error, info)

3. **Ensure Avatar Integration**:
   - The `_buildPostHeader` method (lines 243-331) already uses `CrewMemberAvatar` (line 248)
   - Verify the avatar displays correctly with initials fallback
   - Ensure the avatar size is appropriate (currently 40)

4. **Verify Comment Functionality**:
   - The card already integrates with `CommentInput` (lines 503-513)
   - The card already displays `CommentThread` (lines 518-538)
   - Ensure comments are properly fetched via the provider
   - Verify comment actions (like, edit, delete) are wired up

5. **Maintain Interaction Features**:
   - Keep the like animation (lines 434-446)
   - Keep the reaction picker functionality
   - Keep the bookmark feature (lines 472-483)
   - Ensure all interactions provide visual feedback

### lib\features\crews\widgets\message_bubble.dart(MODIFY)

References:

- lib\design_system\app_theme.dart
- lib\electrical_components\circuit_pattern_painter.dart

**Ensure proper message alignment and electrical theme styling:**

1. **Verify Message Alignment**:
   - The widget already implements proper alignment (lines 32-34)
   - User messages align right when `isCurrentUser` is true
   - Incoming messages align left when `isCurrentUser` is false
   - Ensure this logic is working correctly

2. **Verify Avatar Display**:
   - Incoming messages show avatar on the left (lines 36-49)
   - User messages show avatar on the right (lines 152-163)
   - The avatar uses `CrewMemberAvatar` with initials fallback
   - Ensure avatars are displayed correctly

3. **Verify Color Coding**:
   - The `_getBubbleColor` method (lines 290-300) already implements color coding:
     - System notifications: `AppTheme.electricalSurface`
     - Job shares: Copper tint
     - User messages: Navy background
     - Incoming messages: Light surface
   - Ensure these colors are correct and consistent

4. **Verify Circuit Background**:
   - The message bubble uses `CircuitPatternPainter` (lines 98-105)
   - Ensure the circuit pattern is subtle and doesn't interfere with text readability
   - Verify opacity is set correctly

5. **Ensure Proper Text Contrast**:
   - The `_getTextColor` method (lines 302-312) sets text colors
   - User messages: White text on navy background
   - Incoming messages: Dark text on light background
   - Verify text is readable in all cases

6. **Maintain Electrical Theme**:
   - Keep copper borders on message bubbles (line 84)
   - Keep electrical glow effect on user messages (lines 85-93)
   - Ensure consistent styling across all message types

### lib\features\crews\widgets\chat_input.dart(MODIFY)

References:

- lib\design_system\app_theme.dart

**Enhance chat input with electrical theme styling:**

1. **Add Copper Border to Input Field**:
   - Locate the input container decoration (lines 95-103)
   - Update the border to use copper color:
     - Change `border: Border.all(color: AppTheme.borderLight, width: 1)` to `border: Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper)`
   - Add focus state to make border glow when focused:
     - Use `FocusNode` to detect focus state
     - Animate border color/width when focused

2. **Update Send Button Styling**:
   - The send button (lines 152-161) changes icon based on `_canSend`
   - Ensure the copper color is vibrant when send is enabled
   - Add a subtle glow or pulse animation to the send button when enabled

3. **Verify Keyboard Activation**:
   - The TextField already activates keyboard on tap (line 109)
   - Ensure `textInputAction: TextInputAction.send` triggers the send action
   - The `onSubmitted` callback (line 133) already calls `_sendMessage()`

4. **Maintain Electrical Theme**:
   - Keep the white background for the input container
   - Keep the off-white background for the text field (line 97)
   - Ensure proper shadow and elevation (lines 71-77)

5. **Add Character Counter**:
   - The TextField has `maxLength: 1000` (line 113)
   - Consider showing a character counter when approaching the limit
   - Use `counterText` in InputDecoration or custom widget below input

### lib\features\crews\widgets\crew_member_avatar.dart(MODIFY)

References:

- lib\design_system\app_theme.dart

**Ensure avatar displays initials correctly and is customizable:**

1. **Verify Initials Display**:
   - The `_buildInitials` method (lines 70-82) already extracts initials from name
   - For names with 2+ words, it uses first letter of first two words
   - For single word names, it uses first 2 characters
   - Ensure this logic handles edge cases (empty names, special characters)

2. **Verify Avatar Customization**:
   - The widget accepts `avatarUrl` parameter (line 6)
   - If URL is provided, it displays the network image (lines 37-45)
   - If URL is null or fails to load, it shows initials (line 46)
   - This is correct behavior

3. **Verify Circular Shape**:
   - The avatar uses `borderRadius: BorderRadius.circular(size / 2)` (line 30)
   - This creates a perfect circle
   - Ensure the border radius is always half the size

4. **Verify Online Status Indicator**:
   - The status indicator (lines 49-65) shows green when online, grey when offline
   - The indicator is positioned at bottom-right of avatar
   - Ensure the indicator is visible and properly sized

5. **Verify Copper Border**:
   - The avatar has copper border (lines 31-34)
   - Border color uses `AppTheme.accentCopper.withValues(alpha: 0.3)`
   - Border width is 2px
   - This is correct styling

6. **Verify CrewMemberListItem**:
   - The `CrewMemberListItem` widget (lines 93-224) displays member info in a list
   - It shows: avatar, name, role, online status, last active
   - It has an `onTap` callback for interaction
   - Ensure this widget is used in the Members tab

7. **Maintain Electrical Theme**:
   - Keep the copper accent colors
   - Keep the circular shape and border styling
   - Ensure consistent sizing across the app

### lib\features\crews\services\message_service.dart(MODIFY)

References:

- lib\features\crews\services\chat_service.dart
- lib\features\crews\models\message.dart

**Create MessageService for sending and managing messages:**

Note: This file may already exist. If it does, skip creation and modify the existing file instead.

1. **Create MessageService Class**:
   - Import necessary dependencies: `cloud_firestore`, `flutter/foundation.dart`
   - Import models: `Message`, `MessageType`, `MessageStatus`
   - Import services: `ChatService`

2. **Implement Send Message Method**:
   - Method signature: `Future<String> sendMessage({required String crewId, required String senderId, required String content, MessageType type = MessageType.text})`
   - Create message document in Firestore:
     - Collection: `crews/{crewId}/messages`
     - Fields: senderId, content, type, sentAt (serverTimestamp), status ('sent'), readBy (empty map), isCrewMessage (true)
   - Return the message ID
   - Handle errors and throw appropriate exceptions

3. **Implement Get Messages Stream**:
   - Method signature: `Stream<List<Message>> getCrewMessagesStream(String crewId, String currentUserId)`
   - Query Firestore: `crews/{crewId}/messages` ordered by `sentAt` ascending
   - Map documents to Message objects
   - Filter out deleted messages
   - Return stream of messages

4. **Implement Direct Message Methods**:
   - Method: `Future<String> sendDirectMessage({required String senderId, required String recipientId, required String content})`
   - Create conversation ID: Sort user IDs and join with underscore (e.g., `user1_user2`)
   - Store in `messages/{conversationId}/messages` collection
   - Return message ID

5. **Implement Get Direct Messages Stream**:
   - Method signature: `Stream<List<Message>> getDirectMessagesStream(String userId1, String userId2, String currentUserId)`
   - Generate conversation ID from sorted user IDs
   - Query messages collection
   - Return stream of messages

6. **Integrate with ChatService**:
   - Use `ChatService` methods for marking messages as read/delivered
   - Delegate status updates to ChatService
   - Ensure proper integration between the two services

7. **Add Error Handling**:
   - Wrap all Firestore operations in try-catch
   - Throw descriptive exceptions
   - Log errors in debug mode

### lib\features\crews\providers\messaging_riverpod_provider.dart(MODIFY)

References:

- lib\features\crews\services\message_service.dart(MODIFY)
- lib\features\crews\models\message.dart

**Ensure messaging providers are properly configured:**

1. **Verify MessageService Provider**:
   - Line 12 defines `messageService` provider
   - Ensure it returns an instance of `MessageService`
   - If `MessageService` doesn't exist, it should be created (see previous file change)

2. **Verify Crew Messages Stream Provider**:
   - Lines 15-25 define `crewMessagesStream` provider
   - This fetches messages for a specific crew
   - Ensure it uses the correct service method
   - Verify it returns messages in chronological order

3. **Verify Direct Messages Stream Provider**:
   - Lines 40-54 define `directMessagesStream` provider
   - This fetches direct messages between two users
   - Ensure the conversation ID is generated correctly
   - Verify it integrates with the message service

4. **Add Send Message Notifier**:
   - Create a notifier for sending messages (similar to `PostCreationNotifier` in feed_provider)
   - Method: `Future<void> sendMessage({required String crewId, required String content})`
   - Handle loading state and errors
   - Provide feedback via electrical toasts

5. **Verify Unread Count Providers**:
   - Lines 73-83 define `unreadCrewMessagesCount`
   - Lines 86-101 define `unreadDirectMessagesCount`
   - Ensure these correctly count unread messages
   - Verify they update in real-time

6. **Add Helper Providers**:
   - The file already has many helper providers (chronological, by sender, with attachments, etc.)
   - Ensure all providers are properly typed and return correct data
   - Verify error handling in all providers

### lib\features\crews\widgets\member_profile_dialog.dart(NEW)

References:

- lib\features\crews\widgets\crew_member_avatar.dart(MODIFY)
- lib\design_system\app_theme.dart
- lib\utils\text_formatting_wrapper.dart(MODIFY)

**Create basic member profile view dialog:**

1. **Create MemberProfileDialog Widget**:
   - Create a StatelessWidget that accepts member data as parameters
   - Parameters: `String memberId`, `String memberName`, `String? avatarUrl`, `Map<String, dynamic> memberData`

2. **Design Dialog Layout**:
   - Use `Dialog` or `showModalBottomSheet` for display
   - Header section:
     - Large `CrewMemberAvatar` (size: 80-100)
     - Member name in Title Case (use `toTitleCase()`)
     - Role badge (admin, foreman, lead, member)
   - Info section:
     - Home local: Display with label "Home Local: [number]"
     - Classification: Display with label "Classification: [type]"
     - Books on: Display with label "Books On: [books]"
     - Working status: Display with label "Currently Working: Yes/No"
   - Preferences section:
     - Construction types: Display as chips
     - Hours per week: Display with label
     - Per diem requirement: Display with label
   - Metadata section:
     - Join date: Format as "Joined: MMM DD, YYYY"
     - Last active: Format as "Last active: X hours ago"

3. **Add Action Buttons**:
   - "Send Direct Message" button:
     - Primary button with copper gradient
     - Closes dialog and navigates to chat with this member
   - "Close" button:
     - Secondary button
     - Closes the dialog

4. **Style with Electrical Theme**:
   - Add copper border to dialog
   - Use white/off-white background
   - Add subtle circuit background pattern
   - Use electrical theme colors for all elements
   - Ensure proper spacing and typography

5. **Handle Missing Data**:
   - Use null-safe operators for all optional fields
   - Display "Not specified" for missing data instead of "N/A"
   - Handle cases where user document might not have all fields

6. **Add Loading State**:
   - If fetching additional member data, show loading indicator
   - Use electrical-themed loading animation

### lib\features\crews\widgets\create_post_dialog.dart(NEW)

References:

- lib\design_system\app_theme.dart
- lib\electrical_components\circuit_board_background.dart
- lib\electrical_components\jj_electrical_notifications.dart(MODIFY)

**Create dialog for creating new posts in the feed:**

1. **Create CreatePostDialog Widget**:
   - Create a StatefulWidget for managing form state
   - Parameters: `String crewId`, `Function(String content) onSubmit`

2. **Design Dialog Layout**:
   - Use `Dialog` widget with rounded corners and copper border
   - Header:
     - Title: "Create Post"
     - Close button (X icon)
     - Copper gradient background
   - Content:
     - Multiline TextField for post content
     - Max length: 1000 characters
     - Character counter showing remaining characters
     - Hint text: "Share an update with your crew..."
     - Copper border on the text field
   - Footer:
     - Cancel button (secondary style)
     - Post button (primary style with copper gradient)
     - Disable Post button when content is empty

3. **Add Electrical Circuit Background**:
   - Wrap the dialog content in a Stack
   - Add `ElectricalCircuitBackground` as base layer:
     - `opacity: 0.05` (very subtle for dialog)
     - `componentDensity: ComponentDensity.medium`
     - `enableCurrentFlow: false` (static background)

4. **Implement Form Validation**:
   - Validate content is not empty
   - Validate content length is within limits
   - Show error message if validation fails
   - Use electrical-themed error toast

5. **Implement Submit Logic**:
   - On Post button press:
     - Validate form
     - Call `onSubmit` callback with content
     - Show loading indicator on button
     - Close dialog on success
     - Show error toast on failure

6. **Add Media Upload Placeholder**:
   - Add a button or icon for attaching media (images, documents)
   - Show "Coming soon" message when tapped
   - Add TODO comment for future implementation:

     ```dart
     // TODO: Implement media upload
     // - Allow users to select images from gallery
     // - Upload to Firebase Storage
     // - Add media URLs to post data
     ```

7. **Style with Electrical Theme**:
   - Use copper borders throughout
   - Use navy and copper color scheme
   - Add subtle animations for button interactions
   - Ensure proper spacing and typography

### lib\widgets\storm\power_outage_toggle_header.dart(NEW)

References:

- lib\design_system\app_theme.dart

**Create toggle header widget for power outage accordion:**

1. **Create PowerOutageToggleHeader Widget**:
   - Create a StatelessWidget
   - Parameters:
     - `bool isExpanded` - current expansion state
     - `VoidCallback onToggle` - callback when tapped
     - `int stateCount` - number of affected states
     - `int totalOutages` - total customers affected

2. **Design Header Layout**:
   - Container with white background and copper border
   - Padding: 16px all around
   - Border radius: 12px
   - Row layout:
     - Left side:
       - Icon: `Icons.power_off` with copper color
       - Title: "Power Outages by State" (bold, navy)
       - Subtitle: "$stateCount states • $totalOutages customers affected" (small, grey)
     - Right side:
       - Expansion icon: `Icons.expand_more` when collapsed, `Icons.expand_less` when expanded
       - Rotate icon based on expansion state

3. **Add Tap Interaction**:
   - Wrap entire container in `InkWell` or `GestureDetector`
   - Call `onToggle` callback when tapped
   - Add ripple effect for visual feedback

4. **Add Animation**:
   - Animate the expansion icon rotation (0° to 180°)
   - Use `AnimatedRotation` or `RotationTransition`
   - Duration: 200-300ms
   - Curve: `Curves.easeInOut`

5. **Style with Electrical Theme**:
   - Use copper border: `Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthMedium)`
   - Use white background
   - Add subtle shadow for depth
   - Ensure proper spacing between elements

6. **Add Accessibility**:
   - Add semantic label for screen readers
   - Ensure tap target is large enough (minimum 48x48)
   - Provide haptic feedback on tap

### lib\widgets\storm\emergency_video_placeholder.dart(NEW)

References:

- lib\design_system\app_theme.dart
- lib\electrical_components\circuit_board_background.dart

**Create placeholder widget for emergency declaration videos (admin only):**

1. **Create EmergencyVideoPlaceholder Widget**:
   - Create a StatelessWidget
   - Parameters:
     - `bool isAdmin` - whether current user is admin
     - `VoidCallback? onUploadVideo` - callback for admin video upload (optional)

2. **Design Placeholder Layout**:
   - Container with copper border and white background
   - Padding: 16px all around
   - Header:
     - Icon: `Icons.video_library` with copper color
     - Title: "Emergency Declarations" (bold, navy)
     - Subtitle: "Real-time video updates" (small, grey)
     - Admin badge if user is admin
   - Content:
     - If admin: Show "Upload Video" button (disabled/placeholder)
     - If not admin: Show "No videos available" message
     - Placeholder for video list (empty ListView)

3. **Add Commented-Out Video Player Code**:
   - Add extensive TODO comments for future implementation:

     ```dart
     // TODO: Implement video player functionality
     // Required packages:
     // - video_player: ^2.8.0 (or latest)
     // - chewie: ^1.7.0 (for better controls)
     // 
     // Implementation steps:
     // 1. Create VideoPlayerWidget that accepts videoUrl, thumbnail, title, timestamp
     // 2. Use VideoPlayerController to manage playback
     // 3. Add controls: play/pause, seek, volume, fullscreen
     // 4. Display video metadata (title, description, upload date)
     // 5. Add loading state while video buffers
     // 
     // Example structure:
     // ListView.builder(
     //   itemCount: videos.length,
     //   itemBuilder: (context, index) {
     //     final video = videos[index];
     //     return VideoPlayerWidget(
     //       videoUrl: video.url,
     //       thumbnail: video.thumbnailUrl,
     //       title: video.title,
     //       timestamp: video.uploadedAt,
     //       onPlay: () => _playVideo(video),
     //     );
     //   },
     // )
     ```

4. **Add Admin Upload Placeholder**:
   - Add commented-out code for admin video upload:

     ```dart
     // TODO: Implement admin video upload
     // Required:
     // - Firebase Storage integration
     // - Video file picker (image_picker package)
     // - Video compression (video_compress package)
     // - Upload progress indicator
     // - Metadata form (title, description, category)
     // 
     // Upload flow:
     // 1. Admin selects video file from device
     // 2. Compress video if needed (max 100MB)
     // 3. Upload to Firebase Storage: /emergency_videos/{videoId}.mp4
     // 4. Generate thumbnail from first frame
     // 5. Save metadata to Firestore: /emergency_videos/{videoId}
     // 6. Show success message
     ```

5. **Add Access Control Placeholder**:
   - Add commented-out admin check:

     ```dart
     // TODO: Implement admin role check
     // Check user document for admin role:
     // final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
     // final isAdmin = userDoc.data()?['role'] == 'admin' || userDoc.data()?['isAdmin'] == true;
     // 
     // OR check custom claims:
     // final idTokenResult = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
     // final isAdmin = idTokenResult?.claims?['admin'] == true;
     ```

6. **Style with Electrical Theme**:
   - Use copper border on container
   - Add subtle circuit background
   - Use navy and copper colors for text and icons
   - Add proper spacing and shadows

7. **Add Placeholder Content**:
   - Show a message: "Emergency declaration videos will appear here"
   - Show an icon or illustration
   - If admin, show: "Upload videos to share emergency declarations with users"
   - Add a "Coming Soon" badge

### lib\utils\text_formatting_wrapper.dart(MODIFY)

**Enhance text formatting utilities for app-wide consistency:**

1. **Verify toTitleCase Function**:
   - The function (lines 2-17) already handles:
     - Null and empty string cases
     - Replacing underscores and hyphens with spaces
     - Converting to Title Case
   - This is correct and comprehensive

2. **Add Enum Formatting Helper**:
   - Add a new function to format enum values:

     ```dart
     /// Converts enum names (camelCase) to Title Case with spaces
     /// Example: journeymanLineman -> Journeyman Lineman
     String formatEnumName(String enumName) {
       // Insert space before capital letters
       final withSpaces = enumName.replaceAllMapped(
         RegExp(r'([A-Z])'),
         (match) => ' ${match.group(0)}',
       ).trim();
       return toTitleCase(withSpaces);
     }
     ```

3. **Add Classification Formatter**:
   - Add a specific formatter for classifications:

     ```dart
     /// Formats classification enum values for display
     String formatClassificationName(String classification) {
       return formatEnumName(classification);
     }
     ```

4. **Add Construction Type Formatter**:
   - Add a specific formatter for construction types:

     ```dart
     /// Formats construction type enum values for display
     String formatConstructionType(String constructionType) {
       return formatEnumName(constructionType);
     }
     ```

5. **Update JobDataFormatter Class**:
   - The class (lines 24-79) already has formatters for job fields
   - Ensure all formatters use the `toTitleCase` function
   - Add any missing formatters for new fields

6. **Add Null Safety**:
   - Ensure all formatters handle null values gracefully
   - Return appropriate defaults (empty string or "N/A") for null inputs

### firebase\firestore.rules(MODIFY)

**Update Firestore security rules to fix crew preferences permission error:**

1. **Add or Update Crew Preferences Rules**:
   - Locate the rules for the `crews` collection
   - Ensure crew members with admin or foreman roles can update preferences:

     ```
     match /crews/{crewId} {
       // Allow admins and foremans to update crew preferences
       allow update: if request.auth != null && 
         (get(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid)).data.role in ['admin', 'foreman']);
       
       // Allow members to read crew data
       allow read: if request.auth != null && 
         exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
     }
     ```

2. **Add Construction Types Validation**:
   - Validate that `constructionTypes` field contains only valid values:

     ```dart
     allow update: if request.auth != null && 
       request.resource.data.constructionTypes is list &&
       request.resource.data.constructionTypes.hasAll(['distribution', 'transmission', 'subStation', 'residential', 'industrial', 'dataCenter', 'commercial', 'underground']);
     ```

3. **Ensure Backward Compatibility**:
   - Allow both `jobTypes` and `constructionTypes` fields during migration period
   - Add rules to handle both field names

4. **Add Logging for Debugging**:
   - If Firestore supports it, add logging to track permission denials
   - This helps debug permission issues in production

5. **Test Rules**:
   - Use Firebase Emulator to test rules locally
   - Test with different user roles (admin, foreman, member)
   - Ensure admins and foremans can update, members cannot

6. **Document Rules**:
   - Add comments explaining each rule
   - Document the required user roles for each operation
   - Add examples of valid and invalid requests

### lib\electrical_components\jj_electrical_tooltip_wrapper.dart(NEW)

References:

- lib\electrical_components\jj_electrical_notifications.dart(MODIFY)
- lib\design_system\app_theme.dart

**Create wrapper for easy electrical tooltip integration app-wide:**

1. **Create JJElectricalTooltipWrapper Widget**:
   - Create a StatelessWidget that wraps any child with an electrical tooltip
   - Parameters:
     - `required Widget child` - the widget to wrap
     - `required String message` - tooltip message
     - `ElectricalNotificationType type` - tooltip type (default: info)
     - `bool enabled` - whether tooltip is enabled (default: true)

2. **Implement Contextual Tooltip Messages**:
   - Add a helper method to generate contextual messages based on widget type:

     ```dart
     String _getContextualMessage(String baseMessage, ElectricalNotificationType type) {
       switch (type) {
         case ElectricalNotificationType.success:
           return '✓ $baseMessage'; // Add checkmark for success
         case ElectricalNotificationType.warning:
           return '⚠ $baseMessage'; // Add warning symbol
         case ElectricalNotificationType.error:
           return '✗ $baseMessage'; // Add X for error
         case ElectricalNotificationType.info:
         default:
           return 'ℹ $baseMessage'; // Add info symbol
       }
     }
     ```

3. **Implement Mood-Based Styling**:
   - Success tooltips: Use encouraging language, green glow
   - Warning tooltips: Use cautionary language, yellow glow
   - Error tooltips: Use clear, actionable language, red glow
   - Info tooltips: Use informative language, blue glow

4. **Build Method**:
   - If `enabled` is false, return child without tooltip
   - If `enabled` is true, wrap child with `JJElectricalNotifications.electricalTooltip`:

     ```dart
     return enabled
       ? JJElectricalNotifications.electricalTooltip(
           message: _getContextualMessage(message, type),
           type: type,
           child: child,
         )
       : child;
     ```

5. **Add Convenience Methods**:
   - Add static methods for common tooltip types:

     ```dart
     static Widget success({required Widget child, required String message}) {
       return JJElectricalTooltipWrapper(
         child: child,
         message: message,
         type: ElectricalNotificationType.success,
       );
     }
     // Similar for warning, error, info
     ```

6. **Export from Electrical Components**:
   - Add export to `electrical_components.dart` if that file exists
   - Make it easy to import and use throughout the app

### lib\features\crews\widgets\member_selection_bottom_sheet.dart(NEW)

References:

- lib\design_system\app_theme.dart
- lib\features\crews\widgets\crew_member_avatar.dart(MODIFY)

**Create bottom sheet for member selection actions:**

1. **Create MemberSelectionBottomSheet Widget**:
   - Create a StatelessWidget
   - Parameters:
     - `String memberId` - selected member's ID
     - `String memberName` - selected member's name
     - `String? avatarUrl` - member's avatar URL
     - `VoidCallback onSendMessage` - callback for sending direct message
     - `VoidCallback onViewProfile` - callback for viewing profile

2. **Design Bottom Sheet Layout**:
   - Use `showModalBottomSheet` to display
   - Header:
     - Drag handle (horizontal bar at top)
     - Member avatar (medium size, 60px)
     - Member name (Title Case)
     - Close button
   - Action list:
     - "Send Direct Message" option with message icon
     - "View Profile" option with person icon
     - "Cancel" option

3. **Implement Action Handlers**:
   - Each option should be a `ListTile` with:
     - Leading icon (copper color)
     - Title text (navy color)
     - Tap handler that:
       - Closes the bottom sheet
       - Calls the appropriate callback

4. **Style with Electrical Theme**:
   - White background with rounded top corners
   - Copper accent for icons
   - Navy text for titles
   - Subtle shadow for depth
   - Proper spacing between options

5. **Add Animations**:
   - Slide up animation when opening
   - Fade out animation when closing
   - Ripple effect on tap

6. **Add Accessibility**:
   - Semantic labels for screen readers
   - Large tap targets (minimum 48px height)
   - Clear visual feedback on interaction

### lib\features\crews\widgets\share_job_dialog.dart(NEW)

References:

- lib\design_system\app_theme.dart
- lib\models\job_model.dart
- lib\electrical_components\circuit_board_background.dart

**Create dialog for sharing jobs with crew:**

1. **Create ShareJobDialog Widget**:
   - Create a StatefulWidget for managing selection state
   - Parameters:
     - `String crewId` - crew to share job with
     - `Function(String jobId, String? message) onShare` - callback when job is shared

2. **Design Dialog Layout**:
   - Header:
     - Title: "Share Job with Crew"
     - Close button
     - Copper gradient background
   - Content:
     - Job selection section:
       - Dropdown or searchable list of available jobs
       - Show job summary (company, location, classification)
     - Optional message section:
       - TextField for adding a message about the job
       - Hint: "Add a note about this opportunity..."
       - Max length: 500 characters
   - Footer:
     - Cancel button
     - Share button (disabled until job is selected)

3. **Implement Job Selection**:
   - Fetch available jobs from jobs provider
   - Display in a dropdown or scrollable list
   - Show job details: "[Local 123] Journeyman Lineman - ABC Electric"
   - Allow search/filter by company, location, or classification

4. **Implement Share Logic**:
   - On Share button press:
     - Validate job is selected
     - Create a post with job details and optional message
     - Use `MessageType.jobShare` for the post type
     - Include job ID in post metadata
     - Call `onShare` callback
     - Show success toast
     - Close dialog

5. **Add Electrical Circuit Background**:
   - Wrap content in Stack with `ElectricalCircuitBackground`
   - Use subtle opacity (0.05) for dialog

6. **Style with Electrical Theme**:
   - Copper borders on all input fields
   - Navy and copper color scheme
   - Proper spacing and typography
   - Electrical-themed buttons
