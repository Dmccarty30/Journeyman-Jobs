
## App Wide Changes

### Implement Dark Mode and Theme [P]

**Description:**
Implement a dark mode app theme based on the current colors of the Welcome Screen and Auth Screen. Add the dark mode theme to `lib\design_system\app_theme.dart`. Revert the Welcome Screen and Auth Screen back to their original light mode theme.

**Report Context:**

- Section: APP WIDE CHANGES, APP THEME
- Requirements: "I WANT TO USE THE DARK NAVY BLUE COLORED BACKGROUND ON THE `WELCOME SCREEN` AND `AUTH SCREEN` WILL BE THE THEME FOR `DARK MODE`. THIS MEANS THAT THERE NEEDS TO BE THE ADDITION OF A `DARK MODE` FEATURE. SO THAT MEANS, GO AHEAD AND CREATE THE THE `DARK MODE` APP THEME BASED OFF OF THE CURRENT MODE OF THE `WELCOME SCREEN` AND `AUTH SCREEN` AND ADD IT TO "lib\design_system\app_theme.dart" THEN, CHANGE THE COLOR THEME OF THE `WELCOME SCREEN` AND `AUTH SCREEN` BACK TO THE `LIGHT MODE`"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\design_system\app_theme.dart`, Welcome Screen, Auth Screen
- Dependencies: None

**Validation Criteria:**

- [ ] A dark mode theme is implemented in `lib\design_system\app_theme.dart`.
- [ ] The dark mode theme uses the dark navy blue color from the Welcome and Auth screens.
- [ ] The Welcome and Auth screens are reverted to their original light mode theme.
- [ ] The app can switch between light and dark mode.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

### Provide Detailed Documentation [P]

**Description:**
Provide detailed and comprehensive documentation for all changes, modifications, and additions made during the implementation of these tasks.

**Report Context:**

- Section: APP WIDE CHANGES
- Requirements: "BE SURE TO PROVIDE DETAILED AND COMPREHENSIVE DOCUMENTATION TO ANY AND ALL CHANGES/MODIFICATIONS/ADDITIONS THAT NEED TO BE MADE"

**Technical Implementation:**

- Platform: General Documentation
- Key Components: All modified files
- Dependencies: All tasks

**Validation Criteria:**

- [ ] All code changes are documented with clear and concise comments.
- [ ] Documentation is added to relevant README files or design documents.
- [ ] Documentation follows the project's style guide.

**Assigned Agent:** documentation-writer

**Estimated Complexity:** Simple

### Fix Text Field Text Color in Dark Mode [P]

**Description:**
Change the text color on top of all text fields to black in dark mode. Currently, the text color is light grey, making it difficult to read the text hint or text label.

**Report Context:**

- Section: APP THEME, Dark Mode
- Requirements: "In text color on top of all of the `text fields` needs to be black. They are light grey so you cannot read the `text hint` or `text label`."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: App Theme, Text Fields
- Dependencies: Implement Dark Mode and Theme

**Validation Criteria:**

- [ ] The text color in all text fields is black when dark mode is enabled.
- [ ] The text hint and text label are clearly readable in dark mode.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

## Onboarding Screens

### Reduce Font Size on Welcome Screen [P]

**Description:**
Reduce the font size of the complete button (or next button) on the third screen/step of the Welcome Screen by 15%.

**Report Context:**

- Section: ONBOARDING SCREENS, WELCOME SCREEN
- Requirements: "On the third screen/step of the welcome screen the `complete button` or `next button` needs smaller font sizes. Reduce the size by 15%"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\onboarding\welcome_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The font size of the complete/next button on the third screen of the Welcome Screen is reduced by 15%.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Analyze User Auth Process

**Description:**
Perform a comprehensive analysis of the User Auth process to ensure that everything is working correctly and is proper.

**Report Context:**

- Section: ONBOARDING SCREENS
- Requirements: "I want for you to perform a comprehensive analysis on the User Auth process. I mean a super deep dive into the codebase to ensure that everything is working and is proper."

**Technical Implementation:**

- Platform: Firebase, Flutter/Dart
- Key Components: `lib\services\auth_service.dart`, `lib\screens\onboarding\auth_screen.dart`, Firebase Authentication
- Dependencies: None

**Validation Criteria:**

- [ ] The User Auth process is analyzed for potential issues.
- [ ] All steps in the authentication flow are verified to be working correctly.
- [ ] Any potential security vulnerabilities are identified and addressed.

**Assigned Agent:** auth-expert

**Estimated Complexity:** Moderate

### Align Tab Bar on Auth Screen

**Description:**
Improve the alignment of the tab bar in `lib\screens\onboarding\auth_screen.dart`. The "sign up" and "sign in" tabs are smaller than the entire tab bar, resulting in a gap between the bottom border of the tab bar and the bottom of either of the tabs.

**Report Context:**

- Section: ONBOARDING SCREENS, AUTH SCREEN
- Requirements: "I want to change the `tab bar` needs to be better aligned. The `sign up` and `sign in` tabs are smaller than the entire `tab bar` so there is a gap between the bottom boarder of the entire `tab bar` and the bottom of either of the tabs.. there is a screenshot @assets\tab-bar-gap.png"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\onboarding\auth_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "sign up" and "sign in" tabs are properly aligned within the tab bar.
- [ ] There is no visible gap between the bottom border of the tab bar and the bottom of either of the tabs.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Reduce Tab Bar Border Size on Auth Screen

**Description:**
Reduce the border size of the tab bar in `lib\screens\onboarding\auth_screen.dart` by 50%.

**Report Context:**

- Section: ONBOARDING SCREENS, AUTH SCREEN
- Requirements: "REDUCE the border size of the `tab bar` by 50%"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\onboarding\auth_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The border size of the tab bar is reduced by 50%.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Correct Google Button Overflow on Auth Screen

**Description:**
Correct the overflow error for the "continue with Google" button in `lib\screens\onboarding\auth_screen.dart`.

**Report Context:**

- Section: ONBOARDING SCREENS, AUTH SCREEN
- Requirements: "Correct the overflow error for the continue with `Google button`"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\onboarding\auth_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "continue with Google" button is displayed without any overflow errors.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Create User Document on Onboarding Step 1

**Description:**
On step 1 of SETUP PROFILE in `lib\screens\onboarding\onboarding_steps_screen.dart`, create the user document in Firestore using the input data from the text fields when the user presses the "next" button and navigates to step 2.

**Report Context:**

- Section: ONBOARDING SCREENS, ONBOARDING STEPS SCREEN, STEP 1: BASIC INFORMATION
- Requirements: "On step 1 of SETUP PROFILE when the user presses the `next button` this is when the user document is created using the input data from the `text fields` and the user navigates to step 2"

**Technical Implementation:**

- Platform: Flutter/Dart, Firebase
- Key Components: `lib\screens\onboarding\onboarding_steps_screen.dart`, Firebase Firestore
- Dependencies: None

**Validation Criteria:**

- [ ] A user document is created in Firestore when the user presses the "next" button on step 1 of the onboarding process.
- [ ] The user document contains the data entered in the text fields on step 1.
- [ ] The user is navigated to step 2 after the user document is created.

**Assigned Agent:** auth-expert

**Estimated Complexity:** Moderate

### Update "Books You Are Currently On" Text Field

**Description:**
In the "Books you are currently on" text field in step 2 of `lib\screens\onboarding\onboarding_steps_screen.dart`, replace the current placeholder values "Book1, Book2 etc" with examples of actual local numbers.

**Report Context:**

- Section: ONBOARDING SCREENS, ONBOARDING STEPS SCREEN, STEP 2
- Requirements: "In the "Books you are currently on" `text field` replace the current values " Book1, Book2 etc" with examples of actual local number"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\onboarding\onboarding_steps_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "Books you are currently on" text field displays examples of actual local numbers instead of "Book1, Book2 etc".

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Capitalize Choice Chip Text in Onboarding Step 3

**Description:**
Capitalize the text values for the choice chips in 'construction type' on step 3 of `lib\screens\onboarding\onboarding_steps_screen.dart`.

**Report Context:**

- Section: ONBOARDING SCREENS, ONBOARDING STEPS SCREEN, STEP 3: PREFERENCES AND FEEDBACK
- Requirements: "The `choice chips` for 'construction type' the text values need to be capitalized. They are currently formatted like a backend value with the first letter lower case and the first letter of the second word capitalized. This needs to be corrected"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\onboarding\onboarding_steps_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The text values for the choice chips in 'construction type' are capitalized.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

## Home Screen

### Analyze Home Screen Structure

**Description:**
Read "docs\Home-Analysis.md" to get a better understanding of `lib\screens\storm\home_screen.dart`'s structure and potential issues.

**Report Context:**

- Section: HOME SCREEN
- Requirements: "Read "docs\Home-Analysis.md" to get a better understanding of this files structure and potential issues"

**Technical Implementation:**

- Platform: Documentation
- Key Components: `docs\Home-Analysis.md`, `lib\screens\storm\home_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "docs\Home-Analysis.md" file has been read and its contents are understood.

**Assigned Agent:** code-reviewer

**Estimated Complexity:** Simple

### Display User's Name on Home Screen

**Description:**
Display the user's name underneath the app bar in `lib\screens\storm\home_screen.dart` where it currently says "Welcome Back, [usersName]!".

**Report Context:**

- Section: HOME SCREEN
- Requirements: "Underneath the `app bar` it needs to have the user's name displayed where it says "Welcome Back, [usersName]!""

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\home_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The user's name is displayed correctly underneath the app bar.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Add Resources Screen Navigation to Home Screen

**Description:**
Add one more container to the Quick Actions section in `lib\screens\storm\home_screen.dart` that will navigate the user directly to the Resources Screen.

**Report Context:**

- Section: HOME SCREEN, Quick Actions
- Requirements: "ADD one more container that will navigate the user directly to the `Resources Screen`"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\home_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] A new container is added to the Quick Actions section.
- [ ] The new container navigates the user to the Resources Screen when tapped.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Remove Light Blue Shadow from Home Screen Containers

**Description:**
Remove the light blue shadow from the containers in the Quick Actions section in `lib\screens\storm\home_screen.dart`.

**Report Context:**

- Section: HOME SCREEN, Quick Actions
- Requirements: "REMOVE the light blue shadow from the containers as well."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\home_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The light blue shadow is removed from the containers in the Quick Actions section.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Analyze Job Recommendations Plan

**Description:**
Read "docs\plan-personalize-job-recommendations-0.md" to understand the desired changes for the Suggested Jobs section in `lib\screens\storm\home_screen.dart`.

**Report Context:**

- Section: HOME SCREEN, Suggested Jobs
- Requirements: "Read "docs\plan-personalize-job-recommendations-0.md" to understand what i want to do about this section."

**Technical Implementation:**

- Platform: Documentation
- Key Components: `docs\plan-personalize-job-recommendations-0.md`, `lib\screens\storm\home_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "docs\plan-personalize-job-recommendations-0.md" file has been read and its contents are understood.

**Assigned Agent:** code-reviewer

**Estimated Complexity:** Simple

### Remove Colored Font from Job Cards

**Description:**
Remove all colored font from all cards, containers, and or dialog popups in the Suggested Jobs section in `lib\screens\storm\home_screen.dart`. This includes the grey tint behind and around the local number of the job cards.

**Report Context:**

- Section: HOME SCREEN, Suggested Jobs
- Requirements: "REMOVE all colored font from all cards, containers, and or dialog popups. This includes the grey tint behind and around the local number of the job cards."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\home_screen.dart`
- Dependencies: Analyze Job Recommendations Plan

**Validation Criteria:**

- [ ] All colored font is removed from the specified UI elements.
- [ ] The grey tint behind and around the local number of the job cards is removed.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

## Jobs Screen

### Analyze Jobs Screen Structure

**Description:**
Read "docs\Jobs-Analysis.md" to get a better understanding of `lib\screens\storm\jobs_screen.dart`'s structure and potential issues.

**Report Context:**

- Section: JOB SCREEN
- Requirements: "Read "docs\Jobs-Analysis.md" to get a better understanding of this files structure and potential issues"

**Technical Implementation:**

- Platform: Documentation
- Key Components: `docs\Jobs-Analysis.md`, `lib\screens\storm\jobs_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "docs\Jobs-Analysis.md" file has been read and its contents are understood.

**Assigned Agent:** code-reviewer

**Estimated Complexity:** Simple

### Add Local Union Search Feature to Jobs Screen

**Description:**
Add a simple search feature to `lib\screens\storm\jobs_screen.dart` so that the user can Search for any specific local union. Place this widget underneath the horizontal filter.

**Report Context:**

- Section: JOB SCREEN
- Requirements: "ADD a simple search feature so that the user can `Search` for any specific local union. Place this widget underneath the horizontal filter"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\jobs_screen.dart`
- Dependencies: Analyze Jobs Screen Structure

**Validation Criteria:**

- [ ] A search feature is added to the Jobs Screen.
- [ ] The search feature is placed underneath the horizontal filter.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

### Implement Traditional Search Widget

**Description:**
Make the Search widget in `lib\screens\storm\jobs_screen.dart` a traditional search widget as in a text field with a magnifying icon on one end and the text hint "Search For A Specific Local".

**Report Context:**

- Section: JOB SCREEN
- Requirements: "Make the `Search` widget a traditional seatch widget as in a `text field` with a magnifying icon on one end and the text hint "Search For A Specific Local""

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\jobs_screen.dart`
- Dependencies: Add Local Union Search Feature to Jobs Screen

**Validation Criteria:**

- [ ] The search widget is implemented as a text field with a magnifying icon.
- [ ] The text hint "Search For A Specific Local" is displayed in the text field.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Limit Search to Local Union Number

**Description:**
The only value that will be searchable is the local union number in `lib\screens\storm\jobs_screen.dart`.

**Report Context:**

- Section: JOB SCREEN
- Requirements: "THE ONLY VALUE THAT WILL BE SEARCHABLE IS THE LOCAL UNION NUMBER."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\jobs_screen.dart`
- Dependencies: Implement Traditional Search Widget

**Validation Criteria:**

- [ ] The search function only searches for local union numbers.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

### Remove "Storm Work" Filter Option

**Description:**
Remove "Storm Work" as one of the filtering options in `lib\screens\storm\jobs_screen.dart`.

**Report Context:**

- Section: JOB SCREEN
- Requirements: "REMOVE "Storm Work" as one of the filtering options."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\jobs_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "Storm Work" filter option is removed from the Jobs Screen.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

## Storm Screen

### Analyze Storm Screen Structure

**Description:**
Read "docs\Storm-Analysis.md" to get a better understanding of `lib\screens\storm\storm_screen.dart`'s structure and potential issues.

**Report Context:**

- Section: STORM SCREEN
- Requirements: "Read "docs\Storm-Analysis.md" to get a better understanding of this files structure and potential issues"

**Technical Implementation:**

- Platform: Documentation
- Key Components: `docs\Storm-Analysis.md`, `lib\screens\storm\storm_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "docs\Storm-Analysis.md" file has been read and its contents are understood.

**Assigned Agent:** code-reviewer

**Estimated Complexity:** Simple

### Reduce Border Thickness on Storm Screen

**Description:**
Reduce the thickness of the borders around everything on the `lib\screens\storm\storm_screen.dart` by 1/2.

**Report Context:**

- Section: STORM SCREEN
- Requirements: "The borders around everything on the `Storm Screen` are to thick. They need to be reduced in thickness by 1/2."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\storm_screen.dart`
- Dependencies: Analyze Storm Screen Structure

**Validation Criteria:**

- [ ] The border thickness on the Storm Screen is reduced by 1/2.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Redo Storm Screen Layout

**Description:**
Redo the layout of `lib\screens\storm\storm_screen.dart` to ensure everything is not inside of a single container or column.

**Report Context:**

- Section: STORM SCREEN
- Requirements: "I am not sure what is exactly is going on with this screen. They're just like everything is inside of the container or column including the background Like the circuit board background is inside this container and column it just seems weird something's off but needs to be redone Yeah something's off"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\storm_screen.dart`
- Dependencies: Analyze Storm Screen Structure

**Validation Criteria:**

- [ ] The layout of the Storm Screen is redone to ensure elements are properly structured and not all contained within a single container or column.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

### Remove Admin Status Check on Storm Screen

**Description:**
Remove the check admin status on line 504 of `lib\screens\storm\storm_screen.dart`.

**Report Context:**

- Section: STORM SCREEN
- Requirements: "line 504 has check admin status. I do not know why this is in my codebase. I do not have nor do i want anything to do with an admin status."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\screens\storm\storm_screen.dart`
- Dependencies: Analyze Storm Screen Structure

**Validation Criteria:**

- [ ] The check admin status code is removed from line 504 of `lib\screens\storm\storm_screen.dart`.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

## Tailboard Screen

### Update Tailboard Screen Header

**Description:**
Remove the welcome to the tail board heading and the description below it in `lib\features\crews\screens\tailboard_screen.dart` and replace it with a lower profile header of the name of the active crew with that crew's description underneath in smaller text and font.

**Report Context:**

- Section: TAILBOARD SCREEN
- Requirements: "Once a user joins a crew or creates a crew then it can be assumed that that user will be active with the crew from this point forward therefore the welcome to the tail board heading and the description below will be removed and replaced with a lower profile header of the name of the active crew with that crew's description underneath in smaller text and font So There is more room Or the tab bar and the messages below it"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\tailboard_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The welcome heading and description are removed.
- [ ] The name of the active crew is displayed as a header.
- [ ] The crew's description is displayed underneath the header in smaller text and font.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Fix Horizontal Overflow on Tailboard Screen

**Description:**
Correct the overflow error when the phone is turned horizontally on the `lib\features\crews\screens\tailboard_screen.dart`.

**Report Context:**

- Section: TAILBOARD SCREEN
- Requirements: "When you're on the tailboard screen and you turn the phone horizontally there is an overflow error."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\tailboard_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The Tailboard Screen is displayed without any overflow errors when the phone is turned horizontally.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

## Create Crews Screen

### Remove "Join a Crew" Button

**Description:**
On the first screen of `lib\features\crews\screens\create_crew_screen.dart`, remove the "join a crew" button.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, STEP 1
- Requirements: "Though on the tail board screen there's the Create a Crew button and then a drop down button to select or join a crew So when you hit the create a crew and you start the crew on boarding you then again get the option to create a crew or join a crew I think this is too much So on the first screen of the crew_boarding_screen.dart remove the join a crew button."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\create_crew_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] The "join a crew" button is removed from the first screen of the Create Crews Screen.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Change "Create a Crew" Text

**Description:**
Change the creator crew text from `Create a Crew` to `next` on the first screen of `lib\features\crews\screens\create_crew_screen.dart`.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, STEP 1
- Requirements: "Change the creator crew text from `Create a Crew` to `next`"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\create_crew_screen.dart`
- Dependencies: Remove "Join a Crew" Button

**Validation Criteria:**

- [ ] The text on the button is changed from "Create a Crew" to "next".

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Add Classifications to Crew Onboarding

**Description:**
On the second step of the crew onboarding in `lib\features\crews\screens\create_crew_screen.dart`, add all of the classifications that were listed and the main apps onboarding to include `operator` `tree trimmer` so on and so on and not just limit it to `inside wireman` and `journeyman lineman`.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, STEP 2
- Requirements: "On the second step of the crew on boarding we need to add all of the classifications that were listed and the main apps onboarding to include `operator` `tree trimmer` so on and so on and not just limit it to `inside wireman` and `journeyman lineman`"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\create_crew_screen.dart`
- Dependencies: None

**Validation Criteria:**

- [ ] All of the specified classifications are added to the crew onboarding process.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

### Add Copper Border to Crew Onboarding Fields

**Description:**
On the second step of the crew onboarding in `lib\features\crews\screens\create_crew_screen.dart`, add the copper border around all of the input fields the text box the text input the drop down.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, STEP 2
- Requirements: "On the second step of the onboarding be sure to add the copper border around all of the input fields the text box the text input the drop down"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\create_crew_screen.dart`
- Dependencies: Add Classifications to Crew Onboarding

**Validation Criteria:**

- [ ] A copper border is added around all of the input fields on the second step of the crew onboarding process.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Add Electrical Circuit Background to Crew Onboarding

**Description:**
Add the electrical circuit background to the crew onboarding screen in `lib\features\crews\screens\create_crew_screen.dart`.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, STEP 2
- Requirements: "Add the electrical circuit background to the crew onboarding screen"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\create_crew_screen.dart`, Electrical Circuit Background Widget
- Dependencies: Add Copper Border to Crew Onboarding Fields

**Validation Criteria:**

- [ ] The electrical circuit background is added to the crew onboarding screen.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Change Switch to JJ Circuit Breaker Switch

**Description:**
Change the switch to the custom JJ circuit breaker switch in `lib\features\crews\screens\create_crew_screen.dart`.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, STEP 2
- Requirements: "Change the switch to the custom JJ circuit breaker switch We need to maintain consistency throughout the app in every aspect"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\create_crew_screen.dart`, JJ Circuit Breaker Switch Widget
- Dependencies: Add Electrical Circuit Background to Crew Onboarding

**Validation Criteria:**

- [ ] The switch is replaced with the custom JJ circuit breaker switch.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Enhance "Create a Crew" Button

**Description:**
Add some persistent animation or gradient color gradient or shadow or something something unique to the Create a Crew button in `lib\features\crews\screens\create_crew_screen.dart` to make it pop. Be sure to maintain consistency with the design schema and app theme.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, STEP 2
- Requirements: "I'd like to do something with the Create a Crew button add some persistent animation or gradient color gradient or shadow or something something unique to make it pop to signify you know you're you're creating a crew and you're part of something and you're committed. Be sure to maintain consistency with the design schema and app theme."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: `lib\features\crews\screens\create_crew_screen.dart`
- Dependencies: Change Switch to JJ Circuit Breaker Switch

**Validation Criteria:**

- [ ] The "Create a Crew" button has a persistent animation, gradient color, or shadow.
- [ ] The enhancement is consistent with the design schema and app theme.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

### Fix Overflow in Set Crew Preference Dialog

**Description:**
Correct the overflow on the top right corner of the set crew preference dialog.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, SET CREW PREFERENCES
- Requirements: "There is an overflow on the top right corner of the `set crew preference dialog`"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: Set Crew Preference Dialog
- Dependencies: None

**Validation Criteria:**

- [ ] There is no overflow on the top right corner of the set crew preference dialog.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Update Set Crew Preference Options

**Description:**
Remove `Apprentice Lineman` `electrical Foreman` `project Manager` `electrical Engineer` `safety Coordinator` `Journeyman Lineman` `inside wireman` from the set crew preference dialog and replace them with the construction type meaning `Transmission` `distribution` `substation` `underground` `industrial` `commercial` `residential` `Data center` etcetera.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, SET CREW PREFERENCES
- Requirements: "`Apprentice Lineman` needs to be removed `electrical Foreman` needs to be removed `project Manager` needs to be removed `electrical Engineer` needs to be removed `safety Coordinator` needs to be removed `Journeyman Lineman` needs to be removed `inside wireman` needs to be removed This initial preference is a job type so all of these values need to be replaced with the construction type meaning `Transmission` `distribution` `substation` `underground` `industrial` `commercial` `residential` `Data center` etcetera."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: Set Crew Preference Dialog
- Dependencies: Fix Overflow in Set Crew Preference Dialog

**Validation Criteria:**

- [ ] The specified options are removed from the set crew preference dialog.
- [ ] The construction type options are added to the set crew preference dialog.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Update "Save Preferences" Button Text

**Description:**
Remove the word "preferences" from the Save Preferences button in the set crew preference dialog and change it to simply `save` or `continue`.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, SET CREW PREFERENCES
- Requirements: "The `Save Preferences` button is wrong we need to remove the word preferences it's understood that this is what you're saving so we'll keep cancel and change `save preferences` to simply `save` or `continue`"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: Set Crew Preference Dialog
- Dependencies: Update Set Crew Preference Options

**Validation Criteria:**

- [ ] The text on the button is changed from "Save Preferences" to "Save" or "Continue".

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Fix Firestore Permission Error

**Description:**
Fix the Firestore error updating crew caller does not have permission when hitting the save preference button.

**Report Context:**

- Section: TAILBOARD SCREEN, CREATE CREWS SCREEN, SET CREW PREFERENCES
- Requirements: "When I hit the save preference button I can't move any further because I'm not authorized. The error is the firststore error updating crew caller does not have permission"

**Technical Implementation:**

- Platform: Firebase, Flutter/Dart
- Key Components: Firebase Firestore, Set Crew Preference Dialog
- Dependencies: Update "Save Preferences" Button Text

**Validation Criteria:**

- [ ] The Firestore permission error is resolved.
- [ ] The user can successfully save their crew preferences.

**Assigned Agent:** backend-architect

**Estimated Complexity:** Moderate

## Feed Tab

### Enable Feed Tab Access for All Users

**Description:**
The user should have access and be able to interact with the feed tab regardless of whether or not that user is a member of a crew or just exploring the app.

**Report Context:**

- Section: FEED
- Requirements: "The user should have access and be able to interact with the `feed tab` regardless of whether or not that user is a member of a crew or just exploring the app."

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: Feed Tab, User Authentication
- Dependencies: None

**Validation Criteria:**

- [ ] All users can access and interact with the feed tab.

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

### Add FAB or User Input Window to Feed Tab

**Description:**
When the user tabs on the feed tab, there needs to be some sort of FAB or user input window to show the user or to prompt the user into writing something or posting something.

**Report Context:**

- Section: FEED
- Requirements: "When the user tabs on the `feed tab` There needs to be some sort of `FAB` or user input window As to or to show the user or to prompt the user into writing something or posting something"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: Feed Tab
- Dependencies: Enable Feed Tab Access for All Users

**Validation Criteria:**

- [ ]
